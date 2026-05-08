<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\League;
use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GameController extends Controller
{
    public function index(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);
        $this->authorizeSeasonForLeague($league, $season);

        return response()->json($season->games()->with(['homeTeam', 'awayTeam'])->get());
    }

    public function store(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);
        $this->authorizeSeasonForLeague($league, $season);

        $data = $request->validate([
            'home_team_id' => ['required', 'integer', 'exists:teams,id'],
            'away_team_id' => ['required', 'integer', 'exists:teams,id'],
            'scheduled_at' => ['nullable', 'date'],
        ]);

        if ($data['home_team_id'] === $data['away_team_id']) {
            return response()->json([
                'message' => 'Home team and away team must be different.',
            ], 422);
        }

        $game = $season->games()->create([
            'home_team_id' => $data['home_team_id'],
            'away_team_id' => $data['away_team_id'],
            'scheduled_at' => $data['scheduled_at'] ?? null,
        ]);

        return response()->json($game->load(['homeTeam', 'awayTeam']), 201);
    }

    protected function authorizeLeagueOwner(Request $request, League $league): void
    {
        if ($league->user_id !== $request->user()->id) {
            abort(403);
        }
    }

    protected function authorizeSeasonForLeague(League $league, Season $season): void
    {
        if ($season->league_id !== $league->id) {
            abort(404);
        }
    }
}
