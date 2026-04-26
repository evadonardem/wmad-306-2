<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\Revision;
use App\Services\ArticleService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class EditorController extends Controller
{
    public function __construct(
        private ArticleService $articleService
    ) {}

    /**
     * Display the editor's dashboard with articles to review.
     */
    public function dashboard(): InertiaResponse
    {
        try {
            // Debug: Log that we're reaching the controller
            \Log::info('Editor dashboard accessed by user: ' . auth()->user()->id);
            
            // Use direct queries instead of scopes to avoid potential issues
            $submittedArticles = Article::whereHas('status', function($query) {
                    $query->where('name', 'Submitted');
                })
                ->with(['writer', 'status', 'revisions'])
                ->latest()
                ->get();

            $revisionArticles = Article::whereHas('status', function($query) {
                    $query->where('name', 'Needs Revision');
                })
                ->with(['writer', 'status', 'revisions' => function($query) {
                    $query->latest()->limit(1);
                }])
                ->latest()
                ->get();

            $publishedArticles = Article::whereHas('status', function($query) {
                    $query->where('name', 'Published');
                })
                ->with(['writer', 'status'])
                ->latest()
                ->get();

            // Debug: Log article counts
            \Log::info('Articles found - Submitted: ' . $submittedArticles->count() . 
                      ', Revision: ' . $revisionArticles->count() . 
                      ', Published: ' . $publishedArticles->count());

            return Inertia::render('Editor/Dashboard', [
                'submittedArticles' => $submittedArticles,
                'revisionArticles' => $revisionArticles,
                'publishedArticles' => $publishedArticles,
            ]);
        } catch (\Exception $e) {
            // Log the error for debugging
            \Log::error('Editor dashboard error: ' . $e->getMessage());
            \Log::error('Error trace: ' . $e->getTraceAsString());
            
            // Fallback to empty collections if database queries fail
            return Inertia::render('Editor/Dashboard', [
                'submittedArticles' => collect([]),
                'revisionArticles' => collect([]),
                'publishedArticles' => collect([]),
            ]);
        }
    }

    /**
     * Show the form for reviewing the specified article.
     */
    public function review(Article $article): InertiaResponse|RedirectResponse
    {
        try {
            $this->authorize('review', $article);

            return Inertia::render('Editor/Review', [
                'article' => $article->load(['writer', 'status', 'revisions']),
            ]);
        } catch (\Exception $e) {
            \Log::error('Review error: ' . $e->getMessage());
            return redirect()->route('editor.dashboard')->with('error', 'Unable to review article.');
        }
    }

    /**
     * Publish the specified article.
     */
    public function publish(Request $request, Article $article): RedirectResponse
    {
        try {
            if (!$this->articleService->publishArticle($article, Auth::id())) {
                return redirect()
                    ->route('editor.dashboard')
                    ->with('error', 'This article cannot be published.');
            }

            return redirect()
                ->route('editor.dashboard')
                ->with('success', 'Article published successfully!');
        } catch (\Exception $e) {
            \Log::error('Publish error: ' . $e->getMessage());
            return redirect()
                ->route('editor.dashboard')
                ->with('error', 'Failed to publish article.');
        }
    }

    /**
     * Request revisions for the specified article.
     */
    public function requestRevision(Request $request, Article $article): RedirectResponse
    {
        try {
            $validated = $request->validate([
                'comments' => 'required|string|max:1000',
            ]);

            if (!$this->articleService->requestRevision($article, $validated['comments'], Auth::id())) {
                return redirect()
                    ->route('editor.dashboard')
                    ->with('error', 'This article cannot have revisions requested.');
            }

            return redirect()
                ->route('editor.dashboard')
                ->with('success', 'Revision request sent to writer!');
        } catch (ValidationException|AuthorizationException $e) {
            throw $e;
        } catch (\Exception $e) {
            \Log::error('Request revision error: ' . $e->getMessage());
            return redirect()
                ->route('editor.dashboard')
                ->with('error', 'Failed to request revision.');
        }
    }

    /**
     * Show the form for editing the specified article.
     */
    public function edit(Article $article): InertiaResponse|RedirectResponse
    {
        try {
            return Inertia::render('Editor/Edit', [
                'article' => $article->load(['writer', 'status', 'category', 'revisions' => function($query) {
                    $query->with('editor')->latest();
                }]),
                'categories' => \App\Models\Category::all(),
            ]);
        } catch (\Exception $e) {
            \Log::error('Edit error: ' . $e->getMessage());
            return redirect()->route('editor.dashboard')->with('error', 'Unable to edit article.');
        }
    }

    /**
     * Update the specified article.
     */
    public function update(Request $request, Article $article): RedirectResponse
    {
        try {
            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'content' => 'required|string',
                'category_id' => 'nullable|exists:categories,id',
            ]);

            $article->update($validated);

            // Create revision record for transparency
            Revision::create([
                'article_id' => $article->id,
                'editor_id' => Auth::id(),
                'comments' => 'Article edited by editor',
            ]);

            return redirect()
                ->route('editor.dashboard')
                ->with('success', 'Article updated successfully!');
        } catch (ValidationException|AuthorizationException $e) {
            throw $e;
        } catch (\Exception $e) {
            \Log::error('Update error: ' . $e->getMessage());
            return redirect()
                ->route('editor.dashboard')
                ->with('error', 'Failed to update article.');
        }
    }

    /**
     * Display a single revision for the specified article.
     */
    public function revision(Article $article): InertiaResponse|RedirectResponse
    {
        try {
            $this->authorize('view', $article);

            return Inertia::render('Editor/Revision', [
                'article' => $article->load(['revisions' => function($query) {
                    $query->with('editor')->latest()->limit(1);
                }]),
            ]);
        } catch (\Exception $e) {
            \Log::error('Revision error: ' . $e->getMessage());
            return redirect()->route('editor.dashboard')->with('error', 'Unable to view revision.');
        }
    }

    /**
     * Display the revision history for the specified article.
     */
    public function revisions(Article $article): InertiaResponse|RedirectResponse
    {
        try {
            $this->authorize('view', $article);

            return Inertia::render('Editor/Revisions', [
                'article' => $article->load(['revisions' => function($query) {
                    $query->with('editor')->latest();
                }]),
            ]);
        } catch (\Exception $e) {
            \Log::error('Revisions error: ' . $e->getMessage());
            return redirect()->route('editor.dashboard')->with('error', 'Unable to view revisions.');
        }
    }
}
