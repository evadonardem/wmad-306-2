<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Models\Comment;
use App\Notifications\CommentPostedNotification;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;

class StudentController extends Controller
{
    /**
     * Display the student dashboard with published articles.
     */
    public function index(): Response
    {
        $publishedStatus = ArticleStatus::where('name', 'published')->first();

        $articles = Article::with([
            'writer',
            'category',
            'comments' => fn ($query) => $query->latest(),
            'comments.student',
        ])
            ->where('status_id', $publishedStatus?->id)
            ->latest()
            ->get();

        $myComments = Comment::with(['article'])
            ->where('student_id', Auth::id())
            ->latest()
            ->get();

        return Inertia::render('Student/Dashboard', [
            'articles' => $articles,
            'myComments' => $myComments,
        ]);
    }

    /**
     * Show a published article with comments.
     */
    public function show(Article $article): Response
    {
        $this->authorize('view', $article);

        $article->load([
            'writer',
            'category',
            'comments' => fn ($query) => $query->latest(),
            'comments.student',
        ]);

        return Inertia::render('Student/Show', [
            'article' => $article,
        ]);
    }

    /**
     * Post a comment on a published article.
     */
    public function comment(Request $request, Article $article): RedirectResponse
    {
        $request->validate([
            'content' => 'required|string|min:3',
        ]);

        $comment = Comment::create([
            'article_id' => $article->id,
            'student_id' => Auth::id(),
            'content' => $request->content,
        ]);

        // Notify the writer about the new comment
        $article->writer->notify(new CommentPostedNotification($article, $comment));

        return redirect()->back()
            ->with('success', 'Comment posted successfully.');
    }

    /**
     * Search published articles for students.
     */
    public function search(Request $request)
    {
        $query = $request->input('q', '');

        if (strlen($query) < 2) {
            return response()->json(['results' => []]);
        }

        $publishedStatus = ArticleStatus::where('name', 'published')->first();

        // Search published articles
        $articles = Article::with(['writer', 'category'])
            ->where('status_id', $publishedStatus?->id)
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
                    'subtitle' => 'By ' . $article->writer?->name,
                    'url' => route('articles.show', $article->id),
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
