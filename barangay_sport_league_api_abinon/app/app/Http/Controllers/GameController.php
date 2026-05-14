<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\GameResult;
use App\Models\Season;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GameController extends Controller
{
    public function index(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId);

        return response()->json(
            $season->games()
                ->with(['homeTeam', 'awayTeam', 'result'])
                ->orderBy('scheduled_at')
                ->get()
        );
    }

    public function store(Request $request, int $seasonId): JsonResponse
    {
        $season = $this->ownedSeason($request, $seasonId);

        $validated = $request->validate([
            'home_team_id' => ['required', 'integer', 'exists:teams,id'],
            'away_team_id' => ['required', 'integer', 'exists:teams,id', 'different:home_team_id'],
            'scheduled_at' => ['required', 'date'],
            'venue' => ['required', 'string', 'max:255'],
        ]);

        $teamIds = $season->teams()->pluck('id');

        if (! $teamIds->contains($validated['home_team_id']) || ! $teamIds->contains($validated['away_team_id'])) {
            return response()->json([
                'message' => 'Both teams must belong to the selected season.',
            ], 422);
        }

        $matchupExists = $season->games()
            ->where(function ($query) use ($validated): void {
                $query->where(function ($matchupQuery) use ($validated): void {
                    $matchupQuery->where('home_team_id', $validated['home_team_id'])
                        ->where('away_team_id', $validated['away_team_id']);
                })->orWhere(function ($matchupQuery) use ($validated): void {
                    $matchupQuery->where('home_team_id', $validated['away_team_id'])
                        ->where('away_team_id', $validated['home_team_id']);
                });
            })
            ->exists();

        if ($matchupExists) {
            return response()->json([
                'message' => 'A game between these two teams already exists in this season.',
            ], 422);
        }

        $scheduledDate = date('Y-m-d', strtotime($validated['scheduled_at']));
        $teamHasSameDayGame = $season->games()
            ->whereDate('scheduled_at', $scheduledDate)
            ->where(function ($query) use ($validated): void {
                $query->whereIn('home_team_id', [$validated['home_team_id'], $validated['away_team_id']])
                    ->orWhereIn('away_team_id', [$validated['home_team_id'], $validated['away_team_id']]);
            })
            ->exists();

        if ($teamHasSameDayGame) {
            return response()->json([
                'message' => 'One of the selected teams already has a game scheduled on this date.',
            ], 422);
        }

        $game = $season->games()->create([
            ...$validated,
            'status' => 'scheduled',
        ]);

        return response()->json($game->load(['homeTeam', 'awayTeam']), 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $game = $this->ownedGame($request, $id)->load([
            'season',
            'homeTeam.players',
            'awayTeam.players',
            'result.playerStats.player',
        ]);

        return response()->json($game);
    }

    public function submitResult(Request $request, int $id): JsonResponse
    {
        $game = $this->ownedGame($request, $id);

        $validated = $request->validate([
            'home_score' => ['required', 'integer', 'min:0'],
            'away_score' => ['required', 'integer', 'min:0'],
        ]);

        $result = GameResult::updateOrCreate(
            ['game_id' => $game->id],
            $validated
        );

        $game->update(['status' => 'done']);

        return response()->json(
            $result->load('playerStats.player')
        );
    }

    public function submitStats(Request $request, int $id): JsonResponse
    {
        $game = $this->ownedGame($request, $id)->load(['homeTeam.players', 'awayTeam.players', 'result']);

        if (! $game->result || $game->status !== 'done') {
            return response()->json([
                'message' => 'A game must be marked done before player stats can be submitted.',
            ], 422);
        }

        $statsPayload = $request->input('stats', $request->json()->all());
        $request->merge(['stats' => $statsPayload]);

        $validated = $request->validate([
            'stats' => ['required', 'array', 'min:1'],
            'stats.*.player_id' => ['required', 'integer', 'exists:players,id'],
            'stats.*.points' => ['required', 'integer', 'min:0'],
            'stats.*.assists' => ['required', 'integer', 'min:0'],
            'stats.*.rebounds' => ['required', 'integer', 'min:0'],
            'stats.*.fouls' => ['required', 'integer', 'min:0'],
        ]);

        $eligiblePlayerIds = $game->homeTeam->players
            ->pluck('id')
            ->merge($game->awayTeam->players->pluck('id'));

        foreach ($validated['stats'] as $stat) {
            if (! $eligiblePlayerIds->contains($stat['player_id'])) {
                return response()->json([
                    'message' => 'Each player must belong to one of the teams in this game.',
                ], 422);
            }
        }

        DB::transaction(function () use ($game, $validated): void {
            $game->result->playerStats()->delete();

            $game->result->playerStats()->createMany($validated['stats']);
        });

        return response()->json(
            $game->result->fresh()->load('playerStats.player')
        );
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

    private function ownedGame(Request $request, int $gameId): Game
    {
        return Game::query()
            ->whereKey($gameId)
            ->whereHas('season.league', function ($query) use ($request): void {
                $query->where('user_id', $request->user()->id);
            })
            ->firstOrFail();
    }
}
