<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\PlayerStat;
use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class GameController extends Controller
{
    // GET /api/seasons/{id}/games
    public function index($seasonId)
    {
        $season = Season::findOrFail($seasonId);

        return response()->json(
            $season->games()->with(['homeTeam', 'awayTeam', 'result'])->get()
        );
    }

    // POST /api/seasons/{id}/games
    // Includes EXERCISE 2 validations
    public function store(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);

        $data = $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id',
            'scheduled_at' => 'required|date',
            'venue'        => 'required|string|max:255',
        ]);

        $homeId = (int) $data['home_team_id'];
        $awayId = (int) $data['away_team_id'];

        // Rule 1: Cannot play against itself
        if ($homeId === $awayId) {
            return response()->json([
                'message' => 'A team cannot be scheduled to play against itself.',
            ], 422);
        }

        // Rule 2: Both teams must belong to this season
        $validCount = $season->teams()->whereIn('id', [$homeId, $awayId])->count();
        if ($validCount !== 2) {
            return response()->json([
                'message' => 'Both teams must be registered under this season.',
            ], 422);
        }

        // EXERCISE 2 — Rule 3: No duplicate matchup (order-independent)
        $duplicateExists = $season->games()->where(function ($q) use ($homeId, $awayId) {
            $q->where(fn($q2) =>
                $q2->where('home_team_id', $homeId)->where('away_team_id', $awayId)
            )->orWhere(fn($q2) =>
                $q2->where('home_team_id', $awayId)->where('away_team_id', $homeId)
            );
        })->exists();

        if ($duplicateExists) {
            return response()->json([
                'message' => 'A game between these two teams already exists in this season.',
            ], 422);
        }

        // EXERCISE 2 — Rule 4: Neither team may have another game on the same date
        $scheduledDate = Carbon::parse($data['scheduled_at'])->toDateString();

        $dateConflict = $season->games()
            ->where(function ($q) use ($homeId, $awayId) {
                $q->whereIn('home_team_id', [$homeId, $awayId])
                  ->orWhereIn('away_team_id', [$homeId, $awayId]);
            })
            ->whereDate('scheduled_at', $scheduledDate)
            ->exists();

        if ($dateConflict) {
            return response()->json([
                'message' => 'One or both teams already have a game scheduled on that date.',
            ], 422);
        }

        $game = Game::create([
            'season_id'    => $seasonId,
            'home_team_id' => $homeId,
            'away_team_id' => $awayId,
            'scheduled_at' => $data['scheduled_at'],
            'venue'        => $data['venue'],
            'status'       => 'scheduled',
        ]);

        return response()->json($game->load(['homeTeam', 'awayTeam']), 201);
    }

    // GET /api/games/{id}
    public function show($id)
    {
        $game = Game::with([
            'homeTeam',
            'awayTeam',
            'result.playerStats.player',
        ])->findOrFail($id);

        return response()->json($game);
    }

    // POST /api/games/{id}/result
    public function submitResult(Request $request, $id)
    {
        $game = Game::findOrFail($id);

        if ($game->status === 'done') {
            return response()->json([
                'message' => 'A result has already been submitted for this game.',
            ], 422);
        }

        $data = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        $result = $game->result()->create($data);
        $game->update(['status' => 'done']);

        return response()->json([
            'message' => 'Game result submitted successfully.',
            'result'  => $result,
        ], 201);
    }

    // POST /api/games/{id}/stats
    public function submitStats(Request $request, $id)
    {
        $game = Game::with('result')->findOrFail($id);

        if ($game->status !== 'done') {
            return response()->json([
                'message' => 'Stats can only be submitted after the game result has been recorded.',
            ], 422);
        }

        $data = $request->validate([
            'stats'                => 'required|array|min:1',
            'stats.*.player_id'   => 'required|exists:players,id',
            'stats.*.points'      => 'required|integer|min:0',
            'stats.*.assists'     => 'required|integer|min:0',
            'stats.*.rebounds'    => 'required|integer|min:0',
            'stats.*.fouls'       => 'required|integer|min:0',
        ]);

        $gameResultId = $game->result->id;
        $now          = now();

        $rows = collect($data['stats'])->map(fn($s) => [
            'game_result_id' => $gameResultId,
            'player_id'      => $s['player_id'],
            'points'         => $s['points'],
            'assists'        => $s['assists'],
            'rebounds'       => $s['rebounds'],
            'fouls'          => $s['fouls'],
            'created_at'     => $now,
            'updated_at'     => $now,
        ])->toArray();

        PlayerStat::insert($rows);

        return response()->json(['message' => 'Player stats submitted successfully.'], 201);
    }
}