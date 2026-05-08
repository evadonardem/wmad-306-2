<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlayerController extends Controller
{
    /**
     * Exercise 3: Player Profile Endpoint.
     */
    public function profile(Request $request, Player $player)
    {
        // career totals
        $careerTotals = PlayerStat::where('player_id', $player->id)
            ->select(
                DB::raw('COUNT(*) as total_games'),
                DB::raw('SUM(points) as total_points'),
                DB::raw('SUM(assists) as total_assists'),
                DB::raw('SUM(rebounds) as total_rebounds')
            )
            ->first();

        // personal best (most points in a single game)
        $personalBest = PlayerStat::where('player_id', $player->id)
            ->orderByDesc('points')
            ->first();

        // list of teams played for
        $teams = $player->teams()->with('season')->get()->map(function ($team) {
            return [
                'team_name' => $team->name,
                'season_name' => $team->season->name,
                'jersey_number' => $team->pivot->jersey_number,
            ];
        });

        return response()->json([
            'name' => $player->name,
            'position' => $player->position,
            'career_totals' => [
                'total_games_played' => (int) $careerTotals->total_games,
                'total_points' => (int) $careerTotals->total_points,
                'total_assists' => (int) $careerTotals->total_assists,
                'total_rebounds' => (int) $careerTotals->total_rebounds,
            ],
            'personal_best' => $personalBest ? [
                'points' => $personalBest->points,
                'game_id' => $personalBest->gameResult->game_id,
            ] : null,
            'teams_history' => $teams,
        ]);
    }
}
