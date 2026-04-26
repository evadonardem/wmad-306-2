<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Models\User;
use App\Notifications\ArticleSubmittedNotification;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use Inertia\Response;

class WriterController extends Controller
{
    public function create(): Response
    {
        return Inertia::render('Writer/Create', [
            'categories' => Category::query()->orderBy('name')->get(),
        ]);
    }

    public function dashboard(Request $request): Response
    {
        $articles = Article::query()
            ->with(['status', 'category', 'editor', 'revisions'])
            ->where('writer_id', $request->user()->id)
            ->latest('updated_at')
            ->get();

        return Inertia::render('Writer/Dashboard', [
            'articles' => $articles,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $this->authorize('create', Article::class);

        $rawCoverImageUrl = trim((string) $request->input('cover_image_url', ''));
        $normalizedCoverImageUrl = null;
        if ($rawCoverImageUrl !== '') {
            $normalizedCoverImageUrl = preg_match('/^[a-z][a-z0-9+\-.]*:\/\//i', $rawCoverImageUrl)
                ? $rawCoverImageUrl
                : 'https://' . $rawCoverImageUrl;
        }

        $request->merge([
            'cover_image_url' => $normalizedCoverImageUrl,
        ]);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'content' => ['required', 'string'],
            'category_id' => ['required', 'exists:categories,id'],
            'cover_image_url' => ['nullable', 'url', 'max:5000'],
            'cover_image_file' => ['nullable', 'file', 'image', 'max:5120'],
            'action' => ['nullable', 'in:draft,submit'],
        ]);

        $requestedAction = $validated['action'] ?? 'draft';
        $articlePayload = collect($validated)->except('action')->all();
        $coverImageUrl = $validated['cover_image_url'] ?? null;

        if ($request->hasFile('cover_image_file')) {
            $storedPath = $request->file('cover_image_file')->store('article-covers', 'public');
            $coverImageUrl = Storage::disk('public')->url($storedPath);
        }

        unset($articlePayload['cover_image_file']);

        $draftStatusId = ArticleStatus::query()->where('name', 'draft')->value('id');
        $submittedStatusId = ArticleStatus::query()->where('name', 'submitted')->value('id');

        $article = Article::query()->create([
            ...$articlePayload,
            'cover_image_url' => $coverImageUrl,
            'writer_id' => $request->user()->id,
            'status_id' => $requestedAction === 'submit' ? $submittedStatusId : $draftStatusId,
        ]);

        if ($requestedAction === 'submit') {
            $editors = User::role('editor')->get();
            foreach ($editors as $editor) {
                $editor->notify(new ArticleSubmittedNotification($article));
            }

            return redirect()->route('writer.dashboard')
                ->with('success', 'Article submitted for review.');
        }

        return back()->with('success', 'Draft saved successfully.');
    }

    public function submit(Request $request, Article $article): RedirectResponse
    {
        $article->load('status');
        $this->authorize('submit', $article);

        $submittedStatusId = ArticleStatus::query()->where('name', 'submitted')->value('id');

        $article->update([
            'status_id' => $submittedStatusId,
        ]);

        $editors = User::role('editor')->get();
        foreach ($editors as $editor) {
            $editor->notify(new ArticleSubmittedNotification($article));
        }

        return back()->with('success', 'Article submitted for review.');
    }

    public function updateCoverImage(Request $request, Article $article): RedirectResponse
    {
        $article->load('status');

        abort_unless(
            $article->writer_id === $request->user()->id
                && in_array($article->status?->name, ['draft', 'needs_revision'], true),
            403,
        );

        $rawCoverImageUrl = trim((string) $request->input('cover_image_url', ''));
        $hasUploadedFile = $request->hasFile('cover_image_file');
        $normalizedCoverImageUrl = null;

        if (! $hasUploadedFile && $rawCoverImageUrl !== '') {
            $normalizedCoverImageUrl = preg_match('/^[a-z][a-z0-9+\-.]*:\/\//i', $rawCoverImageUrl)
                ? $rawCoverImageUrl
                : 'https://' . $rawCoverImageUrl;
        }

        $request->merge([
            'cover_image_url' => $normalizedCoverImageUrl,
        ]);

        $validated = $request->validate([
            'cover_image_url' => ['nullable', 'url', 'max:5000'],
            'cover_image_file' => ['nullable', 'file', 'image', 'max:5120'],
        ]);

        $newCoverImageUrl = $validated['cover_image_url'] ?? null;
        if ($hasUploadedFile) {
            $oldLocalPath = $this->extractLocalCoverPath($article->cover_image_url);
            if ($oldLocalPath) {
                Storage::disk('public')->delete($oldLocalPath);
            }

            $storedPath = $request->file('cover_image_file')->store('article-covers', 'public');
            $newCoverImageUrl = Storage::disk('public')->url($storedPath);
        }

        $article->update([
            'cover_image_url' => $newCoverImageUrl,
        ]);

        return back()->with('success', 'Draft cover image updated.');
    }

    public function revise(Request $request, Article $article): RedirectResponse
    {
        $article->load('status');
        $this->authorize('revise', $article);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'content' => ['required', 'string'],
            'category_id' => ['required', 'exists:categories,id'],
        ]);

        $submittedStatusId = ArticleStatus::query()->where('name', 'submitted')->value('id');

        $article->update([
            ...$validated,
            'status_id' => $submittedStatusId,
        ]);

        $editors = User::role('editor')->get();
        foreach ($editors as $editor) {
            $editor->notify(new ArticleSubmittedNotification($article));
        }

        return back()->with('success', 'Revision submitted successfully.');
    }

    private function extractLocalCoverPath(?string $coverImageUrl): ?string
    {
        if (! $coverImageUrl) {
            return null;
        }

        $parsedPath = parse_url($coverImageUrl, PHP_URL_PATH);
        $path = is_string($parsedPath) ? $parsedPath : $coverImageUrl;

        if (! str_starts_with($path, '/storage/article-covers/')) {
            return null;
        }

        return ltrim(str_replace('/storage/', '', $path), '/');
    }
}
