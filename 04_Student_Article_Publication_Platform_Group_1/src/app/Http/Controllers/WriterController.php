<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Services\ArticleService;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response as InertiaResponse;

class WriterController extends Controller
{
    public function __construct(
        private ArticleService $articleService
    ) {}

    /**
     * Display the writer's dashboard with their articles.
     */
    public function dashboard(): InertiaResponse
    {
        try {
            $articles = Article::where('writer_id', Auth::id())
                ->with(['status', 'revisions' => function($query) {
                    $query->latest()->limit(1);
                }])
                ->latest()
                ->get();

            // Filter articles by status using direct comparison
            $draftArticles = $articles->filter(function($article) {
                return $article->status && $article->status->name === 'Draft';
            })->values();

            $submittedArticles = $articles->filter(function($article) {
                return $article->status && $article->status->name === 'Submitted';
            })->values();

            $revisionArticles = $articles->filter(function($article) {
                return $article->status && $article->status->name === 'Needs Revision';
            })->values();

            $publishedArticles = $articles->filter(function($article) {
                return $article->status && $article->status->name === 'Published';
            })->values();

            return Inertia::render('Writer/Dashboard', [
                'draftArticles' => $draftArticles,
                'submittedArticles' => $submittedArticles,
                'revisionArticles' => $revisionArticles,
                'publishedArticles' => $publishedArticles,
                'categories' => \App\Models\Category::all(),
            ]);
        } catch (\Exception $e) {
            // Fallback to empty collections if database queries fail
            return Inertia::render('Writer/Dashboard', [
                'draftArticles' => collect([]),
                'submittedArticles' => collect([]),
                'revisionArticles' => collect([]),
                'publishedArticles' => collect([]),
                'categories' => collect([]),
            ]);
        }
    }

    /**
     * Display a single writer-owned article.
     */
    public function show(Article $article): InertiaResponse
    {
        $this->authorize('view', $article);

        return Inertia::render('Writer/Show', [
            'article' => $article->load(['status', 'category', 'revisions.editor', 'comments.student']),
        ]);
    }

    /**
     * Show the form for creating a new article.
     */
    public function create(): InertiaResponse
    {
        try {
            $categories = \App\Models\Category::all();
            
            return Inertia::render('Writer/Create', [
                'categories' => $categories,
            ]);
        } catch (\Exception $e) {
            // Fallback if categories table doesn't exist
            return Inertia::render('Writer/Create', [
                'categories' => collect([]),
            ]);
        }
    }

    /**
     * Store a newly created article.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $draftStatus = ArticleStatus::firstOrCreate(
            ['name' => 'Draft'],
            ['label' => 'Draft']
        );

        $article = Article::create([
            'title' => $validated['title'],
            'content' => $validated['content'],
            'writer_id' => Auth::id(),
            'status_id' => $draftStatus->id,
            'category_id' => $validated['category_id'] ?? null,
        ]);

        return redirect()
            ->route('writer.dashboard')
            ->with('success', 'Article created successfully!');
    }

    /**
     * Show the form for editing the specified article.
     */
    public function edit(Article $article): InertiaResponse|RedirectResponse
    {
        $this->authorize('update', $article);
        
        return Inertia::render('Writer/Edit', [
            'article' => $article->load(['status', 'category', 'revisions' => function($query) {
                $query->with('editor')->latest();
            }]),
            'categories' => \App\Models\Category::all(),
        ]);
    }

    /**
     * Update the specified article.
     */
    public function update(Request $request, Article $article): RedirectResponse
    {
        $this->authorize('update', $article);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $article->update($validated);

        return redirect()
            ->route('writer.dashboard')
            ->with('success', 'Article updated successfully!');
    }

    /**
     * Submit the article for editorial review.
     */
    public function submit(Article $article): RedirectResponse|JsonResponse
    {
        if ($this->articleService->submitArticle($article)) {
            return redirect()
                ->route('writer.dashboard')
                ->with('success', 'Article submitted for review!');
        }

        return redirect()
            ->route('writer.dashboard')
            ->with('error', 'This article cannot be submitted.');
    }

    /**
     * Display the revision history for the specified article.
     */
    public function revisions(Article $article): InertiaResponse|RedirectResponse
    {
        $this->authorize('view', $article);

        return Inertia::render('Writer/Revisions', [
            'article' => $article->load(['revisions' => function($query) {
                $query->with('editor')->latest();
            }]),
        ]);
    }

    /**
     * Handle article revision requests.
     */
    public function revise(Request $request, Article $article): RedirectResponse
    {
        $this->authorize('update', $article);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'category_id' => 'nullable|exists:categories,id',
        ]);

        $article->update($validated);

        // Resubmit after revision
        if ($this->articleService->reviseAndResubmit($article)) {
            return redirect()
                ->route('writer.dashboard')
                ->with('success', 'Article revised and resubmitted!');
        }

        return redirect()
            ->route('writer.dashboard')
            ->with('error', 'Failed to resubmit article.');
    }
}
