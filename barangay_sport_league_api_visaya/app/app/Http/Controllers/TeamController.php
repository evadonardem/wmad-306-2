<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TeamController extends Controller
{
    /**
     * Display a listing of the resource.
     * GET /api/seasons/{id}/teams
     */
    public function index(string $id)
    {
        $season = Season::whereHas('league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);
        return response()->json($season->teams);
    }

    /**
     * Store a newly created resource in storage.
     * POST /api/seasons/{id}/teams
     */
    public function store(Request $request, string $id)
    {
        $season = Season::whereHas('league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'required|string|max:255',
        ]);

        $team = $season->teams()->create($validated);

        return response()->json($team, 201);
    }

    /**
     * Display the specified resource.
     * GET /api/teams/{id}
     */
    public function show(string $id)
    {
        $team = Team::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->with('players')->findOrFail($id);
        return response()->json($team);
    }

    /**
     * Update the specified resource in storage.
     * PUT /api/teams/{id}
     */
    public function update(Request $request, string $id)
    {
        $team = Team::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'coach' => 'sometimes|required|string|max:255',
        ]);

        $team->update($validated);
        return response()->json($team);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        $team = Team::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);
        $team->delete();
        return response()->json(['message' => 'Team deleted successfully']);
    }

    /**
     * Add player to team with jersey number.
     * POST /api/teams/{id}/players
     */
    public function addPlayer(Request $request, string $id)
    {
        $team = Team::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($id);

        $request->validate([
            'player_id' => 'required|exists:players,id',
            'jersey_number' => 'required|integer',
        ]);

        if ($team->players()->where('players.id', $request->player_id)->exists()) {
            return response()->json(['message' => 'Player is already in this team'], 422);
        }

        // This follows the manual's pivot attach pattern.
        $team->players()->attach($request->player_id, [
            'jersey_number' => $request->jersey_number
        ]);

        return response()->json(['message' => 'Player added to team successfully']);
    }

    /**
     * Remove player from team.
     * DELETE /api/teams/{teamId}/players/{playerId}
     */
    public function removePlayer(string $teamId, string $playerId)
    {
        $team = Team::whereHas('season.league', function ($query) {
            $query->where('user_id', Auth::id());
        })->findOrFail($teamId);
        
        // This detaches the player from the pivot table
        $team->players()->detach($playerId);

        return response()->json(['message' => 'Player removed from team successfully']);
    }
}