<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Season;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\PlayerStat;

class GameController extends Controller
{
    public function index(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        $games = $season->games()->with('homeTeam', 'awayTeam')->get();
        return response()->json($games);
    }

    public function store(Request $request, $seasonId)
    {
        $request->validate([
            'home_team_id' => 'required|exists:teams,id',
            'away_team_id' => 'required|exists:teams,id|different:home_team_id',
            'scheduled_at' => 'required|date',
            'venue' => 'nullable|string|max:255',
        ]);

        $season = Season::findOrFail($seasonId);

        $homeTeam = $season->teams()->findOrFail($request->home_team_id);
        $awayTeam = $season->teams()->findOrFail($request->away_team_id);

        if ($request->home_team_id === $request->away_team_id) {
            return response()->json(['message' => 'A team cannot play against itself'], 422);
        }

        // Check for duplicate matchup (order-independent)
        $existingMatchup = $season->games()
            ->where(function ($query) use ($request) {
                $query->where(function ($q) use ($request) {
                    $q->where('home_team_id', $request->home_team_id)
                      ->where('away_team_id', $request->away_team_id);
                })->orWhere(function ($q) use ($request) {
                    $q->where('home_team_id', $request->away_team_id)
                      ->where('away_team_id', $request->home_team_id);
                });
            })
            ->exists();

        if ($existingMatchup) {
            return response()->json(['message' => 'A game between these two teams already exists in this season'], 422);
        }

        // Check for date conflicts
        $scheduledDate = date('Y-m-d', strtotime($request->scheduled_at));
        $homeTeamConflict = $season->games()
            ->where('home_team_id', $request->home_team_id)
            ->orWhere('away_team_id', $request->home_team_id)
            ->whereDate('scheduled_at', $scheduledDate)
            ->exists();

        if ($homeTeamConflict) {
            return response()->json(['message' => 'The home team already has a game scheduled on this date'], 422);
        }

        $awayTeamConflict = $season->games()
            ->where('home_team_id', $request->away_team_id)
            ->orWhere('away_team_id', $request->away_team_id)
            ->whereDate('scheduled_at', $scheduledDate)
            ->exists();

        if ($awayTeamConflict) {
            return response()->json(['message' => 'The away team already has a game scheduled on this date'], 422);
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
        $game = Game::with(['homeTeam', 'awayTeam', 'result', 'result.playerStats.player'])->findOrFail($id);
        return response()->json($game);
    }

    public function submitResult(Request $request, $id)
    {
        $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        $game = Game::findOrFail($id);

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

        return response()->json(['message' => 'Player stats submitted successfully'], 201);
    }
}
