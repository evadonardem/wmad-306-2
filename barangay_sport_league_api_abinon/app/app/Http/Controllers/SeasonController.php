<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    public function index(Request $request, League $league): JsonResponse
    {
        $league = $this->ownedLeague($request, $league);

        return response()->json(
            $league->seasons()->latest()->get()
        );
    }

    public function store(Request $request, League $league): JsonResponse
    {
        $league = $this->ownedLeague($request, $league);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'start_date' => ['required', 'date'],
            'end_date' => ['required', 'date', 'after_or_equal:start_date'],
            'status' => ['required', 'in:active,done'],
        ]);

        $season = $league->seasons()->create($validated);

        return response()->json($season, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $season = $this->ownedSeason($request, $id)->load([
            'teams.players',
            'games.homeTeam',
            'games.awayTeam',
            'games.result.playerStats.player',
        ]);

        return response()->json($season);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $season = $this->ownedSeason($request, $id);

        $validated = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'start_date' => ['sometimes', 'required', 'date'],
            'end_date' => ['sometimes', 'required', 'date', 'after_or_equal:start_date'],
            'status' => ['sometimes', 'required', 'in:active,done'],
        ]);

        $season->update($validated);

        return response()->json($season->fresh());
    }

    private function ownedLeague(Request $request, League $league): League
    {
        return $request->user()
            ->leagues()
            ->whereKey($league->id)
            ->firstOrFail();
    }

    private function ownedSeason(Request $request, int $seasonId): Season
    {
        return Season::query()
            ->whereKey($seasonId)
            ->whereHas('league', function ($query) use ($request): void {
                $query->where('user_id', $request->user()->id);
            })
            ->firstOrFail();
    }
}
