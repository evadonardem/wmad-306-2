<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
    public function index()
    {
        $tasks = Task::all();
        return response()->json(['success' => true, 'data' => $tasks]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'project_id' => 'required|exists:projects,id',
            'title' => 'required|string',
            'description' => 'nullable|string',
            'priority' => 'nullable|string',
            'status' => 'nullable|string',
        ]);

        // Ensure the authenticated user owns the project before creating a task
        $project = Project::findOrFail($data['project_id']);
        // Ensure the authenticated user owns the project (use ProjectPolicy)
        $this->authorize('update', $project);

        $data['project_id'] = $project->getKey();
        $task = Task::create($data);

        return response()->json(['success' => true, 'data' => $task, 'message' => 'Task created'], 201);
    }

    public function show(Task $task)
    {
        $this->authorize('view', $task);

        return response()->json(['success' => true, 'data' => $task]);
    }

    public function create()
    {
        // Minimal placeholder for resource route compatibility.
        return response()->json(['success' => true, 'data' => null]);
    }

    public function update(Request $request, Task $task)
    {
        $this->authorize('update', $task);

        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'priority' => 'nullable|string',
            'status' => 'nullable|string',
        ]);

        $task->update($data);

        return response()->json(['success' => true, 'data' => $task, 'message' => 'Task updated']);
    }

    public function destroy(Task $task)
    {
        $this->authorize('delete', $task);

        $task->delete();

        return response()->json(['success' => true, 'message' => 'Task deleted']);
    }

    public function edit(Task $task)
    {
        // Minimal placeholder for resource route compatibility.
        return response()->json(['success' => true, 'data' => $task]);
    }

    public function toggleStatus(Task $task)
    {
        $this->authorize('update', $task);

        $task->status = ($task->status === 'done') ? 'todo' : 'done';
        $task->save();

        return response()->json(['success' => true, 'data' => $task, 'message' => 'Task status toggled']);
    }
}
