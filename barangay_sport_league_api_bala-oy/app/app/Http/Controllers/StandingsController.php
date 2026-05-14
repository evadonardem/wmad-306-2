<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StandingsController extends Controller
{
    /**
     * Get team standings for a season.
     */
    public function standings(Season $season, Request $request)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $teams = $season->teams()->with(['homeGames' => function ($query) {
            $query->where('status', 'done')->with('result');
        }, 'awayGames' => function ($query) {
            $query->where('status', 'done')->with('result');
        }])->get();

        $standings = $teams->map(function ($team) {
            $wins = 0;
            $losses = 0;
            $gamesPlayed = 0;

            foreach ($team->homeGames as $game) {
                if ($game->result) {
                    $gamesPlayed++;
                    if ($game->result->home_score > $game->result->away_score) {
                        $wins++;
                    } else {
                        $losses++;
                    }
                }
            }

            foreach ($team->awayGames as $game) {
                if ($game->result) {
                    $gamesPlayed++;
                    if ($game->result->away_score > $game->result->home_score) {
                        $wins++;
                    } else {
                        $losses++;
                    }
                }
            }

            return [
                'id' => $team->id,
                'name' => $team->name,
                'coach' => $team->coach,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $gamesPlayed,
                'record' => "$wins-$losses",
            ];
        })->sortByDesc('wins')->sortBy('losses')->values();

        return response()->json(['data' => $standings], 200);
    }

    /**
     * Get player leaderboard for a season (top 10 by points).
     */
    public function leaderboard(Season $season, Request $request)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $leaderboard = DB::table('player_stats')
            ->join('players', 'player_stats.player_id', '=', 'players.id')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $season->id)
            ->where('games.status', 'done')
            ->select(
                'players.id',
                'players.name',
                'players.position',
                DB::raw('SUM(player_stats.points) as total_points'),
                DB::raw('SUM(player_stats.assists) as total_assists'),
                DB::raw('SUM(player_stats.rebounds) as total_rebounds'),
                DB::raw('SUM(player_stats.fouls) as total_fouls'),
                DB::raw('COUNT(DISTINCT games.id) as games_played')
            )
            ->groupBy('players.id', 'players.name', 'players.position')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json(['data' => $leaderboard], 200);
    }
}
