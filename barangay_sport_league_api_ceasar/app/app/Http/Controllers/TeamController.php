<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use App\Models\Player;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Season $season)
    {
        return $season->teams()->with('players')->get();
    }

    public function store(Request $request, Season $season)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $team = $season->teams()->create($validated);
        return response()->json($team, 201);
    }

    public function show(Team $team)
    {
        return $team->load(['players']);
    }

    public function update(Request $request, Team $team)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $team->update($validated);
        return response()->json($team);
    }

    public function destroy(Team $team)
    {
        $team->delete();
        return response()->json(null, 204);
    }

    public function addPlayer(Request $request, Team $team)
    {
        $validated = $request->validate([
            'player_id' => 'required|exists:players,id',
            'jersey_number' => 'nullable|string',
        ]);

        if ($team->players()->where('player_id', $validated['player_id'])->exists()) {
            return response()->json(['message' => 'Player already on this team.'], 422);
        }

        $team->players()->attach($validated['player_id'], ['jersey_number' => $validated['jersey_number'] ?? null]);
        return response()->json(['message' => 'Player added to team successfully']);
    }

    public function removePlayer(Team $team, Player $player)
    {
        $team->players()->detach($player->id);
        return response()->json(['message' => 'Player removed from team successfully']);
    }
}
