<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Notifications\ArticleSubmittedNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Inertia\Inertia;

class WriterController extends Controller
{
    /**
     * Writer dashboard — shows the writer's articles grouped by status.
     */
    public function dashboard(Request $request)
    {
        $articles = Article::with('status', 'category')
            ->where('writer_id', $request->user()->id)
            ->latest()
            ->get();

        $categories = Category::orderBy('name')->get();

        return Inertia::render('Writer/Dashboard', [
            'articles'   => $articles,
            'categories' => $categories,
        ]);
    }

    /**
     * Store a new draft article.
     */
    public function store(Request $request)
    {
        $request->validate([
            'title'       => 'required|string|max:255',
            'content'     => 'nullable|string',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $draftStatus = ArticleStatus::where('name', 'draft')->firstOrFail();

        Article::create([
            'title'       => $request->input('title'),
            'slug'        => Str::slug($request->input('title')) . '-' . Str::random(6),
            'content'     => $request->input('content', ''),
            'status_id'   => $draftStatus->id,
            'writer_id'   => $request->user()->id,
            'category_id' => $request->input('category_id'),
        ]);

        return redirect()->route('writer.dashboard')->with('success', 'Article created as draft.');
    }

    /**
     * Submit an article for editorial review.
     */
    public function submit(Request $request, Article $article)
    {
        $this->authorize('submit', $article);

        $submittedStatus = ArticleStatus::where('name', 'submitted')->firstOrFail();
        $article->update(['status_id' => $submittedStatus->id]);

        // Notify editors
        $editors = \App\Models\User::role('editor')->get();
        foreach ($editors as $editor) {
            $editor->notify(new ArticleSubmittedNotification($article));
        }

        return redirect()->route('writer.dashboard')->with('success', 'Article submitted for review.');
    }

    /**
     * Revise an article (update content after revision request).
     */
    public function revise(Request $request, Article $article)
    {
        $this->authorize('update', $article);

        $request->validate([
            'title'       => 'required|string|max:255',
            'content'     => 'nullable|string',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $article->update($request->only(['title', 'content', 'category_id']));

        return redirect()->route('writer.dashboard')->with('success', 'Article updated.');
    }
}
