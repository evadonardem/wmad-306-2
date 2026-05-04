<?php

namespace App\Http\Controllers;

use App\Models\Season;
use App\Models\Game;
use App\Models\GameResult;
use App\Models\PlayerStat;
use Illuminate\Http\Request;

class GameController extends Controller
{
    public function index(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $games = $season->games()
                    ->with(['homeTeam', 'awayTeam', 'result'])
                    ->get();
        return response()->json($games);
    }

    // POST /api/seasons/{season}/games
    public function store(Request $request, Season $season)
    {
        // Ensure season belongs to auth user
        if ($season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
    $data = $request->validate([
        'home_team_id' => 'required|exists:teams,id',
        'away_team_id' => 'required|exists:teams,id',
        'scheduled_at' => 'required|date',
        'venue'        => 'nullable|string',
    ]);

    $homeId = $data['home_team_id'];
    $awayId = $data['away_team_id'];
    $date   = date('Y-m-d', strtotime($data['scheduled_at']));

    if ($homeId === $awayId) {
        return response()->json(
            ['message' => 'A team cannot play against itself'], 422
        );
    }

    $teamIds = $season->teams()->pluck('id');
    if (! $teamIds->contains($homeId) || ! $teamIds->contains($awayId)) {
        return response()->json(
            ['message' => 'Both teams must belong to this season'], 422
        );
    }

    // Check: same matchup already exists (order-independent)
    $duplicateMatchup = $season->games()
        ->where(function ($q) use ($homeId, $awayId) {
            $q->where(function ($q2) use ($homeId, $awayId) {
                $q2->where('home_team_id', $homeId)
                   ->where('away_team_id', $awayId);
            })->orWhere(function ($q2) use ($homeId, $awayId) {
                $q2->where('home_team_id', $awayId)
                   ->where('away_team_id', $homeId);
            });
        })->exists();

    if ($duplicateMatchup) {
        return response()->json(
            ['message' => 'This matchup already exists in the season'], 422
        );
    }

    // Check: either team already has a game on this date
    $conflictingGame = $season->games()
        ->whereDate('scheduled_at', $date)
        ->where(function ($q) use ($homeId, $awayId) {
            $q->whereIn('home_team_id', [$homeId, $awayId])
              ->orWhereIn('away_team_id', [$homeId, $awayId]);
        })->exists();

    if ($conflictingGame) {
        return response()->json(
            ['message' => 'One or both teams already have a game on this date'], 422
        );
    }

    $data['season_id'] = $season->id;
    $data['status']    = 'scheduled';
    $game = Game::create($data);

    return response()->json($game->load(['homeTeam', 'awayTeam']), 201);
}

    public function show(Request $request, Game $game)
    {
        // Ensure game belongs to auth user's season
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        $game->load(['homeTeam', 'awayTeam', 'result.playerStats.player']);
        return response()->json($game);
    }

    // POST /api/games/{game}/result
    public function submitResult(Request $request, Game $game)
    {
        // Ensure game belongs to auth user's season
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $data = $request->validate([
            'home_score' => 'required|integer|min:0',
            'away_score' => 'required|integer|min:0',
        ]);

        // Create result and mark game as done
        $result = GameResult::create([
            'game_id'    => $game->id,
            'home_score' => $data['home_score'],
            'away_score' => $data['away_score'],
        ]);

        $game->update(['status' => 'done']);

        return response()->json([
            'message' => 'Result submitted',
            'result'  => $result,
        ]);
    }

    // POST /api/games/{game}/stats
    // Accepts an array of player stats
    public function submitStats(Request $request, Game $game)
    {
        // Ensure game belongs to auth user's season
        if ($game->season->league->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Forbidden'], 403);
        }
        // Game must be done before stats can be submitted
        if ($game->status !== 'done') {
            return response()->json(
                ['message' => 'Game must be done before submitting stats'], 422
            );
        }

        $request->validate([
            'stats'                 => 'required|array',
            'stats.*.player_id'    => 'required|exists:players,id',
            'stats.*.points'       => 'required|integer|min:0',
            'stats.*.assists'      => 'required|integer|min:0',
            'stats.*.rebounds'     => 'required|integer|min:0',
            'stats.*.fouls'        => 'required|integer|min:0',
        ]);

        $result = $game->result;

        // Bulk insert all player stats at once
        $statsToInsert = array_map(function ($stat) use ($result) {
            return [
                'game_result_id' => $result->id,
                'player_id'      => $stat['player_id'],
                'points'         => $stat['points'],
                'assists'        => $stat['assists'],
                'rebounds'       => $stat['rebounds'],
                'fouls'          => $stat['fouls'],
                'created_at'     => now(),
                'updated_at'     => now(),
            ];
        }, $request->stats);

        PlayerStat::insert($statsToInsert);

        return response()->json(['message' => 'Stats submitted successfully']);
    }
}