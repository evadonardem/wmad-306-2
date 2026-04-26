<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

// ensure spatie role middleware alias is available for route groups
// correct namespace for the middleware (singular "Middleware")
Route::aliasMiddleware('role', \Spatie\Permission\Middleware\RoleMiddleware::class);

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::get('/dashboard', function () {
    $user = Auth::user();

    // Redirect based on user role
    if ($user->hasRole('writer')) {
        return redirect()->route('writer.dashboard');
    } elseif ($user->hasRole('editor')) {
        return redirect()->route('editor.dashboard');
    } elseif ($user->hasRole('student')) {
        return redirect()->route('student.dashboard');
    }

    // Fallback default dashboard
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

// application-specific routes

Route::middleware(['auth'])->prefix('writer')->name('writer.')->group(function () {
    Route::get('/dashboard', [\App\Http\Controllers\WriterController::class, 'dashboard'])->name('dashboard');
    Route::post('/articles', [\App\Http\Controllers\WriterController::class, 'store'])->name('articles.store');
    Route::get('/articles/{article}', [\App\Http\Controllers\WriterController::class, 'show'])->name('articles.show');
    Route::get('/articles/{article}/revise', [\App\Http\Controllers\WriterController::class, 'revisePage'])->name('articles.revise.page');
    Route::put('/articles/{article}', [\App\Http\Controllers\WriterController::class, 'update'])->name('articles.update');
    Route::post('/articles/{article}/submit', [\App\Http\Controllers\WriterController::class, 'submit'])->name('articles.submit');
    Route::post('/articles/{article}/revise', [\App\Http\Controllers\WriterController::class, 'revise'])->name('articles.revise');
    Route::post('/upload-image', [\App\Http\Controllers\WriterController::class, 'uploadImage'])->name('upload.image');
});

Route::middleware(['auth'])->prefix('editor')->name('editor.')->group(function () {
    Route::get('/dashboard', [\App\Http\Controllers\EditorController::class, 'dashboard'])->name('dashboard');
    Route::get('/articles/{article}/review', [\App\Http\Controllers\EditorController::class, 'review'])->name('articles.review');
    Route::post('/articles/{article}/revision', [\App\Http\Controllers\EditorController::class, 'requestRevision'])->name('articles.requestRevision');
    Route::post('/articles/{article}/publish', [\App\Http\Controllers\EditorController::class, 'publish'])->name('articles.publish');
});

Route::middleware(['auth','role:student'])->prefix('student')->name('student.')->group(function () {
    Route::get('/dashboard', [\App\Http\Controllers\StudentController::class, 'dashboard'])->name('dashboard');
    Route::post('/articles/{article}/comment', [\App\Http\Controllers\StudentController::class, 'comment'])->name('articles.comment');
});

// Notification routes
Route::middleware(['auth'])->prefix('notifications')->name('notifications.')->group(function () {
    Route::post('/mark-read', [\App\Http\Controllers\NotificationController::class, 'markAsRead'])->name('mark-read');
    Route::post('/mark-all-read', [\App\Http\Controllers\NotificationController::class, 'markAllAsRead'])->name('mark-all-read');
});

require __DIR__.'/auth.php';
require __DIR__.'/sample.php';
