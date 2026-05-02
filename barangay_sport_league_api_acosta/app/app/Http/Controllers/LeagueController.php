<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class LeagueController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $leagues = $request->user()->leagues()->with('seasons')->get();
        return response()->json($leagues);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sport' => 'required|string|max:100',
            'description' => 'nullable|string',
        ]);

        $league = League::create([
            'user_id' => Auth::id(),
            'name' => $validated['name'],
            'sport' => $validated['sport'],
            'description' => $validated['description'] ?? null,
        ]);

        return response()->json($league, 201);
    }

    public function show(League $league): JsonResponse
    {
        $this->authorize('view', $league);
        return response()->json($league->load('seasons'));
    }

    public function update(Request $request, League $league): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'sport' => 'sometimes|string|max:100',
            'description' => 'nullable|string',
        ]);

        $league->update($validated);

        return response()->json($league);
    }

    public function destroy(League $league): JsonResponse
    {
        $this->authorize('delete', $league);
        $league->delete();

        return response()->json(['message' => 'League deleted successfully']);
    }
}
