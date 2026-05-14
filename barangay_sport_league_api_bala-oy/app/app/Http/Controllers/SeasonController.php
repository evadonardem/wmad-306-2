<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\League;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SeasonController extends Controller
{
    /**
     * Get all seasons for a league.
     */
    public function index(League $league, Request $request)
    {
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $seasons = $league->seasons()->get();

        return response()->json(['data' => $seasons], 200);
    }

    /**
     * Create a new season for a league.
     */
    public function store(League $league, Request $request)
    {
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'status' => 'sometimes|in:active,done',
        ]);

        $season = $league->seasons()->create($validated);

        return response()->json([
            'message' => 'Season created successfully',
            'data' => $season,
        ], 201);
    }

    /**
     * Get a specific season with teams and games.
     */
    public function show(Season $season, Request $request)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season->load('league', 'teams.players', 'games.homeTeam', 'games.awayTeam', 'games.result');

        return response()->json(['data' => $season], 200);
    }

    /**
     * Update a season.
     */
    public function update(Season $season, Request $request)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after:start_date',
            'status' => 'sometimes|in:active,done',
        ]);

        $season->update($validated);

        return response()->json([
            'message' => 'Season updated successfully',
            'data' => $season,
        ], 200);
    }

    /**
     * Get season summary statistics.
     */
    public function summary(Season $season, Request $request)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $completedGames = $season->games()->where('status', 'done')->with('result')->get();

        if ($completedGames->isEmpty()) {
            return response()->json(['message' => 'No completed games found for this season'], 404);
        }

        $totalPoints = $completedGames->sum(function ($game) {
            return $game->result->home_score + $game->result->away_score;
        });

        $teamScores = $season->teams()->get()->mapWithKeys(function ($team) use ($completedGames) {
            $total = 0;

            foreach ($completedGames as $game) {
                if ($game->home_team_id === $team->id) {
                    $total += $game->result->home_score;
                }

                if ($game->away_team_id === $team->id) {
                    $total += $game->result->away_score;
                }
            }

            return [$team->id => [
                'id' => $team->id,
                'name' => $team->name,
                'total_points' => $total,
            ]];
        });

        $topScoringTeam = $teamScores->sortByDesc('total_points')->values()->first();

        return response()->json([
            'data' => [
                'total_games_played' => $completedGames->count(),
                'total_games_scheduled' => $season->games()->where('status', 'scheduled')->count(),
                'top_scoring_team' => $topScoringTeam,
                'total_points' => $totalPoints,
            ],
        ], 200);
    }
}
