<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\League;

class LeagueController extends Controller
{
    public function index(Request $request)
    {
        $leagues = $request->user()->leagues;
        return response()->json($leagues);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'sport' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $league = $request->user()->leagues()->create($request->all());
        return response()->json($league, 201);
    }

    public function show(Request $request, $id)
    {
        $league = $request->user()->leagues()->with('seasons')->findOrFail($id);
        return response()->json($league);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'sport' => 'required|string|max:255',
            'description' => 'nullable|string',
        ]);

        $league = $request->user()->leagues()->findOrFail($id);
        $league->update($request->all());
        return response()->json($league);
    }

    public function destroy(Request $request, $id)
    {
        $league = $request->user()->leagues()->findOrFail($id);
        $league->delete();
        return response()->json(null, 204);
    }
}
