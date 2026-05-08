<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $leagues = $request->user()
            ->leagues()
            ->withCount('seasons')
            ->latest()
            ->get();

        return response()->json($leagues);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'sport' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
        ]);

        $league = $request->user()->leagues()->create($data);

        return response()->json($league, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $league = $this->ownedLeague($request, $id)
            ->with(['seasons.teams'])
            ->firstOrFail();

        return response()->json($league);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $league = $this->ownedLeague($request, $id)->firstOrFail();

        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'sport' => ['sometimes', 'required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
        ]);

        $league->update($data);

        return response()->json($league->fresh());
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $league = $this->ownedLeague($request, $id)->firstOrFail();
        $league->delete();

        return response()->json([
            'message' => 'League deleted successfully.',
        ]);
    }

    private function ownedLeague(Request $request, int $id)
    {
        return League::where('id', $id)->where('user_id', $request->user()->id);
    }
}
