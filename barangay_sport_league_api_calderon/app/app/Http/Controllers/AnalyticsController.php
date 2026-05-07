<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    /**
     * Team standings: W-L record, sorted by wins.
     */
    public function standings(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $teams = $season->teams;
        $games = $season->games()->where('status', 'done')->with('result')->get();

        $standings = $teams->map(function ($team) use ($games) {
            $wins = 0;
            $losses = 0;
            $played = 0;

            foreach ($games as $game) {
                if ($game->home_team_id == $team->id) {
                    $played++;
                    if ($game->result->home_score > $game->result->away_score) {
                        $wins++;
                    } else if ($game->result->home_score < $game->result->away_score) {
                        $losses++;
                    }
                } else if ($game->away_team_id == $team->id) {
                    $played++;
                    if ($game->result->away_score > $game->result->home_score) {
                        $wins++;
                    } else if ($game->result->away_score < $game->result->home_score) {
                        $losses++;
                    }
                }
            }

            return [
                'id' => $team->id,
                'name' => $team->name,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $played,
            ];
        })->sortByDesc('wins')->values();

        return response()->json($standings);
    }

    /**
     * Top players by total points (top 10).
     */
    public function leaderboard(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $leaderboard = PlayerStat::whereHas('gameResult.game', function ($query) use ($season) {
            $query->where('season_id', $season->id);
        })
        ->with('player')
        ->select('player_id', DB::raw('SUM(points) as total_points'))
        ->groupBy('player_id')
        ->orderByDesc('total_points')
        ->limit(10)
        ->get()
        ->map(function ($stat) {
            return [
                'player_id' => $stat->player_id,
                'name' => $stat->player->name,
                'total_points' => (int) $stat->total_points,
            ];
        });

        return response()->json($leaderboard);
    }

    /**
     * Exercise 1: Season Summary Stats.
     */
    public function summary(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $totalGamesPlayed = $season->games()->where('status', 'done')->count();
        $totalGamesScheduled = $season->games()->where('status', 'scheduled')->count();

        $allResults = $season->games()->where('status', 'done')->with('result')->get();
        $totalPointsScored = $allResults->sum(function ($game) {
            return $game->result->home_score + $game->result->away_score;
        });

        // Top scoring team
        $teamPoints = [];
        foreach ($allResults as $game) {
            $teamPoints[$game->home_team_id] = ($teamPoints[$game->home_team_id] ?? 0) + $game->result->home_score;
            $teamPoints[$game->away_team_id] = ($teamPoints[$game->away_team_id] ?? 0) + $game->result->away_score;
        }

        $topScoringTeam = null;
        if (!empty($teamPoints)) {
            arsort($teamPoints);
            $topTeamId = key($teamPoints);
            $topTeam = Team::find($topTeamId);
            $topScoringTeam = [
                'name' => $topTeam->name,
                'total_points' => $teamPoints[$topTeamId]
            ];
        }

        return response()->json([
            'total_games_played' => $totalGamesPlayed,
            'total_games_scheduled' => $totalGamesScheduled,
            'total_points_scored' => $totalPointsScored,
            'top_scoring_team' => $topScoringTeam,
        ]);
    }
}
