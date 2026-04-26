<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\Writer\ArticleController;
use App\Http\Controllers\Writer\DashboardController;
use App\Http\Controllers\Editor\EditorController;
use App\Http\Controllers\Student\StudentController;
use App\Http\Controllers\GuestController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

/*
|--------------------------------------------------------------------------
| Public Routes (Published Articles Gallery)
|--------------------------------------------------------------------------
*/
Route::get('/', [GuestController::class, 'index'])->name('home');
Route::get('/articles/{article}', [GuestController::class, 'show'])->name('articles.show');

/*
|--------------------------------------------------------------------------
| Authenticated & Verified Routes
|--------------------------------------------------------------------------
*/
Route::middleware(['auth', 'verified'])->group(function () {
    
    // REDIRECT / DASHBOARD 
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Profile Management
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    /*
    |--------------------------------------------------------------------------
    | Writer Routes
    |--------------------------------------------------------------------------
    */
    Route::prefix('writer')->name('writer.')->group(function () {
        Route::get('/articles/create', [ArticleController::class, 'create'])->name('articles.create');
        Route::post('/articles', [ArticleController::class, 'store'])->name('articles.store');
        Route::get('/articles/{article}/edit', [ArticleController::class, 'edit'])->name('articles.edit');
        Route::patch('/articles/{article}', [ArticleController::class, 'update'])->name('articles.update');
        Route::delete('/articles/{article}', [ArticleController::class, 'destroy'])->name('articles.destroy');
        Route::post('/articles/{article}/submit', [ArticleController::class, 'submit'])->name('articles.submit');
    });

    /*
    |--------------------------------------------------------------------------
    | Editor Routes
    |--------------------------------------------------------------------------
    */
    Route::prefix('editor')->name('editor.')->group(function () {
        Route::get('/dashboard', [EditorController::class, 'index'])->name('dashboard');
        Route::post('/articles/{article}/approve', [EditorController::class, 'approve'])->name('articles.approve');
        Route::post('/articles/{article}/reject', [EditorController::class, 'reject'])->name('articles.reject');
        Route::delete('/articles/{article}', [EditorController::class, 'destroy'])->name('articles.destroy');
    });

    /*
    |--------------------------------------------------------------------------
    | Student Routes
    |--------------------------------------------------------------------------
    */
    // FIX: Using the '|' operator allows both 'Student' and 'student'
    Route::middleware(['role:Student|student'])->group(function () {
        Route::get('/student/dashboard', [StudentController::class, 'index'])->name('student.dashboard');
    });
});

require __DIR__.'/auth.php';