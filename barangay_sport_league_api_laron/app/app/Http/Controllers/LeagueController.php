<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    public function index(Request $request)
    {
        $leagues = $request->user()->leagues()->with('seasons')->get();
        return response()->json($leagues);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'sport' => 'required|string',
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
            'name' => 'sometimes|required|string',
            'sport' => 'sometimes|required|string',
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
