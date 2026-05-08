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
    public function index(Season $season)
    {
        return $season->games()->with(['homeTeam', 'awayTeam', 'result'])->get();
    }

    public function store(Request $request, Season $season)
    {
        $validated = $request->validate([
            'home_team_id' => 'required|exists:teams,id|different:away_team_id',
            'away_team_id' => 'required|exists:teams,id',
            'scheduled_at' => 'required|date',
            'venue' => 'nullable|string',
        ]);

        $homeTeamValid = $season->teams()->where('id', $validated['home_team_id'])->exists();
        $awayTeamValid = $season->teams()->where('id', $validated['away_team_id'])->exists();

        if (!$homeTeamValid || !$awayTeamValid) {
            return response()->json(['message' => 'Both teams must belong to the given season.'], 422);
        }

        // Exercise 2: Game Validation Rules
        $matchupExists = $season->games()->where(function ($query) use ($validated) {
            $query->where(function ($q) use ($validated) {
                $q->where('home_team_id', $validated['home_team_id'])
                  ->where('away_team_id', $validated['away_team_id']);
            })->orWhere(function ($q) use ($validated) {
                $q->where('home_team_id', $validated['away_team_id'])
                  ->where('away_team_id', $validated['home_team_id']);
            });
        })->exists();

        if ($matchupExists) {
            return response()->json(['message' => 'A matchup between these two teams already exists in this season.'], 422);
        }

        $scheduledAtDate = date('Y-m-d', strtotime($validated['scheduled_at']));

        $homeTeamBusy = $season->games()
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['home_team_id'])
                      ->orWhere('away_team_id', $validated['home_team_id']);
            })
            ->whereDate('scheduled_at', $scheduledAtDate)
            ->exists();

        if ($homeTeamBusy) {
            return response()->json(['message' => 'The home team already has a game scheduled on this date.'], 422);
        }

        $awayTeamBusy = $season->games()
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['away_team_id'])
                      ->orWhere('away_team_id', $validated['away_team_id']);
            })
            ->whereDate('scheduled_at', $scheduledAtDate)
            ->exists();

        if ($awayTeamBusy) {
            return response()->json(['message' => 'The away team already has a game scheduled on this date.'], 422);
        }

        $game = $season->games()->create($validated);
        return response()->json($game, 201);
    }

    public function show(Game $game)
    {
        return $game->load(['homeTeam', 'awayTeam', 'result.playerStats']);
    }

    public function update(Request $request, Game $game)
    {
        $validated = $request->validate([
            'scheduled_at' => 'sometimes|date',
            'venue' => 'nullable|string',
            'status' => 'sometimes|string|in:scheduled,done',
        ]);

        $game->update($validated);
        return response()->json($game);
    }

    public function destroy(Game $game)
    {
        $game->delete();
        return response()->json(null, 204);
    }

    public function submitResult(Request $request, Game $game)
    {
        if ($game->status === 'done') {
            return response()->json(['message' => 'Game is already done.'], 422);
        }

        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        DB::transaction(function () use ($game, $validated) {
            GameResult::create([
                'game_id' => $game->id,
                'home_score' => $validated['home_score'],
                'away_score' => $validated['away_score'],
            ]);

            $game->update(['status' => 'done']);
        });

        return response()->json($game->load('result'), 201);
    }

    public function submitStats(Request $request, Game $game)
    {
        if ($game->status !== 'done') {
            return response()->json(['message' => 'Game must be done before saving stats.'], 422);
        }

        $result = $game->result;
        if (!$result) {
            return response()->json(['message' => 'Game result must be submitted first.'], 422);
        }

        $validated = $request->validate([
            'player_stats' => 'required|array',
            'player_stats.*.player_id' => 'required|exists:players,id',
            'player_stats.*.points' => 'required|integer|min:0',
            'player_stats.*.rebounds' => 'required|integer|min:0',
            'player_stats.*.assists' => 'required|integer|min:0',
            'player_stats.*.fouls' => 'required|integer|min:0',
        ]);

        foreach ($validated['player_stats'] as $stat) {
            PlayerStat::create([
                'game_result_id' => $result->id,
                'player_id' => $stat['player_id'],
                'points' => $stat['points'] ?? 0,
                'rebounds' => $stat['rebounds'] ?? 0,
                'assists' => $stat['assists'] ?? 0,
                'fouls' => $stat['fouls'] ?? 0,
            ]);
        }

        return response()->json($result->load('playerStats'), 201);
    }
}
