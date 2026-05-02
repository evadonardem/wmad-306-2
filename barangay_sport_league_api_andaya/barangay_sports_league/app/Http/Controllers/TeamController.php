<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Season;
use App\Models\Team;
use App\Models\Player;

class TeamController extends Controller
{
    public function index(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        $teams = $season->teams;
        return response()->json($teams);
    }

    public function store(Request $request, $seasonId)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $season = Season::findOrFail($seasonId);
        $team = $season->teams()->create($request->all());
        return response()->json($team, 201);
    }

    public function show(Request $request, $id)
    {
        $team = Team::with('players')->findOrFail($id);
        return response()->json($team);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $team = Team::findOrFail($id);
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
        $team->players()->attach($request->player_id, ['jersey_number' => $request->jersey_number]);
        
        return response()->json(['message' => 'Player added to team'], 201);
    }

    public function removePlayer(Request $request, $id, $playerId)
    {
        $team = Team::findOrFail($id);
        $team->players()->detach($playerId);
        
        return response()->json(['message' => 'Player removed from team']);
    }
}
