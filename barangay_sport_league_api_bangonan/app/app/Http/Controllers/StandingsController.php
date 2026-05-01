<?php

namespace App\Http\Controllers;

use App\Http\Resources\PlayerResource;
use App\Http\Resources\TeamResource;
use App\Models\Player;
use App\Models\Season;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StandingsController extends Controller
{
    public function seasonStandings(Request $request, $seasonId)
    {
        $season = Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Get all teams in the season
        $teams = $season->teams()->get();

        // Initialize standings array
        $standings = [];

        foreach ($teams as $team) {
            $standings[$team->id] = [
                'team' => $team,
                'wins' => 0,
                'losses' => 0,
                'games_played' => 0,
            ];
        }

        // Get completed games for the season with results
        $completedGames = $season->games()
            ->where('status', 'done')
            ->with('result')
            ->get();

        // Calculate wins and losses for each team
        foreach ($completedGames as $game) {
            if (!$game->result) continue;

            $homeTeamId = $game->home_team_id;
            $awayTeamId = $game->away_team_id;
            $homeScore = $game->result->home_score;
            $awayScore = $game->result->away_score;

            // Increment games played
            $standings[$homeTeamId]['games_played']++;
            $standings[$awayTeamId]['games_played']++;

            // Determine winner and update standings
            if ($homeScore > $awayScore) {
                $standings[$homeTeamId]['wins']++;
                $standings[$awayTeamId]['losses']++;
            } else {
                $standings[$homeTeamId]['losses']++;
                $standings[$awayTeamId]['wins']++;
            }
        }

        // Convert to array and sort by wins (descending), then by win percentage
        $sortedStandings = collect($standings)
            ->sortByDesc(function ($standing) {
                $winPercentage = $standing['games_played'] > 0 
                    ? $standing['wins'] / $standing['games_played'] 
                    : 0;
                return [$standing['wins'], $winPercentage];
            })
            ->values()
            ->map(function ($standing) {
                return [
                    'team' => new TeamResource($standing['team']),
                    'wins' => $standing['wins'],
                    'losses' => $standing['losses'],
                    'games_played' => $standing['games_played'],
                    'win_percentage' => $standing['games_played'] > 0 
                        ? round(($standing['wins'] / $standing['games_played']) * 100, 2) 
                        : 0,
                ];
            });

        return response()->json($sortedStandings);
    }

    public function playerLeaderboard(Request $request, $seasonId)
    {
        $season = Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Get top 10 players by total points across all completed games in the season
        $topPlayers = Player::select([
            'players.id',
            'players.name',
            'players.position',
            DB::raw('SUM(player_stats.points) as total_points'),
            DB::raw('COUNT(DISTINCT player_stats.id) as games_played'),
            DB::raw('AVG(player_stats.points) as avg_points'),
        ])
        ->join('player_stats', 'players.id', '=', 'player_stats.player_id')
        ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
        ->join('games', 'game_results.game_id', '=', 'games.id')
        ->where('games.season_id', $seasonId)
        ->where('games.status', 'done')
        ->groupBy('players.id', 'players.name', 'players.position')
        ->orderByDesc('total_points')
        ->limit(10)
        ->get();

        $payload = $topPlayers->map(function ($row) {
            return [
                'player' => new PlayerResource($row),
                'total_points' => (int) $row->total_points,
                'games_played' => (int) $row->games_played,
                'avg_points' => (float) $row->avg_points,
            ];
        });

        return response()->json($payload);
    }

    public function seasonSummary(Request $request, $seasonId)
    {
        $season = Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Get total games and completed games
        $totalGames = $season->games()->count();
        $completedGames = $season->games()->where('status', 'done')->count();
        $scheduledGames = $totalGames - $completedGames;

        // Check if there are any completed games
        if ($completedGames === 0) {
            return response()->json([
                'message' => 'Season has no completed games',
                'total_games' => $totalGames,
                'completed_games' => $completedGames,
                'scheduled_games' => $scheduledGames,
            ], 404);
        }

        // Get top scoring team
        $topScoringTeam = DB::table('games')
            ->join('game_results', 'games.id', '=', 'game_results.game_id')
            ->join('teams as home_teams', 'games.home_team_id', '=', 'home_teams.id')
            ->join('teams as away_teams', 'games.away_team_id', '=', 'away_teams.id')
            ->select([
                'home_teams.name as home_team_name',
                'away_teams.name as away_team_name',
                DB::raw('game_results.home_score + game_results.away_score as total_game_points'),
            ])
            ->where('games.season_id', $seasonId)
            ->where('games.status', 'done')
            ->get();

        // Calculate team scores
        $teamScores = [];
        foreach ($topScoringTeam as $game) {
            $teamScores[$game->home_team_name] = ($teamScores[$game->home_team_name] ?? 0) + $game->total_game_points;
            $teamScores[$game->away_team_name] = ($teamScores[$game->away_team_name] ?? 0) + $game->total_game_points;
        }

        $topTeam = null;
        $maxScore = 0;
        foreach ($teamScores as $teamName => $score) {
            if ($score > $maxScore) {
                $maxScore = $score;
                $topTeam = $teamName;
            }
        }

        // Get total points scored across all games
        $totalPoints = DB::table('games')
            ->join('game_results', 'games.id', '=', 'game_results.game_id')
            ->where('games.season_id', $seasonId)
            ->where('games.status', 'done')
            ->sum(DB::raw('game_results.home_score + game_results.away_score'));

        return response()->json([
            'total_games' => $totalGames,
            'completed_games' => $completedGames,
            'scheduled_games' => $scheduledGames,
            'top_scoring_team' => [
                'name' => $topTeam,
                'total_points_scored' => $maxScore,
            ],
            'total_points_scored' => $totalPoints,
        ]);
    }
}
