<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Inertia\Inertia;

class WriterController extends Controller
{
    public function dashboard()
    {
        // Debug: Check user roles
        $user = auth()->user();
        $userRoles = $user->roles->pluck('name')->toArray();
        
        // Check if user has writer role, if not, redirect appropriately
        if (!in_array('writer', $userRoles)) {
            if (in_array('editor', $userRoles)) {
                return redirect()->route('editor.dashboard');
            } elseif (in_array('student', $userRoles)) {
                return redirect()->route('student.dashboard');
            } else {
                // If no valid role, redirect to main dashboard
                return redirect()->route('dashboard');
            }
        }
        
        $articles = Article::where('writer_id', auth()->id())->with('status', 'category')->get();
        $categories = \App\Models\Category::orderBy('name')->get();
        
        // Get notifications from database if table exists, otherwise use revision data
        $notifications = [];
        try {
            $notifications = auth()->user()->notifications()->orderBy('created_at', 'desc')->take(10)->get();
        } catch (\Exception $e) {
            // If notifications table doesn't exist, create notifications from revision data
            $revisions = \App\Models\Revision::whereHas('article', function($query) {
                $query->where('writer_id', auth()->id());
            })
            ->with('article', 'editor')
            ->orderBy('created_at', 'desc')
            ->take(10)
            ->get();
            
            foreach ($revisions as $revision) {
                $notifications[] = (object)[
                    'id' => 'revision_' . $revision->id,
                    'data' => (object)[
                        'message' => 'Revision requested for: ' . $revision->article->title,
                        'article_title' => $revision->article->title,
                        'comments' => $revision->comments,
                        'editor_name' => $revision->editor->name,
                        'type' => 'revision_requested'
                    ],
                    'created_at' => $revision->created_at,
                    'type' => 'revision_requested'
                ];
            }
            
            // Also add published articles
            $publishedArticles = Article::where('writer_id', auth()->id())
                ->whereHas('status', function($query) {
                    $query->where('name', 'published');
                })
                ->whereNotNull('editor_id')
                ->with('editor')
                ->orderBy('updated_at', 'desc')
                ->take(5)
                ->get();
                
            foreach ($publishedArticles as $article) {
                $notifications[] = (object)[
                    'id' => 'published_' . $article->id,
                    'data' => (object)[
                        'message' => 'Your article has been published: ' . $article->title,
                        'article_title' => $article->title,
                        'editor_name' => $article->editor->name,
                        'type' => 'article_published'
                    ],
                    'created_at' => $article->updated_at,
                    'type' => 'article_published'
                ];
            }
            
            // Sort by date
            usort($notifications, function($a, $b) {
                return strtotime($b->created_at) - strtotime($a->created_at);
            });
        }
        
        return Inertia::render('Writer/Dashboard', compact('articles', 'categories', 'notifications'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id',
        ]);

        $data['writer_id'] = Auth::id();
        
        // Generate slug from title
        $data['slug'] = Str::slug($data['title']) . '-' . time();

        // determine status: draft by default, but if request asks to submit, mark submitted
        $draftStatus = ArticleStatus::firstOrCreate(['name' => 'draft'], ['label' => 'Draft']);
        $submittedStatus = ArticleStatus::firstOrCreate(['name' => 'submitted'], ['label' => 'Submitted']);

        if ($request->boolean('submit')) {
            $data['status_id'] = $submittedStatus->id;
        } else {
            $data['status_id'] = $draftStatus->id;
        }

        $article = Article::create($data);

        // notify editors only when article is submitted
        if ($data['status_id'] === $submittedStatus->id) {
            $editors = \App\Models\User::role('editor')->get();
            foreach ($editors as $editor) {
                $editor->notify(new \App\Notifications\ArticleSubmittedNotification($article));
            }
            return redirect()->route('writer.dashboard')->with('success', 'Article submitted');
        }

        return redirect()->route('writer.dashboard')->with('success', 'Draft created');
    }

    public function submit(Article $article)
    {
        // Check if user owns this article instead of using policy
        if ($article->writer_id !== auth()->id()) {
            abort(403);
        }
        
        $submitted = ArticleStatus::where('name','submitted')->first();
        $article->update(['status_id' => $submitted->id]);
        
        // notify editors
        try {
            $editors = \App\Models\User::role('editor')->get();
            foreach ($editors as $editor) {
                $editor->notify(new \App\Notifications\ArticleSubmittedNotification($article));
            }
        } catch (\Exception $e) {
            // Notifications table doesn't exist yet, continue without notification
        }

        return redirect()->back()->with('success', 'Article submitted');
    }

    public function show(Article $article)
    {
        // Authorize that the user owns this article
        if ($article->writer_id !== auth()->id()) {
            abort(403);
        }

        $article->load('status', 'category');
        
        // Load comments with user relationships for published articles
        if ($article->status->name === 'published') {
            $article->load(['comments.user']);
        }
        
        $categories = \App\Models\Category::orderBy('name')->get();
        
        return Inertia::render('Writer/ArticleView', compact('article', 'categories'));
    }

    public function update(Request $request, Article $article)
    {
        // Authorize that the user owns this article
        if ($article->writer_id !== auth()->id()) {
            abort(403);
        }

        $data = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id',
        ]);

        // Generate new slug if title changed
        if ($data['title'] !== $article->title) {
            $data['slug'] = Str::slug($data['title']) . '-' . time();
        }

        $article->update($data);

        return redirect()->route('writer.articles.show', $article->id)->with('success', 'Article updated successfully');
    }

    public function revisePage(Article $article)
    {
        // Authorize that user owns this article
        if ($article->writer_id !== auth()->id()) {
            abort(403);
        }

        $article->load(['status', 'category', 'comments.user']);
        $categories = \App\Models\Category::orderBy('name')->get();
        
        return Inertia::render('Writer/ArticleRevise', compact('article', 'categories'));
    }

    public function revise(Request $request, Article $article)
    {
        $this->authorize('revise', $article);
        $data = $request->validate(['content' => 'required']);
        $article->update($data);
        
        // Change status to submitted after revision so editor can review it
        $submittedStatus = ArticleStatus::where('name','submitted')->first();
        $article->update(['status_id' => $submittedStatus->id]);
        
        // Notify editors that the article has been revised and resubmitted
        try {
            $editors = \App\Models\User::role('editor')->get();
            foreach ($editors as $editor) {
                $editor->notify(new \App\Notifications\ArticleRevisedNotification($article));
            }
        } catch (\Exception $e) {
            // Notifications table doesn't exist yet, continue without notification
        }
        
        return redirect()->route('writer.dashboard')->with('success','Article revised and submitted to editor');
    }

    public function uploadImage(Request $request)
    {
        // Check if user has writer role
        $user = auth()->user();
        $userRoles = $user->roles->pluck('name')->toArray();

        if (!in_array('writer', $userRoles)) {
            abort(403);
        }

        $request->validate([
            'upload' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048', // 2MB max
        ]);

        $image = $request->file('upload');

        // Generate a unique filename
        $filename = time() . '_' . uniqid() . '.' . $image->getClientOriginalExtension();

        // Store the image in storage/app/public/article-images directory
        $path = $image->storeAs('article-images', $filename, 'public');

        // Return the URL for Jodit
        $url = asset('storage/' . $path);

        return response()->json([
            'uploaded' => 1,
            'fileName' => $filename,
            'url' => $url
        ]);
    }
}
