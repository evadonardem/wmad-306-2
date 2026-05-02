<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\PlayerStat;
use Illuminate\Http\Request;

class PlayerStatController extends Controller
{
    public function store(Request $request, Game $game)
    {
        // REQUIREMENT: Check if game is done
        if ($game->status !== 'done') {
            return response()->json(['message' => 'Player stats can only be submitted for finished games.'], 422);
        }

        $fields = $request->validate([
            'player_id' => 'required|exists:players,id',
            'points' => 'required|integer|min:0',
        ]);

        $stat = PlayerStat::updateOrCreate(
            ['game_id' => $game->id, 'player_id' => $fields['player_id']],
            ['points' => $fields['points']]
        );

        return response()->json($stat, 201);
    }
}