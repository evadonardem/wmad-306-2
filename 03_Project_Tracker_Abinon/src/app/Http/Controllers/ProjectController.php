<?php

namespace App\Http\Controllers;


use Illuminate\Http\Request;
use App\Models\Project;
use Inertia\Inertia;
use Illuminate\Support\Facades\Auth;

class ProjectController extends Controller
{
    public function index()
    {
        return Inertia::render('Projects/index', [
            'projects' => Project::with('tasks')->latest()->get()
        ]);
    }

    public function create()
    {
        return Inertia::render('Projects/create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $validated['user_id'] = Auth::user()->id;

        Project::create($validated);

        return redirect()->route('projects.index')
                         ->with('success', 'Project created.');
    }

    public function edit(Project $project)
    {
        return Inertia::render('Projects/edit', [
            'project' => $project
        ]);
    }

    public function update(Request $request, Project $project)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $project->update($validated);

        return redirect()->route('projects.index')
                         ->with('success', 'Project updated.');
    }

    public function destroy(Project $project)
    {
        $project->delete();

        return redirect()->route('projects.index')
                         ->with('success', 'Project deleted.');
    }
}