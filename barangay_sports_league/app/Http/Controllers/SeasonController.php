<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    /** Helper: verify season belongs to authenticated user's league */
    private function findUserSeason(Request $request, int $seasonId): Season
    {
        return Season::whereHas('league', fn($q) =>
            $q->where('user_id', $request->user()->id)
        )->findOrFail($seasonId);
    }

    // GET /api/leagues/{id}/seasons
    public function index(Request $request, $leagueId)
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);

        return response()->json($league->seasons()->get());
    }

    // POST /api/leagues/{id}/seasons
    public function store(Request $request, $leagueId)
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);

        $data = $request->validate([
            'name'       => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date'   => 'required|date|after:start_date',
            'status'     => 'sometimes|in:active,done',
        ]);

        $season = $league->seasons()->create($data);

        return response()->json($season, 201);
    }

    // GET /api/seasons/{id}
    public function show(Request $request, $id)
    {
        $season = $this->findUserSeason($request, $id);
        $season->load(['teams', 'games.homeTeam', 'games.awayTeam']);

        return response()->json($season);
    }

    // PUT /api/seasons/{id}
    public function update(Request $request, $id)
    {
        $season = $this->findUserSeason($request, $id);

        $data = $request->validate([
            'name'       => 'sometimes|string|max:255',
            'start_date' => 'sometimes|date',
            'end_date'   => 'sometimes|date|after:start_date',
            'status'     => 'sometimes|in:active,done',
        ]);

        $season->update($data);

        return response()->json($season);
    }

    // GET /api/seasons/{id}/summary  ← EXERCISE 1
    public function summary(Request $request, $id)
    {
        $season = $this->findUserSeason($request, $id);

        $completedGames = $season->games()
                                 ->where('status', 'done')
                                 ->with('result')
                                 ->get();

        if ($completedGames->isEmpty()) {
            return response()->json([
                'message' => 'No completed games found for this season.',
            ], 404);
        }

        $scheduledCount = $season->games()->where('status', 'scheduled')->count();

        $totalPoints = 0;
        $teamPoints  = [];

        foreach ($completedGames as $game) {
            if (! $game->result) continue;

            $totalPoints += $game->result->home_score + $game->result->away_score;

            $teamPoints[$game->home_team_id] =
                ($teamPoints[$game->home_team_id] ?? 0) + $game->result->home_score;

            $teamPoints[$game->away_team_id] =
                ($teamPoints[$game->away_team_id] ?? 0) + $game->result->away_score;
        }

        $topTeamId = array_search(max($teamPoints), $teamPoints);
        $topTeam   = Team::find($topTeamId);

        return response()->json([
            'total_games_played'   => $completedGames->count(),
            'total_games_scheduled' => $scheduledCount,
            'total_points_scored'  => $totalPoints,
            'top_scoring_team'     => $topTeam,
        ]);
    }
}