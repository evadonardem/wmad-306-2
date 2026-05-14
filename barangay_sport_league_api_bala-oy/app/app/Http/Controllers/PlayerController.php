<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    /**
     * Get a player's career profile.
     */
    public function profile(Player $player, Request $request)
    {
        $player->load(['teams.season', 'stats.gameResult.game.homeTeam', 'stats.gameResult.game.awayTeam']);

        $teams = $player->teams->map(function ($team) {
            return [
                'id' => $team->id,
                'name' => $team->name,
                'season' => [
                    'id' => $team->season->id,
                    'name' => $team->season->name,
                ],
                'jersey_number' => $team->pivot->jersey_number,
            ];
        });

        $careerTotals = $player->stats()
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.status', 'done')
            ->selectRaw('SUM(player_stats.points) as total_points, SUM(player_stats.assists) as total_assists, SUM(player_stats.rebounds) as total_rebounds')
            ->first();

        $gamesPlayed = $player->stats()
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.status', 'done')
            ->distinct('game_results.game_id')
            ->count('game_results.game_id');

        $bestStat = $player->stats()
            ->whereHas('gameResult.game', function ($query) {
                $query->where('status', 'done');
            })
            ->with(['gameResult.game.homeTeam', 'gameResult.game.awayTeam'])
            ->orderByDesc('points')
            ->first();

        $bestGame = null;

        if ($bestStat && $bestStat->gameResult && $bestStat->gameResult->game) {
            $game = $bestStat->gameResult->game;
            $bestGame = [
                'game_id' => $game->id,
                'home_team' => $game->homeTeam?->name,
                'away_team' => $game->awayTeam?->name,
                'points' => $bestStat->points,
                'scheduled_at' => $game->scheduled_at,
                'venue' => $game->venue,
            ];
        }

        return response()->json([
            'data' => [
                'id' => $player->id,
                'name' => $player->name,
                'position' => $player->position,
                'birthdate' => $player->birthdate,
                'teams' => $teams,
                'career_totals' => [
                    'games_played' => $gamesPlayed,
                    'total_points' => $careerTotals->total_points ?? 0,
                    'total_assists' => $careerTotals->total_assists ?? 0,
                    'total_rebounds' => $careerTotals->total_rebounds ?? 0,
                ],
                'personal_best_game' => $bestGame,
            ],
        ], 200);
    }
}
