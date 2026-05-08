<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    public function index(Request $request, $leagueId)
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);
        $seasons = $league->seasons()->get();
        return response()->json($seasons);
    }

    public function store(Request $request, $leagueId)
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);

        $request->validate([
            'name'       => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date'   => 'required|date|after_or_equal:start_date',
            'status'     => 'in:active,done',
        ]);

        $season = $league->seasons()->create($request->only('name', 'start_date', 'end_date', 'status'));

        return response()->json($season, 201);
    }

    public function show(Request $request, $id)
    {
        $season = Season::with(['teams', 'games.homeTeam', 'games.awayTeam', 'games.result'])->findOrFail($id);

        // Verify league belongs to authenticated user
        $request->user()->leagues()->findOrFail($season->league_id);

        return response()->json($season);
    }

    public function update(Request $request, $id)
    {
        $season = Season::findOrFail($id);
        $request->user()->leagues()->findOrFail($season->league_id);

        $request->validate([
            'name'       => 'sometimes|string|max:255',
            'start_date' => 'sometimes|date',
            'end_date'   => 'sometimes|date',
            'status'     => 'sometimes|in:active,done',
        ]);

        $season->update($request->only('name', 'start_date', 'end_date', 'status'));

        return response()->json($season);
    }
}