<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\Season;
use App\Models\GameResult;
use Carbon\Carbon;
use Illuminate\Http\Request;

class GameController extends Controller
{
    /**
     * Get all games in a season.
     */
    public function indexBySeason(Season $season, Request $request)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $games = $season->games()->with('homeTeam', 'awayTeam', 'result.playerStats.player')->get();

        return response()->json(['data' => $games], 200);
    }

    /**
     * Schedule a new game.
     */
    public function storeInSeason(Season $season, Request $request)
    {
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $jsonPayload = json_decode($request->getContent(), true);
        $input = is_array($jsonPayload) ? $jsonPayload : [];
        $input = array_merge($request->all(), $input);

        $input['home_team_id'] = $request->input('home_team_id', $request->input('homeTeamId')) ?? ($input['home_team_id'] ?? null);
        $input['away_team_id'] = $request->input('away_team_id', $request->input('awayTeamId')) ?? ($input['away_team_id'] ?? null);
        $input['scheduled_at'] = $request->input('scheduled_at', $request->input('scheduledAt')) ?? ($input['scheduled_at'] ?? null);
        $input['venue'] = $request->input('venue', $request->input('venue')) ?? ($input['venue'] ?? null);

        $validated = validator($input, [
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id|different:home_team_id',
            'scheduled_at' => 'required|date_format:Y-m-d H:i:s',
            'venue' => 'required|string|max:255',
        ])->validate();

        $homeTeam = $season->teams()->find($validated['home_team_id']);
        $awayTeam = $season->teams()->find($validated['away_team_id']);

        if (!$homeTeam || !$awayTeam) {
            return response()->json(['message' => 'Both teams must belong to the same season'], 422);
        }

        $matchupExists = $season->games()
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['home_team_id'])
                    ->where('away_team_id', $validated['away_team_id']);
            })
            ->orWhere(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['away_team_id'])
                    ->where('away_team_id', $validated['home_team_id']);
            })
            ->exists();

        if ($matchupExists) {
            return response()->json([
                'message' => 'A game between these two teams already exists in this season',
            ], 422);
        }

        $scheduledDate = Carbon::createFromFormat('Y-m-d H:i:s', $validated['scheduled_at'])->toDateString();

        $dateConflict = $season->games()
            ->whereDate('scheduled_at', $scheduledDate)
            ->where(function ($query) use ($validated) {
                $query->where('home_team_id', $validated['home_team_id'])
                    ->orWhere('away_team_id', $validated['home_team_id'])
                    ->orWhere('home_team_id', $validated['away_team_id'])
                    ->orWhere('away_team_id', $validated['away_team_id']);
            })
            ->exists();

        if ($dateConflict) {
            return response()->json([
                'message' => 'One of the teams already has a game scheduled on this date',
            ], 422);
        }

        $validated['status'] = 'scheduled';
        $game = $season->games()->create($validated);

        return response()->json([
            'message' => 'Game scheduled successfully',
            'data' => $game,
        ], 201);
    }

    /**
     * Get a specific game with result and stats.
     */
    public function show(Game $game, Request $request)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $game->load('season', 'homeTeam', 'awayTeam', 'result.playerStats.player');

        return response()->json(['data' => $game], 200);
    }

    /**
     * Submit final score for a game.
     */
    public function submitResult(Game $game, Request $request)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        if ($game->result()->exists()) {
            return response()->json(['message' => 'Result already submitted for this game'], 422);
        }

        $result = $game->result()->create($validated);
        $game->update(['status' => 'done']);

        return response()->json([
            'message' => 'Game result submitted successfully',
            'data' => $result,
        ], 201);
    }

    /**
     * Submit individual player stats for a game.
     */
    public function submitPlayerStats(Game $game, Request $request)
    {
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        if ($game->status !== 'done' || !$game->result()->exists()) {
            return response()->json([
                'message' => 'Player stats can only be submitted for games with status done',
            ], 422);
        }

        $input = json_decode($request->getContent(), true);
        $data = is_array($input) ? $input : $request->all();

        if (!isset($data['stats']) && isset($data['player_id'])) {
            $data['stats'] = [$data];
        }

        if (isset($data['stats']) && is_array($data['stats']) && !array_is_list($data['stats'])) {
            $data['stats'] = [$data['stats']];
        }

        $validated = validator($data, [
            'stats' => 'required|array|min:1',
            'stats.*.player_id' => 'required|exists:players,id',
            'stats.*.points' => 'required|integer|min:0',
            'stats.*.assists' => 'required|integer|min:0',
            'stats.*.rebounds' => 'required|integer|min:0',
            'stats.*.fouls' => 'required|integer|min:0',
        ])->validate();

        $playerIds = collect($validated['stats'])->pluck('player_id')->unique()->values();
        $homePlayerIds = $game->homeTeam->players()->whereIn('players.id', $playerIds)->pluck('players.id')->toArray();
        $awayPlayerIds = $game->awayTeam->players()->whereIn('players.id', $playerIds)->pluck('players.id')->toArray();
        $allowedPlayerIds = array_unique(array_merge($homePlayerIds, $awayPlayerIds));

        $invalidPlayers = $playerIds->diff($allowedPlayerIds);
        if ($invalidPlayers->isNotEmpty()) {
            return response()->json([
                'message' => 'One or more players are not on either team',
                'invalid_player_ids' => $invalidPlayers,
            ], 422);
        }

        $existingStats = $game->result->playerStats()->whereIn('player_id', $playerIds)->pluck('player_id');
        if ($existingStats->isNotEmpty()) {
            return response()->json([
                'message' => 'Stats already submitted for one or more players',
                'player_ids' => $existingStats,
            ], 422);
        }

        $stats = $game->result->playerStats()->createMany($validated['stats']);

        return response()->json([
            'message' => 'Player stats submitted successfully',
            'data' => $stats,
        ], 201);
    }
}
