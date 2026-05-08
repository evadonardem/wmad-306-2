<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\GameResult;
use App\Models\PlayerStat;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class GameController extends Controller
{
    public function index(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId)->firstOrFail();

        return response()->json(
            $season->games()
                ->with(['homeTeam', 'awayTeam', 'result'])
                ->orderBy('scheduled_at')
                ->get()
        );
    }

    public function store(Request $request, int $seasonId): JsonResponse
    {
        $this->ownedSeason($request, $seasonId)->firstOrFail();

        $data = $request->validate([
            'home_team_id' => ['required', 'integer', 'exists:teams,id'],
            'away_team_id' => ['required', 'integer', 'exists:teams,id'],
            'scheduled_at' => ['required', 'date'],
            'venue' => ['required', 'string', 'max:255'],
        ]);

        if ((int) $data['home_team_id'] === (int) $data['away_team_id']) {
            return response()->json([
                'message' => 'A team cannot play against itself.',
            ], 422);
        }

        $teams = Team::whereIn('id', [$data['home_team_id'], $data['away_team_id']])->get()->keyBy('id');
        $homeTeam = $teams->get((int) $data['home_team_id']);
        $awayTeam = $teams->get((int) $data['away_team_id']);

        if (! $homeTeam || ! $awayTeam || (int) $homeTeam->season_id !== $seasonId || (int) $awayTeam->season_id !== $seasonId) {
            return response()->json([
                'message' => 'Teams must belong to the same season as the scheduled game.',
            ], 422);
        }

        $duplicate = Game::where('season_id', $seasonId)
            ->where(function ($query) use ($data) {
                $query->where(function ($inner) use ($data) {
                    $inner->where('home_team_id', $data['home_team_id'])
                        ->where('away_team_id', $data['away_team_id']);
                })->orWhere(function ($inner) use ($data) {
                    $inner->where('home_team_id', $data['away_team_id'])
                        ->where('away_team_id', $data['home_team_id']);
                });
            })
            ->exists();

        if ($duplicate) {
            return response()->json([
                'message' => 'Same matchup already exists in this season.',
            ], 422);
        }

        $scheduledDate = Carbon::parse($data['scheduled_at'])->toDateString();
        $teamDateConflict = Game::where('season_id', $seasonId)
            ->whereDate('scheduled_at', $scheduledDate)
            ->where(function ($query) use ($data) {
                $query->whereIn('home_team_id', [$data['home_team_id'], $data['away_team_id']])
                    ->orWhereIn('away_team_id', [$data['home_team_id'], $data['away_team_id']]);
            })
            ->exists();

        if ($teamDateConflict) {
            return response()->json([
                'message' => 'One of the teams already has a game scheduled on this date.',
            ], 422);
        }

        $game = Game::create([
            'season_id' => $seasonId,
            'home_team_id' => $data['home_team_id'],
            'away_team_id' => $data['away_team_id'],
            'scheduled_at' => $data['scheduled_at'],
            'venue' => $data['venue'],
            'status' => 'scheduled',
        ]);

        return response()->json($game->load(['homeTeam', 'awayTeam']), 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $game = $this->ownedGame($request, $id)
            ->with(['season', 'homeTeam.players', 'awayTeam.players', 'result.stats.player'])
            ->firstOrFail();

        return response()->json($game);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $game = $this->ownedGame($request, $id)->firstOrFail();
        $game->delete();

        return response()->json([
            'message' => 'Game deleted successfully.',
        ]);
    }

    public function result(Request $request, int $id): JsonResponse
    {
        $game = $this->ownedGame($request, $id)->with('result')->firstOrFail();

        $data = $request->validate([
            'home_score' => ['required', 'integer', 'min:0'],
            'away_score' => ['required', 'integer', 'min:0'],
        ]);

        if ($game->status === 'done' || $game->result) {
            return response()->json([
                'message' => 'Result has already been submitted for this game.',
            ], 422);
        }

        $result = DB::transaction(function () use ($game, $data) {
            $result = GameResult::create([
                'game_id' => $game->id,
                'home_score' => $data['home_score'],
                'away_score' => $data['away_score'],
            ]);

            $game->update(['status' => 'done']);

            return $result;
        });

        return response()->json($result->load('game'), 201);
    }

    public function stats(Request $request, int $id): JsonResponse
    {
        $game = $this->ownedGame($request, $id)->with(['result', 'homeTeam.players', 'awayTeam.players'])->firstOrFail();

        if ($game->status !== 'done') {
            return response()->json([
                'message' => 'Player stats can only be submitted after the game is done.',
            ], 422);
        }

        if (! $game->result) {
            return response()->json([
                'message' => 'Game result is required before submitting player stats.',
            ], 422);
        }

        $data = $request->validate([
            'stats' => ['required', 'array', 'min:1'],
            'stats.*.player_id' => ['required', 'integer', 'exists:players,id'],
            'stats.*.points' => ['required', 'integer', 'min:0'],
            'stats.*.assists' => ['required', 'integer', 'min:0'],
            'stats.*.rebounds' => ['required', 'integer', 'min:0'],
            'stats.*.fouls' => ['required', 'integer', 'min:0'],
        ]);

        $eligiblePlayerIds = $game->homeTeam->players
            ->merge($game->awayTeam->players)
            ->pluck('id')
            ->unique()
            ->values();

        $submittedPlayerIds = collect($data['stats'])->pluck('player_id');
        $invalidPlayerIds = $submittedPlayerIds->diff($eligiblePlayerIds)->values();

        if ($invalidPlayerIds->isNotEmpty()) {
            return response()->json([
                'message' => 'All stat players must belong to one of the teams in this game.',
                'invalid_player_ids' => $invalidPlayerIds,
            ], 422);
        }

        if ($submittedPlayerIds->duplicates()->isNotEmpty()) {
            return response()->json([
                'message' => 'Each player can only have one stat line per game.',
            ], 422);
        }

        $stats = DB::transaction(function () use ($game, $data) {
            PlayerStat::where('game_result_id', $game->result->id)->delete();

            $rows = collect($data['stats'])->map(fn ($stat) => [
                'game_result_id' => $game->result->id,
                'player_id' => $stat['player_id'],
                'points' => $stat['points'],
                'assists' => $stat['assists'],
                'rebounds' => $stat['rebounds'],
                'fouls' => $stat['fouls'],
                'created_at' => now(),
                'updated_at' => now(),
            ])->all();

            PlayerStat::insert($rows);

            return PlayerStat::with('player')
                ->where('game_result_id', $game->result->id)
                ->get();
        });

        return response()->json([
            'message' => 'Player stats saved successfully.',
            'stats' => $stats,
        ], 201);
    }

    private function ownedSeason(Request $request, int $seasonId)
    {
        return Season::where('id', $seasonId)
            ->whereHas('league', fn ($query) => $query->where('user_id', $request->user()->id));
    }

    private function ownedGame(Request $request, int $gameId)
    {
        return Game::where('id', $gameId)
            ->whereHas('season.league', fn ($query) => $query->where('user_id', $request->user()->id));
    }
}
