<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class GameController extends Controller
{
    public function index(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $season->games()->with(['homeTeam', 'awayTeam'])->get();
    }

    public function store(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id',
            'scheduled_at' => 'required|date',
            'venue' => 'required|string',
        ]);

        $homeTeam = $season->teams()->find($validated['home_team_id']);
        $awayTeam = $season->teams()->find($validated['away_team_id']);

        if (!$homeTeam || !$awayTeam) {
            return response()->json(['message' => 'Both teams must belong to this season'], 422);
        }

        if ($validated['home_team_id'] == $validated['away_team_id']) {
            return response()->json(['message' => 'A team cannot play against itself'], 422);
        }

        // Exercise 2: Duplicate matchup check
        $existingMatchup = Game::where('season_id', $season->id)
            ->where(function ($query) use ($validated) {
                $query->where(function ($q) use ($validated) {
                    $q->where('home_team_id', $validated['home_team_id'])
                      ->where('away_team_id', $validated['away_team_id']);
                })->orWhere(function ($q) use ($validated) {
                    $q->where('home_team_id', $validated['away_team_id'])
                      ->where('away_team_id', $validated['home_team_id']);
                });
            })->exists();

        if ($existingMatchup) {
            return response()->json(['message' => 'A game between these two teams already exists in this season'], 422);
        }

        // Exercise 2: Team already has a game on the same date
        $date = date('Y-m-d', strtotime($validated['scheduled_at']));
        $teamConflict = Game::where('season_id', $season->id)
            ->whereDate('scheduled_at', $date)
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['home_team_id'])
                      ->orWhere('away_team_id', $validated['home_team_id'])
                      ->orWhere('home_team_id', $validated['away_team_id'])
                      ->orWhere('away_team_id', $validated['away_team_id']);
            })->exists();

        if ($teamConflict) {
            return response()->json(['message' => 'One of the teams already has a game scheduled on this date'], 422);
        }

        $game = $season->games()->create($validated);

        return response()->json($game, 201);
    }

    public function show(Request $request, Game $game)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $game->load(['homeTeam', 'awayTeam', 'result.stats.player']);
    }

    public function submitResult(Request $request, Game $game)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        DB::transaction(function () use ($game, $validated) {
            $game->result()->updateOrCreate([], $validated);
            $game->update(['status' => 'done']);
        });

        return response()->json(['message' => 'Result submitted and game marked as done']);
    }

    public function submitStats(Request $request, Game $game)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($game->status !== 'done') {
            return response()->json(['message' => 'Stats can only be submitted for completed games'], 422);
        }

        $validated = $request->validate([
            'stats' => 'required|array',
            'stats.*.player_id' => 'required|exists:players,id',
            'stats.*.points' => 'required|integer|min:0',
            'stats.*.assists' => 'required|integer|min:0',
            'stats.*.rebounds' => 'required|integer|min:0',
            'stats.*.fouls' => 'required|integer|min:0',
        ]);

        $result = $game->result;

        DB::transaction(function () use ($result, $validated) {
            foreach ($validated['stats'] as $statData) {
                $result->playerStats()->updateOrCreate(
                    ['player_id' => $statData['player_id']],
                    $statData
                );
            }
        });

        return response()->json(['message' => 'Player stats submitted']);
    }
}
