<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\PlayerStat;
use App\Models\Game;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StandingsController extends Controller
{
    public function getStandings(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $teams = $season->teams;
        $games = $season->games()->where('status', 'done')->with('result')->get();

        $standings = $teams->map(function ($team) use ($games) {
            $wins = 0;
            $losses = 0;
            $played = 0;

            foreach ($games as $game) {
                if ($game->home_team_id == $team->id || $game->away_team_id == $team->id) {
                    $played++;
                    $isHome = $game->home_team_id == $team->id;
                    $teamScore = $isHome ? $game->result->home_score : $game->result->away_score;
                    $opponentScore = $isHome ? $game->result->away_score : $game->result->home_score;

                    if ($teamScore > $opponentScore) {
                        $wins++;
                    } else if ($teamScore < $opponentScore) {
                        $losses++;
                    }
                    // Draws are not explicitly mentioned but could be handled
                }
            }

            return [
                'id' => $team->id,
                'name' => $team->name,
                'wins' => $wins,
                'losses' => $losses,
                'games_played' => $played
            ];
        });

        return $standings->sortByDesc('wins')->values();
    }

    public function getLeaderboard(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $leaderboard = DB::table('player_stats')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->join('players', 'player_stats.player_id', '=', 'players.id')
            ->where('games.season_id', $season->id)
            ->select('players.id', 'players.name', DB::raw('SUM(player_stats.points) as total_points'))
            ->groupBy('players.id', 'players.name')
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return $leaderboard;
    }

    public function getSeasonSummary(Request $request, Season $season)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $totalGamesPlayed = $season->games()->where('status', 'done')->count();
        $totalGamesScheduled = $season->games()->where('status', 'scheduled')->count();
        
        $totalPoints = DB::table('game_results')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $season->id)
            ->sum(DB::raw('home_score + away_score'));

        // Top scoring team (highest total points across all games)
        $homePoints = DB::table('game_results')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $season->id)
            ->select('games.home_team_id as team_id', DB::raw('SUM(home_score) as points'))
            ->groupBy('games.home_team_id');

        $awayPoints = DB::table('game_results')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $season->id)
            ->select('games.away_team_id as team_id', DB::raw('SUM(away_score) as points'))
            ->groupBy('games.away_team_id');

        $topScoringTeam = DB::table(DB::raw("({$homePoints->toSql()} UNION ALL {$awayPoints->toSql()}) as combined"))
            ->mergeBindings($homePoints)
            ->mergeBindings($awayPoints)
            ->select('team_id', DB::raw('SUM(points) as total_team_points'))
            ->groupBy('team_id')
            ->orderByDesc('total_team_points')
            ->first();

        $teamName = $topScoringTeam ? Team::find($topScoringTeam->team_id)->name : null;

        return [
            'total_games_played' => $totalGamesPlayed,
            'total_games_scheduled' => $totalGamesScheduled,
            'total_points_scored' => (int)$totalPoints,
            'top_scoring_team' => [
                'name' => $teamName,
                'total_points' => $topScoringTeam ? (int)$topScoringTeam->total_team_points : 0
            ]
        ];
    }
}
