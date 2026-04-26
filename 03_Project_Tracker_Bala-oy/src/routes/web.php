<?php

use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\TaskController;
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

Route::get('/dashboard', function (Illuminate\Http\Request $request) {
    // Get the current user's stats
    $userId = $request->user()->id;
    
    return Inertia::render('Dashboard', [
        'stats' => [
            'projects' => $request->user()->projects()->count(),
            'total_tasks' => \App\Models\Task::whereHas('project', fn($q) => $q->where('user_id', $userId))->count(),
            'pending_tasks' => \App\Models\Task::whereHas('project', fn($q) => $q->where('user_id', $userId))
                                ->where('status', 'pending')->count(),
            'completed_tasks' => \App\Models\Task::whereHas('project', fn($q) => $q->where('user_id', $userId))
                                ->where('status', 'completed')->count(),
        ]
    ]);
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::resource('projects', ProjectController::class);
    Route::resource('tasks', TaskController::class);
});

require __DIR__.'/auth.php';