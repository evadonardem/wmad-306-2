<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\Comment;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class StudentController extends Controller
{
    /**
     * Display the student dashboard with published articles.
     */
    public function dashboard(): InertiaResponse
    {
        $publishedArticles = Article::published()
            ->with(['writer', 'comments' => function($query) {
                $query->with('student')->latest()->limit(3);
            }])
            ->withCount(['comments'])
            ->latest()
            ->paginate(12);

        // Get featured articles (most commented)
        $featuredArticles = Article::published()
            ->with(['writer', 'comments' => function($query) {
                $query->with('student')->latest()->limit(2);
            }])
            ->withCount(['comments'])
            ->orderBy('comments_count', 'desc')
            ->limit(6)
            ->get();

        return Inertia::render('Student/Dashboard', [
            'articles' => $publishedArticles,
            'featuredArticles' => $featuredArticles,
        ]);
    }

    /**
     * Display the specified article.
     */
    public function show(Article $article): InertiaResponse|RedirectResponse
    {
        // Only allow viewing published articles
        if (!$article->isPublished()) {
            abort(404, 'Article not found.');
        }

        $article->load([
            'writer',
            'comments' => function($query) {
                $query->with('student')->latest();
            }
        ]);

        // Get related articles
        $relatedArticles = Article::published()
            ->where('id', '!=', $article->id)
            ->with('writer')
            ->inRandomOrder()
            ->limit(3)
            ->get();

        return Inertia::render('Student/Show', [
            'article' => $article,
            'relatedArticles' => $relatedArticles,
        ]);
    }

    /**
     * Store a newly created comment.
     */
    public function comment(Request $request, Article $article): RedirectResponse
    {
        // Only allow commenting on published articles
        if (!$article->isPublished()) {
            abort(404, 'Article not found.');
        }

        $this->authorize('comment', $article);

        $validated = $request->validate([
            'content' => 'required|string|max:1000',
        ]);

        Comment::create([
            'content' => $validated['content'],
            'article_id' => $article->id,
            'student_id' => Auth::id(),
        ]);

        return redirect()
            ->back()
            ->with('success', 'Comment added successfully!');
    }

    /**
     * API: Store a newly created comment via AJAX.
     */
    public function apiComment(Request $request, Article $article): \Illuminate\Http\JsonResponse
    {
        // Only allow commenting on published articles
        if (!$article->isPublished()) {
            return response()->json(['success' => false, 'message' => 'Article not found.'], 404);
        }

        $this->authorize('comment', $article);

        $validated = $request->validate([
            'content' => 'required|string|max:1000',
        ]);

        $comment = Comment::create([
            'content' => $validated['content'],
            'article_id' => $article->id,
            'student_id' => Auth::id(),
        ]);

        $comment->load('student');

        return response()->json([
            'success' => true,
            'comment' => [
                'id' => $comment->id,
                'text' => $comment->content,
                'author' => $comment->student?->name ?? 'Unknown',
                'timestamp' => $comment->created_at->toISOString(),
                'date' => $comment->created_at->format('M d, Y')
            ]
        ]);
    }

    /**
     * Display user's comments across all articles.
     */
    public function myComments(): InertiaResponse
    {
        // Fetch ONLY the authenticated student's comments from PUBLISHED articles with eager loading
        $comments = Comment::where('student_id', Auth::id())
            ->whereHas('article', function($query) {
                $query->whereHas('status', function($statusQuery) {
                    $statusQuery->where('name', 'Published');
                });
            })
            ->with(['article', 'article.writer'])  // Load article and its writer (publisher)
            ->latest()
            ->get();

        return Inertia::render('Student/MyComments', [
            'comments' => $comments
        ]);
    }

    /**
     * Search for published articles.
     */
    public function search(Request $request): InertiaResponse|RedirectResponse
    {
        $query = $request->input('query');
        
        if (!$query) {
            return redirect()->route('student.dashboard');
        }

        $articles = Article::published()
            ->where(function($q) use ($query) {
                $q->where('title', 'like', "%{$query}%")
                  ->orWhere('content', 'like', "%{$query}%");
            })
            ->with(['writer', 'comments' => function($query) {
                $query->with('student')->latest()->limit(2);
            }])
            ->withCount(['comments'])
            ->latest()
            ->paginate(12);

        return Inertia::render('Student/Search', [
            'articles' => $articles,
            'query' => $query,
        ]);
    }
}
