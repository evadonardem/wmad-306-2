<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class LeagueController extends Controller
{
    /**
     * Display a listing of the user's leagues.
     */
    public function index(Request $request): JsonResponse
    {
        // Using the relationship as a property is slightly cleaner for simple gets
        return response()->json($request->user()->leagues);
    }

    /**
     * Store a newly created league in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $attributes = $request->validate([
            'name'        => ['required', 'string', 'max:255'],
            'sport'       => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
        ]);

        // Creating directly through the user relationship ensures the foreign key is set
        $newLeague = $request->user()->leagues()->create($attributes);

        return response()->json($newLeague, 201);
    }

    /**
     * Display the specified league with its seasons.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        // Scope the query to the user's leagues immediately
        $league = $request->user()
            ->leagues()
            ->with('seasons')
            ->findOrFail($id);

        return response()->json($league);
    }

    /**
     * Update the specified league in storage.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $league = $request->user()->leagues()->findOrFail($id);

        $validated = $request->validate([
            'name'        => ['sometimes', 'string', 'max:255'],
            'sport'       => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
        ]);

        $league->fill($validated)->save();

        return response()->json($league);
    }

    /**
     * Remove the specified league from storage.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $targetLeague = $request->user()->leagues()->findOrFail($id);
        
        $targetLeague->delete();

        return response()->json([
            'status' => 'deleted',
            'info'   => 'The league has been removed.'
        ]);
    }
}