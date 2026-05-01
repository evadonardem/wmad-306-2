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
        $request->user()->leagues()->findOrFail($season->league_id);

        $games = $season->games()->with(['homeTeam', 'awayTeam', 'result'])->get();
        return response()->json($games);
    }

    public function store(Request $request, $seasonId)
{
    $season = Season::findOrFail($seasonId);
    $request->user()->leagues()->findOrFail($season->league_id);

    $request->validate([
        'home_team_id' => 'required|exists:teams,id',
        'away_team_id' => 'required|exists:teams,id',
        'scheduled_at' => 'required|date',
        'venue'        => 'nullable|string|max:255',
    ]);

    $homeId = $request->home_team_id;
    $awayId = $request->away_team_id;

    // Teams must not be the same
    if ($homeId === $awayId) {
        return response()->json(['message' => 'A team cannot play against itself.'], 422);
    }

    // Both teams must belong to this season
    $teamIds = $season->teams()->pluck('id')->toArray();
    if (! in_array($homeId, $teamIds) || ! in_array($awayId, $teamIds)) {
        return response()->json(['message' => 'Both teams must belong to the same season.'], 422);
    }

    // Duplicate matchup check (order-independent)
    $duplicateMatchup = Game::where('season_id', $seasonId)
        ->where(function ($q) use ($homeId, $awayId) {
            $q->where(function ($q) use ($homeId, $awayId) {
                $q->where('home_team_id', $homeId)->where('away_team_id', $awayId);
            })->orWhere(function ($q) use ($homeId, $awayId) {
                $q->where('home_team_id', $awayId)->where('away_team_id', $homeId);
            });
        })->exists();

    if ($duplicateMatchup) {
        return response()->json([
            'message' => 'A game between these two teams already exists in this season.'
        ], 422);
    }

    // Same-date conflict check for either team
    $gameDate = \Carbon\Carbon::parse($request->scheduled_at)->toDateString();

    $dateConflict = Game::where('season_id', $seasonId)
        ->whereDate('scheduled_at', $gameDate)
        ->where(function ($q) use ($homeId, $awayId) {
            $q->whereIn('home_team_id', [$homeId, $awayId])
            ->orWhereIn('away_team_id', [$homeId, $awayId]);
        })->first();

    if ($dateConflict) {
        return response()->json([
            'message' => 'One or both teams already have a game scheduled on ' . $gameDate . '.'
        ], 422);
    }

    $game = Game::create([
        'season_id'    => $season->id,
        'home_team_id' => $homeId,
        'away_team_id' => $awayId,
        'scheduled_at' => $request->scheduled_at,
        'venue'        => $request->venue,
        'status'       => 'scheduled',
    ]);

    return response()->json($game->load(['homeTeam', 'awayTeam']), 201);
}

    public function show(Request $request, $id)
    {
        $game = Game::with(['homeTeam', 'awayTeam', 'result.playerStats.player'])->findOrFail($id);

        $season = Season::findOrFail($game->season_id);
        $request->user()->leagues()->findOrFail($season->league_id);

        return response()->json($game);
    }

    public function submitResult(Request $request, $gameId)
    {
        $game = Game::findOrFail($gameId);
        $season = Season::findOrFail($game->season_id);
        $request->user()->leagues()->findOrFail($season->league_id);

        $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        $result = GameResult::create([
            'game_id'    => $game->id,
            'home_score' => $request->home_score,
            'away_score' => $request->away_score,
        ]);

        $game->update(['status' => 'done']);

        return response()->json($result, 201);
    }

    public function submitStats(Request $request, $gameId)
    {
        $game = Game::with('result')->findOrFail($gameId);
        $season = Season::findOrFail($game->season_id);
        $request->user()->leagues()->findOrFail($season->league_id);

        if ($game->status !== 'done') {
            return response()->json(['message' => 'Stats can only be submitted for completed games.'], 422);
        }

        $request->validate([
            'stats'                => 'required|array',
            'stats.*.player_id'   => 'required|exists:players,id',
            'stats.*.points'      => 'required|integer|min:0',
            'stats.*.assists'     => 'required|integer|min:0',
            'stats.*.rebounds'    => 'required|integer|min:0',
            'stats.*.fouls'       => 'required|integer|min:0',
        ]);

        $insertData = collect($request->stats)->map(function ($stat) use ($game) {
            return [
                'game_result_id' => $game->result->id,
                'player_id'      => $stat['player_id'],
                'points'         => $stat['points'],
                'assists'        => $stat['assists'],
                'rebounds'       => $stat['rebounds'],
                'fouls'          => $stat['fouls'],
                'created_at'     => now(),
                'updated_at'     => now(),
            ];
        })->toArray();

        PlayerStat::insert($insertData);

        return response()->json(['message' => 'Player stats submitted successfully.'], 201);
    }
}