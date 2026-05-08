<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class GameController extends Controller
{
    /**
     * Display a listing of the games in a season.
     * GET /api/seasons/{id}/games
     */
    public function index(string $id)
    {
        $season = Season::whereHas('league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);
        return response()->json($season->games);
    }

    /**
     * Schedule a new game.
     * POST /api/seasons/{id}/games
     */
    public function store(Request $request, string $id)
    {
        $season = Season::whereHas('league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);

        $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            // Task 7: Team cannot play itself (different:home_team_id)
            'away_team_id' => 'required|exists:teams,id|different:home_team_id',
            'scheduled_at' => 'required|date',
            'venue' => 'required|string|max:255',
        ]);

        // Task 7: Validate both teams actually belong to this season
        $homeTeam = Team::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($request->home_team_id);
        $awayTeam = Team::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($request->away_team_id);

        if ($homeTeam->season_id !== $season->id || $awayTeam->season_id !== $season->id) {
            return response()->json(['message' => 'Both teams must belong to this season'], 422);
        }

        $scheduledDate = Carbon::parse($request->scheduled_at)->toDateString();

        // Exercise 2: Reject duplicate matchup in this season, regardless of home/away order.
        $matchupExists = $season->games()
            ->where(function ($query) use ($request) {
                $query->where('home_team_id', $request->home_team_id)
                    ->where('away_team_id', $request->away_team_id);
            })
            ->orWhere(function ($query) use ($request) {
                $query->where('home_team_id', $request->away_team_id)
                    ->where('away_team_id', $request->home_team_id);
            })
            ->exists();

        if ($matchupExists) {
            return response()->json([
                'message' => 'A game between these two teams already exists in this season'
            ], 422);
        }

        // Exercise 2: Reject if either team already has a game on the same date.
        $homeTeamDateConflict = $season->games()
            ->whereDate('scheduled_at', $scheduledDate)
            ->where(function ($query) use ($request) {
                $query->where('home_team_id', $request->home_team_id)
                    ->orWhere('away_team_id', $request->home_team_id);
            })
            ->exists();

        if ($homeTeamDateConflict) {
            return response()->json([
                'message' => "Scheduling conflict: home team already has a game on {$scheduledDate}"
            ], 422);
        }

        $awayTeamDateConflict = $season->games()
            ->whereDate('scheduled_at', $scheduledDate)
            ->where(function ($query) use ($request) {
                $query->where('home_team_id', $request->away_team_id)
                    ->orWhere('away_team_id', $request->away_team_id);
            })
            ->exists();

        if ($awayTeamDateConflict) {
            return response()->json([
                'message' => "Scheduling conflict: away team already has a game on {$scheduledDate}"
            ], 422);
        }

        // New games default to status: scheduled
        $game = $season->games()->create([
            'home_team_id' => $request->home_team_id,
            'away_team_id' => $request->away_team_id,
            'scheduled_at' => $request->scheduled_at,
            'venue' => $request->venue,
            'status' => 'scheduled' // Default status
        ]);

        return response()->json($game, 201);
    }

    /**
     * Display the specific game with result and stats.
     * GET /api/games/{id}
     */
    public function show(string $id)
    {
        $game = Game::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->with(['result', 'result.playerStats'])->findOrFail($id);
        
        return response()->json($game);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        // Not explicitly required by the manual's endpoint list, but good to have
        $game = Game::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);
        $game->update($request->all());
        return response()->json($game);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        // Not explicitly required, but completes the skeleton
        $game = Game::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);
        $game->delete();
        return response()->json(['message' => 'Game deleted successfully']);
    }

    /**
     * Submit final score. Marks game as done.
     * POST /api/games/{id}/result
     */
    public function submitResult(Request $request, string $id)
    {
        $game = Game::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->with('result')->findOrFail($id);

        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        if ($game->result) {
            return response()->json(['message' => 'Result already submitted for this game'], 422);
        }

        // Create the result tied to this game
        $result = $game->result()->create($validated);
        
        // Task 8: Mark game as done
        $game->update(['status' => 'done']);

        return response()->json($result, 201);
    }

    /**
     * Submit individual player stats.
     * POST /api/games/{id}/stats
     */
    public function submitStats(Request $request, string $id)
    {
        $game = Game::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->with('result')->findOrFail($id);

        // Task 8: Check if game is done before saving stats
        if ($game->status !== 'done') {
            return response()->json(['message' => 'Game must be done before stats can be submitted'], 422);
        }

        $validated = $request->validate([
            'stats' => 'required|array',
            'stats.*.player_id' => 'required|exists:players,id',
            'stats.*.points' => 'required|integer|min:0',
            'stats.*.assists' => 'required|integer|min:0',
            'stats.*.rebounds' => 'required|integer|min:0',
            'stats.*.fouls' => 'required|integer|min:0',
        ]);

        $gameResult = $game->result;
        if (! $gameResult) {
            return response()->json(['message' => 'Game result is required before submitting stats'], 422);
        }

        $gameResult->playerStats()->createMany($validated['stats']);

        return response()->json(['message' => 'Stats successfully saved'], 201);
    }
}