<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    public function index()
    {
        return Player::with('teams')->get();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'birthdate' => 'nullable|date',
            'position' => 'nullable|string|max:50',
            'team_id' => 'nullable|exists:teams,id',
            'jersey_number' => 'nullable|string',
        ]);

        $player = Player::create($validated);

        if (!empty($validated['team_id'])) {
            $player->teams()->attach($validated['team_id'], ['jersey_number' => $validated['jersey_number'] ?? null]);
        }

        return response()->json($player->load('teams'), 201);
    }

    public function show(Player $player)
    {
        return $player->load('teams');
    }

    public function update(Request $request, Player $player)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'birthdate' => 'nullable|date',
            'position' => 'nullable|string|max:50',
        ]);

        $player->update($validated);
        return response()->json($player);
    }

    public function destroy(Player $player)
    {
        $player->delete();
        return response()->json(null, 204);
    }

    public function profile(Player $player)
    {
        // Eager load everything to prevent N+1 queries
        $player->load(['teams.season', 'stats.gameResult.game']);

        $teams = $player->teams->map(function ($team) {
            return [
                'team_name' => $team->name,
                'season_name' => $team->season ? $team->season->name : null,
                'jersey_number' => $team->pivot->jersey_number
            ];
        });

        $totalGamesPlayed = $player->stats->count();
        $totalPoints = $player->stats->sum('points');
        $totalAssists = $player->stats->sum('assists');
        $totalRebounds = $player->stats->sum('rebounds');

        $bestStat = $player->stats->sortByDesc('points')->first();
        
        $personalBestGame = null;
        if ($bestStat && $bestStat->gameResult && $bestStat->gameResult->game) {
            $personalBestGame = [
                'game_id' => $bestStat->gameResult->game->id,
                'scheduled_at' => $bestStat->gameResult->game->scheduled_at,
                'points_scored' => $bestStat->points,
            ];
        }

        return response()->json([
            'name' => $player->name,
            'position' => $player->position,
            'teams' => $teams,
            'career_totals' => [
                'games_played' => $totalGamesPlayed,
                'total_points' => $totalPoints,
                'total_assists' => $totalAssists,
                'total_rebounds' => $totalRebounds,
            ],
            'personal_best_game' => $personalBestGame
        ]);
    }
}
