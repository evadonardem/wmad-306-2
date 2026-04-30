<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId)->firstOrFail();

        return response()->json(
            $season->teams()->with('players')->latest()->get()
        );
    }

    public function store(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId)->firstOrFail();

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'coach' => ['required', 'string', 'max:255'],
        ]);

        $team = $season->teams()->create($data);

        return response()->json($team, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $team = $this->ownedTeam($request, $id)
            ->with(['season.league', 'players'])
            ->firstOrFail();

        return response()->json($team);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $team = $this->ownedTeam($request, $id)->firstOrFail();

        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'coach' => ['sometimes', 'required', 'string', 'max:255'],
        ]);

        $team->update($data);

        return response()->json($team->fresh('players'));
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $team = $this->ownedTeam($request, $id)->firstOrFail();
        $team->delete();

        return response()->json([
            'message' => 'Team deleted successfully.',
        ]);
    }

    public function addPlayer(Request $request, int $id): JsonResponse
    {
        $team = $this->ownedTeam($request, $id)->firstOrFail();

        $data = $request->validate([
            'player_id' => ['required', 'integer', 'exists:players,id'],
            'jersey_number' => ['required', 'integer', 'min:0', 'max:999'],
        ]);

        Player::findOrFail($data['player_id']);

        if ($team->players()->where('players.id', $data['player_id'])->exists()) {
            return response()->json([
                'message' => 'Player is already assigned to this team.',
            ], 422);
        }

        if ($team->players()->wherePivot('jersey_number', $data['jersey_number'])->exists()) {
            return response()->json([
                'message' => 'Jersey number is already used by another player on this team.',
            ], 422);
        }

        $team->players()->attach($data['player_id'], [
            'jersey_number' => $data['jersey_number'],
        ]);

        return response()->json([
            'message' => 'Player added to team successfully.',
            'team' => $team->fresh('players'),
        ], 201);
    }

    public function removePlayer(Request $request, int $id, int $playerId): JsonResponse
    {
        $team = $this->ownedTeam($request, $id)->firstOrFail();

        if (! $team->players()->where('players.id', $playerId)->exists()) {
            return response()->json([
                'message' => 'Player is not assigned to this team.',
            ], 404);
        }

        $team->players()->detach($playerId);

        return response()->json([
            'message' => 'Player removed from team successfully.',
        ]);
    }

    private function ownedSeason(Request $request, int $seasonId)
    {
        return Season::where('id', $seasonId)
            ->whereHas('league', fn ($query) => $query->where('user_id', $request->user()->id));
    }

    private function ownedTeam(Request $request, int $teamId)
    {
        return Team::where('id', $teamId)
            ->whereHas('season.league', fn ($query) => $query->where('user_id', $request->user()->id));
    }
}
