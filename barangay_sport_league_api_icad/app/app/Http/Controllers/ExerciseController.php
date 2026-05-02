<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Player;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExerciseController extends Controller
{
    // Exercise 1: Season Summary
    public function seasonSummary(Season $season)
    {
        return response()->json([
            'season' => $season->name,
            'total_teams' => $season->teams()->count(),
            'status' => $season->status
        ]);
    }

    // Leaderboard Requirement: Top 10 Players
    public function leaderboard()
    {
        $topPlayers = PlayerStat::with('player')
            ->select('player_id', DB::raw('SUM(points) as total_points'))
            ->groupBy('player_id')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($topPlayers);
    }

    // Exercise 3: Player Career Profile
    public function playerProfile(Player $player)
    {
        $careerPoints = PlayerStat::where('player_id', $player->id)->sum('points');
        
        return response()->json([
            'player' => $player,
            'career_stats' => [
                'total_points' => (int) $careerPoints
            ]
        ]);
    }
}