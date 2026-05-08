<?php

namespace App\Http\Controllers;

use App\Models\Game;
use Illuminate\Http\Request;

class GameController extends Controller
{
    public function index()
    {
        return response()->json(Game::all());
    }

    public function store(Request $request)
    {
        $fields = $request->validate([
            'season_id' => 'required|exists:seasons,id',
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id|different:home_team_id',
            'scheduled_at' => 'required|date',
            'venue' => 'required|string',
        ]);

        $game = Game::create($fields);

        return response()->json($game, 201);
    }

    public function show(Game $game)
    {
        return response()->json($game->load(['season', 'homeTeam', 'awayTeam']));
    }

    public function update(Request $request, Game $game)
    {
        $fields = $request->validate([
            'home_team_score' => 'sometimes|integer|min:0',
            'away_team_score' => 'sometimes|integer|min:0',
            'status' => 'sometimes|in:scheduled,done'
        ]);

        // Automatically set status to done if scores are provided
        if (isset($fields['home_team_score']) || isset($fields['away_team_score'])) {
            $fields['status'] = 'done';
        }

        $game->update($fields);

        return response()->json($game);
    }
}