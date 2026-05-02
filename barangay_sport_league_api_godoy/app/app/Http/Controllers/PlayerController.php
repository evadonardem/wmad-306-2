<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    public function profile(Request $request, $id)
    {
        $player = Player::with([
            'teams.season.league',
            'stats.gameResult.game'
        ])->find($id);

        if (!$player) {
            return response()->json(['message' => 'Player not found'], 404);
        }

        // Build teams list with season name and jersey number
        $teams = $player->teams->map(function ($team) {
            return [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'season_name' => $team->season->name,
                'jersey_number' => $team->pivot->jersey_number,
            ];
        });

        // Calculate career totals
        $careerTotals = [
            'total_games_played' => 0,
            'total_points' => 0,
            'total_assists' => 0,
            'total_rebounds' => 0,
        ];

        $personalBest = null;
        $maxPoints = 0;

        foreach ($player->stats as $stat) {
            $careerTotals['total_games_played']++;
            $careerTotals['total_points'] += $stat->points;
            $careerTotals['total_assists'] += $stat->assists;
            $careerTotals['total_rebounds'] += $stat->rebounds;

            // Track personal best game
            if ($stat->points > $maxPoints) {
                $maxPoints = $stat->points;
                $personalBest = [
                    'game_id' => $stat->gameResult->game->id,
                    'points' => $stat->points,
                    'assists' => $stat->assists,
                    'rebounds' => $stat->rebounds,
                    'scheduled_at' => $stat->gameResult->game->scheduled_at,
                ];
            }
        }

        return response()->json([
            'id' => $player->id,
            'name' => $player->name,
            'position' => $player->position,
            'birthdate' => $player->birthdate,
            'teams' => $teams,
            'career_totals' => $careerTotals,
            'personal_best_game' => $personalBest,
        ]);
    }
}
