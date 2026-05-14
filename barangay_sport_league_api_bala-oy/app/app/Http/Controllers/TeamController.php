<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\Season;
use App\Models\Player;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    /**
     * Get all teams in a season.
     */
    public function indexByseason(Season $season, Request $request)
    {
        // Authorization check through league
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $teams = $season->teams()->with('players')->get();

        return response()->json([
            'data' => $teams,
        ], 200);
    }

    /**
     * Create a team for a season.
     */
    public function storeInSeason(Season $season, Request $request)
    {
        // Authorization check through league
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'coach' => 'required|string|max:255',
        ]);

        $team = $season->teams()->create($validated);

        return response()->json([
            'message' => 'Team created successfully',
            'data' => $team,
        ], 201);
    }

    /**
     * Get a specific team with its players.
     */
    public function show(Team $team, Request $request)
    {
        // Authorization check through league
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team->load('season', 'players');

        return response()->json([
            'data' => $team,
        ], 200);
    }

    /**
     * Update team information.
     */
    public function update(Team $team, Request $request)
    {
        // Authorization check through league
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'coach' => 'sometimes|string|max:255',
        ]);

        $team->update($validated);

        return response()->json([
            'message' => 'Team updated successfully',
            'data' => $team,
        ], 200);
    }

    /**
     * Add a player to a team with jersey number.
     */
    public function addPlayer(Team $team, Request $request)
    {
        // Authorization check through league
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'player_id' => 'sometimes|nullable|integer',
            'name' => 'required_without:player_id|string|max:255',
            'position' => 'required_with:name|string|max:255',
            'birthdate' => 'nullable|date',
            'jersey_number' => 'required|string|max:255',
        ]);

        $playerId = $validated['player_id'] ?? null;
        $player = null;

        if ($playerId) {
            $player = Player::find($playerId);
        }

        if (!$player) {
            if (!isset($validated['name'])) {
                return response()->json(['message' => 'The selected player id is invalid.'], 422);
            }

            $playerData = [
                'name' => $validated['name'],
                'position' => $validated['position'] ?? null,
                'birthdate' => $validated['birthdate'] ?? null,
            ];

            $player = Player::create(array_filter($playerData, function ($value) {
                return $value !== null;
            }));

            $playerId = $player->id;
        }

        if ($team->players()->where('player_id', $playerId)->exists()) {
            return response()->json(['message' => 'Player is already on this team'], 400);
        }

        $team->players()->attach($playerId, [
            'jersey_number' => $validated['jersey_number'],
        ]);

        return response()->json([
            'message' => 'Player added to team successfully',
            'data' => ['player_id' => $playerId],
        ], 201);
    }

    /**
     * Remove a player from a team.
     */
    public function removePlayer(Team $team, Player $player, Request $request)
    {
        // Authorization check through league
        if ($team->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $team->players()->detach($player->id);

        return response()->json([
            'message' => 'Player removed from team successfully',
        ], 200);
    }
}
