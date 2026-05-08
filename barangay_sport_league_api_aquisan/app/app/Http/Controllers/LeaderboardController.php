<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\PlayerStat;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class LeaderboardController extends Controller
{
    public function topPlayers(): JsonResponse
    {
        $topPlayers = Player::select('players.id', 'players.name', 'players.created_at', 'players.updated_at')
            ->selectRaw('COALESCE(SUM(player_stats.points), 0) as total_points')
            ->leftJoin('player_stats', 'players.id', '=', 'player_stats.player_id')
            ->groupBy('players.id', 'players.name', 'players.created_at', 'players.updated_at')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($topPlayers);
    }
}
