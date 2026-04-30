<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(
            Player::with('teams.season')->latest()->get()
        );
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'birthdate' => ['required', 'date'],
            'position' => ['required', 'string', 'max:255'],
        ]);

        $player = Player::create($data);

        return response()->json($player, 201);
    }

    public function show(int $id): JsonResponse
    {
        $player = Player::with(['teams.season', 'stats.gameResult.game'])->findOrFail($id);

        $gamesPlayed = $player->stats
            ->filter(fn ($stat) => $stat->gameResult && $stat->gameResult->game && $stat->gameResult->game->status === 'done')
            ->pluck('game_result_id')
            ->unique()
            ->count();

        $best = $player->stats
            ->sortByDesc('points')
            ->first();

        return response()->json([
            'player' => [
                'id' => $player->id,
                'name' => $player->name,
                'position' => $player->position,
            ],
            'teams' => $player->teams->map(fn ($team) => [
                'team_name' => $team->name,
                'season_name' => $team->season?->name,
                'jersey_number' => $team->pivot->jersey_number,
            ])->values(),
            'career_totals' => [
                'games_played' => $gamesPlayed,
                'points' => $player->stats->sum('points'),
                'assists' => $player->stats->sum('assists'),
                'rebounds' => $player->stats->sum('rebounds'),
            ],
            'personal_best_game' => $best ? [
                'game_id' => $best->gameResult?->game_id,
                'points' => $best->points,
            ] : null,
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $player = Player::findOrFail($id);
        $player->delete();

        return response()->json([
            'message' => 'Player deleted successfully.',
        ]);
    }

    public function profile(int $id): JsonResponse
    {
        return $this->show($id);
    }
}
