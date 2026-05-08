<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function attachPlayer(Request $request, Team $team): JsonResponse
    {
        $data = $request->validate([
            'player_id' => ['required', 'integer', 'exists:players,id'],
            'jersey_number' => ['required', 'integer', 'min:0'],
        ]);

        $team->players()->syncWithoutDetaching([
            $data['player_id'] => ['jersey_number' => $data['jersey_number']],
        ]);

        return response()->json(['message' => 'Player attached to team.']);
    }

    public function detachPlayer(Team $team, Player $player): JsonResponse
    {
        $team->players()->detach($player->id);

        return response()->json(['message' => 'Player detached from team.']);
    }
}
