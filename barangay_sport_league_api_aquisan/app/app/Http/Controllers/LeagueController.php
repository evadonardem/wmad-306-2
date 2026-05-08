<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        return response()->json($request->user()->leagues()->get());
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $league = $request->user()->leagues()->create($data);

        return response()->json($league, 201);
    }

    public function show(Request $request, League $league): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);

        return response()->json($league);
    }

    public function update(Request $request, League $league): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $league->update($data);

        return response()->json($league);
    }

    public function destroy(Request $request, League $league): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);

        $league->delete();

        return response()->json(['message' => 'League deleted.']);
    }

    protected function authorizeLeagueOwner(Request $request, League $league): void
    {
        if ($league->user_id !== $request->user()->id) {
            abort(403);
        }
    }
}
