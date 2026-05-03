<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    public function index(League $league)
    {
        return $league->seasons()->with('teams')->get();
    }

    public function store(Request $request, League $league)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'status' => 'nullable|string|in:active,done',
        ]);

        $season = $league->seasons()->create($validated);
        return response()->json($season, 201);
    }

    public function show(Season $season)
    {
        return $season->load(['teams', 'games']);
    }

    public function update(Request $request, Season $season)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after_or_equal:start_date',
            'status' => 'sometimes|string|in:active,done',
        ]);

        $season->update($validated);
        return response()->json($season);
    }

    public function destroy(Season $season)
    {
        $season->delete();
        return response()->json(null, 204);
    }

    public function summary(Season $season)
    {
        $completedGames = $season->games()->where('status', 'done')->with('result.game.homeTeam', 'result.game.awayTeam')->get();
        
        if ($completedGames->isEmpty()) {
            return response()->json(['message' => 'This season has no completed games yet.'], 404);
        }

        $scheduledGamesCount = $season->games()->where('status', 'scheduled')->count();
        $playedGamesCount = $completedGames->count();

        $totalPoints = 0;
        $teamPoints = [];

        foreach ($completedGames as $game) {
            $result = $game->result;
            if (!$result) continue;

            $totalPoints += $result->home_score + $result->away_score;

            if (!isset($teamPoints[$game->home_team_id])) {
                $teamPoints[$game->home_team_id] = [
                    'team' => clone $game->homeTeam,
                    'points' => 0
                ];
            }
            if (!isset($teamPoints[$game->away_team_id])) {
                $teamPoints[$game->away_team_id] = [
                    'team' => clone $game->awayTeam,
                    'points' => 0
                ];
            }

            $teamPoints[$game->home_team_id]['points'] += $result->home_score;
            $teamPoints[$game->away_team_id]['points'] += $result->away_score;
        }

        $topScoringTeam = null;
        $maxPoints = -1;

        foreach ($teamPoints as $teamData) {
            if ($teamData['points'] > $maxPoints) {
                $maxPoints = $teamData['points'];
                $topScoringTeam = [
                    'team_id' => $teamData['team']->id,
                    'team_name' => $teamData['team']->name,
                    'total_points_scored' => $maxPoints
                ];
            }
        }

        return response()->json([
            'total_games_played' => $playedGamesCount,
            'total_games_scheduled' => $scheduledGamesCount,
            'total_points_scored' => $totalPoints,
            'top_scoring_team' => $topScoringTeam
        ]);
    }
}
