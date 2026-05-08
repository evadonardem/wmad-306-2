<?php

namespace App\Http\Controllers;

use App\Models\Season;
use Illuminate\Http\Request;

class StandingsController extends Controller
{
    public function standings(Request $request, $seasonId)
    {
        $season = Season::with(['teams', 'games' => function ($q) {
            $q->where('status', 'done')->with('result');
        }])->findOrFail($seasonId);

        $request->user()->leagues()->findOrFail($season->league_id);

        $completedGames = $season->games;

        $standings = $season->teams->map(function ($team) use ($completedGames) {
            $wins   = 0;
            $losses = 0;

            foreach ($completedGames as $game) {
                if (! $game->result) {
                    continue;
                }

                $isHome = $game->home_team_id == $team->id;
                $isAway = $game->away_team_id == $team->id;

                if (! $isHome && ! $isAway) {
                    continue;
                }

                $homeScore = $game->result->home_score;
                $awayScore = $game->result->away_score;

                if ($isHome) {
                    $homeScore > $awayScore ? $wins++ : $losses++;
                } else {
                    $awayScore > $homeScore ? $wins++ : $losses++;
                }
            }

            return [
                'team_id'      => $team->id,
                'team_name'    => $team->name,
                'wins'         => $wins,
                'losses'       => $losses,
                'games_played' => $wins + $losses,
            ];
        })->sortByDesc('wins')->values();

        return response()->json($standings);
    }

    public function leaderboard(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        $request->user()->leagues()->findOrFail($season->league_id);

        $leaderboard = \DB::table('player_stats')
            ->join('players', 'players.id', '=', 'player_stats.player_id')
            ->join('game_results', 'game_results.id', '=', 'player_stats.game_result_id')
            ->join('games', 'games.id', '=', 'game_results.game_id')
            ->where('games.season_id', $seasonId)
            ->where('games.status', 'done')
            ->groupBy('player_stats.player_id', 'players.name', 'players.position')
            ->select(
                'player_stats.player_id',
                'players.name',
                'players.position',
                \DB::raw('SUM(player_stats.points) as total_points'),
                \DB::raw('SUM(player_stats.assists) as total_assists'),
                \DB::raw('SUM(player_stats.rebounds) as total_rebounds')
            )
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($leaderboard);
    }

public function summary(Request $request, $seasonId)
{
    $season = Season::with([
        'games' => function ($q) {
            $q->with('result');
        },
        'teams'
    ])->findOrFail($seasonId);

    $request->user()->leagues()->findOrFail($season->league_id);

    $completedGames = $season->games->where('status', 'done');
    $scheduledGames = $season->games->where('status', 'scheduled');

    if ($completedGames->isEmpty()) {
        return response()->json([
            'message' => 'No completed games found for this season.'
        ], 404);
    }

    // Total points scored across all games
    $totalPoints = $completedGames->sum(function ($game) {
        return $game->result
            ? $game->result->home_score + $game->result->away_score
            : 0;
    });

    // Top scoring team
    $teamScores = [];
    foreach ($completedGames as $game) {
        if (! $game->result) {
            continue;
        }
        $teamScores[$game->home_team_id] = ($teamScores[$game->home_team_id] ?? 0) + $game->result->home_score;
        $teamScores[$game->away_team_id] = ($teamScores[$game->away_team_id] ?? 0) + $game->result->away_score;
    }

    $topTeamId    = array_search(max($teamScores), $teamScores);
    $topTeam      = $season->teams->firstWhere('id', $topTeamId);

    return response()->json([
        'season'              => $season->name,
        'games_played'        => $completedGames->count(),
        'games_scheduled'     => $scheduledGames->count(),
        'total_points_scored' => $totalPoints,
        'top_scoring_team'    => [
            'id'     => $topTeam?->id,
            'name'   => $topTeam?->name,
            'points' => $teamScores[$topTeamId] ?? 0,
        ],
    ]);
}

}