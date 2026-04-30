<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        return response()->json($request->user()->leagues);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sport' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $league = $request->user()->leagues()->create($validated);

        return response()->json($league, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, League $league)
    {
        $league = $request->user()->leagues()->with('seasons')->findOrFail($league->id);
        
        return response()->json($league);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, League $league)
    {
        $league = $request->user()->leagues()->findOrFail($league->id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'sport' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $league->update($validated);

        return response()->json($league);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, League $league)
    {
        $league = $request->user()->leagues()->findOrFail($league->id);
        
        $league->delete();

        return response()->json(['message' => 'League deleted successfully']);
    }
}