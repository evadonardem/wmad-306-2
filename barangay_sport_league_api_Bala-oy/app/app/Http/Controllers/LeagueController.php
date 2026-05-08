<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    /**
     * Get all leagues for the authenticated user.
     */
    public function index(Request $request)
    {
        $leagues = $request->user()->leagues()->with('seasons')->get();

        return response()->json([
            'data' => $leagues,
        ], 200);
    }

    /**
     * Create a new league.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'sport' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $league = $request->user()->leagues()->create($validated);

        return response()->json([
            'message' => 'League created successfully',
            'data' => $league,
        ], 201);
    }

    /**
     * Get a specific league with its seasons.
     */
    public function show(League $league, Request $request)
    {
        // Authorization check
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $league->load('seasons.teams', 'seasons.games');

        return response()->json([
            'data' => $league,
        ], 200);
    }

    /**
     * Update a league.
     */
    public function update(League $league, Request $request)
    {
        // Authorization check
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'sport' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
        ]);

        $league->update($validated);

        return response()->json([
            'message' => 'League updated successfully',
            'data' => $league,
        ], 200);
    }

    /**
     * Delete a league.
     */
    public function destroy(League $league, Request $request)
    {
        // Authorization check
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $league->delete();

        return response()->json([
            'message' => 'League deleted successfully',
        ], 200);
    }
}
