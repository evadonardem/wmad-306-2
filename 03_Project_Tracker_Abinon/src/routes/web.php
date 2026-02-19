<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use App\Http\Controllers\ProjectController;
use App\Http\Controllers\TaskController;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;

Route::get('/test-hierarchy', function () {
    $user = User::with('projects.tasks')->first();

    return response()->json($user);
});

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'canLogin' => Route::has('login'),
        'canRegister' => Route::has('register'),
        'laravelVersion' => Application::VERSION,
        'phpVersion' => PHP_VERSION,
    ]);
});

Route::get('/dashboard', function () {
    $user = auth()->user();
    $projects = $user->projects()->count();
    $total_tasks = $user->projects()->withCount('tasks')->get()->sum('tasks_count');
    $completed_tasks = Task::whereHas('project', function($q) use ($user) {
        $q->where('user_id', $user->id);
    })->where('status', 'done')->count();
    $pending_tasks = $total_tasks - $completed_tasks;

    return Inertia::render('Dashboard', [
        'stats' => [
            'projects' => $projects,
            'total_tasks' => $total_tasks,
            'pending_tasks' => $pending_tasks,
            'completed_tasks' => $completed_tasks,
        ]
    ]);
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
    Route::resource('projects', ProjectController::class);
    Route::resource('tasks', TaskController::class);
    Route::post('/tasks/{task}/toggle-status', [TaskController::class, 'toggleStatus'])
     ->name('tasks.toggleStatus');

});

require __DIR__.'/auth.php';
