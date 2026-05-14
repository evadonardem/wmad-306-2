<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    public function profile(Request $request, int $id): JsonResponse
    {
        $player = Player::query()
            ->whereKey($id)
            ->whereHas('teams.season.league', function ($query) use ($request): void {
                $query->where('user_id', $request->user()->id);
            })
            ->with([
                'teams' => function ($query) use ($request): void {
                    $query->whereHas('season.league', function ($leagueQuery) use ($request): void {
                        $leagueQuery->where('user_id', $request->user()->id);
                    })->with('season');
                },
                'stats' => function ($query) use ($request): void {
                    $query->whereHas('gameResult.game.season.league', function ($leagueQuery) use ($request): void {
                        $leagueQuery->where('user_id', $request->user()->id);
                    })->with(['gameResult.game.homeTeam', 'gameResult.game.awayTeam']);
                },
            ])
            ->first();

        if (! $player) {
            return response()->json([
                'message' => 'Player not found.',
            ], 404);
        }

        $teams = $player->teams->map(function ($team) {
            return [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'season_id' => $team->season?->id,
                'season_name' => $team->season?->name,
                'jersey_number' => $team->pivot->jersey_number,
            ];
        })->values();

        $careerTotals = [
            'games_played' => $player->stats->count(),
            'total_points' => $player->stats->sum('points'),
            'total_assists' => $player->stats->sum('assists'),
            'total_rebounds' => $player->stats->sum('rebounds'),
        ];

        $personalBest = $player->stats
            ->sortByDesc('points')
            ->first();

        return response()->json([
            'player' => [
                'id' => $player->id,
                'name' => $player->name,
                'position' => $player->position,
            ],
            'teams' => $teams,
            'career_totals' => $careerTotals,
            'personal_best_game' => $personalBest ? [
                'game_id' => $personalBest->gameResult?->game?->id,
                'season_id' => $personalBest->gameResult?->game?->season_id,
                'home_team' => $personalBest->gameResult?->game?->homeTeam?->name,
                'away_team' => $personalBest->gameResult?->game?->awayTeam?->name,
                'points' => $personalBest->points,
                'assists' => $personalBest->assists,
                'rebounds' => $personalBest->rebounds,
                'fouls' => $personalBest->fouls,
            ] : null,
        ]);
    }
}
