<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\Season;
use App\Models\Player;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TeamController extends Controller
{
    /**
     * Fetch all teams associated with a specific season.
     */
    public function index(Season $season): JsonResponse
    {
        return response()->json($season->teams);
    }

    /**
     * Register a new team within a season.
     */
    public function store(Request $request, Season $season): JsonResponse
    {
        $payload = $request->validate([
            'name'  => ['required', 'string', 'max:255'],
            'coach' => ['required', 'string', 'max:255'],
        ]);

        $club = $season->teams()->create($payload);

        return response()->json($club, 201);
    }

    /**
     * Get a team's full details and roster.
     */
    public function show(Team $team): JsonResponse
    {
        return response()->json($team->load('players'));
    }

    /**
     * Update team administrative details.
     */
    public function update(Request $request, Team $team): JsonResponse
    {
        $input = $request->validate([
            'name'  => ['sometimes', 'string', 'max:255'],
            'coach' => ['sometimes', 'string', 'max:255'],
        ]);

        $team->fill($input)->save();

        return response()->json($team);
    }

    /**
     * Add an athlete to the team roster.
     */
    public function addPlayer(Request $request, Team $team): JsonResponse
    {
        $validated = $request->validate([
            'player_id'     => ['required', 'exists:players,id'],
            'jersey_number' => ['required', 'integer', 'between:0,99'],
        ]);

        // Check roster status to prevent duplicates manually for custom error message
        if ($team->players()->where('players.id', $validated['player_id'])->exists()) {
            return response()->json(['error' => 'Roster conflict: Athlete already assigned.'], 422);
        }

        $team->players()->attach($validated['player_id'], [
            'jersey_number' => $validated['jersey_number'],
        ]);

        return response()->json(['status' => 'Roster updated.'], 201);
    }

    /**
     * Remove an athlete from the team.
     */
    public function removePlayer(Team $team, Player $player): JsonResponse
    {
        // Using Route Model Binding for both Team and Player makes this very clean
        $team->players()->detach($player->id);

        return response()->json([
            'status' => 'success',
            'info'   => "Player {$player->id} has been dropped from the team."
        ]);
    }
}