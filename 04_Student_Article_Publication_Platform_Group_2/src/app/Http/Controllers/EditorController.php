<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Models\Revision;
use App\Models\User;
use App\Notifications\ArticlePublishedNotification;
use App\Notifications\RevisionRequestedNotification;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;

class EditorController extends Controller
{
    /**
     * Display the editor dashboard with submitted and published articles.
     */
    public function index(): Response
    {
        $submittedStatus = ArticleStatus::where('name', 'submitted')->first();
        $publishedStatus = ArticleStatus::where('name', 'published')->first();

        $pendingArticles = Article::with(['writer', 'category', 'status'])
            ->where('status_id', $submittedStatus?->id)
            ->latest()
            ->get();

        $publishedArticles = Article::with(['writer', 'category', 'status', 'editor'])
            ->where('status_id', $publishedStatus?->id)
            ->latest()
            ->get();

        return Inertia::render('Editor/Dashboard', [
            'pendingArticles' => $pendingArticles,
            'publishedArticles' => $publishedArticles,
        ]);
    }

    /**
     * Show an article for review.
     */
    public function review(Article $article): Response
    {
        $this->authorize('review', $article);

        $article->load(['writer', 'category', 'status', 'revisions.editor']);

        return Inertia::render('Editor/Review', [
            'article' => $article,
        ]);
    }

    /**
     * Request a revision on a submitted article.
     */
    public function requestRevision(Request $request, Article $article): RedirectResponse
    {
        $this->authorize('requestRevision', $article);

        $request->validate([
            'comments' => 'required|string|min:10',
        ]);

        $needsRevisionStatus = ArticleStatus::where('name', 'needs_revision')->firstOrFail();

        // Create revision record
        Revision::create([
            'article_id' => $article->id,
            'editor_id' => Auth::id(),
            'comments' => $request->comments,
        ]);

        // Update article status and assign editor
        $article->update([
            'status_id' => $needsRevisionStatus->id,
            'editor_id' => Auth::id(),
        ]);

        // Notify the writer
        $article->writer->notify(new RevisionRequestedNotification($article));

        return redirect()->route('editor.dashboard')
            ->with('success', 'Revision requested for "' . $article->title . '".');
    }

    /**
     * Publish a submitted article.
     */
    public function publish(Article $article): RedirectResponse
    {
        $this->authorize('publish', $article);

        $publishedStatus = ArticleStatus::where('name', 'published')->firstOrFail();

        $article->update([
            'status_id' => $publishedStatus->id,
            'editor_id' => Auth::id(),
        ]);

        // Notify the writer
        $article->writer->notify(new ArticlePublishedNotification($article));

        return redirect()->route('editor.dashboard')
            ->with('success', '"' . $article->title . '" has been published.');
    }

    /**
     * Search articles for editor review.
     */
    public function search(Request $request)
    {
        $query = $request->input('q', '');

        if (strlen($query) < 2) {
            return response()->json(['results' => []]);
        }

        // Search across submitted and published articles
        $submittedStatus = ArticleStatus::where('name', 'submitted')->first();
        $publishedStatus = ArticleStatus::where('name', 'published')->first();

        $articles = Article::with(['writer', 'status', 'category'])
            ->whereIn('status_id', [$submittedStatus?->id, $publishedStatus?->id])
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
                    'subtitle' => 'By ' . $article->writer?->name . ' • ' . $article->status->name,
                    'url' => route('articles.review', $article->id),
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
