<?php

namespace App\Http\Controllers;

use App\Models\Project;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProjectController extends Controller
{
    public function index()
    {
        $userId = Auth::id();

        if (! $userId) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $projects = Project::where('user_id', $userId)->get();
        return response()->json(['success' => true, 'data' => $projects]);
    }

    public function store(Request $request)
    {
        $this->authorize('create', Project::class);

        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $data['user_id'] = Auth::id();

        $project = Project::create($data);

        return response()->json(['success' => true, 'data' => $project, 'message' => 'Project created'], 201);
    }

    public function show(Project $project)
    {
        $this->authorize('view', $project);

        return response()->json(['success' => true, 'data' => $project]);
    }

    public function create()
    {
        // Minimal placeholder for resource route compatibility.
        return response()->json(['success' => true, 'data' => null]);
    }

    public function update(Request $request, Project $project)
    {
        $this->authorize('update', $project);

        $data = $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $project->update($data);

        return response()->json(['success' => true, 'data' => $project, 'message' => 'Project updated']);
    }

    public function destroy(Project $project)
    {
        $this->authorize('delete', $project);

        $project->delete();

        return response()->json(['success' => true, 'message' => 'Project deleted']);
    }

    public function edit(Project $project)
    {
        // Minimal placeholder for resource route compatibility.
        return response()->json(['success' => true, 'data' => $project]);
    }
}
