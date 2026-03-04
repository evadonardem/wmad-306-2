<?php

use App\Http\Controllers\EditorController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\WriterController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

/*
|--------------------------------------------------------------------------
| Auth-based dashboard redirect
|--------------------------------------------------------------------------
*/
Route::get('/dashboard', function () {
    $user = auth()->user();
    if ($user->hasRole('writer')) {
        return redirect()->route('writer.dashboard');
    }
    if ($user->hasRole('editor')) {
        return redirect()->route('editor.dashboard');
    }
    if ($user->hasRole('student')) {
        return redirect()->route('student.dashboard');
    }
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

/*
|--------------------------------------------------------------------------
| Profile (Breeze default)
|--------------------------------------------------------------------------
*/
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

/*
|--------------------------------------------------------------------------
| Writer routes
|--------------------------------------------------------------------------
*/
Route::middleware(['auth', 'role:writer'])->prefix('writer')->name('writer.')->group(function () {
    Route::get('/dashboard', [WriterController::class, 'dashboard'])->name('dashboard');
    Route::post('/articles', [WriterController::class, 'store'])->name('articles.store');
    Route::post('/articles/{article}/submit', [WriterController::class, 'submit'])->name('articles.submit');
    Route::patch('/articles/{article}/revise', [WriterController::class, 'revise'])->name('articles.revise');
});

/*
|--------------------------------------------------------------------------
| Editor routes
|--------------------------------------------------------------------------
*/
Route::middleware(['auth', 'role:editor'])->prefix('editor')->name('editor.')->group(function () {
    Route::get('/dashboard', [EditorController::class, 'dashboard'])->name('dashboard');
    Route::get('/articles/{article}/review', [EditorController::class, 'review'])->name('articles.review');
    Route::post('/articles/{article}/revision', [EditorController::class, 'requestRevision'])->name('articles.revision');
    Route::post('/articles/{article}/publish', [EditorController::class, 'publish'])->name('articles.publish');
});

/*
|--------------------------------------------------------------------------
| Student routes
|--------------------------------------------------------------------------
*/
Route::middleware(['auth', 'role:student'])->prefix('student')->name('student.')->group(function () {
    Route::get('/dashboard', [StudentController::class, 'dashboard'])->name('dashboard');
    Route::get('/articles/{article}', [StudentController::class, 'show'])->name('articles.show');
    Route::post('/articles/{article}/comment', [StudentController::class, 'comment'])->name('articles.comment');
});

require __DIR__.'/auth.php';
require __DIR__.'/sample.php';

