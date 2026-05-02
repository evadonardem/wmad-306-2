<?php

namespace App\Http\Controllers;

use App\Models\League;
use App\Models\Season;
use App\Models\Team;
use App\Models\Player;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class PlayerController extends Controller
{
    public function index(League $league, Season $season, Team $team): JsonResponse
    {
        $this->authorize('view', $league);
        $players = $team->players;
        return response()->json($players);
    }

    public function store(Request $request, League $league, Season $season, Team $team): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'birthdate' => 'nullable|date',
            'position' => 'nullable|string|max:50',
            'jersey_number' => 'nullable|string|max:10',
        ]);

        // Create player and attach to team via pivot with jersey number
        $player = Player::create([
            'name' => $validated['name'],
            'birthdate' => $validated['birthdate'] ?? null,
            'position' => $validated['position'] ?? null,
        ]);

        $team->players()->attach($player->id, [
            'jersey_number' => $validated['jersey_number'] ?? null,
        ]);

        return response()->json($player, 201);
    }

    public function show(League $league, Season $season, Team $team, Player $player): JsonResponse
    {
        $this->authorize('view', $league);

        // Load player with pivot data for current team
        $player->load(['teams' => function ($query) use ($team) {
            $query->where('teams.id', $team->id);
        }]);

        // Get player's stats for games in this season
        $stats = \App\Models\PlayerStat::select([
                'player_stats.points',
                'player_stats.rebounds',
                'player_stats.assists',
                'player_stats.fouls',
                'games.scheduled_at',
                'game_results.home_score',
                'game_results.away_score',
            ])
            ->join('game_results', 'player_stats.game_result_id', '=', 'game_results.id')
            ->join('games', 'game_results.game_id', '=', 'games.id')
            ->where('player_stats.player_id', $player->id)
            ->where('games.season_id', $season->id)
            ->where('games.status', 'done')
            ->orderByDesc('games.scheduled_at')
            ->get();

        // Calculate career totals
        $careerStats = \App\Models\PlayerStat::select([
                \Illuminate\Support\Facades\DB::raw('SUM(points) as total_points'),
                \Illuminate\Support\Facades\DB::raw('SUM(rebounds) as total_rebounds'),
                \Illuminate\Support\Facades\DB::raw('SUM(assists) as total_assists'),
                \Illuminate\Support\Facades\DB::raw('SUM(fouls) as total_fouls'),
                \Illuminate\Support\Facades\DB::raw('COUNT(*) as games_played'),
            ])
            ->where('player_id', $player->id)
            ->first();

        return response()->json([
            'player' => [
                'id' => $player->id,
                'name' => $player->name,
                'birthdate' => $player->birthdate,
                'position' => $player->position,
                'jersey_number' => $player->teams->first()?->pivot->jersey_number ?? null,
            ],
            'current_team' => [
                'id' => $team->id,
                'name' => $team->name,
                'season' => $season->name,
                'league' => $league->name,
            ],
            'career_stats' => [
                'games_played' => $careerStats->games_played,
                'total_points' => $careerStats->total_points ?? 0,
                'total_rebounds' => $careerStats->total_rebounds ?? 0,
                'total_assists' => $careerStats->total_assists ?? 0,
                'total_fouls' => $careerStats->total_fouls ?? 0,
                'points_per_game' => $careerStats->games_played > 0 ? round($careerStats->total_points / $careerStats->games_played, 1) : 0,
                'rebounds_per_game' => $careerStats->games_played > 0 ? round($careerStats->total_rebounds / $careerStats->games_played, 1) : 0,
                'assists_per_game' => $careerStats->games_played > 0 ? round($careerStats->total_assists / $careerStats->games_played, 1) : 0,
            ],
            'game_log' => $stats->map(function ($stat) use ($team) {
                return [
                    'date' => $stat->scheduled_at,
                    'points' => $stat->points,
                    'rebounds' => $stat->rebounds,
                    'assists' => $stat->assists,
                    'fouls' => $stat->fouls,
                ];
            }),
        ]);
    }

    public function update(Request $request, League $league, Season $season, Team $team, Player $player): JsonResponse
    {
        $this->authorize('update', $league);

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'birthdate' => 'nullable|date',
            'position' => 'nullable|string|max:50',
            'jersey_number' => 'nullable|string|max:10',
        ]);

        // Update player info
        $playerData = array_diff_key($validated, ['jersey_number' => true]);
        if (!empty($playerData)) {
            $player->update($playerData);
        }

        // Update pivot jersey_number if provided
        if (isset($validated['jersey_number'])) {
            $team->players()->updateExistingPivot($player->id, [
                'jersey_number' => $validated['jersey_number'],
            ]);
        }

        return response()->json($player);
    }

    public function destroy(League $league, Season $season, Team $team, Player $player): JsonResponse
    {
        $this->authorize('update', $league);

        // Detach from team only (pivot delete)
        $team->players()->detach($player->id);

        return response()->json(['message' => 'Player removed from team successfully']);
    }
}
