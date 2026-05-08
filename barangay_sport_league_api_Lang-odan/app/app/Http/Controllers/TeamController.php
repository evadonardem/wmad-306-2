<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use App\Models\Player;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        return response()->json($season->teams);
    }

    public function store(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'name'  => 'required|string',
            'coach' => 'nullable|string',
        ]);
        $team = $season->teams()->create($data);
        return response()->json($team, 201);
    }

    public function show(Request $request, Team $team)
    {
        // Ensure team belongs to auth user's season
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // Load players WITH pivot data (jersey number)
        $team->load('players');
        return response()->json($team);
    }

    public function update(Request $request, Team $team)
    {
        // Ensure team belongs to auth user's season
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $team->update($request->only(['name', 'coach']));
        return response()->json($team);
    }

    // POST /api/teams/{team}/players
    // Add a player to a team with a jersey number
    public function addPlayer(Request $request, Team $team)
    {
        // Ensure team belongs to auth user's season
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $data = $request->validate([
            'player_id'    => 'required|exists:players,id',
            'jersey_number'=> 'required|integer',
        ]);

        // attach() inserts into the pivot table
        $team->players()->attach($data['player_id'], [
            'jersey_number' => $data['jersey_number']
        ]);

        return response()->json(['message' => 'Player added to team']);
    }

    // DELETE /api/teams/{team}/players/{player}
    public function removePlayer(Request $request, Team $team, Player $player)
    {
        // Ensure team belongs to auth user's season
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        // detach() removes from the pivot table
        $team->players()->detach($player->id);
        return response()->json(['message' => 'Player removed from team']);
    }
}