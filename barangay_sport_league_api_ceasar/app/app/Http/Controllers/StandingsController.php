<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Game;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StandingsController extends Controller
{
    public function standings(Season $season)
    {
        $teams = $season->teams;
        
        $standings = [];

        foreach ($teams as $team) {
            $games = Game::where('season_id', $season->id)
                ->where('status', 'done')
                ->where(function ($q) use ($team) {
                    $q->where('home_team_id', $team->id)
                      ->orWhere('away_team_id', $team->id);
                })
                ->with('result')
                ->get();

            $wins = 0;
            $losses = 0;

            foreach ($games as $game) {
                if (!$game->result) continue;

                $isHome = $game->home_team_id == $team->id;
                $homeScore = $game->result->home_score;
                $awayScore = $game->result->away_score;

                if ($isHome) {
                    if ($homeScore > $awayScore) $wins++;
                    else if ($homeScore < $awayScore) $losses++;
                } else {
                    if ($awayScore > $homeScore) $wins++;
                    else if ($awayScore < $homeScore) $losses++;
                }
            }

            $standings[] = [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $wins + $losses,
            ];
        }

        usort($standings, function ($a, $b) {
            if ($a['wins'] == $b['wins']) {
                return $a['losses'] <=> $b['losses'];
            }
            return $b['wins'] <=> $a['wins'];
        });

        return response()->json($standings);
    }

    public function leaderboard(Season $season)
    {
        $stats = PlayerStat::select('player_id', DB::raw('SUM(points) as total_points'))
            ->whereHas('gameResult.game', function ($query) use ($season) {
                $query->where('season_id', $season->id)->where('status', 'done');
            })
            ->groupBy('player_id')
            ->orderByDesc('total_points')
            ->limit(10)
            ->with('player')
            ->get();

        return response()->json($stats);
    }
}
