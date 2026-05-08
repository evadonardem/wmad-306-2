<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Team;
use App\Models\Game;
use Illuminate\Http\Request;

class StandingsController extends Controller
{
    /**
     * Task 8: Calculate standings for a specific season.
     * This version calculates directly from the games table scores.
     */
    public function index(Season $season)
    {
        // Get all teams in this season
        $teams = Team::where('season_id', $season->id)->get();
        
        $standings = $teams->map(function ($team) use ($season) {
            // Get all games for this team in this season that are marked as 'done'
            // and have scores recorded.
            $games = Game::where('season_id', $season->id)
                ->where(function($query) use ($team) {
                    $query->where('home_team_id', $team->id)
                          ->orWhere('away_team_id', $team->id);
                })
                ->where('status', 'done')
                ->whereNotNull('home_team_score')
                ->whereNotNull('away_team_score')
                ->get();

            $wins = 0;
            $losses = 0;
            $draws = 0;

            foreach ($games as $game) {
                $isHome = $game->home_team_id == $team->id;
                
                // Determine our score vs opponent score based on home/away status
                $myScore = $isHome ? $game->home_team_score : $game->away_team_score;
                $oppScore = $isHome ? $game->away_team_score : $game->home_team_score;

                if ($myScore > $oppScore) {
                    $wins++;
                } elseif ($myScore < $oppScore) {
                    $losses++;
                } else {
                    $draws++;
                }
            }

            return [
                'team' => $team->name,
                'played' => $games->count(),
                'wins' => $wins,
                'losses' => $losses,
                'draws' => $draws,
                'points' => ($wins * 2) + ($draws * 1) // 2 points for win, 1 for draw
            ];
        });

        // Sort by wins (or points) descending and reset keys
        return response()->json($standings->sortByDesc('wins')->values());
    }
}