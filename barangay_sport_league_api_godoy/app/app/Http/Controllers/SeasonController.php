<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    public function index(Request $request, $leagueId)
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);
        $seasons = $league->seasons()->with('teams')->get();
        return response()->json($seasons);
    }

    public function store(Request $request, $leagueId)
    {
        $request->validate([
            'name' => 'required|string',
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
        $season = Season::with(['teams.players', 'games'])->findOrFail($id);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);
        
        return response()->json($season);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'sometimes|required|string',
            'start_date' => 'sometimes|required|date',
            'end_date' => 'sometimes|required|date|after:start_date',
            'status' => 'in:active,done',
        ]);

        $season = Season::findOrFail($id);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);
        
        $season->update($request->all());
        return response()->json($season);
    }

    public function summary(Request $request, $id)
    {
        $season = Season::findOrFail($id);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);

        $games = $season->games()->with('result')->get();
        $gamesPlayed = $games->where('status', 'done')->count();
        $gamesScheduled = $games->where('status', 'scheduled')->count();

        if ($gamesPlayed === 0) {
            return response()->json(['message' => 'No completed games in this season'], 404);
        }

        // Calculate total points across all games
        $totalPoints = 0;
        $teamPoints = [];

        foreach ($games->where('status', 'done') as $game) {
            $totalPoints += $game->result->home_score + $game->result->away_score;
            
            // Track points per team
            $teamPoints[$game->home_team_id] = ($teamPoints[$game->home_team_id] ?? 0) + $game->result->home_score;
            $teamPoints[$game->away_team_id] = ($teamPoints[$game->away_team_id] ?? 0) + $game->result->away_score;
        }

        // Find top scoring team
        $topScoringTeamId = array_key_first($teamPoints);
        $topScoringTeamPoints = $teamPoints[$topScoringTeamId];

        foreach ($teamPoints as $teamId => $points) {
            if ($points > $topScoringTeamPoints) {
                $topScoringTeamId = $teamId;
                $topScoringTeamPoints = $points;
            }
        }

        $topScoringTeam = $season->teams()->find($topScoringTeamId);

        return response()->json([
            'total_games_played' => $gamesPlayed,
            'total_games_scheduled' => $gamesScheduled,
            'top_scoring_team' => [
                'id' => $topScoringTeam->id,
                'name' => $topScoringTeam->name,
                'total_points' => $topScoringTeamPoints,
            ],
            'total_points' => $totalPoints,
        ]);
    }
}
