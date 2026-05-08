<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use App\Models\Player;
use App\Models\PlayerStat;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class StatsController extends Controller
{
    public function playerLeaderboard(League $league, Season $season): JsonResponse
    {
        $this->authorize('view', $league);

        $leaderboard = Player::select([
                'players.id',
                'players.name',
                DB::raw('SUM(player_stats.points) as total_points'),
            ])
            ->join('player_stats', 'players.id', '=', 'player_stats.player_id')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $season->id)
            ->where('games.status', 'done')
            ->groupBy(['players.id', 'players.name'])
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($leaderboard);
    }

    public function topScorers(League $league, Season $season): JsonResponse
    {
        $this->authorize('view', $league);

        $topScorers = PlayerStat::select([
                'player_stats.player_id',
                'players.name',
                'player_team.jersey_number',
                'teams.name as team_name',
                DB::raw('SUM(player_stats.points) as total_points'),
                DB::raw('COUNT(player_stats.id) as games_played'),
            ])
            ->join('players', 'player_stats.player_id', '=', 'players.id')
            ->join('player_team', 'players.id', '=', 'player_team.player_id')
            ->join('teams', 'player_team.team_id', '=', 'teams.id')
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('teams.season_id', $season->id)
            ->where('games.status', 'done')
            ->groupBy([
                'player_stats.player_id',
                'players.name',
                'player_team.jersey_number',
                'teams.name',
            ])
            ->orderByDesc('total_points')
            ->limit(10)
            ->get();

        return response()->json($topScorers);
    }

    public function gameStats(League $league, Season $season): JsonResponse
    {
        $this->authorize('view', $league);

        $stats = [
            'total_games' => $season->games()->count(),
            'done_games' => $season->games()->where('status', 'done')->count(),
            'scheduled_games' => $season->games()->where('status', 'scheduled')->count(),
            'average_points_per_game' => DB::table('game_results')
                ->join('games', 'game_results.game_id', '=', 'games.id')
                ->where('games.season_id', $season->id)
                ->select(DB::raw('AVG(home_score + away_score) as avg_points'))
                ->value('avg_points') ?? 0,
        ];

        return response()->json($stats);
    }

    public function seasonSummary(Season $season): JsonResponse
    {
        // Check if season has any completed games
        $doneGames = $season->games()->where('status', 'done')->count();
        
        if ($doneGames === 0) {
            return response()->json([
                'message' => 'No completed games found for this season'
            ], 404);
        }

        $totalGames = $season->games()->count();
        $scheduledGames = $totalGames - $doneGames;

        $teamCount = $season->teams()->count();
        $playerCount = $season->teams()->withCount('players')->get()->sum('players_count');

        // Top scoring team (highest total points across all games)
        $topTeam = DB::table('teams')
            ->select([
                'teams.name',
                DB::raw('SUM(CASE 
                    WHEN games.home_team_id = teams.id THEN game_results.home_score 
                    ELSE game_results.away_score 
                END) as total_points')
            ])
            ->join('games', function ($join) {
                $join->on('teams.id', '=', 'games.home_team_id')
                    ->orOn('teams.id', '=', 'games.away_team_id');
            })
            ->join('game_results', 'games.id', '=', 'game_results.game_id')
            ->where('teams.season_id', $season->id)
            ->where('games.status', 'done')
            ->groupBy('teams.id', 'teams.name')
            ->orderByDesc('total_points')
            ->first();

        $totalPoints = DB::table('game_results')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('games.season_id', $season->id)
            ->select(DB::raw('SUM(home_score + away_score) as total'))
            ->value('total') ?? 0;

        return response()->json([
            'season_name' => $season->name,
            'status' => $season->status,
            'games_played' => $doneGames,
            'games_scheduled' => $scheduledGames,
            'top_scoring_team' => $topTeam ? [
                'name' => $topTeam->name,
                'total_points' => $topTeam->total_points
            ] : null,
            'total_points_scored' => $totalPoints,
        ]);
    }

    public function playerProfile(Player $player): JsonResponse
    {
        // Load all teams with season and pivot data
        $teams = $player->teams()
            ->with('season')
            ->get()
            ->map(function ($team) {
                return [
                    'team_name' => $team->name,
                    'season_name' => $team->season->name,
                    'jersey_number' => $team->pivot->jersey_number,
                ];
            });

        // Career totals
        $careerTotals = PlayerStat::where('player_id', $player->id)
            ->select([
                DB::raw('COUNT(*) as total_games'),
                DB::raw('SUM(points) as total_points'),
                DB::raw('SUM(assists) as total_assists'),
                DB::raw('SUM(rebounds) as total_rebounds'),
            ])
            ->first();

        // Personal best game
        $bestGame = PlayerStat::where('player_id', $player->id)
            ->with(['gameResult.game.homeTeam', 'gameResult.game.awayTeam'])
            ->orderByDesc('points')
            ->first();

        return response()->json([
            'player' => [
                'id' => $player->id,
                'name' => $player->name,
                'position' => $player->position,
            ],
            'teams' => $teams,
            'career_totals' => [
                'total_games' => $careerTotals->total_games ?? 0,
                'total_points' => $careerTotals->total_points ?? 0,
                'total_assists' => $careerTotals->total_assists ?? 0,
                'total_rebounds' => $careerTotals->total_rebounds ?? 0,
            ],
            'personal_best' => $bestGame ? [
                'points' => $bestGame->points,
                'game_date' => $bestGame->gameResult->game->scheduled_at,
                'opponent' => $bestGame->gameResult->game->home_team_id === $player->teams->first()?->id 
                    ? $bestGame->gameResult->game->awayTeam->name 
                    : $bestGame->gameResult->game->homeTeam->name,
            ] : null,
        ]);
    }
}
