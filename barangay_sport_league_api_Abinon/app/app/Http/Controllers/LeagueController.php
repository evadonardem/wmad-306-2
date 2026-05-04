<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $leagues = $request->user()
            ->leagues()
            ->latest()
            ->get();

        return response()->json($leagues);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sport' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
        ]);

        $league = $request->user()->leagues()->create($validated);

        return response()->json($league, 201);
    }

    public function show(Request $request, League $league): JsonResponse
    {
        $league = $this->ownedLeague($request, $league)->load('seasons');

        return response()->json($league);
    }

    public function update(Request $request, League $league): JsonResponse
    {
        $league = $this->ownedLeague($request, $league);

        $validated = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'sport' => ['sometimes', 'required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
        ]);

        $league->update($validated);

        return response()->json($league->fresh());
    }

    public function destroy(Request $request, League $league): JsonResponse
    {
        $league = $this->ownedLeague($request, $league);
        $league->delete();

        return response()->json([
            'message' => 'League deleted successfully',
        ]);
    }

    private function ownedLeague(Request $request, League $league): League
    {
        return $request->user()
            ->leagues()
            ->whereKey($league->id)
            ->firstOrFail();
    }
}
