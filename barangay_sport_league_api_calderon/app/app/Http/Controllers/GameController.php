<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\Team;
use Illuminate\Http\Request;
use Carbon\Carbon;

class GameController extends Controller
{
    /**
     * Display a listing of games in a season.
     */
    public function index(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $season->games;
    }

    /**
     * Schedule a game.
     */
    public function store(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id',
            'scheduled_at' => 'required|date',
            'venue' => 'required|string|max:255',
        ]);

        $homeTeam = Team::findOrFail($request->home_team_id);
        $awayTeam = Team::findOrFail($request->away_team_id);

        // Validation Rules
        if ($homeTeam->season_id !== $season->id || $awayTeam->season_id !== $season->id) {
            return response()->json(['message' => 'Both teams must belong to the same season.'], 422);
        }

        if ($request->home_team_id == $request->away_team_id) {
            return response()->json(['message' => 'A team cannot play against itself.'], 422);
        }

        // Exercise 2: Already exists in season
        $exists = Game::where('season_id', $season->id)
            ->where(function ($query) use ($request) {
                $query->where(function ($q) use ($request) {
                    $q->where('home_team_id', $request->home_team_id)
                      ->where('away_team_id', $request->away_team_id);
                })->orWhere(function ($q) use ($request) {
                    $q->where('home_team_id', $request->away_team_id)
                      ->where('away_team_id', $request->home_team_id);
                });
            })->exists();

        if ($exists) {
            return response()->json(['message' => 'A game between these two teams already exists in this season.'], 422);
        }

        // Exercise 2: Team already has a game on same date
        $date = Carbon::parse($request->scheduled_at)->toDateString();
        $dateConflict = Game::where('season_id', $season->id)
            ->whereDate('scheduled_at', $date)
            ->where(function ($query) use ($request) {
                $query->whereIn('home_team_id', [$request->home_team_id, $request->away_team_id])
                      ->orWhereIn('away_team_id', [$request->home_team_id, $request->away_team_id]);
            })->exists();

        if ($dateConflict) {
            return response()->json(['message' => 'One of the teams already has a game scheduled on this date.'], 422);
        }

        $game = $season->games()->create(array_merge($validated, ['status' => 'scheduled']));

        return response()->json($game, 201);
    }

    /**
     * Display the specified game.
     */
    public function show(Request $request, Game $game)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $game->load(['homeTeam', 'awayTeam', 'result.playerStats.player']);
    }

    /**
     * Submit final score. Marks game as done.
     */
    public function submitResult(Request $request, Game $game)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        $result = $game->result()->updateOrCreate([], $validated);
        $game->update(['status' => 'done']);

        return response()->json($result);
    }

    /**
     * Submit individual player stats.
     */
    public function submitStats(Request $request, Game $game)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($game->status !== 'done') {
            return response()->json(['message' => 'A game must have status "done" before stats can be submitted.'], 422);
        }

        $request->validate([
            'stats' => 'required|array',
            'stats.*.player_id' => 'required|exists:players,id',
            'stats.*.points' => 'required|integer|min:0',
            'stats.*.assists' => 'required|integer|min:0',
            'stats.*.rebounds' => 'required|integer|min:0',
            'stats.*.fouls' => 'required|integer|min:0',
        ]);

        $gameResult = $game->result;

        foreach ($request->stats as $statData) {
            $gameResult->playerStats()->updateOrCreate(
                ['player_id' => $statData['player_id']],
                $statData
            );
        }

        return response()->json(['message' => 'Stats submitted successfully']);
    }
}
