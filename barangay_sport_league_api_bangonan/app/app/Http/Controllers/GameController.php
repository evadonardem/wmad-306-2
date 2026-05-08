<?php

namespace App\Http\Controllers;

use App\Http\Resources\GameResource;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\PlayerStat;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class GameController extends Controller
{
    public function index(Request $request, $seasonId)
    {
        $season = Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $games = $season->games()
            ->with(['homeTeam', 'awayTeam', 'result'])
            ->get();

        return GameResource::collection($games);
    }

    public function store(Request $request, $seasonId)
    {
        $validator = Validator::make($request->all(), [
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id',
            'scheduled_at' => 'required|date|after:now',
            'venue' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        // Validate that home_team_id and away_team_id are different
        if ($request->home_team_id == $request->away_team_id) {
            return response()->json(['message' => 'A team cannot play against itself'], 422);
        }

        $season = Season::with('league')->findOrFail($seasonId);
        
        // Ensure the season belongs to a league owned by the authenticated user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Validate that both teams belong to the same season
        $homeTeam = Team::findOrFail($request->home_team_id);
        $awayTeam = Team::findOrFail($request->away_team_id);

        if ($homeTeam->season_id != $seasonId || $awayTeam->season_id != $seasonId) {
            return response()->json(['message' => 'Both teams must belong to the same season'], 422);
        }

        // Check if the same matchup already exists in the season (order-independent)
        $existingMatchup = $season->games()
            ->where(function ($query) use ($request) {
                $query->where(function ($q) use ($request) {
                    $q->where('home_team_id', $request->home_team_id)
                      ->where('away_team_id', $request->away_team_id);
                })
                ->orWhere(function ($q) use ($request) {
                    $q->where('home_team_id', $request->away_team_id)
                      ->where('away_team_id', $request->home_team_id);
                });
            })
            ->exists();

        if ($existingMatchup) {
            return response()->json([
                'message' => 'A game between these two teams already exists in this season'
            ], 422);
        }

        // Check if either team already has a game scheduled on the same date
        $scheduledDate = date('Y-m-d', strtotime($request->scheduled_at));
        $conflictingGames = $season->games()
            ->whereDate('scheduled_at', $scheduledDate)
            ->where(function ($query) use ($request) {
                $query->where('home_team_id', $request->home_team_id)
                      ->orWhere('away_team_id', $request->home_team_id)
                      ->orWhere('home_team_id', $request->away_team_id)
                      ->orWhere('away_team_id', $request->away_team_id);
            })
            ->exists();

        if ($conflictingGames) {
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

        $game->load(['homeTeam', 'awayTeam', 'result']);

        return (new GameResource($game))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Request $request, $id)
    {
        $game = Game::with([
            'season.league', 
            'homeTeam', 
            'awayTeam', 
            'result.playerStats.player'
        ])->findOrFail($id);

        // Ensure the game belongs to a season owned by the authenticated user
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return new GameResource($game);
    }

    public function submitResult(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $game = Game::with(['season.league', 'result'])->findOrFail($id);

        // Ensure the game belongs to a season owned by the authenticated user
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Check if game already has a result
        if ($game->result) {
            return response()->json(['message' => 'Game already has a result'], 422);
        }

        // Create game result
        $gameResult = GameResult::create([
            'game_id' => $game->id,
            'home_score' => $request->home_score,
            'away_score' => $request->away_score,
        ]);

        // Update game status to done
        $game->update(['status' => 'done']);

        $game->load(['homeTeam', 'awayTeam', 'result']);

        return new GameResource($game);
    }

    public function submitStats(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'stats' => 'required|array',
            'stats.*.player_id' => 'required|exists:players,id',
            'stats.*.points' => 'required|integer|min:0',
            'stats.*.assists' => 'required|integer|min:0',
            'stats.*.rebounds' => 'required|integer|min:0',
            'stats.*.fouls' => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $game = Game::with(['season.league', 'result'])->findOrFail($id);

        // Ensure the game belongs to a season owned by the authenticated user
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Check if game status is done
        if ($game->status !== 'done') {
            return response()->json(['message' => 'Stats can only be submitted for completed games'], 422);
        }

        // Check if game has a result
        if (!$game->result) {
            return response()->json(['message' => 'Game must have a result before stats can be submitted'], 422);
        }

        // Bulk insert player stats
        $statsData = [];
        foreach ($request->stats as $stat) {
            $statsData[] = [
                'game_id' => $game->id,
                'game_result_id' => $game->result->id,
                'player_id' => $stat['player_id'],
                'points' => $stat['points'],
                'assists' => $stat['assists'],
                'rebounds' => $stat['rebounds'],
                'fouls' => $stat['fouls'],
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        PlayerStat::insert($statsData);

        $game->load(['homeTeam', 'awayTeam', 'result.playerStats.player']);

        return new GameResource($game);
    }
}
