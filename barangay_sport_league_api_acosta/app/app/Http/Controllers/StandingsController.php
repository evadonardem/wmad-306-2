<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use Illuminate\Http\JsonResponse;

class StandingsController extends Controller
{
    public function index(League $league, Season $season): JsonResponse
    {
        $this->authorize('view', $league);

        $teams = $season->teams()->with(['homeGames.gameResult', 'awayGames.gameResult'])->get();

        $standings = $teams->map(function ($team) {
            $wins = 0;
            $losses = 0;

            foreach ($team->homeGames as $game) {
                if ($game->status === 'done' && $game->gameResult) {
                    if ($game->gameResult->home_score > $game->gameResult->away_score) {
                        $wins++;
                    } elseif ($game->gameResult->home_score < $game->gameResult->away_score) {
                        $losses++;
                    }
                }
            }

            foreach ($team->awayGames as $game) {
                if ($game->status === 'done' && $game->gameResult) {
                    if ($game->gameResult->away_score > $game->gameResult->home_score) {
                        $wins++;
                    } elseif ($game->gameResult->away_score < $game->gameResult->home_score) {
                        $losses++;
                    }
                }
            }

            return [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $wins + $losses,
                'win_percentage' => ($wins + $losses) > 0 ? round($wins / ($wins + $losses), 3) : 0,
            ];
        })->sortByDesc('win_percentage')->values();

        return response()->json($standings);
    }
}
