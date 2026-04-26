<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Notifications\ArticleSubmittedNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Notification;
use Inertia\Inertia;

class WriterController extends Controller
{
    private function statusId(string $name): int
    {
        return ArticleStatus::where('name', $name)->firstOrFail()->id;
    }

    public function dashboard()
    {
        $user = Auth::user();
        $draftId = $this->statusId('draft');
        $submittedId = $this->statusId('submitted');
        $needsRevisionId = $this->statusId('needs_revision');
        $publishedId = $this->statusId('published');

        $drafts = Article::where('writer_id', $user->id)
            ->when($draftId, fn ($q) => $q->where('status_id', $draftId))
            ->with(['category', 'status'])
            ->get();

        $submitted = Article::where('writer_id', $user->id)
            ->when($submittedId, fn ($q) => $q->where('status_id', $submittedId))
            ->with(['category', 'status'])
            ->get();

        $needsRevision = Article::where('writer_id', $user->id)
            ->when($needsRevisionId, fn ($q) => $q->where('status_id', $needsRevisionId))
            ->with(['category', 'status', 'revisions' => function($query) {
                $query->latest();
            }])
            ->get();

        $published = Article::where('writer_id', $user->id)
            ->when($publishedId, fn ($q) => $q->where('status_id', $publishedId))
            ->with(['category', 'status'])
            ->get();

        $categories = Category::all();

        return Inertia::render('Writer/Dashboard', [
            'drafts' => $drafts,
            'submitted' => $submitted,
            'needsRevision' => $needsRevision,
            'published' => $published,
            'categories' => $categories
        ]);
    }

    public function create()
    {
        $categories = Category::all();

        return Inertia::render('Writer/Create', [
            'categories' => $categories
        ]);
    }

    public function revision()
    {
        $needsRevisionId = $this->statusId('needs_revision');

        $needsRevision = Article::when($needsRevisionId, fn ($q) => $q->where('status_id', $needsRevisionId))
            ->where('writer_id', Auth::id())
            ->with(['writer', 'category', 'status', 'revisions' => function($query) {
                $query->with('editor')->latest();
            }])
            ->get();

        return Inertia::render('Writer/Revision', [
            'needsRevision' => $needsRevision
        ]);
    }

    public function edit(Article $article)
    {
        $this->authorize('edit', $article);

        $article->load(['category', 'status', 'revisions' => function ($query) {
            $query->latest();
        }]);

        return Inertia::render('Writer/Edit', [
            'article' => $article,
            'categories' => Category::all(),
        ]);
    }

    public function view(Article $article)
    {
        $this->authorize('view', $article);

        $article->load(['category', 'status', 'writer']);

        return Inertia::render('Writer/ViewArticle', [
            'article' => $article,
        ]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Article::class);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'status' => 'sometimes|string|in:draft',
            'submit_for_review' => 'sometimes|boolean'
        ]);

        // Determine status based on parameters
        if (isset($validated['submit_for_review']) && $validated['submit_for_review']) {
            $statusName = 'submitted';
        } else {
            $statusName = $validated['status'] ?? 'draft';
        }
        
        $article = Article::create([
            'title' => $validated['title'],
            'content' => $validated['content'],
            'category_id' => $validated['category_id'],
            'writer_id' => Auth::id(),
            'status_id' => $this->statusId($statusName)
        ]);

        // If submitted for review, notify editors
        if ($statusName === 'submitted') {
            $editors = \App\Models\User::role('editor')->get();
            Notification::send($editors, new \App\Notifications\ArticleSubmittedNotification($article));
            return redirect()->back()->with('success', 'Article submitted for review!');
        }

        // If saved as draft
        return redirect()->back()->with('success', 'Article saved as draft!');
    }

    public function update(Request $request, Article $article)
    {
        $this->authorize('update', $article);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id'
        ]);

        $article->update($validated);

        return redirect()->back()->with('success', 'Article updated successfully!');
    }

    public function submit(Article $article)
    {
        $this->authorize('submit', $article);

        $article->update(['status_id' => $this->statusId('submitted')]);

        // Notify all editors
        $editors = \App\Models\User::role('editor')->get();
        Notification::send($editors, new ArticleSubmittedNotification($article));

        return redirect()->back()->with('success', 'Article submitted for review!');
    }

    public function revise(Request $request, Article $article)
    {
        $this->authorize('revise', $article);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'required|exists:categories,id'
        ]);

        $article->update($validated);
        $article->update(['status_id' => 2]); // Resubmit after revision

        return redirect()->route('writer.revision')->with('success', 'Article revised and resubmitted!');
    }

    public function resubmit(Article $article)
    {
        $this->authorize('revise', $article);

        // Change status from 'needs_revision' (status_id = 3) back to 'submitted' (status_id = 2)
        $article->update(['status_id' => 2]);

        return redirect()->route('writer.revision')->with('success', 'Article resubmitted for editor review!');
    }

    public function destroy(Article $article)
    {
        $this->authorize('delete', $article);

        $article->delete();

        return redirect()->back()->with('success', 'Article deleted successfully!');
    }
}
