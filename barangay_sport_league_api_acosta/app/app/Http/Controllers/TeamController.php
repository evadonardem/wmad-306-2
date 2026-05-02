<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class TeamController extends Controller
{
    public function index(League $league, Season $season): JsonResponse
    {
        $this->authorize('view', $league);
        $teams = $season->teams()->with('players')->get();
        return response()->json($teams);
    }

    public function store(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $team = $season->teams()->create($validated);

        return response()->json($team, 201);
    }

    public function show(League $league, Season $season, Team $team): JsonResponse
    {
        $this->authorize('view', $league);
        return response()->json($team->load('players'));
    }

    public function update(Request $request, League $league, Season $season, Team $team): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $team->update($validated);

        return response()->json($team);
    }

    public function destroy(League $league, Season $season, Team $team): JsonResponse
    {
        $this->authorize('update', $league);
        $team->delete();

        return response()->json(['message' => 'Team deleted successfully']);
    }
}
