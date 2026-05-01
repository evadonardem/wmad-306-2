<?php

namespace App\Http\Controllers;

use App\Http\Resources\PlayerResource;
use App\Http\Resources\TeamResource;
use App\Models\Player;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlayerController extends Controller
{
    public function index(Request $request)
    {
        $players = Player::with('teams')->get();
        return PlayerResource::collection($players);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'birthdate' => 'required|date',
            'position' => 'required|string|max:100',
        ]);

        $player = Player::create($validated);
        return new PlayerResource($player);
    }

    public function show(Request $request, $id)
    {
        $player = Player::with('teams')->findOrFail($id);
        return new PlayerResource($player);
    }

    public function update(Request $request, $id)
    {
        $player = Player::findOrFail($id);
        
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'birthdate' => 'sometimes|date',
            'position' => 'sometimes|string|max:100',
        ]);

        $player->update($validated);
        return new PlayerResource($player);
    }

    public function destroy(Request $request, $id)
    {
        $player = Player::findOrFail($id);
        $player->delete();
        
        return response()->json(null, 204);
    }

    public function leaderboard(Request $request, $seasonId)
    {
        // Verify season exists and user has access
        $season = \App\Models\Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Get player stats aggregated from completed games in the season
        $leaderboard = DB::table('player_stats')
            ->select([
                'player_stats.player_id',
                'players.name',
                'players.position',
                'teams.name as team_name',
                'teams.id as team_id',
                DB::raw('SUM(player_stats.points) as total_points'),
                DB::raw('SUM(player_stats.assists) as total_assists'),
                DB::raw('SUM(player_stats.rebounds) as total_rebounds'),
                DB::raw('COUNT(DISTINCT player_stats.game_id) as games_played'),
            ])
            ->join('players', 'player_stats.player_id', '=', 'players.id')
            ->join('player_team', 'players.id', '=', 'player_team.player_id')
            ->join('teams', 'player_team.team_id', '=', 'teams.id')
            ->join('games', 'player_stats.game_id', '=', 'games.id')
            ->where('games.season_id', $seasonId)
            ->where('games.status', 'done')
            ->where('teams.season_id', $seasonId)
            ->groupBy('player_stats.player_id', 'players.name', 'players.position', 'teams.name', 'teams.id')
            ->orderByDesc('total_points')
            ->get();

        return response()->json($leaderboard);
    }

    public function profile(Request $request, $id)
    {
        // Get player with all their teams and seasons (eager loading to avoid N+1)
        $player = Player::with([
            'teams.season.league',
            'stats.gameResult.game.season.league'
        ])->findOrFail($id);

        // Build teams list with season name and jersey number from pivot
        $teamsList = $player->teams->map(function ($team) {
            return [
                'team' => new TeamResource($team),
                'season_name' => $team->season->name,
                'jersey_number' => $team->pivot->jersey_number,
            ];
        });

        // Calculate career totals across all seasons
        $careerTotals = [
            'total_games_played' => 0,
            'total_points' => 0,
            'total_assists' => 0,
            'total_rebounds' => 0,
        ];

        // Find personal best game (most points in a single game)
        $personalBestGame = null;
        $maxPoints = 0;

        foreach ($player->stats as $stat) {
            // Only include stats from completed games
            if ($stat->gameResult && $stat->gameResult->game && $stat->gameResult->game->status === 'done') {
                $careerTotals['total_games_played']++;
                $careerTotals['total_points'] += $stat->points;
                $careerTotals['total_assists'] += $stat->assists;
                $careerTotals['total_rebounds'] += $stat->rebounds;

                // Check if this is the personal best game
                if ($stat->points > $maxPoints) {
                    $maxPoints = $stat->points;
                    $personalBestGame = [
                        'game_id' => $stat->gameResult->game->id,
                        'date' => $stat->gameResult->game->scheduled_at,
                        'venue' => $stat->gameResult->game->venue,
                        'home_team' => $stat->gameResult->game->homeTeam->name,
                        'away_team' => $stat->gameResult->game->awayTeam->name,
                        'home_score' => $stat->gameResult->home_score,
                        'away_score' => $stat->gameResult->away_score,
                        'points_scored' => $stat->points,
                        'assists' => $stat->assists,
                        'rebounds' => $stat->rebounds,
                        'fouls' => $stat->fouls,
                    ];
                }
            }
        }

        return response()->json([
            'player_info' => new PlayerResource($player),
            'teams' => $teamsList,
            'career_totals' => $careerTotals,
            'personal_best_game' => $personalBestGame,
        ]);
    }
}
