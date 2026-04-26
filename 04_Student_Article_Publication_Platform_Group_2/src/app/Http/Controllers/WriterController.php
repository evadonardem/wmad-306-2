<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Notifications\ArticleSubmittedNotification;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;

class WriterController extends Controller
{
    /**
     * Display the writer dashboard with articles and form data.
     */
    public function index(): Response
    {
        $user = Auth::user();

        $articles = Article::with([
            'status',
            'category',
            'revisions.editor',
            'comments' => fn ($query) => $query->latest(),
            'comments.student',
        ])
            ->withCount('comments')
            ->where('writer_id', $user->id)
            ->latest()
            ->get();

        $categories = Category::all();

        return Inertia::render('Writer/Dashboard', [
            'articles' => $articles,
            'categories' => $categories,
        ]);
    }

    /**
     * Store a new article as draft or submit for review.
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'tags' => 'nullable|array',
            'reviewer_notes' => 'nullable|string',
            'submit' => 'boolean',
        ]);

        $this->authorize('create', Article::class);

        $statusName = $request->boolean('submit') ? 'submitted' : 'draft';
        $status = ArticleStatus::where('name', $statusName)->firstOrFail();

        Article::create([
            'title' => $request->title,
            'content' => $request->content,
            'category_id' => $request->category_id,
            'tags' => $request->input('tags', []),
            'reviewer_notes' => $request->input('reviewer_notes'),
            'writer_id' => Auth::id(),
            'status_id' => $status->id,
        ]);

        $message = $request->boolean('submit') 
            ? 'Article submitted for review.' 
            : 'Article saved as draft.';

        return redirect()->route('writer.dashboard')
            ->with('success', $message);
    }

    /**
     * Update an existing draft/revision article.
     */
    public function update(Request $request, Article $article): RedirectResponse
    {
        $this->authorize('update', $article);

        $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'tags' => 'nullable|array',
            'reviewer_notes' => 'nullable|string',
        ]);

        $article->update([
            'title' => $request->title,
            'content' => $request->content,
            'category_id' => $request->category_id,
            'tags' => $request->input('tags', []),
            'reviewer_notes' => $request->input('reviewer_notes'),
        ]);

        return redirect()->route('writer.dashboard')
            ->with('success', 'Article updated successfully.');
    }

    /**
     * Submit an article for editorial review.
     */
    public function submit(Article $article): RedirectResponse
    {
        $this->authorize('submit', $article);

        $submittedStatus = ArticleStatus::where('name', 'submitted')->firstOrFail();
        $article->update(['status_id' => $submittedStatus->id]);

        // Notify editors about the submission
        $editors = \App\Models\User::role('editor')->get();
        foreach ($editors as $editor) {
            $editor->notify(new ArticleSubmittedNotification($article));
        }

        return redirect()->route('writer.dashboard')
            ->with('success', 'Article submitted for review.');
    }

    /**
     * Show the edit form for an article.
     */
    public function edit(Article $article): Response
    {
        $this->authorize('update', $article);

        $article->load(['status', 'category', 'revisions.editor']);
        $categories = Category::all();

        return Inertia::render('Writer/Edit', [
            'article' => $article,
            'categories' => $categories,
        ]);
    }

    /**
     * Delete a draft article.
     */
    public function destroy(Article $article): RedirectResponse
    {
        $this->authorize('delete', $article);

        $article->delete();

        return redirect()->route('writer.dashboard')
            ->with('success', 'Article deleted.');
    }

    /**
     * Search articles and categories.
     */
    public function search(Request $request)
    {
        $query = $request->input('q', '');

        if (strlen($query) < 2) {
            return response()->json(['results' => []]);
        }

        $user = Auth::user();

        // Search articles (current user's articles)
        $articles = Article::with('status', 'category')
            ->where('writer_id', $user->id)
            ->where(function ($q) use ($query) {
                $q->where('title', 'LIKE', "%{$query}%")
                  ->orWhere('content', 'LIKE', "%{$query}%");
            })
            ->limit(8)
            ->get()
            ->map(function ($article) {
                return [
                    'id' => $article->id,
                    'type' => 'article',
                    'title' => $article->title,
                    'subtitle' => $article->status->name,
                    'url' => route('articles.edit', $article->id),
                ];
            });

        // Search categories
        $categories = Category::where('name', 'LIKE', "%{$query}%")
            ->limit(5)
            ->get()
            ->map(function ($category) {
                return [
                    'id' => $category->id,
                    'type' => 'category',
                    'title' => $category->name,
                    'subtitle' => 'Category',
                    'url' => '#',
                ];
            });

        $results = $articles->concat($categories);

        return response()->json(['results' => $results]);
    }
}
