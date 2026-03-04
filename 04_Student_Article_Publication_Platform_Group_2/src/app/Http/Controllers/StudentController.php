<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Comment;
use App\Notifications\CommentPostedNotification;
use Illuminate\Http\Request;
use Inertia\Inertia;

class StudentController extends Controller
{
    /**
     * Student dashboard — published articles list and the student's comments.
     */
    public function dashboard(Request $request)
    {
        $publishedStatus = ArticleStatus::where('name', 'published')->first();

        $articles = Article::with('writer', 'category', 'status', 'comments')
            ->where('status_id', $publishedStatus?->id)
            ->latest('published_at')
            ->paginate(10);

        $myComments = Comment::with('article')
            ->where('student_id', $request->user()->id)
            ->latest()
            ->get();

        return Inertia::render('Student/Dashboard', [
            'articles'   => $articles,
            'myComments' => $myComments,
        ]);
    }

    /**
     * View a single published article.
     */
    public function show(Article $article)
    {
        $article->load('writer', 'category', 'comments.student', 'status');

        return Inertia::render('Student/Article', [
            'article' => $article,
        ]);
    }

    /**
     * Post a comment on a published article.
     */
    public function comment(Request $request, Article $article)
    {
        $request->validate([
            'content' => 'required|string',
        ]);

        if (! $article->isPublished()) {
            abort(403, 'You can only comment on published articles.');
        }

        $comment = Comment::create([
            'article_id' => $article->id,
            'student_id' => $request->user()->id,
            'content'    => $request->input('content'),
        ]);

        // Notify writer about the new comment
        $article->writer->notify(new CommentPostedNotification($article, $comment));

        return back()->with('success', 'Comment posted.');
    }
}
