<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\PlayerStat;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    // POST /api/players
    public function store(Request $request)
    {
        $data = $request->validate([
            'name'      => 'required|string',
            'birthdate' => 'nullable|date',
            'position'  => 'nullable|string',
        ]);

        $player = Player::create($data);
        return response()->json($player, 201);
    }

    // GET /api/players/{player}/profile
    public function profile(Request $request, Player $player)
    {
        // Check if player is associated with any teams in user's leagues
        $userTeamIds = $request->user()->leagues()
            ->with('seasons.teams')
            ->get()
            ->pluck('seasons.*.teams.*.id')
            ->flatten()
            ->unique();

        $playerTeamIds = $player->teams()->pluck('teams.id');

        if ($playerTeamIds->intersect($userTeamIds)->isEmpty()) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // Load all teams with season info and jersey number from pivot
        $player->load(['teams.season']);

        $teams = $player->teams->map(function ($team) {
            return [
                'team'          => $team->name,
                'season'        => $team->season->name,
                'jersey_number' => $team->pivot->jersey_number,
            ];
        });

        // Career totals across all games
        $stats = PlayerStat::where('player_id', $player->id)->get();

        $careerTotals = [
            'games_played'   => $stats->count(),
            'total_points'   => $stats->sum('points'),
            'total_assists'  => $stats->sum('assists'),
            'total_rebounds' => $stats->sum('rebounds'),
        ];

        // Personal best (most points in a single game)
        $bestStat = $stats->sortByDesc('points')->first();
        $personalBest = null;
        if ($bestStat) {
            $personalBest = [
                'points'         => $bestStat->points,
                'game_result_id' => $bestStat->game_result_id,
            ];
        }

        return response()->json([
            'name'          => $player->name,
            'position'      => $player->position,
            'teams'         => $teams,
            'career_totals' => $careerTotals,
            'personal_best' => $personalBest,
        ]);
    }
}