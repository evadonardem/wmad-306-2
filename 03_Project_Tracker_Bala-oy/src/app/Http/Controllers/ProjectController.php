<?php

namespace App\Http\Controllers;

use App\Models\Project;
use Illuminate\Http\Request;
use Inertia\Inertia;
// Removed AuthorizesRequests trait to use manual checks for immediate fix
class ProjectController extends Controller
{
    public function index(Request $request) {
        return Inertia::render('Projects/Index', [
            'projects' => Project::where('user_id', $request->user()->id)->get()
        ]);
    }

    public function create() { 
        return Inertia::render('Projects/Create'); 
    }
    
    public function store(Request $request) {
        $validated = $request->validate([
            'title' => 'required|string',
            'description' => 'required'
        ]);

        $request->user()->projects()->create($validated);
        return redirect()->route('projects.index');
    }
    
    public function edit(Request $request, Project $project) {
        // MANUAL FIX: Check if the project belongs to the current user
        if ($project->user_id !== $request->user()->id) {
            abort(403);
        }

        return Inertia::render('Projects/Edit', ['project' => $project]);
    }
    
    public function update(Request $request, Project $project) {
        // MANUAL FIX: Check if the project belongs to the current user
        if ($project->user_id !== $request->user()->id) {
            abort(403);
        }

        $validated = $request->validate([
            'title' => 'required',
            'description' => 'required'
        ]);

        $project->update($validated);
        return redirect()->route('projects.index');
    }
    
    public function destroy(Request $request, Project $project) {
        // MANUAL FIX: Check if the project belongs to the current user
        if ($project->user_id !== $request->user()->id) {
            abort(403);
        }

        $project->delete();
        return redirect()->route('projects.index');
    }
}