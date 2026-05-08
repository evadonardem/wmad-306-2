<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SeasonSummaryController extends Controller
{
    public function index(Request $request, int $seasonId): JsonResponse
    {
        $season = Season::where('id', $seasonId)
            ->whereHas('league', fn ($query) => $query->where('user_id', $request->user()->id))
            ->with(['teams', 'games.result'])
            ->firstOrFail();

        $completedGames = $season->games->filter(fn ($game) => $game->status === 'done' && $game->result);

        if ($completedGames->isEmpty()) {
            return response()->json([
                'message' => 'No completed games found for this season.',
            ], 404);
        }

        $teamPoints = [];
        $totalPoints = 0;

        foreach ($completedGames as $game) {
            $homeScore = $game->result->home_score;
            $awayScore = $game->result->away_score;

            $totalPoints += $homeScore + $awayScore;
            $teamPoints[$game->home_team_id] = ($teamPoints[$game->home_team_id] ?? 0) + $homeScore;
            $teamPoints[$game->away_team_id] = ($teamPoints[$game->away_team_id] ?? 0) + $awayScore;
        }

        arsort($teamPoints);
        $topTeamId = (int) array_key_first($teamPoints);
        $topTeam = $season->teams->firstWhere('id', $topTeamId);

        return response()->json([
            'season_id' => $season->id,
            'total_games_played' => $completedGames->count(),
            'total_games_scheduled' => $season->games->where('status', 'scheduled')->count(),
            'total_points_scored' => $totalPoints,
            'top_scoring_team' => [
                'team_id' => $topTeamId,
                'team_name' => $topTeam?->name,
                'points' => $teamPoints[$topTeamId],
            ],
        ]);
    }
}
