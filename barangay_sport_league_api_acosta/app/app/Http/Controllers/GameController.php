<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class GameController extends Controller
{
    public function index(League $league, Season $season): JsonResponse
    {
        $this->authorize('view', $league);
        $games = $season->games()
            ->with(['homeTeam', 'awayTeam'])
            ->orderBy('scheduled_at')
            ->get();
        return response()->json($games);
    }

    public function store(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id|different:home_team_id',
            'scheduled_at' => 'required|date',
            'venue' => 'nullable|string|max:255',
        ]);

        // Validate teams belong to this season
        $homeTeam = Team::where('id', $validated['home_team_id'])
            ->where('season_id', $season->id)
            ->first();
        $awayTeam = Team::where('id', $validated['away_team_id'])
            ->where('season_id', $season->id)
            ->first();

        if (!$homeTeam || !$awayTeam) {
            return response()->json(['message' => 'Both teams must belong to this season'], 422);
        }

        // Validate scheduled_at is in the future
        $scheduledAt = \Carbon\Carbon::parse($validated['scheduled_at']);
        if ($scheduledAt->isPast()) {
            return response()->json(['message' => 'Game must be scheduled in the future'], 422);
        }

        // Validate scheduled_at is within season date range
        if ($scheduledAt->lt($season->start_date) || $scheduledAt->gt($season->end_date)) {
            return response()->json(['message' => 'Game must be scheduled within season dates'], 422);
        }

        // Check for duplicate game (same teams already scheduled in this season)
        $existingGame = $season->games()
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['home_team_id'])
                    ->where('away_team_id', $validated['away_team_id']);
            })
            ->orWhere(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['away_team_id'])
                    ->where('away_team_id', $validated['home_team_id']);
            })
            ->where('status', 'scheduled')
            ->first();

        if ($existingGame) {
            return response()->json(['message' => 'These teams already have a scheduled game in this season'], 422);
        }

        // Check if home team is already scheduled at this time
        $homeTeamConflict = $season->games()
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['home_team_id'])
                    ->orWhere('away_team_id', $validated['home_team_id']);
            })
            ->where('scheduled_at', $validated['scheduled_at'])
            ->where('status', 'scheduled')
            ->first();

        if ($homeTeamConflict) {
            return response()->json(['message' => 'Home team already has a game scheduled at this time'], 422);
        }

        // Check if away team is already scheduled at this time
        $awayTeamConflict = $season->games()
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['away_team_id'])
                    ->orWhere('away_team_id', $validated['away_team_id']);
            })
            ->where('scheduled_at', $validated['scheduled_at'])
            ->where('status', 'scheduled')
            ->first();

        if ($awayTeamConflict) {
            return response()->json(['message' => 'Away team already has a game scheduled at this time'], 422);
        }

        $game = $season->games()->create([
            'home_team_id' => $validated['home_team_id'],
            'away_team_id' => $validated['away_team_id'],
            'scheduled_at' => $validated['scheduled_at'],
            'venue' => $validated['venue'] ?? null,
        ]);

        return response()->json($game->load(['homeTeam', 'awayTeam']), 201);
    }

    public function show(League $league, Season $season, Game $game): JsonResponse
    {
        $this->authorize('view', $league);
        return response()->json($game->load(['homeTeam', 'awayTeam', 'gameResult.playerStats.player']));
    }

    public function update(Request $request, League $league, Season $season, Game $game): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'scheduled_at' => 'sometimes|date',
            'venue' => 'nullable|string|max:255',
            'status' => 'in:scheduled,done',
        ]);

        $game->update($validated);

        return response()->json($game->load(['homeTeam', 'awayTeam']));
    }

    public function destroy(League $league, Season $season, Game $game): JsonResponse
    {
        $this->authorize('update', $league);
        $game->delete();

        return response()->json(['message' => 'Game deleted successfully']);
    }

    public function submitResult(Request $request, League $league, Season $season, Game $game): JsonResponse
    {
        $this->authorize('update', $league);

        // Prevent duplicate result submissions
        if ($game->status === 'done') {
            return response()->json(['message' => 'Game result has already been submitted'], 422);
        }

        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
            'player_stats' => 'array',
            'player_stats.*.player_id' => 'required|exists:players,id',
            'player_stats.*.points' => 'integer|min:0',
            'player_stats.*.assists' => 'integer|min:0',
            'player_stats.*.rebounds' => 'integer|min:0',
            'player_stats.*.fouls' => 'integer|min:0',
        ]);

        DB::transaction(function () use ($game, $validated) {
            // Update game status to done
            $game->update(['status' => 'done']);

            // Create game result
            $gameResult = GameResult::create([
                'game_id' => $game->id,
                'home_score' => $validated['home_score'],
                'away_score' => $validated['away_score'],
            ]);

            if (isset($validated['player_stats'])) {
                foreach ($validated['player_stats'] as $stats) {
                    $gameResult->playerStats()->create([
                        'player_id' => $stats['player_id'],
                        'points' => $stats['points'] ?? 0,
                        'assists' => $stats['assists'] ?? 0,
                        'rebounds' => $stats['rebounds'] ?? 0,
                        'fouls' => $stats['fouls'] ?? 0,
                    ]);
                }
            }
        });

        return response()->json($game->load(['homeTeam', 'awayTeam', 'gameResult.playerStats.player']));
    }

}
