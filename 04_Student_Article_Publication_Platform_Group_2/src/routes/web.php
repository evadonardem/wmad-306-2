<?php

use App\Http\Controllers\AdminController;
use App\Http\Controllers\EditorController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\WriterController;
use App\Models\Article;
use App\Models\ArticleStatus;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Str;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::get('/articles', function () {
    $publishedStatusId = ArticleStatus::where('name', 'published')->value('id');

    $articles = Article::with([
        'writer:id,name',
        'category:id,name',
    ])
        ->withCount('comments')
        ->where('status_id', $publishedStatusId)
        ->latest()
        ->paginate(9)
        ->through(function ($article) {
            return [
                'id' => $article->id,
                'title' => $article->title,
                'excerpt' => Str::limit(strip_tags($article->content), 220),
                'writer' => $article->writer?->name,
                'category' => $article->category?->name,
                'comments_count' => $article->comments_count,
                'published_at' => $article->updated_at,
            ];
        });

    return Inertia::render('Public/Articles', [
        'articles' => $articles,
    ]);
})->name('public.articles.index');

// Redirect /dashboard to the proper role-based dashboard
Route::get('/dashboard', function () {
    $user = Auth::user();

    if ($user->hasRole('admin')) {
        return redirect()->route('admin.dashboard');
    }

    $roleRoutes = [
        'writer' => 'writer.dashboard',
        'editor' => 'editor.dashboard',
        'student' => 'student.dashboard',
    ];

    $userRoles = $user->getRoleNames()->toArray();
    $availableDashboards = [];

    foreach ($roleRoutes as $role => $routeName) {
        if (in_array($role, $userRoles, true)) {
            $availableDashboards[] = [
                'role' => $role,
                'route' => route($routeName),
            ];
        }
    }

    if (count($availableDashboards) === 1) {
        return redirect()->to($availableDashboards[0]['route']);
    }

    return Inertia::render('Dashboard', [
        'availableDashboards' => $availableDashboards,
    ]);
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead'])
        ->name('notifications.read-all');
    Route::put('/notifications/{notificationId}/read', [NotificationController::class, 'markAsRead'])
        ->name('notifications.read');
});

// Admin routes
Route::middleware(['auth', 'verified', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'index'])->name('admin.dashboard');
    Route::put('/users/{user}/roles', [AdminController::class, 'updateRoles'])->name('admin.users.update-roles');
});

// Writer routes
Route::middleware(['auth', 'verified', 'role:writer'])->prefix('writer')->group(function () {
    Route::get('/dashboard', [WriterController::class, 'index'])->name('writer.dashboard');
    Route::post('/articles', [WriterController::class, 'store'])->name('articles.store');
    Route::get('/articles/{article}/edit', [WriterController::class, 'edit'])->name('articles.edit');
    Route::put('/articles/{article}', [WriterController::class, 'update'])->name('articles.update');
    Route::post('/articles/{article}/submit', [WriterController::class, 'submit'])->name('articles.submit');
    Route::delete('/articles/{article}', [WriterController::class, 'destroy'])->name('articles.destroy');
    Route::get('/search', [WriterController::class, 'search'])->name('search');
});

// Editor routes
Route::middleware(['auth', 'verified', 'role:editor'])->prefix('editor')->group(function () {
    Route::get('/dashboard', [EditorController::class, 'index'])->name('editor.dashboard');
    Route::get('/articles/{article}/review', [EditorController::class, 'review'])->name('articles.review');
    Route::post('/articles/{article}/revision', [EditorController::class, 'requestRevision'])->name('articles.revision');
    Route::post('/articles/{article}/publish', [EditorController::class, 'publish'])->name('articles.publish');
    Route::get('/search', [EditorController::class, 'search'])->name('search');
});

// Student routes
Route::middleware(['auth', 'verified', 'role:student'])->prefix('student')->group(function () {
    Route::get('/dashboard', [StudentController::class, 'index'])->name('student.dashboard');
    Route::get('/articles/{article}', [StudentController::class, 'show'])->name('articles.show');
    Route::post('/articles/{article}/comment', [StudentController::class, 'comment'])->name('articles.comment');
    Route::get('/search', [StudentController::class, 'search'])->name('search');
});

require __DIR__.'/auth.php';
require __DIR__.'/sample.php';
