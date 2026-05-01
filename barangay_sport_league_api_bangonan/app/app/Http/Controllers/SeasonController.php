<?php

namespace App\Http\Controllers;

use App\Http\Resources\SeasonResource;
use App\Models\League;
use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SeasonController extends Controller
{
    public function index(Request $request, $leagueId)
    {
        $league = $request->user()->leagues()->findOrFail($leagueId);
        $seasons = $league->seasons()->with('teams', 'games')->get();
        return SeasonResource::collection($seasons);
    }

    public function store(Request $request, $leagueId)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
            'status' => 'sometimes|in:active,done',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $league = $request->user()->leagues()->findOrFail($leagueId);
        $season = $league->seasons()->create($request->all());
        $season->load('teams', 'games');

        return (new SeasonResource($season))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Request $request, $id)
    {
        $season = Season::with(['league', 'teams', 'games' => function ($query) {
            $query->with('homeTeam', 'awayTeam');
        }])->findOrFail($id);

        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return new SeasonResource($season);
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'start_date' => 'sometimes|required|date',
            'end_date' => 'sometimes|required|date|after:start_date',
            'status' => 'sometimes|in:active,done',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $season = Season::with('league')->findOrFail($id);

        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season->update($request->all());
        $season->load('teams', 'games');

        return new SeasonResource($season);
    }

    public function destroy(Request $request, $id)
    {
        $season = Season::with('league')->findOrFail($id);

        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $season->delete();

        return response()->json(['message' => 'Season deleted successfully']);
    }
}
