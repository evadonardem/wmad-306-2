<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class StandingsController extends Controller
{
    /**
     * Team standings: W-L record, sorted by wins.
     * GET /api/seasons/{id}/standings
     */
    public function standings(string $id)
    {
        $season = Season::whereHas('league', function ($query) {
            $query->where('user_id', Auth::id());
        })->with(['teams', 'games' => function($query) {
            $query->where('status', 'done')->with('result');
        }])->findOrFail($id);

        $standings = $season->teams->map(function ($team) use ($season) {
            $wins = 0;
            $losses = 0;

            foreach ($season->games as $game) {
                if (! $game->result) {
                    continue;
                }

                // Check if the team played in this game
                if ($game->home_team_id === $team->id || $game->away_team_id === $team->id) {
                    $isHome = $game->home_team_id === $team->id;
                    $homeScore = $game->result->home_score;
                    $awayScore = $game->result->away_score;

                    // Calculate Win or Loss
                    if ($isHome && $homeScore > $awayScore) {
                        $wins++;
                    } elseif (!$isHome && $awayScore > $homeScore) {
                        $wins++;
                    } else {
                        $losses++;
                    }
                }
            }

            return [
                'team_id' => $team->id,
                'name' => $team->name,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $wins + $losses,
            ];
        });

        // Sort descending by wins and reset the array keys
        $sortedStandings = $standings->sortByDesc('wins')->values();

        return response()->json($sortedStandings);
    }

    /**
     * Top players by total points (top 10).
     * GET /api/seasons/{id}/leaderboard
     */
    public function leaderboard(string $id)
    {
        $leaderboard = DB::table('player_stats')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->join('players', 'player_stats.player_id', '=', 'players.id')
            ->join('seasons', 'games.season_id', '=', 'seasons.id')
            ->join('leagues', 'seasons.league_id', '=', 'leagues.id')
            ->where('games.season_id', $id)
            ->where('games.status', 'done')
            ->where('leagues.user_id', Auth::id())
            ->selectRaw('players.id as player_id, players.name, SUM(player_stats.points) as total_points')
            ->groupBy('players.id', 'players.name')
            ->orderByDesc('total_points')
            ->limit(10) // Top 10 players
            ->get();

        return response()->json($leaderboard);
    }

    /**
     * Season summary stats.
     * GET /api/seasons/{id}/summary
     */
    public function summary(string $id)
    {
        $season = Season::whereHas('league', function ($query) {
            $query->where('user_id', Auth::id());
        })->with(['teams', 'games' => function ($query) {
            $query->with('result');
        }])->findOrFail($id);

        $gamesPlayed = $season->games->where('status', 'done')->count();
        $gamesScheduled = $season->games->where('status', 'scheduled')->count();

        $completedGames = $season->games->where('status', 'done')->filter(function ($game) {
            return $game->result !== null;
        });

        if ($completedGames->isEmpty()) {
            return response()->json([
                'message' => 'No completed games found for this season'
            ], 404);
        }

        $teamPoints = [];
        foreach ($season->teams as $team) {
            $teamPoints[$team->id] = 0;
        }

        $totalPointsScored = 0;
        foreach ($completedGames as $game) {
            $homeScore = $game->result->home_score;
            $awayScore = $game->result->away_score;

            $teamPoints[$game->home_team_id] = ($teamPoints[$game->home_team_id] ?? 0) + $homeScore;
            $teamPoints[$game->away_team_id] = ($teamPoints[$game->away_team_id] ?? 0) + $awayScore;
            $totalPointsScored += $homeScore + $awayScore;
        }

        $topTeamId = null;
        $topTeamPoints = -1;
        foreach ($teamPoints as $teamId => $points) {
            if ($points > $topTeamPoints) {
                $topTeamId = $teamId;
                $topTeamPoints = $points;
            }
        }

        $topTeam = $season->teams->firstWhere('id', $topTeamId);

        return response()->json([
            'season_id' => $season->id,
            'games_played' => $gamesPlayed,
            'games_scheduled' => $gamesScheduled,
            'top_scoring_team' => [
                'team_id' => $topTeam?->id,
                'name' => $topTeam?->name,
                'total_points' => $topTeamPoints,
            ],
            'total_points_scored' => $totalPointsScored,
        ]);
    }
}