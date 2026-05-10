<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class SeasonController extends Controller
{
    /**
     * Retrieve all seasons for a specific league.
     */
    public function index(Request $request, int $leagueId): JsonResponse
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);

        return response()->json($league->seasons);
    }

    /**
     * Create a new season entry.
     */
    public function store(Request $request, int $leagueId): JsonResponse
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);

        $params = $request->validate([
            'name'       => ['required', 'string', 'max:255'],
            'start_date' => ['required', 'date'],
            'end_date'   => ['required', 'date', 'after:start_date'],
            'status'     => ['nullable', 'in:active,done'],
        ]);

        $season = $league->seasons()->create($params);

        return response()->json($season, 201);
    }

    /**
     * View detailed season data including roster and matchups.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        // We scope the query by the user's leagues to ensure ownership
        $record = Season::whereHas('league', fn($query) => 
            $query->where('user_id', $request->user()->id)
        )->with(['teams', 'games.homeTeam', 'games.awayTeam'])->findOrFail($id);

        return response()->json($record);
    }

    /**
     * Modify existing season details.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $season = Season::whereHas('league', fn($q) => $q->where('user_id', $request->user()->id))
            ->findOrFail($id);

        $validated = $request->validate([
            'name'       => ['sometimes', 'string', 'max:255'],
            'start_date' => ['sometimes', 'date'],
            'end_date'   => ['sometimes', 'date', 'after:start_date'],
            'status'     => ['sometimes', 'in:active,done'],
        ]);

        return response()->json(tap($season)->update($validated));
    }

    /**
     * Generate a statistical overview of the season performance.
     */
    public function summary(Request $request, int $id): JsonResponse
    {
        $season = Season::whereHas('league', fn($q) => $q->where('user_id', $request->user()->id))
            ->with(['games.result'])
            ->findOrFail($id);

        $finishedMatches = $season->games()->where('status', 'done')->get();

        if ($finishedMatches->isEmpty()) {
            return response()->json(['error' => 'Insufficient data for summary.'], 404);
        }

        // Logic: Map the results to extract scores and identify the lead team
        $scoringMap = collect();

        $finishedMatches->each(function ($match) use ($scoringMap) {
            if ($match->result) {
                $scoringMap->put($match->home_team_id, ($scoringMap->get($match->home_team_id, 0) + $match->result->home_score));
                $scoringMap->put($match->away_team_id, ($scoringMap->get($match->away_team_id, 0) + $match->result->away_score));
            }
        });

        $topScorerId = $scoringMap->sortDesc()->keys()->first();

        return response()->json([
            'metrics' => [
                'played'    => $finishedMatches->count(),
                'pending'   => $season->games()->where('status', 'scheduled')->count(),
                'aggregate' => $finishedMatches->sum(fn($m) => ($m->result->home_score ?? 0) + ($m->result->away_score ?? 0)),
            ],
            'leaderboard_top' => Team::find($topScorerId),
        ]);
    }
}