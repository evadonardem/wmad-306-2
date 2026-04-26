<?php

namespace App\Http\Controllers;

use App\Models\Article;
use Illuminate\Http\Request;
use Inertia\Inertia;

class GuestController extends Controller
{
    /**
     * Display the public homepage with the Published Articles Gallery.
     */
    public function index()
    {
        return Inertia::render('Welcome', [
            // Only fetch articles that have been approved (Status ID 3 = Published)
            'articles' => Article::where('status_id', 3) 
                ->with(['user:id,name', 'category:id,name', 'status']) // Eager load relationships
                ->latest()
                ->get(),
        ]);
    }

    /**
     * Display a specific published article in full.
     */
    public function show(Article $article)
    {
        // SECURITY: Only allow viewing if the article is Published (ID 3)
        // This prevents guests from viewing private drafts or pending submissions
        if ($article->status_id !== 3) {
            abort(404, 'Article not found or not yet published.');
        }

        // Load the author and category details
        $article->load(['user:id,name', 'category:id,name', 'status']);

        // Pointing to the Guest/Show component we created
        return Inertia::render('Guest/Show', [
            'article' => $article,
        ]);
    }
}