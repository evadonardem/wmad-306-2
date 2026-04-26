<?php

namespace App\Http\Controllers;

use App\Models\Project;
use App\Models\Task;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    /**
     * Display the dashboard.
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        
        // Get statistics for the authenticated user
        $projectsCount = $user->projects()->count();
        $tasksCount = Task::whereHas('project', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })->count();
        
        $completedTasksCount = Task::whereHas('project', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })->where('status', 'completed')->count();
        
        $pendingTasksCount = Task::whereHas('project', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })->where('status', 'pending')->count();

        // Get upcoming deadlines (tasks with due dates, ordered by due date)
        $upcomingDeadlines = Task::whereHas('project', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->whereNotNull('due_date')
        ->with('project')
        ->orderBy('due_date', 'asc')
        ->limit(10)
        ->get()
        ->map(function ($task) {
            $task->due_date_status = $task->due_date_status;
            return $task;
        });

        return inertia('Dashboard', [
            'auth' => [
                'user' => $user,
            ],
            'projectsCount' => $projectsCount,
            'tasksCount' => $tasksCount,
            'completedTasksCount' => $completedTasksCount,
            'pendingTasksCount' => $pendingTasksCount,
            'upcomingDeadlines' => $upcomingDeadlines,
        ]);
    }
}
