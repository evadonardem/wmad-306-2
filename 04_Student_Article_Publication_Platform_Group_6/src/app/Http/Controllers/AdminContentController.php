<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\Category;
use App\Models\Comment;
use Illuminate\Http\Request;
use Inertia\Inertia;

class AdminContentController extends Controller
{
    // Load the moderation dashboard
    public function index()
    {
        $articles = Article::with(['writer', 'category', 'status'])->latest()->get();
        $comments = Comment::with(['student', 'article'])->latest()->get();
        $categories = Category::all();

        return Inertia::render('Admin/ContentManagement', [
            'articles' => $articles,
            'comments' => $comments,
            'categories' => $categories,
        ]);
    }

    // Force edit any article
    public function updateArticle(Request $request, Article $article)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id',
        ]);

        $article->update($request->only('title', 'content', 'category_id'));

        return back()->with('success', 'Article updated successfully.');
    }

    // Force delete any article
    public function destroyArticle(Article $article)
    {
        $article->delete();
        return back()->with('success', 'Article completely deleted from the platform.');
    }

    // Force delete any comment
    public function destroyComment(Comment $comment)
    {
        $comment->delete();
        return back()->with('success', 'Comment removed successfully.');
    }
}