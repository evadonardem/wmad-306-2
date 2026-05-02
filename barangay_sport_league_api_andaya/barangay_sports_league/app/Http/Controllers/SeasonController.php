<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\League;
use App\Models\Season;

class SeasonController extends Controller
{
    public function index(Request $request, $leagueId)
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);
        $seasons = $league->seasons;
        return response()->json($seasons);
    }

    public function store(Request $request, $leagueId)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'status' => 'in:active,done',
        ]);

        $league = $request->user()->leagues()->findOrFail($leagueId);
        $season = $league->seasons()->create($request->all());
        return response()->json($season, 201);
    }

    public function show(Request $request, $id)
    {
        $season = Season::with(['teams', 'games'])->findOrFail($id);
        return response()->json($season);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'status' => 'in:active,done',
        ]);

        $season = Season::findOrFail($id);
        $season->update($request->all());
        return response()->json($season);
    }

    public function summary(Request $request, $id)
    {
        $season = Season::findOrFail($id);
        $games = $season->games;
        $completedGames = $games->where('status', 'done')->load('result');
        $scheduledGames = $games->where('status', 'scheduled');

        if ($completedGames->count() === 0) {
            return response()->json(['message' => 'Season has no completed games'], 404);
        }

        $totalPoints = 0;
        $teamPoints = [];

        foreach ($completedGames as $game) {
            $totalPoints += $game->result->home_score + $game->result->away_score;

            $homePoints = $teamPoints[$game->home_team_id] ?? 0;
            $awayPoints = $teamPoints[$game->away_team_id] ?? 0;

            $teamPoints[$game->home_team_id] = $homePoints + $game->result->home_score;
            $teamPoints[$game->away_team_id] = $awayPoints + $game->result->away_score;
        }

        $topScoringTeamId = array_keys($teamPoints, max($teamPoints))[0];
        $topScoringTeam = $season->teams()->find($topScoringTeamId);

        return response()->json([
            'total_games_played' => $completedGames->count(),
            'total_games_scheduled' => $scheduledGames->count(),
            'top_scoring_team' => $topScoringTeam,
            'top_scoring_team_points' => $teamPoints[$topScoringTeamId],
            'total_points_scored' => $totalPoints,
        ]);
    }
}
