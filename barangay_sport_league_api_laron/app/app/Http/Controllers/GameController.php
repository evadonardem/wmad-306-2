<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\GameResult;
use App\Models\PlayerStat;
use App\Models\Season;
use Illuminate\Http\Request;

class GameController extends Controller
{
    public function index(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);
        
        $games = $season->games()->with(['homeTeam', 'awayTeam', 'result'])->get();
        return response()->json($games);
    }

    public function store(Request $request, $seasonId)
    {
        $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id',
            'scheduled_at' => 'required|date',
            'venue' => 'nullable|string',
        ]);

        $season = Season::findOrFail($seasonId);
        
        // Verify the season belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($season->league_id);

        // Validate both teams belong to the same season
        $homeTeam = $season->teams()->findOrFail($request->home_team_id);
        $awayTeam = $season->teams()->findOrFail($request->away_team_id);

        // Validate team cannot play against itself
        if ($request->home_team_id == $request->away_team_id) {
            return response()->json(['message' => 'A team cannot play against itself'], 422);
        }

        // Check if the same matchup already exists in the season (order-independent)
        $existingGame = $season->games()
            ->where(function ($query) use ($request) {
                $query->where(function ($q) use ($request) {
                    $q->where('home_team_id', $request->home_team_id)
                      ->where('away_team_id', $request->away_team_id);
                })->orWhere(function ($q) use ($request) {
                    $q->where('home_team_id', $request->away_team_id)
                      ->where('away_team_id', $request->home_team_id);
                });
            })
            ->first();

        if ($existingGame) {
            return response()->json([
                'message' => 'A game between these two teams already exists in this season'
            ], 422);
        }

        // Check if either team already has a game scheduled on the same date
        $scheduledDate = date('Y-m-d', strtotime($request->scheduled_at));
        $conflictingGame = $season->games()
            ->whereDate('scheduled_at', $scheduledDate)
            ->where(function ($query) use ($request) {
                $query->where('home_team_id', $request->home_team_id)
                      ->orWhere('away_team_id', $request->home_team_id)
                      ->orWhere('home_team_id', $request->away_team_id)
                      ->orWhere('away_team_id', $request->away_team_id);
            })
            ->first();

        if ($conflictingGame) {
            return response()->json([
                'message' => 'One or both teams already have a game scheduled on this date'
            ], 422);
        }

        $game = $season->games()->create([
            'home_team_id' => $request->home_team_id,
            'away_team_id' => $request->away_team_id,
            'scheduled_at' => $request->scheduled_at,
            'venue' => $request->venue,
            'status' => 'scheduled',
        ]);

        return response()->json($game, 201);
    }

    public function show(Request $request, $id)
    {
        $game = Game::with(['homeTeam', 'awayTeam', 'result.playerStats.player'])->findOrFail($id);
        
        // Verify the game belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($game->season->league_id);
        
        return response()->json($game);
    }

    public function submitResult(Request $request, $id)
    {
        $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        $game = Game::findOrFail($id);
        
        // Verify the game belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($game->season->league_id);

        if ($game->status === 'done') {
            return response()->json(['message' => 'Game result already submitted'], 422);
        }

        $result = GameResult::create([
            'game_id' => $game->id,
            'home_score' => $request->home_score,
            'away_score' => $request->away_score,
        ]);

        $game->update(['status' => 'done']);

        return response()->json($result, 201);
    }

    public function submitStats(Request $request, $id)
    {
        $request->validate([
            'stats' => 'required|array',
            'stats.*.player_id' => 'required|exists:players,id',
            'stats.*.points' => 'required|integer|min:0',
            'stats.*.assists' => 'required|integer|min:0',
            'stats.*.rebounds' => 'required|integer|min:0',
            'stats.*.fouls' => 'required|integer|min:0',
        ]);

        $game = Game::findOrFail($id);
        
        // Verify the game belongs to the authenticated user's league
        $league = $request->user()->leagues()->findOrFail($game->season->league_id);

        if ($game->status !== 'done') {
            return response()->json(['message' => 'Stats can only be submitted for completed games'], 422);
        }

        $result = $game->result;
        
        foreach ($request->stats as $stat) {
            PlayerStat::create([
                'game_result_id' => $result->id,
                'player_id' => $stat['player_id'],
                'points' => $stat['points'],
                'assists' => $stat['assists'],
                'rebounds' => $stat['rebounds'],
                'fouls' => $stat['fouls'],
            ]);
        }

        return response()->json(['message' => 'Stats submitted successfully'], 201);
    }
}
