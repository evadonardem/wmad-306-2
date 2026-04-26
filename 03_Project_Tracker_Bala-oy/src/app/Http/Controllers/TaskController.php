<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\Project;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        $query = Task::whereHas('project', function ($q) use ($request) {
            $q->where('user_id', $request->user()->id);
        });

        if ($request->project_id) {
            $query->where('project_id', $request->project_id);
        }

        return Inertia::render('Tasks/Index', [
            'tasks' => $query->with('project')->get(),
            'projects' => Project::where('user_id', $request->user()->id)->get(),
            'filters' => $request->only(['project_id'])
        ]);
    }

    public function create(Request $request)
    {
        return Inertia::render('Tasks/Create', [
            'projects' => Project::where('user_id', $request->user()->id)->get()
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'priority' => 'required|in:low,medium,high',
            'project_id' => 'required|exists:projects,id',
        ]);

        $project = Project::findOrFail($validated['project_id']);
        if ($project->user_id !== $request->user()->id) {
            abort(403);
        }

        // Default status to 0 (pending) on creation
        $validated['status'] = 0;

        Task::create($validated);
        return redirect()->route('tasks.index');
    }

    public function edit(Request $request, Task $task)
    {
        // Load the project relationship to ensure the check works
        $task->load('project');

        if ($task->project->user_id !== $request->user()->id) {
            abort(403);
        }

        return Inertia::render('Tasks/Edit', [
            'task' => $task,
            'projects' => Project::where('user_id', $request->user()->id)->get()
        ]);
    }

    public function update(Request $request, Task $task)
    {
        // 1. IMPORTANT: Load project to prevent 'null' property errors
        $task->load('project');

        // 2. Security Check
        if ($task->project->user_id !== $request->user()->id) {
            abort(403);
        }

        // 3. Validation
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'priority' => 'required|in:low,medium,high',
            'status' => 'required', // Accept whatever string/bool comes from React
            'project_id' => 'required|exists:projects,id',
        ]);

        // 4. THE FIX: Strict conversion to integer to prevent QueryException
        // This ensures 'pending' becomes 0 and 'completed' becomes 1
        $validated['status'] = ($request->status === 'completed' || $request->status === 1 || $request->status === true) ? 1 : 0;

        // 5. Save and Redirect
        $task->update($validated);
        
        // Use route() to ensure correct redirection after saving
        return redirect()->route('tasks.index');
    }

    public function destroy(Request $request, Task $task)
    {
        $task->load('project');
        
        if ($task->project->user_id !== $request->user()->id) {
            abort(403);
        }
        
        $task->delete();
        return redirect()->back();
    }
}