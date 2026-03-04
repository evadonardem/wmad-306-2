<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Revision;
use App\Notifications\ArticlePublishedNotification;
use App\Notifications\RevisionRequestedNotification;
use Illuminate\Http\Request;
use Inertia\Inertia;

class EditorController extends Controller
{
    /**
     * Editor dashboard — submitted articles awaiting review and published list.
     */
    public function dashboard(Request $request)
    {
        $submittedStatus = ArticleStatus::where('name', 'submitted')->first();
        $publishedStatus = ArticleStatus::where('name', 'published')->first();

        $pending = Article::with('writer', 'category', 'status', 'revisions.editor')
            ->where('status_id', $submittedStatus?->id)
            ->latest()
            ->get();

        $published = Article::with('writer', 'category', 'status')
            ->where('status_id', $publishedStatus?->id)
            ->latest('published_at')
            ->get();

        return Inertia::render('Editor/Dashboard', [
            'pending'   => $pending,
            'published' => $published,
        ]);
    }

    /**
     * Show a single article for review.
     */
    public function review(Article $article)
    {
        $article->load('writer', 'category', 'status', 'revisions.editor');

        return Inertia::render('Editor/Review', [
            'article' => $article,
        ]);
    }

    /**
     * Request a revision — add a revision record and set status to "revision".
     */
    public function requestRevision(Request $request, Article $article)
    {
        $this->authorize('requestRevision', $article);

        $request->validate([
            'comments' => 'required|string',
        ]);

        Revision::create([
            'article_id' => $article->id,
            'editor_id'  => $request->user()->id,
            'comments'   => $request->input('comments'),
        ]);

        $revisionStatus = ArticleStatus::where('name', 'revision')->firstOrFail();
        $article->update([
            'status_id' => $revisionStatus->id,
            'editor_id' => $request->user()->id,
        ]);

        // Notify writer
        $article->writer->notify(new RevisionRequestedNotification($article));

        return redirect()->route('editor.dashboard')->with('success', 'Revision requested.');
    }

    /**
     * Publish the article.
     */
    public function publish(Request $request, Article $article)
    {
        $this->authorize('publish', $article);

        $publishedStatus = ArticleStatus::where('name', 'published')->firstOrFail();
        $article->update([
            'status_id'    => $publishedStatus->id,
            'editor_id'    => $request->user()->id,
            'published_at' => now(),
        ]);

        // Notify writer
        $article->writer->notify(new ArticlePublishedNotification($article));

        return redirect()->route('editor.dashboard')->with('success', 'Article published!');
    }
}
