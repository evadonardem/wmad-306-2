<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    public function index(Request $request)
    {
        return $request->user()->leagues;
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'sport' => 'required|string',
            'description' => 'nullable|string',
        ]);

        $league = $request->user()->leagues()->create($validated);

        return response()->json($league, 201);
    }

    public function show(Request $request, League $league)
    {
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $league->load('seasons');
    }

    public function update(Request $request, League $league)
    {
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string',
            'sport' => 'sometimes|required|string',
            'description' => 'nullable|string',
        ]);

        $league->update($validated);

        return response()->json($league);
    }

    public function destroy(Request $request, League $league)
    {
        if ($league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $league->delete();

        return response()->json(['message' => 'League deleted']);
    }
}
