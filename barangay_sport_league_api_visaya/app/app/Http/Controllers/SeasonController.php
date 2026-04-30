<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    /**
     * Display a listing of the resource.
     * GET /api/leagues/{id}/seasons
     */
    public function index(Request $request, string $id)
    {
        // Find the league that belongs to the user, then get its seasons
        $league = $request->user()->leagues()->findOrFail($id);
        
        return response()->json($league->seasons);
    }

    /**
     * Store a newly created resource in storage.
     * POST /api/leagues/{id}/seasons
     */
    public function store(Request $request, string $id)
    {
        // Ensure the admin actually owns this league before adding a season
        $league = $request->user()->leagues()->findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'status' => 'in:active,done'
        ]);

        // Create the nested season
        $season = $league->seasons()->create($validated);

        return response()->json($season, 201);
    }

    /**
     * Display the specified resource.
     * GET /api/seasons/{id}
     */
    public function show(Request $request, string $id)
    {
        $season = Season::whereHas('league', function ($query) use ($request) {
            $query->where('user_id', $request->user()->id);
        })->with(['teams', 'games'])->findOrFail($id);
        
        return response()->json($season);
    }

    /**
     * Update the specified resource in storage.
     * PUT /api/seasons/{id}
     */
    public function update(Request $request, string $id)
    {
        $season = Season::whereHas('league', function ($query) use ($request) {
            $query->where('user_id', $request->user()->id);
        })->findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'start_date' => 'sometimes|required|date',
            'end_date' => 'sometimes|required|date',
            'status' => 'sometimes|in:active,done'
        ]);

        $season->update($validated);
        
        return response()->json($season);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, string $id)
    {
        $season = Season::whereHas('league', function ($query) use ($request) {
            $query->where('user_id', $request->user()->id);
        })->findOrFail($id);
        $season->delete();
        
        return response()->json(['message' => 'Season deleted successfully']);
    }
}