<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Models\Task;
use Inertia\Inertia;
use Illuminate\Http\Request;

class TaskController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $this->authorize('viewAny', Task::class);

        // Eager load relationships to prevent N+1 problems
        $tasks = Task::whereHas('project', function ($q) use ($request) {
            $q->where('user_id', auth()->id());
        })->with('project')->latest()->get();

        $projects = auth()->user()->projects()->get();

        if ($request->wantsJson()) {
            return response()->json($tasks);
        }

        return Inertia::render('Tasks/Index', [
            'tasks' => $tasks,
            'projects' => $projects,
        ]);
    }

    /**
     * Toggle task status
     */
    public function toggleStatus(Request $request, Task $task)
    {
        $this->authorize('update', $task);

        // Cycle through statuses: pending -> on going -> completed -> pending
        $statuses = ['pending', 'on going', 'completed'];
        $currentIndex = array_search($task->status, $statuses);
        $nextIndex = ($currentIndex + 1) % count($statuses);
        $nextStatus = $statuses[$nextIndex];

        $task->update(['status' => $nextStatus]);

        if ($request->wantsJson()) {
            return response()->json($task);
        }

        return redirect()->route('tasks.index')->with('success', 'Task status updated');
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(Request $request)
    {
        $this->authorize('create', Task::class);

        $projects = auth()->user()->projects()->get();

        return Inertia::render('Tasks/Create', [
            'projects' => $projects,
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreTaskRequest $request)
    {
        $this->authorize('create', Task::class);

        $data = $request->validated();

        // Ensure project belongs to current user
        $project = auth()->user()->projects()->find($data['project_id']);
        if (! $project) {
            abort(403);
        }

        $task = $project->tasks()->create($data);

        if ($request->wantsJson()) {
            return response()->json($task, 201);
        }

        // Return to tasks index with success message
        return redirect()->route('tasks.index')->with('success', 'Task successfully saved');
    }

    /**
     * Display the specified resource.
     */
    public function show(Task $task)
    {
        $this->authorize('view', $task);

        if (request()->wantsJson()) {
            return response()->json($task->load('project'));
        }

        return Inertia::render('Tasks/Show', [
            'task' => $task->load('project'),
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Task $task)
    {
        $this->authorize('update', $task);

        $projects = auth()->user()->projects()->get();

        return Inertia::render('Tasks/Edit', [
            'task' => $task,
            'projects' => $projects,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateTaskRequest $request, Task $task)
    {
        $this->authorize('update', $task);

        $task->update($request->validated());

        if ($request->wantsJson()) {
            return response()->json($task);
        }

        // Return to tasks index with success message
        return redirect()->route('tasks.index')->with('success', 'Task successfully updated');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, Task $task)
    {
        $this->authorize('delete', $task);

        $task->delete();

        if ($request->wantsJson()) {
            return response()->noContent();
        }

        return redirect()->route('tasks.index')->with('success', 'Task deleted successfully');
    }
}
