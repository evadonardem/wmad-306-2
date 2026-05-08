<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StandingsController extends Controller
{
    // GET /api/seasons/{season}/standings
    public function standings(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $teams = $season->teams()->get();

        // Only look at completed games
        $games = $season->games()
                    ->where('status', 'done')
                    ->with('result')
                    ->get();

        $standings = $teams->map(function ($team) use ($games) {
            $wins = 0;
            $losses = 0;

            foreach ($games as $game) {
                $isHome = $game->home_team_id === $team->id;
                $isAway = $game->away_team_id === $team->id;

                if (! $isHome && ! $isAway) continue;
                if (! $game->result) continue;

                $homeScore = $game->result->home_score;
                $awayScore = $game->result->away_score;

                if ($isHome) {
                    $homeScore > $awayScore ? $wins++ : $losses++;
                } else {
                    $awayScore > $homeScore ? $wins++ : $losses++;
                }
            }

            return [
                'team'         => $team->name,
                'wins'         => $wins,
                'losses'       => $losses,
                'games_played' => $wins + $losses,
            ];
        });

        // Sort by wins descending
        $sorted = $standings->sortByDesc('wins')->values();

        return response()->json($sorted);
    }

    // GET /api/seasons/{season}/leaderboard
    public function leaderboard(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // Top 10 players by total points in this season
        $leaders = DB::table('player_stats')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->join('players', 'player_stats.player_id', '=', 'players.id')
            ->where('games.season_id', $season->id)
            ->where('games.status', 'done')
            ->groupBy('player_stats.player_id', 'players.name')
            ->selectRaw('players.name, SUM(player_stats.points) as total_points')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($leaders);
    }
}