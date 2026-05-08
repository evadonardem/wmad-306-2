<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Database\QueryException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId);

        return response()->json(
            $season->teams()->with('players')->latest()->get()
        );
    }

    public function store(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'coach' => ['required', 'string', 'max:255'],
        ]);

        $team = $season->teams()->create($validated);

        return response()->json($team, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $team = $this->ownedTeam($request, $id)->load('players');

        return response()->json($team);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $team = $this->ownedTeam($request, $id);

        $validated = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'coach' => ['sometimes', 'required', 'string', 'max:255'],
        ]);

        $team->update($validated);

        return response()->json($team->fresh());
    }

    public function addPlayer(Request $request, int $id): JsonResponse
    {
        $team = $this->ownedTeam($request, $id);

        $validated = $request->validate([
            'player_id' => ['nullable', 'integer', 'exists:players,id'],
            'name' => ['required_without:player_id', 'string', 'max:255'],
            'birthdate' => ['required_without:player_id', 'date'],
            'position' => ['required_without:player_id', 'string', 'max:255'],
            'jersey_number' => ['required', 'integer', 'min:0'],
        ]);

        $player = isset($validated['player_id'])
            ? Player::findOrFail($validated['player_id'])
            : Player::create([
                'name' => $validated['name'],
                'birthdate' => $validated['birthdate'],
                'position' => $validated['position'],
            ]);

        try {
            $team->players()->attach($player->id, [
                'jersey_number' => $validated['jersey_number'],
            ]);
        } catch (QueryException $exception) {
            return response()->json([
                'message' => 'Unable to assign player. Check duplicate team membership or jersey number.',
            ], 422);
        }

        return response()->json(
            $team->fresh()->load('players')
        );
    }

    public function removePlayer(Request $request, int $id, int $playerId): JsonResponse
    {
        $team = $this->ownedTeam($request, $id);
        $team->players()->detach($playerId);

        return response()->json([
            'message' => 'Player removed from team successfully',
        ]);
    }

    private function ownedSeason(Request $request, int $seasonId): Season
    {
        return Season::query()
            ->whereKey($seasonId)
            ->whereHas('league', function ($query) use ($request): void {
                $query->where('user_id', $request->user()->id);
            })
            ->firstOrFail();
    }

    private function ownedTeam(Request $request, int $teamId): Team
    {
        return Team::query()
            ->whereKey($teamId)
            ->whereHas('season.league', function ($query) use ($request): void {
                $query->where('user_id', $request->user()->id);
            })
            ->firstOrFail();
    }
}
