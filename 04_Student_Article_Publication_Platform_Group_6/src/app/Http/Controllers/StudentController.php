<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\Category;
use App\Notifications\CommentPostedNotification;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class StudentController extends Controller
{
    public function studentDashboard(Request $request): Response
    {
        $filters = $request->only([
            'search',
            'category_id',
            'date_from',
            'date_to',
            'sort',
        ]);

        $query = Article::query()
            ->with(['writer', 'category', 'comments.student', 'status'])
            ->whereHas('status', fn ($q) => $q->where('name', 'published'));

        if (! empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search): void {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('content', 'like', "%{$search}%");
            });
        }

        if (! empty($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (! empty($filters['date_from'])) {
            $query->whereDate('updated_at', '>=', $filters['date_from']);
        }

        if (! empty($filters['date_to'])) {
            $query->whereDate('updated_at', '<=', $filters['date_to']);
        }

        $sort = $filters['sort'] ?? 'newest';
        $query->when(
            $sort === 'oldest',
            fn ($q) => $q->orderBy('updated_at', 'asc'),
            fn ($q) => $q
        );

        if ($sort === 'title_asc') {
            $query->orderBy('title', 'asc');
        } elseif ($sort === 'title_desc') {
            $query->orderBy('title', 'desc');
        } elseif ($sort !== 'oldest') {
            $query->latest('updated_at');
        }

        $publishedArticles = $query->get();

        $featuredArticle = $publishedArticles->first();
        $latestPublications = $publishedArticles->take(6)->values();

        $studentComments = $publishedArticles
            ->flatMap(fn ($article) => $article->comments)
            ->where('student_id', $request->user()->id)
            ->values();

        return Inertia::render('Student/Dashboard', [
            'publishedArticles' => $publishedArticles,
            'featuredArticle' => $featuredArticle,
            'latestPublications' => $latestPublications,
            'myComments' => $studentComments,
            'categories' => Category::query()->orderBy('name')->get(['id', 'name']),
            'filters' => $filters,
        ]);
    }

    public function comment(Request $request, Article $article): RedirectResponse
    {
        $article->load('status', 'writer', 'editor');
        $this->authorize('comment', $article);

        $validated = $request->validate([
            'content' => ['required', 'string', 'max:2000'],
        ]);

        $comment = $article->comments()->create([
            'student_id' => $request->user()->id,
            'content' => $validated['content'],
        ]);

        $article->writer?->notify(new CommentPostedNotification($article, $comment));
        $article->editor?->notify(new CommentPostedNotification($article, $comment));

        return back()->with('success', 'Comment posted.');
    }
}
