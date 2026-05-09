<?php

namespace App\Http\Controllers;

use App\Models\PlayerStat;
use App\Models\Season;

class StandingsController extends Controller
{
    // GET /api/seasons/{id}/standings
    public function standings($seasonId)
    {
        $season = Season::with('teams')->findOrFail($seasonId);

        $completedGames = $season->games()
                                 ->where('status', 'done')
                                 ->with('result')
                                 ->get();

        $standings = $season->teams->map(function ($team) use ($completedGames) {
            $wins   = 0;
            $losses = 0;

            foreach ($completedGames as $game) {
                if (! $game->result) continue;

                $isHome = $game->home_team_id === $team->id;
                $isAway = $game->away_team_id === $team->id;

                if (! $isHome && ! $isAway) continue;

                $myScore  = $isHome ? $game->result->home_score : $game->result->away_score;
                $oppScore = $isHome ? $game->result->away_score : $game->result->home_score;

                $myScore > $oppScore ? $wins++ : $losses++;
            }

            return [
                'team'         => $team,
                'wins'         => $wins,
                'losses'       => $losses,
                'games_played' => $wins + $losses,
            ];
        })->sortByDesc('wins')->values();

        return response()->json($standings);
    }

    // GET /api/seasons/{id}/leaderboard
    public function leaderboard($seasonId)
    {
        Season::findOrFail($seasonId); // 404 guard

        $leaders = PlayerStat::selectRaw('player_id, SUM(points) as total_points')
            ->whereHas('gameResult.game', fn($q) =>
                $q->where('season_id', $seasonId)->where('status', 'done')
            )
            ->with('player:id,name,position')
            ->groupBy('player_id')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get()
            ->map(fn($s) => [
                'player'       => $s->player,
                'total_points' => (int) $s->total_points,
            ]);

        return response()->json($leaders);
    }
}