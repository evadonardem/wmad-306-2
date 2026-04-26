<?php

use App\Http\Controllers\EditorController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\WriterController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

// Public routes
Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

// Student routes
Route::middleware(['auth', 'verified', 'role:student'])->prefix('student')->name('student.')->group(function () {
    Route::get('/dashboard', [StudentController::class, 'dashboard'])->name('dashboard');
    Route::get('/my-comments', [StudentController::class, 'myComments'])->name('my.comments');
    Route::get('/search', [StudentController::class, 'search'])->name('search');

    Route::get('/articles/{article}', [StudentController::class, 'show'])->name('articles.show');
    Route::post('/articles/{article}/comment', [StudentController::class, 'comment'])->name('articles.comment');
});

// Optional AJAX comment endpoint
Route::middleware(['auth', 'verified', 'role:student'])
    ->post('/api/student/articles/{article}/comment', [StudentController::class, 'apiComment'])
    ->name('student.articles.comment.api');

// Writer routes
Route::middleware(['auth', 'verified', 'role:writer'])->prefix('writer')->name('writer.')->group(function () {
    Route::get('/dashboard', [WriterController::class, 'dashboard'])->name('dashboard');

    Route::get('/articles/create', [WriterController::class, 'create'])->name('articles.create');
    Route::post('/articles', [WriterController::class, 'store'])->name('articles.store');
    Route::get('/articles/{article}', [WriterController::class, 'show'])->name('articles.show');
    Route::get('/articles/{article}/edit', [WriterController::class, 'edit'])->name('articles.edit');
    Route::put('/articles/{article}', [WriterController::class, 'update'])->name('articles.update');
    Route::post('/articles/{article}/submit', [WriterController::class, 'submit'])->name('articles.submit');
    Route::post('/articles/{article}/revise', [WriterController::class, 'revise'])->name('articles.revise');
    Route::get('/articles/{article}/revisions', [WriterController::class, 'revisions'])->name('articles.revisions');
});

// Editor routes
Route::middleware(['auth', 'verified', 'role:editor'])->prefix('editor')->name('editor.')->group(function () {
    Route::get('/dashboard', [EditorController::class, 'dashboard'])->name('dashboard');

    Route::get('/articles/{article}/review', [EditorController::class, 'review'])->name('articles.review');
    Route::post('/articles/{article}/publish', [EditorController::class, 'publish'])->name('articles.publish');
    Route::post('/articles/{article}/request-revision', [EditorController::class, 'requestRevision'])->name('articles.request-revision');

    Route::get('/articles/{article}/edit', [EditorController::class, 'edit'])->name('articles.edit');
    Route::put('/articles/{article}/update', [EditorController::class, 'update'])->name('articles.update');

    Route::get('/articles/{article}/revision', [EditorController::class, 'revision'])->name('articles.revision');
    Route::get('/articles/{article}/revisions', [EditorController::class, 'revisions'])->name('articles.revisions');
});

// API route for latest published articles
Route::middleware(['auth', 'verified'])->get('/api/latest-articles', function () {
    $articles = \App\Models\Article::with(['writer', 'category', 'status'])
        ->whereHas('status', function ($query) {
            $query->where('name', 'Published');
        })
        ->orderBy('updated_at', 'desc')
        ->take(10)
        ->get()
        ->map(function ($article) {
            return [
                'id' => $article->id,
                'title' => $article->title,
                'excerpt' => substr($article->content ?? '', 0, 150) . '...',
                'writer' => $article->writer ? $article->writer->name : 'Unknown',
                'category' => $article->category ? $article->category->name : 'General',
                'comment_count' => $article->comments()->count(),
                'updated_at' => $article->updated_at->format('M d, Y'),
            ];
        });

    return response()->json($articles);
});

Route::middleware('auth')->get('/api/articles/{article}/comments', function ($article) {
    $comments = \App\Models\Comment::where('article_id', $article)
        ->with('student')
        ->latest()
        ->get()
        ->map(function ($comment) {
            return [
                'id' => $comment->id,
                'text' => $comment->content,
                'author' => $comment->student?->name ?? 'Unknown',
                'timestamp' => $comment->created_at->toISOString(),
                'date' => $comment->created_at->format('M d, Y'),
            ];
        });

    return response()->json(['comments' => $comments]);
});

// Profile routes
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

require __DIR__ . '/auth.php';
require __DIR__ . '/sample.php';
