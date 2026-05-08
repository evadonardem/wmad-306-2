<?php

namespace App\Http\Controllers;

use App\Models\Team;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index()
    {
        return Team::all();
    }

    public function store(Request $request)
    {
        $fields = $request->validate([
            'season_id' => 'required|exists:seasons,id',
            'name' => 'required|string',
            'coach' => 'nullable|string'
        ]);

        return Team::create($fields);
    }

    // Task 5.3: Add Player to Team with Pivot Data
    public function addPlayer(Request $request, Team $team)
    {
        $fields = $request->validate([
            'player_id' => 'required|exists:players,id',
            'jersey_number' => 'required|integer|min:0|max:99',
        ]);

        // Attach the player to the team via the pivot table
        $team->players()->attach($fields['player_id'], [
            'jersey_number' => $fields['jersey_number']
        ]);

        return response()->json(['message' => 'Player added to team successfully!'], 200);
    }
}