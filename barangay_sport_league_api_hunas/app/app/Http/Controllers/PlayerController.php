<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class PlayerController extends Controller
{
    /**
     * Retrieve a full roster of players.
     */
    public function index(): JsonResponse
    {
        return response()->json(Player::latest()->get());
    }

    /**
     * Create a new player record.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'      => ['required', 'string', 'max:255'],
            'birthdate' => ['required', 'date'],
            'position'  => ['required', 'string', 'max:100'],
        ]);

        $entry = Player::create($validated);

        return response()->json($entry, 201);
    }

    /**
     * Compile comprehensive player history and career performance.
     */
    public function profile(Player $player): JsonResponse
    {
        // Eager load nested relationships using the 'load' method on the model instance
        $player->load([
            'teams.season.league',
            'stats.gameResult.game',
        ]);

        // Transform team history
        $history = $player->teams->map(function ($team) {
            return [
                'club'   => $team->name,
                'manager' => $team->coach,
                'tier'    => "{$team->season->league->name} - {$team->season->name}",
                'number'  => $team->pivot->jersey_number,
            ];
        });

        // Compute performance metrics
        $records = $player->stats;
        
        $metrics = [
            'appearances' => $records->pluck('game_result_id')->unique()->count(),
            'pts'         => $records->sum('points'),
            'ast'         => $records->sum('assists'),
            'reb'         => $records->sum('rebounds'),
        ];

        // Identify top performance
        $peakPerformance = $records->sortByDesc('points')->first();

        $highlight = $peakPerformance ? [
            'match_id' => $peakPerformance->gameResult->game_id,
            'stats'    => $peakPerformance->only(['points', 'assists', 'rebounds', 'fouls']),
            'date'     => $peakPerformance->gameResult->game->scheduled_at,
        ] : null;

        return response()->json([
            'bio'           => $player->only(['name', 'position']),
            'affiliations'  => $history,
            'career_stats'  => $metrics,
            'career_high'   => $highlight,
        ]);
    }
}