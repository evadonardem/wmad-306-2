<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LeaderboardController extends Controller
{
    public function index(Request $request, int $seasonId): JsonResponse
    {
        Season::where('id', $seasonId)
            ->whereHas('league', fn ($query) => $query->where('user_id', $request->user()->id))
            ->firstOrFail();

        $leaders = DB::table('player_stats')
            ->join('players', 'players.id', '=', 'player_stats.player_id')
            ->join('game_results', 'game_results.id', '=', 'player_stats.game_result_id')
            ->join('games', 'games.id', '=', 'game_results.game_id')
            ->where('games.season_id', $seasonId)
            ->where('games.status', 'done')
            ->select([
                'players.id as player_id',
                'players.name as player_name',
                DB::raw('SUM(player_stats.points) as total_points'),
            ])
            ->groupBy('players.id', 'players.name')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($leaders);
    }
}
