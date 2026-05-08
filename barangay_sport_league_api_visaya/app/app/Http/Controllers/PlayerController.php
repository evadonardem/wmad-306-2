<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class PlayerController extends Controller
{
    /**
     * Player career profile.
     * GET /api/players/{id}/profile
     */
    public function profile(string $id)
    {
        $player = Player::query()
            ->where('id', $id)
            ->whereHas('teams.season.league', function ($query) {
                $query->where('user_id', Auth::id());
            })
            ->with([
                'teams' => function ($query) {
                    $query->whereHas('season.league', function ($leagueQuery) {
                        $leagueQuery->where('user_id', Auth::id());
                    })->with('season:id,name');
                },
            ])
            ->first();

        if (! $player) {
            return response()->json(['message' => 'Player not found'], 404);
        }

        $totals = DB::table('player_stats')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->join('seasons', 'games.season_id', '=', 'seasons.id')
            ->join('leagues', 'seasons.league_id', '=', 'leagues.id')
            ->where('player_stats.player_id', $player->id)
            ->where('leagues.user_id', Auth::id())
            ->selectRaw('COUNT(DISTINCT games.id) as total_games_played, SUM(player_stats.points) as total_points, SUM(player_stats.assists) as total_assists, SUM(player_stats.rebounds) as total_rebounds')
            ->first();

        $personalBest = DB::table('player_stats')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->join('seasons', 'games.season_id', '=', 'seasons.id')
            ->join('leagues', 'seasons.league_id', '=', 'leagues.id')
            ->where('player_stats.player_id', $player->id)
            ->where('leagues.user_id', Auth::id())
            ->select([
                'games.id as game_id',
                'games.season_id',
                'games.home_team_id',
                'games.away_team_id',
                'games.scheduled_at',
                'player_stats.points',
            ])
            ->orderByDesc('player_stats.points')
            ->first();

        $teams = $player->teams->map(function ($team) {
            return [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'season_name' => $team->season?->name,
                'jersey_number' => $team->pivot?->jersey_number,
            ];
        })->values();

        return response()->json([
            'player' => [
                'id' => $player->id,
                'name' => $player->name,
                'position' => $player->position,
            ],
            'teams' => $teams,
            'career_totals' => [
                'total_games_played' => (int) ($totals->total_games_played ?? 0),
                'total_points' => (int) ($totals->total_points ?? 0),
                'total_assists' => (int) ($totals->total_assists ?? 0),
                'total_rebounds' => (int) ($totals->total_rebounds ?? 0),
            ],
            'personal_best_game' => $personalBest ? [
                'game_id' => $personalBest->game_id,
                'season_id' => $personalBest->season_id,
                'home_team_id' => $personalBest->home_team_id,
                'away_team_id' => $personalBest->away_team_id,
                'scheduled_at' => $personalBest->scheduled_at,
                'points' => (int) $personalBest->points,
            ] : null,
        ]);
    }
}
