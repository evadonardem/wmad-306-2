<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

use App\Models\Project;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ProjectController extends Controller
{
    public function index()
    {
        $projects = auth()->user()
            ->projects()
            ->latest()
            ->paginate(10);

        return Inertia::render('Projects/Index', [
            'projects' => $projects
        ]);
    }

    public function create()
    {
        return Inertia::render('Projects/Create');
    }

    public function store(Request $request)
    {
        auth()->user()->projects()->create(
            $request->validate([
                'name' => 'required',
                'description' => 'nullable',
                'status' => 'required',
                'due_date' => 'nullable|date',
                'progress' => 'required|integer|min:0|max:100'
            ])
        );

        return redirect()->route('projects.index');
    }

    public function show(Project $project)
    {
        return Inertia::render('Projects/Show', [
            'project' => $project
        ]);
    }

    public function edit(Project $project)
    {
        return Inertia::render('Projects/Edit', [
            'project' => $project
        ]);
    }

    public function update(Request $request, Project $project)
    {
        $project->update(
            $request->validate([
                'name' => 'required',
                'description' => 'nullable',
                'status' => 'required',
                'due_date' => 'nullable|date',
                'progress' => 'required|integer|min:0|max:100'
            ])
        );

        return redirect()->route('projects.index');
    }

    public function destroy(Project $project)
    {
        $project->delete();
        return redirect()->route('projects.index');
    }
}
