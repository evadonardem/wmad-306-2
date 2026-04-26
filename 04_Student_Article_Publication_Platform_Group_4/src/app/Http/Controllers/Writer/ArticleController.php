<?php

namespace App\Http\Controllers\Writer;

use App\Http\Controllers\Controller;
use App\Models\Article;
use App\Models\Category;
use App\Models\ArticleStatus;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Auth;

class ArticleController extends Controller
{
    /**
     * Show the form for creating a new article.
     */
    public function create()
    {
        return Inertia::render('Writer/Create', [
            // Fetches categories to populate the dropdown for the writer
            'categories' => Category::all()
        ]);
    }

    /**
     * Store a newly created article (Status ID 1 = Draft).
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'content' => 'required|string', 
        ]);

        // Creating the article with initial 'Draft' status
        Article::create([
            'user_id' => Auth::id(), // Assigns ownership to the current writer
            'title' => $validated['title'],
            'category_id' => $validated['category_id'],
            'content' => $validated['content'],
            'status_id' => 1, // Logic: 1 = Draft
        ]);

        return redirect()->route('dashboard')->with('message', 'Draft saved successfully!');
    }

    /**
     * Show the form for editing.
     */
    public function edit(Article $article)
    {
        // Security check: Prevents writers from editing articles they don't own
        if ($article->user_id !== Auth::id()) {
            abort(403, 'Unauthorized action.');
        }

        return Inertia::render('Writer/Edit', [
            'article' => $article->load(['category', 'status']),
            'categories' => Category::all(),
        ]);
    }

    /**
     * Update the article.
     */
    public function update(Request $request, Article $article)
    {
        // Ensures only the owner can update the content
        if ($article->user_id !== Auth::id()) {
            abort(403, 'You do not own this article.');
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'content' => 'required|string',
        ]);

        $article->update($validated);

        return redirect()->route('dashboard')->with('message', 'Article updated successfully!');
    }

    /**
     * Submit article for Editor review (Status ID 2 = Submitted).
     */
    public function submit(Article $article)
    {
        // Crucial security check to prevent unauthorized submissions
        if ($article->user_id !== Auth::id()) {
            abort(403, 'Unauthorized submission attempt.');
        }

        // Moves article from 'Draft' to 'Submitted' for Jane Editor to see
        $article->update(['status_id' => 2]);

        return redirect()->route('dashboard')->with('message', 'Article submitted for review!');
    }

    /**
     * Delete the article.
     */
    public function destroy(Article $article)
    {
        if ($article->user_id !== Auth::id()) {
            abort(403, 'Unauthorized delete attempt.');
        }

        $article->delete();

        return redirect()->route('dashboard')->with('message', 'Article deleted successfully.');
    }
}