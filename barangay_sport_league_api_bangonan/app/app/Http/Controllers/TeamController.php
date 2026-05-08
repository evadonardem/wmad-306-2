<?php

namespace App\Http\Controllers;

use App\Http\Resources\TeamResource;
use App\Models\Player;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TeamController extends Controller
{
    public function index(Request $request, $seasonId)
    {
        $season = Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $teams = $season->teams()->with('players')->get();
        return TeamResource::collection($teams);
    }

    public function store(Request $request, $seasonId)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $season = Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team = $season->teams()->create($request->all());
        $team->load('players');

        return (new TeamResource($team))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Request $request, $id)
    {
        $team = Team::with(['season.league', 'players'])->findOrFail($id);
        
        // Ensure the team belongs to a season owned by the authenticated user
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return new TeamResource($team);
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $team = Team::with('season.league')->findOrFail($id);
        
        // Ensure the team belongs to a season owned by the authenticated user
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team->update($request->all());
        $team->load('players');

        return new TeamResource($team);
    }

    public function destroy(Request $request, $id)
    {
        $team = Team::with('season.league')->findOrFail($id);
        
        // Ensure the team belongs to a season owned by the authenticated user
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team->delete();

        return response()->json(['message' => 'Team deleted successfully']);
    }

    public function addPlayer(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'player_id' => 'required|exists:players,id',
            'jersey_number' => 'required|integer|min:1|max:99',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $team = Team::with('season.league')->findOrFail($id);
        
        // Ensure the team belongs to a season owned by the authenticated user
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Check if player is already on this team
        if ($team->players()->where('player_id', $request->player_id)->exists()) {
            return response()->json(['message' => 'Player is already on this team'], 422);
        }

        $team->players()->attach($request->player_id, [
            'jersey_number' => $request->jersey_number
        ]);

        $team->load('players');

        return new TeamResource($team);
    }

    public function removePlayer(Request $request, $id, $playerId)
    {
        $team = Team::with('season.league')->findOrFail($id);
        
        // Ensure the team belongs to a season owned by the authenticated user
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Check if player is on this team
        if (!$team->players()->where('player_id', $playerId)->exists()) {
            return response()->json(['message' => 'Player is not on this team'], 404);
        }

        $team->players()->detach($playerId);

        return response()->json(['message' => 'Player removed from team successfully']);
    }
}
