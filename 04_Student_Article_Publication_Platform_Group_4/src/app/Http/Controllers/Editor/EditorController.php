<?php

namespace App\Http\Controllers\Editor;

use App\Http\Controllers\Controller;
use App\Models\Article;
use Illuminate\Http\Request;
use Inertia\Inertia;

class EditorController extends Controller
{
    /**
     * Display a listing of articles submitted for review and those already published.
     */
    public function index()
    {
        return Inertia::render('Editor/Dashboard', [
            // Articles waiting for review (Status ID 2)
            'pendingArticles' => Article::where('status_id', 2)
                ->with(['user', 'category']) 
                ->get(),

            // Articles already live on the platform (Status ID 3)
            'publishedArticles' => Article::where('status_id', 3)
                ->with(['user', 'category'])
                ->get(),
        ]);
    }

    /**
     * Approve the article (Publish it).
     */
    public function approve(Article $article)
    {
        // Change status to 'Published' (ID 3)
        $article->update(['status_id' => 3]); 

        return redirect()->route('editor.dashboard')->with('message', 'Article has been published successfully!');
    }

    /**
     * Reject the article (Back to Draft).
     */
    public function reject(Article $article)
    {
        // Change status back to 'Draft' (ID 1)
        $article->update(['status_id' => 1]); 

        return redirect()->route('editor.dashboard')->with('message', 'Article rejected and sent back to Draft.');
    }

    /**
     * Update a published article's content directly.
     */
    public function update(Request $request, Article $article)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id',
        ]);

        $article->update($validated);

        return redirect()->route('editor.dashboard')->with('message', 'Published article updated successfully!');
    }

    /**
     * Permanently remove the article from the system.
     */
    public function destroy(Article $article)
    {
        // This command removes the record from the articles table
        $article->delete();

        return redirect()->route('editor.dashboard')
            ->with('message', 'The published article has been permanently removed.');
    }
}