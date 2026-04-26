<?php

use App\Http\Controllers\EditorController;
use App\Models\Article;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\WriterController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\RoleRequestController;
use App\Http\Controllers\AdminContentController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

// Public Landing Page (Accessible to guests)
Route::get('/', function () {
    $recentPublications = Article::query()
        ->with(['writer', 'category', 'status'])
        ->whereHas('status', fn ($query) => $query->where('name', 'published'))
        ->latest('updated_at')
        ->take(6)
        ->get();

    return Inertia::render('Welcome', [
        'recentPublications' => $recentPublications,
    ]);
})->name('welcome');

// Public Article Preview
Route::get('/publications/{article}', function (Article $article) {
    $article->load(['writer', 'editor', 'category', 'status', 'comments.student']);

    if ($article->status?->name !== 'published') {
        abort(404);
    }

    $latestPublications = Article::query()
        ->with(['writer', 'category', 'status'])
        ->whereHas('status', fn ($query) => $query->where('name', 'published'))
        ->where('id', '!=', $article->id)
        ->latest('updated_at')
        ->take(4)
        ->get();

    return Inertia::render('Publications/Show', [
        'article' => $article,
        'latestPublications' => $latestPublications,
    ]);
})->name('publications.show');

// Main Authenticated Dashboard / Universal Home Feed
Route::get('/dashboard', function () {
    $recentPublications = Article::query()
        ->with(['writer', 'category', 'status'])
        ->whereHas('status', fn ($query) => $query->where('name', 'published'))
        ->latest('updated_at')
        ->take(6)
        ->get();

    return Inertia::render('Dashboard', [
        'recentPublications' => $recentPublications,
    ]);
})->middleware(['auth', 'verified'])->name('dashboard');

// Profile Management & General Authenticated Actions
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // Role Application Submission
    Route::post('/role-requests', [RoleRequestController::class, 'store'])->name('role-requests.store');
});

// ==========================================
// SUPER ADMIN WORKSPACE
// ==========================================
Route::middleware(['auth', 'role:superadmin|super-admin'])->group(function () {
    // Role Requests
    Route::get('/admin/requests', [RoleRequestController::class, 'index'])->name('admin.requests');
    Route::post('/admin/requests/{roleRequest}/approve', [RoleRequestController::class, 'approve'])->name('admin.requests.approve');
    Route::post('/admin/requests/{roleRequest}/reject', [RoleRequestController::class, 'reject'])->name('admin.requests.reject');
    Route::post('/admin/users/{user}/roles/remove', [RoleRequestController::class, 'removeRole'])->name('admin.users.roles.remove');

    // Content Moderation
    Route::get('/admin/content', [AdminContentController::class, 'index'])->name('admin.content');
    Route::put('/admin/articles/{article}', [AdminContentController::class, 'updateArticle'])->name('admin.articles.update');
    Route::delete('/admin/articles/{article}', [AdminContentController::class, 'destroyArticle'])->name('admin.articles.destroy');
    Route::delete('/admin/comments/{comment}', [AdminContentController::class, 'destroyComment'])->name('admin.comments.destroy');
});

// ==========================================
// WRITER WORKSPACE
// ==========================================
Route::middleware(['auth', 'role:writer'])->group(function () {
    Route::get('/writer/dashboard', [WriterController::class, 'dashboard'])->name('writer.dashboard');
    Route::get('/writer/articles/create', [WriterController::class, 'create'])->name('writer.articles.create');
    Route::post('/articles', [WriterController::class, 'store'])->name('articles.store');
    Route::patch('/writer/articles/{article}/cover-image', [WriterController::class, 'updateCoverImage'])->name('writer.articles.cover-image');
    Route::post('/articles/{article}/submit', [WriterController::class, 'submit'])->name('articles.submit');
    Route::put('/articles/{article}/revise', [WriterController::class, 'revise'])->name('articles.revise');
});

// ==========================================
// EDITOR WORKSPACE
// ==========================================
Route::middleware(['auth', 'role:editor'])->group(function () {
    Route::get('/editor/dashboard', [EditorController::class, 'review'])->name('editor.dashboard');
    Route::post('/articles/{article}/revision', [EditorController::class, 'requestRevision'])->name('articles.revision');
    Route::post('/articles/{article}/publish', [EditorController::class, 'publish'])->name('articles.publish');
    Route::patch('/articles/{article}/cover-image', [EditorController::class, 'updateCoverImage'])->name('articles.cover-image');
});

// ==========================================
// STUDENT WORKSPACE
// ==========================================
Route::middleware(['auth', 'role:student'])->group(function () {
    Route::get('/student/dashboard', [StudentController::class, 'studentDashboard'])->name('student.dashboard');
    Route::post('/articles/{article}/comment', [StudentController::class, 'comment'])->name('articles.comment');
});

require __DIR__.'/auth.php';
require __DIR__.'/sample.php';
