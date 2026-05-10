<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\PlayerStat;
use Illuminate\Http\JsonResponse;

class StandingsController extends Controller
{
    /**
     * Calculate and return the win/loss record for all teams in a season.
     */
    public function standings(Season $season): JsonResponse
    {
        // Load only the necessary relations for calculation
        $matches = $season->games()
            ->where('status', 'done')
            ->with('result')
            ->get();

        $table = $season->teams->map(function ($club) use ($matches) {
            // Filter matches where this specific team participated
            $participated = $matches->filter(fn($m) => 
                $m->home_team_id === $club->id || $m->away_team_id === $club->id
            );

            $w = 0;
            $l = 0;

            foreach ($participated as $match) {
                if (!$match->result) continue;

                $isHome = $match->home_team_id === $club->id;
                
                // Determine if the team won based on location
                $won = $isHome 
                    ? $match->result->home_score > $match->result->away_score 
                    : $match->result->away_score > $match->result->home_score;

                $won ? $w++ : $l++;
            }

            return [
                'identity' => $club,
                'stats' => [
                    'w' => $w,
                    'l' => $l,
                    'gp' => $w + $l,
                ]
            ];
        })->sortByDesc('stats.w')->values();

        return response()->json($table);
    }

    /**
     * Retrieve the top 10 scoring players for the season.
     */
    public function leaderboard(Season $season): JsonResponse
    {
        // Use a more descriptive variable for the ranking
        $topPerformers = PlayerStat::query()
            ->selectRaw('player_id, SUM(points) as points_count')
            ->whereRelation('gameResult.game', function ($query) use ($season) {
                $query->where('season_id', $season->id)->where('status', 'done');
            })
            ->with('player:id,name,position')
            ->groupBy('player_id')
            ->orderByDesc('points_count')
            ->limit(10)
            ->get();

        // Format the output differently
        $formatted = $topPerformers->transform(fn($stat) => [
            'athlete' => $stat->player,
            'score'   => (int) $stat->points_count,
        ]);

        return response()->json($formatted);
    }
}