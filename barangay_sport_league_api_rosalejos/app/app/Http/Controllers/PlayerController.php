<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlayerController extends Controller
{
    public function index()
    {
        return Player::all();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'birthdate' => 'required|date',
            'position' => 'required|string',
        ]);

        $player = Player::create($validated);

        return response()->json($player, 201);
    }

    public function show(Player $player)
    {
        return $player;
    }

    public function update(Request $request, Player $player)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string',
            'birthdate' => 'sometimes|required|date',
            'position' => 'sometimes|required|string',
        ]);

        $player->update($validated);

        return response()->json($player);
    }

    public function destroy(Player $player)
    {
        $player->delete();

        return response()->json(['message' => 'Player deleted']);
    }

    public function showProfile(Request $request, Player $player)
    {
        // Team history
        $teams = $player->teams()->with('season')->get()->map(function ($team) {
            return [
                'team_name' => $team->name,
                'season_name' => $team->season->name,
                'jersey_number' => $team->pivot->jersey_number,
            ];
        });

        // Career totals
        $careerTotals = PlayerStat::where('player_id', $player->id)
            ->select(
                DB::raw('COUNT(*) as total_games_played'),
                DB::raw('SUM(points) as total_points'),
                DB::raw('SUM(assists) as total_assists'),
                DB::raw('SUM(rebounds) as total_rebounds')
            )
            ->first();

        // Personal best (most points in a single game)
        $personalBest = PlayerStat::where('player_id', $player->id)
            ->orderByDesc('points')
            ->first();

        return [
            'name' => $player->name,
            'position' => $player->position,
            'teams' => $teams,
            'career_totals' => [
                'total_games_played' => (int)$careerTotals->total_games_played,
                'total_points' => (int)$careerTotals->total_points,
                'total_assists' => (int)$careerTotals->total_assists,
                'total_rebounds' => (int)$careerTotals->total_rebounds,
            ],
            'personal_best' => $personalBest ? [
                'points' => $personalBest->points,
                'assists' => $personalBest->assists,
                'rebounds' => $personalBest->rebounds,
                'fouls' => $personalBest->fouls,
            ] : null
        ];
    }
}
