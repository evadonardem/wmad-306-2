<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Revision;
use App\Notifications\ArticlePublishedNotification;
use App\Notifications\RevisionRequestedNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Notification;
use Inertia\Inertia;

class EditorController extends Controller
{
    private function statusId(string $name): int
    {
        return ArticleStatus::where('name', $name)->firstOrFail()->id;
    }

    public function dashboard()
    {
        $submittedId = $this->statusId('submitted');
        $needsRevisionId = $this->statusId('needs_revision');
        $publishedId = $this->statusId('published');

        $pending = Article::when($submittedId, fn ($q) => $q->where('status_id', $submittedId))
            ->with(['writer', 'category', 'status'])
            ->get();

        $needsRevision = Article::when($needsRevisionId, fn ($q) => $q->where('status_id', $needsRevisionId))
            ->with(['writer', 'category', 'status', 'revisions'])
            ->get();

        $published = Article::when($publishedId, fn ($q) => $q->where('status_id', $publishedId))
            ->where('editor_id', Auth::id())
            ->with(['writer', 'category', 'status'])
            ->get();

        return Inertia::render('Editor/Dashboard', [
            'pending' => $pending,
            'needsRevision' => $needsRevision,
            'published' => $published
        ]);
    }

    public function needsRevision()
    {
        $needsRevisionId = $this->statusId('needs_revision');

        $needsRevision = Article::when($needsRevisionId, fn ($q) => $q->where('status_id', $needsRevisionId))
            ->with(['writer', 'category', 'status', 'revisions'])
            ->get();

        return Inertia::render('Editor/Revision', [
            'needsRevision' => $needsRevision
        ]);
    }

    public function review(Article $article)
    {
        $this->authorize('review', $article);

        $article->load(['writer', 'category', 'status', 'revisions']);

        return Inertia::render('Editor/Review', [
            'article' => $article
        ]);
    }

    public function viewArticle(Article $article)
    {
        $this->authorize('view', $article);

        $article->load(['writer', 'category', 'status']);

        return Inertia::render('Editor/ViewArticle', [
            'article' => $article
        ]);
    }

    public function requestRevision(Request $request, Article $article)
    {
        $this->authorize('requestRevision', $article);

        $validated = $request->validate([
            'comments' => 'required|string'
        ]);

        $revision = Revision::create([
            'article_id' => $article->id,
            'editor_id' => Auth::id(),
            'comments' => $validated['comments']
        ]);

        $article->update([
            'status_id' => $this->statusId('needs_revision'),
            'editor_id' => Auth::id()
        ]);

        // Notify the writer
        $article->writer->notify(new RevisionRequestedNotification($article, $revision));

        return back()->with('success', 'Revision request sent!');
    }

    public function publish(Article $article)
    {
        $this->authorize('publish', $article);

        $article->update([
            'status_id' => $this->statusId('published'),
            'editor_id' => Auth::id()
        ]);

        // Notify the writer
        $article->writer->notify(new ArticlePublishedNotification($article));

        return redirect()->back()->with('success', 'Article published successfully!');
    }
}
