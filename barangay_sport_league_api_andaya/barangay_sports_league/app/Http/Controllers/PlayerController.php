<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Player;
use App\Models\PlayerStat;

class PlayerController extends Controller
{
    public function profile(Request $request, $id)
    {
        $player = Player::with([
            'teams' => function ($query) {
                $query->with('season');
            }
        ])->find($id);

        if (!$player) {
            return response()->json(['message' => 'Player not found'], 404);
        }

        $teamsWithSeasons = $player->teams->map(function ($team) {
            return [
                'team' => $team,
                'season_name' => $team->season->name,
                'jersey_number' => $team->pivot->jersey_number,
            ];
        });

        $stats = PlayerStat::whereHas('gameResult.game')
            ->where('player_id', $player->id)
            ->get();

        $careerTotals = [
            'total_games_played' => $stats->count(),
            'total_points' => $stats->sum('points'),
            'total_assists' => $stats->sum('assists'),
            'total_rebounds' => $stats->sum('rebounds'),
        ];

        $personalBestGame = PlayerStat::whereHas('gameResult.game')
            ->where('player_id', $player->id)
            ->with('gameResult.game.homeTeam', 'gameResult.game.awayTeam')
            ->orderByDesc('points')
            ->first();

        return response()->json([
            'player' => [
                'name' => $player->name,
                'position' => $player->position,
            ],
            'teams' => $teamsWithSeasons,
            'career_totals' => $careerTotals,
            'personal_best_game' => $personalBestGame,
        ]);
    }
}
