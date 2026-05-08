<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SeasonController extends Controller
{
    public function index(Request $request, League $league): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);

        return response()->json($league->seasons()->get());
    }

    public function store(Request $request, League $league): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $season = $league->seasons()->create($data);

        return response()->json($season, 201);
    }

    public function show(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);
        $this->authorizeSeasonForLeague($league, $season);

        return response()->json($season);
    }

    public function update(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);
        $this->authorizeSeasonForLeague($league, $season);

        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);

        $season->update($data);

        return response()->json($season);
    }

    public function destroy(Request $request, League $league, Season $season): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);
        $this->authorizeSeasonForLeague($league, $season);

        $season->delete();

        return response()->json(['message' => 'Season deleted.']);
    }

    protected function authorizeLeagueOwner(Request $request, League $league): void
    {
        if ($league->user_id !== $request->user()->id) {
            abort(403);
        }
    }

    protected function authorizeSeasonForLeague(League $league, Season $season): void
    {
        if ($season->league_id !== $league->id) {
            abort(404);
        }
    }
}
