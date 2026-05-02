<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Season;
use Illuminate\Http\Request;

class StandingsController extends Controller
{
    public function standings(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);

        // Get completed games with results
        $games = $season->games()
            ->where('status', 'done')
            ->with('result')
            ->get();

        $teams = $season->teams->map(function ($team) use ($games) {
            $wins = 0;
            $losses = 0;
            $gamesPlayed = 0;

            foreach ($games as $game) {
                if ($game->home_team_id == $team->id || $game->away_team_id == $team->id) {
                    $gamesPlayed++;
                    
                    if ($game->home_team_id == $team->id) {
                        if ($game->result->home_score > $game->result->away_score) {
                            $wins++;
                        } else {
                            $losses++;
                        }
                    } else {
                        if ($game->result->away_score > $game->result->home_score) {
                            $wins++;
                        } else {
                            $losses++;
                        }
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
            ];
        });

        // Sort by wins descending
        $standings = $teams->sortByDesc('wins')->values();

        return response()->json($standings);
    }

    public function leaderboard(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);

        // Get top 10 players by total points across all completed games in the season
        $leaderboard = Player::select('players.id', 'players.name', 'players.position')
            ->join('player_stats', 'players.id', '=', 'player_stats.player_id')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $seasonId)
            ->where('games.status', 'done')
            ->selectRaw('players.id, players.name, players.position, SUM(player_stats.points) as total_points')
            ->groupBy('players.id', 'players.name', 'players.position')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($leaderboard);
    }
}
