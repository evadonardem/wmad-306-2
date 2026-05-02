<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);
        
        $teams = $season->teams()->with('players')->get();
        return response()->json($teams);
    }

    public function store(Request $request, $seasonId)
    {
        $request->validate([
            'name' => 'required|string',
            'coach' => 'nullable|string',
        ]);

        $season = Season::findOrFail($seasonId);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);
        
        $team = $season->teams()->create($request->all());
        return response()->json($team, 201);
    }

    public function show(Request $request, $id)
    {
        $team = Team::with('players')->findOrFail($id);
        
        // Verify the team belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($team->season->league_id);
        
        return response()->json($team);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'sometimes|required|string',
            'coach' => 'nullable|string',
        ]);

        $team = Team::findOrFail($id);
        
        // Verify the team belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($team->season->league_id);
        
        $team->update($request->all());
        return response()->json($team);
    }

    public function addPlayer(Request $request, $id)
    {
        $request->validate([
            'player_id' => 'required|exists:players,id',
            'jersey_number' => 'required|integer',
        ]);

        $team = Team::findOrFail($id);
        
        // Verify the team belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($team->season->league_id);
        
        $team->players()->attach($request->player_id, [
            'jersey_number' => $request->jersey_number
        ]);

        $team->load('players');
        return response()->json($team, 201);
    }

    public function removePlayer(Request $request, $id, $playerId)
    {
        $team = Team::findOrFail($id);
        
        // Verify the team belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($team->season->league_id);
        
        $team->players()->detach($playerId);

        return response()->json(null, 204);
    }
}
