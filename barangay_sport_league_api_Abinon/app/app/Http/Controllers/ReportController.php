<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    public function summary(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId);
        $completedGames = $season->games()
            ->where('status', 'done')
            ->whereHas('result')
            ->with(['result', 'homeTeam', 'awayTeam'])
            ->get();

        if ($completedGames->isEmpty()) {
            return response()->json([
                'message' => 'No completed games found for this season.',
            ], 404);
        }

        $teamPoints = [];
        $totalPointsScored = 0;

        foreach ($completedGames as $game) {
            if (! $game->result) {
                continue;
            }

            $teamPoints[$game->home_team_id] = ($teamPoints[$game->home_team_id] ?? 0) + $game->result->home_score;
            $teamPoints[$game->away_team_id] = ($teamPoints[$game->away_team_id] ?? 0) + $game->result->away_score;
            $totalPointsScored += $game->result->home_score + $game->result->away_score;
        }

        $topScoringTeamId = collect($teamPoints)->sortDesc()->keys()->first();
        $topScoringTeam = $season->teams()
            ->whereKey($topScoringTeamId)
            ->first();

        return response()->json([
            'season_id' => $season->id,
            'season_name' => $season->name,
            'total_games_played' => $completedGames->count(),
            'total_games_scheduled' => $season->games()->where('status', 'scheduled')->count(),
            'top_scoring_team' => $topScoringTeam ? [
                'team_id' => $topScoringTeam->id,
                'team_name' => $topScoringTeam->name,
                'total_points' => $teamPoints[$topScoringTeam->id] ?? 0,
            ] : null,
            'total_points_scored' => $totalPointsScored,
        ]);
    }

    public function standings(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId)->load('teams');
        $games = $season->games()
            ->where('status', 'done')
            ->with('result')
            ->get();

        $standings = $season->teams->map(function ($team) use ($games) {
            $wins = 0;
            $losses = 0;
            $gamesPlayed = 0;

            foreach ($games as $game) {
                if (! $game->result) {
                    continue;
                }

                $isHome = $game->home_team_id === $team->id;
                $isAway = $game->away_team_id === $team->id;

                if (! $isHome && ! $isAway) {
                    continue;
                }

                $gamesPlayed++;

                $teamScore = $isHome ? $game->result->home_score : $game->result->away_score;
                $opponentScore = $isHome ? $game->result->away_score : $game->result->home_score;

                if ($teamScore > $opponentScore) {
                    $wins++;
                } elseif ($teamScore < $opponentScore) {
                    $losses++;
                }
            }

            return [
                'team_id' => $team->id,
                'team_name' => $team->name,
                'coach' => $team->coach,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $gamesPlayed,
            ];
        })->sortByDesc('wins')->values();

        return response()->json($standings);
    }

    public function leaderboard(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId);

        $leaders = DB::table('player_stats')
            ->join('game_results', 'game_results.id', '=', 'player_stats.game_result_id')
            ->join('games', 'games.id', '=', 'game_results.game_id')
            ->join('players', 'players.id', '=', 'player_stats.player_id')
            ->where('games.season_id', $season->id)
            ->where('games.status', 'done')
            ->select(
                'players.id as player_id',
                'players.name',
                DB::raw('SUM(player_stats.points) as total_points')
            )
            ->groupBy('players.id', 'players.name')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($leaders);
    }

    private function ownedSeason(Request $request, int $seasonId): Season
    {
        return Season::query()
            ->whereKey($seasonId)
            ->whereHas('league', function ($query) use ($request): void {
                $query->where('user_id', $request->user()->id);
            })
            ->firstOrFail();
    }
}
