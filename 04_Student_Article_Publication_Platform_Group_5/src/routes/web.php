<?php

use App\Http\Controllers\WriterController;
use App\Http\Controllers\EditorController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\RoleSwitchController;
use App\Http\Controllers\ArticleMessageController;
use App\Http\Controllers\AdminController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

// Temporary cache clearing route
Route::get('/clear-cache', function () {
    \Artisan::call('config:clear');
    \Artisan::call('route:clear');
    \Artisan::call('cache:clear');
    \Artisan::call('view:clear');
    return 'Cache cleared!';
});

// Debug route to check user roles
Route::get('/debug-roles', function () {
    $user = \Illuminate\Support\Facades\Auth::user();
    if ($user) {
        return response()->json([
            'user_id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'roles' => $user->roles->pluck('name'),
            'has_writer_role' => $user->hasRole('writer'),
            'has_editor_role' => $user->hasRole('editor'),
            'has_student_role' => $user->hasRole('student'),
            'has_admin_role' => $user->hasRole('admin'),
        ]);
    }
    return response()->json(['message' => 'Not authenticated']);
})->middleware('auth');

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

// Writer Routes
Route::middleware(['web', 'auth', 'role:writer'])->prefix('writer')->name('writer.')->group(function () {
    Route::get('/dashboard', [WriterController::class, 'dashboard'])->name('dashboard');
    Route::get('/revision', [WriterController::class, 'revision'])->name('revision');
    Route::get('/test', function () {
        return response()->json(['message' => 'Writer routes working!']);
    });
    Route::get('/articles/create', [WriterController::class, 'create'])->name('articles.create');
    Route::get('/articles/{article}', [WriterController::class, 'view'])->name('articles.view');
    Route::get('/articles/{article}/edit', [WriterController::class, 'edit'])->name('articles.edit');
    Route::get('/articles/{article}/view', [WriterController::class, 'view'])->name('articles.view.detailed');
    Route::post('/articles', [WriterController::class, 'store'])->name('articles.store');
    Route::put('/articles/{article}', [WriterController::class, 'update'])->name('articles.update');
    Route::delete('/articles/{article}', [WriterController::class, 'destroy'])->name('articles.destroy');
    Route::post('/articles/{article}/submit', [WriterController::class, 'submit'])->name('articles.submit');
    Route::put('/articles/{article}/revise', [WriterController::class, 'revise'])->name('articles.revise');
    Route::put('/articles/{article}/resubmit', [WriterController::class, 'resubmit'])->name('articles.resubmit');
});

// Fallback writer route without role middleware for testing
Route::get('/writer-dashboard-test', [WriterController::class, 'dashboard'])->name('writer.dashboard.test')->middleware('auth');

// Editor Routes
Route::middleware(['web', 'auth', 'role:editor'])->prefix('editor')->name('editor.')->group(function () {
    Route::get('/dashboard', [EditorController::class, 'dashboard'])->name('dashboard');
    Route::get('/needs-revision', [EditorController::class, 'needsRevision'])->name('needs-revision');
    Route::get('/articles/{article}/review', [EditorController::class, 'review'])->name('articles.review');
    Route::post('/articles/{article}/revision', [EditorController::class, 'requestRevision'])->name('articles.revision');
    Route::post('/articles/{article}/publish', [EditorController::class, 'publish'])->name('articles.publish');
});

// Admin Routes
Route::middleware(['web', 'auth'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard')->middleware('role:admin');
    Route::get('/users', [AdminController::class, 'users'])->name('users')->middleware('role:admin');
    Route::get('/users/{user}', [AdminController::class, 'userDetail'])->name('users.show')->middleware('role:admin');
    Route::put('/users/{user}/role', [AdminController::class, 'updateUserRole'])->name('users.role.update')->middleware('role:admin');
    Route::delete('/users/{user}', [AdminController::class, 'deleteUser'])->name('users.delete')->middleware('role:admin');
    Route::get('/role-requests', [AdminController::class, 'roleRequests'])->name('role-requests')->middleware('role:admin');
    Route::post('/role-requests/{roleRequest}/approve', [AdminController::class, 'approveRoleRequest'])->name('role-requests.approve')->middleware('role:admin');
    Route::post('/role-requests/{roleRequest}/reject', [AdminController::class, 'rejectRoleRequest'])->name('role-requests.reject')->middleware('role:admin');
});

// Student Routes
Route::middleware(['web', 'auth', 'role:student'])->prefix('student')->name('student.')->group(function () {
    Route::get('/dashboard', [StudentController::class, 'dashboard'])->name('dashboard');
    Route::get('/published-articles', [StudentController::class, 'publishedArticles'])->name('published.articles');
    Route::get('/my-comments', [StudentController::class, 'myComments'])->name('my.comments');
    Route::get('/favorites', [StudentController::class, 'favorites'])->name('favorites');
    Route::get('/role-request', [StudentController::class, 'roleRequest'])->name('role.request');
    Route::get('/articles/{article}', [StudentController::class, 'show'])->name('articles.show');
    Route::post('/articles/{article}/favorite', [StudentController::class, 'toggleFavorite'])->name('articles.favorite');
    Route::post('/articles/{article}/comment', [StudentController::class, 'comment'])->name('articles.comment');
    Route::delete('/comments/{comment}', [StudentController::class, 'deleteComment'])->name('comments.delete');
});

// Role Request Routes (accessible by any authenticated user)
Route::middleware(['web', 'auth'])->group(function () {
    Route::post('/role-requests', [StudentController::class, 'storeRoleRequest'])->name('role-requests.store');
});

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
    
    // Role switching routes
    Route::post('/switch-role/{role}', [RoleSwitchController::class, 'switchRole'])->name('role.switch');

    // Article discussion (editor <-> writer)
    Route::get('/articles/{article}/messages', [ArticleMessageController::class, 'index'])->name('articles.messages.index');
    Route::post('/articles/{article}/messages', [ArticleMessageController::class, 'store'])->name('articles.messages.store');
    
    // Public article view route for editors
    Route::get('/articles/{article}/view', [WriterController::class, 'view'])->name('articles.view');
});

require __DIR__.'/auth.php';

