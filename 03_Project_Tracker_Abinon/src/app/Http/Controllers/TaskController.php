<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\Project;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TaskController extends Controller
{
    public function index()
    {
        return Inertia::render('Tasks/index', [
            'tasks' => Task::with('project')->latest()->get()
        ]);
    }

    public function create()
    {
        return Inertia::render('Tasks/Create', [
            'projects' => Project::all()
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'project_id' => 'required|exists:projects,id',
        ]);

        Task::create($validated);

        return redirect()->route('tasks.index')
                         ->with('success', 'Task created.');
    }

    public function edit(Task $task)
    {
        return Inertia::render('Tasks/Edit', [
            'task' => $task,
            'projects' => Project::all()
        ]);
    }

    public function update(Request $request, Task $task)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'project_id' => 'required|exists:projects,id',
            'priority' => 'sometimes|string|in:Low,Medium,High',
        ]);

        $task->update($validated);

        return redirect()->route('tasks.index')
                         ->with('success', 'Task updated.');
    }

    public function destroy(Task $task)
    {
        $task->delete();

        return redirect()->route('tasks.index')
                         ->with('success', 'Task deleted.');
    }
    public function toggleStatus(Task $task)
{
    $task->status = $task->status === 'done' ? 'pending' : 'done';
    $task->save();

    return redirect()->back()->with('success', 'Task status updated.');
}

}
