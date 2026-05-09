<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    // GET /api/players
    public function index()
    {
        return response()->json(Player::all());
    }

    // POST /api/players
    public function store(Request $request)
    {
        $data = $request->validate([
            'name'      => 'required|string|max:255',
            'birthdate' => 'required|date',
            'position'  => 'required|string|max:100',
        ]);

        $player = Player::create($data);

        return response()->json($player, 201);
    }

    // GET /api/players/{id}/profile  ← EXERCISE 3
    public function profile($id)
    {
        $player = Player::with([
            'teams.season.league',
            'stats.gameResult.game',
        ])->find($id);

        if (! $player) {
            return response()->json(['message' => 'Player not found.'], 404);
        }

        // Teams list with season name and jersey number from pivot
        $teams = $player->teams->map(fn($team) => [
            'team_name'     => $team->name,
            'coach'         => $team->coach,
            'season'        => $team->season->name,
            'league'        => $team->season->league->name,
            'jersey_number' => $team->pivot->jersey_number,
        ]);

        // Career totals aggregated across all seasons
        $stats = $player->stats;

        $careerTotals = [
            'games_played'    => $stats->unique('game_result_id')->count(),
            'total_points'    => $stats->sum('points'),
            'total_assists'   => $stats->sum('assists'),
            'total_rebounds'  => $stats->sum('rebounds'),
        ];

        // Personal best game (most points in a single game)
        $bestStat = $stats->sortByDesc('points')->first();

        $personalBest = $bestStat ? [
            'game_id'     => $bestStat->gameResult->game_id,
            'points'      => $bestStat->points,
            'assists'     => $bestStat->assists,
            'rebounds'    => $bestStat->rebounds,
            'fouls'       => $bestStat->fouls,
            'scheduled_at'=> $bestStat->gameResult->game->scheduled_at,
        ] : null;

        return response()->json([
            'player'        => ['name' => $player->name, 'position' => $player->position],
            'teams'         => $teams,
            'career_totals' => $careerTotals,
            'personal_best_game' => $personalBest,
        ]);
    }
}