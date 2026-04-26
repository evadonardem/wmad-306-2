<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Notifications\ArticlePublishedNotification;
use App\Notifications\RevisionRequestedNotification;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use Inertia\Response;

class EditorController extends Controller
{
    public function review(): Response
    {
        $submittedArticles = Article::query()
            ->with(['writer', 'category', 'status'])
            ->whereHas('status', fn ($query) => $query->where('name', 'submitted'))
            ->latest('updated_at')
            ->get();

        $publishedArticles = Article::query()
            ->with(['writer', 'category', 'status'])
            ->whereHas('status', fn ($query) => $query->where('name', 'published'))
            ->latest('updated_at')
            ->get();

        return Inertia::render('Editor/Dashboard', [
            'submittedArticles' => $submittedArticles,
            'publishedArticles' => $publishedArticles,
        ]);
    }

    public function requestRevision(Request $request, Article $article): RedirectResponse
    {
        $article->load('status', 'writer');
        $this->authorize('requestRevision', $article);

        $validated = $request->validate([
            'comments' => ['required', 'string', 'max:3000'],
        ]);

        $needsRevisionStatusId = ArticleStatus::query()->where('name', 'needs_revision')->value('id');

        $article->update([
            'status_id' => $needsRevisionStatusId,
            'editor_id' => $request->user()->id,
        ]);

        $article->revisions()->create([
            'editor_id' => $request->user()->id,
            'comments' => $validated['comments'],
        ]);

        $article->writer->notify(new RevisionRequestedNotification($article, $validated['comments']));

        return back()->with('success', 'Revision requested from writer.');
    }

    public function publish(Request $request, Article $article): RedirectResponse
    {
        $article->load('status', 'writer');
        $this->authorize('publish', $article);

        $publishedStatusId = ArticleStatus::query()->where('name', 'published')->value('id');

        $article->update([
            'status_id' => $publishedStatusId,
            'editor_id' => $request->user()->id,
        ]);

        $article->writer->notify(new ArticlePublishedNotification($article));

        return back()->with('success', 'Article published successfully.');
    }

    public function updateCoverImage(Request $request, Article $article): RedirectResponse
    {
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
            'cover_image_url' => ['nullable', 'url', 'max:5000', 'required_without:cover_image_file'],
            'cover_image_file' => ['nullable', 'file', 'image', 'max:5120', 'required_without:cover_image_url'],
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

        return back()->with('success', 'Article cover image updated.');
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
