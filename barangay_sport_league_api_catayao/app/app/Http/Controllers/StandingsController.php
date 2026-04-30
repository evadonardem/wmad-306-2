<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StandingsController extends Controller
{
    public function index(Request $request, int $seasonId): JsonResponse
    {
        $season = Season::where('id', $seasonId)
            ->whereHas('league', fn ($query) => $query->where('user_id', $request->user()->id))
            ->with(['teams', 'games' => fn ($query) => $query->where('status', 'done')->with('result')])
            ->firstOrFail();

        $standings = $season->teams->map(function ($team) use ($season) {
            $wins = 0;
            $losses = 0;

            foreach ($season->games as $game) {
                if (! $game->result) {
                    continue;
                }

                if ((int) $game->home_team_id === (int) $team->id) {
                    $game->result->home_score > $game->result->away_score ? $wins++ : $losses++;
                }

                if ((int) $game->away_team_id === (int) $team->id) {
                    $game->result->away_score > $game->result->home_score ? $wins++ : $losses++;
                }
            }

            return [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $wins + $losses,
            ];
        })->sortByDesc('wins')->values();

        return response()->json($standings);
    }
}
