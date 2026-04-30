<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class SeasonController extends Controller
{
    public function index(Request $request, int $leagueId): JsonResponse
    {
        $league = $this->ownedLeague($request, $leagueId)->firstOrFail();

        return response()->json(
            $league->seasons()->withCount(['teams', 'games'])->latest()->get()
        );
    }

    public function store(Request $request, int $leagueId): JsonResponse
    {
        $league = $this->ownedLeague($request, $leagueId)->firstOrFail();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
            'status' => ['sometimes', Rule::in(['active', 'done'])],
        ]);

        $season = $league->seasons()->create($data);

        return response()->json($season, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $season = $this->ownedSeason($request, $id)
            ->with(['league', 'teams.players', 'games.homeTeam', 'games.awayTeam', 'games.result'])
            ->firstOrFail();

        return response()->json($season);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $season = $this->ownedSeason($request, $id)->firstOrFail();

        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'start_date' => ['sometimes', 'required', 'date'],
            'end_date' => ['sometimes', 'required', 'date', 'after_or_equal:start_date'],
            'status' => ['sometimes', Rule::in(['active', 'done'])],
        ]);

        $season->update($data);

        return response()->json($season->fresh());
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $season = $this->ownedSeason($request, $id)->firstOrFail();
        $season->delete();

        return response()->json([
            'message' => 'Season deleted successfully.',
        ]);
    }

    private function ownedLeague(Request $request, int $leagueId)
    {
        return League::where('id', $leagueId)->where('user_id', $request->user()->id);
    }

    private function ownedSeason(Request $request, int $seasonId)
    {
        return Season::where('id', $seasonId)
            ->whereHas('league', fn ($query) => $query->where('user_id', $request->user()->id));
    }
}
