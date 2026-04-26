<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\Comment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class StudentController extends Controller
{
    public function dashboard()
    {
        $articles = Article::whereHas('status', function ($q) {
            $q->where('name', 'published');
        })->with('writer','category','comments.user')->get();

        $comments = Auth::user()->comments()->with('article')->get();

        $categories = \App\Models\Category::orderBy('name')->get();
        return Inertia::render('Student/Dashboard', compact('articles','comments','categories'));
    }

    public function comment(Request $request, Article $article)
    {
        $this->authorize('comment', [Comment::class, $article]);
        $data = $request->validate(['content' => 'required|string']);

        $comment = Comment::create([
            'article_id' => $article->id,
            'student_id' => Auth::id(),
            'content' => $data['content'],
        ]);

        // notify writer
        $article->writer->notify(new \App\Notifications\CommentPostedNotification($comment));

        return redirect()->back()->with('success','Comment posted');
    }
}
