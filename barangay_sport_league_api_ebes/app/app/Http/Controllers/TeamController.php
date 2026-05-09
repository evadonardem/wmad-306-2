<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use App\Models\Player;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    // GET /api/seasons/{id}/teams
    public function index($seasonId)
    {
        $season = Season::findOrFail($seasonId);

        return response()->json($season->teams()->get());
    }

    // POST /api/seasons/{id}/teams
    public function store(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);

        $data = $request->validate([
            'name'  => 'required|string|max:255',
            'coach' => 'required|string|max:255',
        ]);

        $team = $season->teams()->create($data);

        return response()->json($team, 201);
    }

    // GET /api/teams/{id}
    public function show($id)
    {
        $team = Team::with('players')->findOrFail($id);

        return response()->json($team);
    }

    // PUT /api/teams/{id}
    public function update(Request $request, $id)
    {
        $team = Team::findOrFail($id);

        $data = $request->validate([
            'name'  => 'sometimes|string|max:255',
            'coach' => 'sometimes|string|max:255',
        ]);

        $team->update($data);

        return response()->json($team);
    }

    // POST /api/teams/{id}/players
    public function addPlayer(Request $request, $id)
    {
        $team = Team::findOrFail($id);

        $data = $request->validate([
            'player_id'     => 'required|exists:players,id',
            'jersey_number' => 'required|integer|min:0|max:99',
        ]);

        // Prevent duplicate roster entry
        if ($team->players()->where('player_id', $data['player_id'])->exists()) {
            return response()->json([
                'message' => 'Player is already on this team.',
            ], 422);
        }

        $team->players()->attach($data['player_id'], [
            'jersey_number' => $data['jersey_number'],
        ]);

        return response()->json(['message' => 'Player added to team successfully.'], 201);
    }

    // DELETE /api/teams/{id}/players/{playerId}
    public function removePlayer($id, $playerId)
    {
        $team = Team::findOrFail($id);
        $team->players()->detach($playerId);

        return response()->json(['message' => 'Player removed from team successfully.']);
    }
}