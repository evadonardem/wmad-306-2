<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    public function index(Request $request, League $league)
    {
        // Ensure league belongs to auth user
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return response()->json($league->seasons);
    }

    public function store(Request $request, League $league)
    {
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'name'       => 'required|string',
            'start_date' => 'required|date',
            'end_date'   => 'required|date|after:start_date',
            'status'     => 'in:active,done',
        ]);

        $season = $league->seasons()->create($data);
        return response()->json($season, 201);
    }

    public function show(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $season->load(['teams', 'games.homeTeam', 'games.awayTeam']);
        return response()->json($season);
    }

    public function update(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $season->update($request->only(['name','start_date','end_date','status']));
        return response()->json($season);
    }
    // GET /api/seasons/{season}/summary
    public function summary(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
    $games = $season->games()->with('result')->get();
    $completedGames = $games->where('status', 'done');

    if ($completedGames->isEmpty()) {
        return response()->json([
            'message' => 'No completed games found for this season'
        ], 404);
    }

    // Total points in all games
    $totalPoints = $completedGames->sum(function ($game) {
        return ($game->result->home_score ?? 0)
             + ($game->result->away_score ?? 0);
    });

    // Top scoring team (sum home + away across all games)
    $teamScores = [];
    foreach ($completedGames as $game) {
        $homeId = $game->home_team_id;
        $awayId = $game->away_team_id;
        $teamScores[$homeId] = ($teamScores[$homeId] ?? 0)
                             + ($game->result->home_score ?? 0);
        $teamScores[$awayId] = ($teamScores[$awayId] ?? 0)
                             + ($game->result->away_score ?? 0);
    }
    arsort($teamScores);
    $topTeamId = array_key_first($teamScores);
    $topTeam = \App\Models\Team::find($topTeamId);

    return response()->json([
        'total_games_played'    => $completedGames->count(),
        'total_games_scheduled' => $games->where('status', 'scheduled')->count(),
        'total_points'          => $totalPoints,
        'top_scoring_team'      => $topTeam ? $topTeam->name : null,
    ]);
}
}