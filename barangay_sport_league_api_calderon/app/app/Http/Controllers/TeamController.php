<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use App\Models\Player;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    /**
     * Display a listing of teams in a season.
     */
    public function index(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $season->teams;
    }

    /**
     * Store a newly created team in a season.
     */
    public function store(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'required|string|max:255',
        ]);

        $team = $season->teams()->create($validated);

        return response()->json($team, 201);
    }

    /**
     * Display the specified team.
     */
    public function show(Request $request, Team $team)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $team->load('players');
    }

    /**
     * Update the specified team.
     */
    public function update(Request $request, Team $team)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'required|string|max:255',
        ]);

        $team->update($validated);

        return $team;
    }

    /**
     * Add player to team with jersey number.
     */
    public function addPlayer(Request $request, Team $team)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'player_id' => 'required_without:name|exists:players,id',
            'name' => 'required_without:player_id|string|max:255',
            'birthdate' => 'required_with:name|date',
            'position' => 'required_with:name|string|max:255',
            'jersey_number' => 'required|integer',
        ]);

        if ($request->has('name')) {
            $player = Player::create($request->only(['name', 'birthdate', 'position']));
        } else {
            $player = Player::findOrFail($request->player_id);
        }

        $team->players()->attach($player->id, ['jersey_number' => $request->jersey_number]);

        return response()->json(['message' => 'Player added to team', 'player' => $player]);
    }

    /**
     * Remove player from team.
     */
    public function removePlayer(Request $request, Team $team, $playerId)
    {
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team->players()->detach($playerId);

        return response()->json(['message' => 'Player removed from team']);
    }
}
