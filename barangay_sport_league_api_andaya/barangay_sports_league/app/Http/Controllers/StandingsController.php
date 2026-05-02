<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Season;
use App\Models\Player;
use App\Models\PlayerStat;

class StandingsController extends Controller
{
    public function standings(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        $teams = $season->teams;
        $games = $season->games()->where('status', 'done')->with('result')->get();

        $standings = [];

        foreach ($teams as $team) {
            $wins = 0;
            $losses = 0;
            $gamesPlayed = 0;

            foreach ($games as $game) {
                if ($game->home_team_id === $team->id || $game->away_team_id === $team->id) {
                    $gamesPlayed++;
                    if ($game->home_team_id === $team->id) {
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

            $standings[] = [
                'team' => $team,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $gamesPlayed,
            ];
        }

        usort($standings, function ($a, $b) {
            return $b['wins'] - $a['wins'];
        });

        return response()->json($standings);
    }

    public function leaderboard(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        
        $topPlayers = Player::select('players.id', 'players.name', 'players.position')
            ->join('player_stats', 'players.id', '=', 'player_stats.player_id')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $seasonId)
            ->selectRaw('players.*, SUM(player_stats.points) as total_points')
            ->groupBy('players.id')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($topPlayers);
    }
}
