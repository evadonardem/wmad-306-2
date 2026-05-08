<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\League;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    /**
     * Display a listing of seasons for a specific league.
     */
    public function index(Request $request)
    {
        $request->validate(['league_id' => 'required|exists:leagues,id']);
        
        // Ensure the league belongs to the user before showing seasons
        $league = $request->user()->leagues()->findOrFail($request->league_id);
        
        return response()->json($league->seasons);
    }

    /**
     * Store a newly created season in storage.
     */
    public function store(Request $request)
    {
        $fields = $request->validate([
            'league_id'  => 'required|exists:leagues,id',
            'name'       => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date'   => 'required|date|after:start_date', // Logical validation
            'status'     => 'required|in:active,done'
        ]);
 
        // Ensure the league belongs to the logged-in user
        $league = $request->user()->leagues()->findOrFail($fields['league_id']);

        $season = $league->seasons()->create($fields);

        return response()->json($season, 201);
    }

    /**
     * Display the specified season.
     */
    public function show(Season $season)
    {
        // Load teams and games for this season
        return $season->load(['teams', 'games']);
    }

    /**
     * Update the specified season (e.g., closing a season).
     */
    public function update(Request $request, Season $season)
    {
        $fields = $request->validate([
            'name' => 'sometimes|string|max:255',
            'status' => 'sometimes|in:active,done'
        ]);

        $season->update($fields);

        return response()->json($season);
    }

    /**
     * Remove the specified season.
     */
    public function destroy(Season $season)
    {
        $season->delete();
        return response()->json(null, 204);
    }
}