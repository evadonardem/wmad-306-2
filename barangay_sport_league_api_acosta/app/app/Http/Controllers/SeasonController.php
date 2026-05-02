<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class SeasonController extends Controller
{
    public function index(League $league): JsonResponse
    {
        $this->authorize('view', $league);
        $seasons = $league->seasons()->with('teams')->get();
        return response()->json($seasons);
    }

    public function store(Request $request, League $league): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'status' => 'in:active,done',
        ]);

        $season = $league->seasons()->create($validated);

        return response()->json($season, 201);
    }

    public function show(League $league, Season $season): JsonResponse
    {
        $this->authorize('view', $league);
        return response()->json($season->load(['teams', 'games']));
    }

    public function update(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'start_date' => 'sometimes|date',
            'end_date' => 'sometimes|date|after_or_equal:start_date',
            'status' => 'in:active,done',
        ]);

        $season->update($validated);

        return response()->json($season);
    }

    public function destroy(League $league, Season $season): JsonResponse
    {
        $this->authorize('update', $league);
        $season->delete();

        return response()->json(['message' => 'Season deleted successfully']);
    }
}
