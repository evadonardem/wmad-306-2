<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use App\Models\Player;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $season->teams;
    }

    public function store(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string',
            'coach' => 'required|string',
        ]);

        $team = $season->teams()->create($validated);

        return response()->json($team, 201);
    }

    public function show(Request $request, Team $team)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $team->load('players');
    }

    public function update(Request $request, Team $team)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string',
            'coach' => 'sometimes|required|string',
        ]);

        $team->update($validated);

        return response()->json($team);
    }

    public function addPlayer(Request $request, Team $team)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'player_id' => 'required|exists:players,id',
            'jersey_number' => 'required|integer',
        ]);

        $team->players()->syncWithoutDetaching([
            $validated['player_id'] => ['jersey_number' => $validated['jersey_number']]
        ]);

        return response()->json(['message' => 'Player added to team']);
    }

    public function removePlayer(Request $request, Team $team, Player $player)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team->players()->detach($player->id);

        return response()->json(['message' => 'Player removed from team']);
    }
}
