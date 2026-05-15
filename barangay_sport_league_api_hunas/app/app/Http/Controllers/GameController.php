<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\Season;
use App\Models\PlayerStat;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class GameController extends Controller
{
    /**
     * List all games for a specific season.
     */
    public function index(Season $season): JsonResponse
    {
        // Using Route Model Binding (Season $season) removes the need for findOrFail
        $fixtures = $season->games()
            ->with(['homeTeam', 'awayTeam', 'result'])
            ->get();

        return response()->json($fixtures);
    }

    /**
     * Schedule a new game with strict league rules.
     */
    public function store(Request $request, Season $season): JsonResponse
    {
        $input = $request->validate([
            'home_team_id' => ['required', 'exists:teams,id'],
            'away_team_id' => ['required', 'exists:teams,id'],
            'scheduled_at' => ['required', 'date'],
            'venue'        => ['required', 'string', 'max:255'],
        ]);

        $home = $input['home_team_id'];
        $away = $input['away_team_id'];

        // 1. Validation: Self-matchup check
        abort_if($home == $away, 422, 'A team cannot play against itself.');

        // 2. Validation: Ensure both teams belong to the season
        $registeredTeams = $season->teams()->whereIn('teams.id', [$home, $away])->count();
        abort_if($registeredTeams !== 2, 422, 'One or both teams are not part of this season.');

        // 3. Validation: Unique matchup check (Bidirectional)
        $exists = $season->games()->where(function ($query) use ($home, $away) {
            $query->whereIn('home_team_id', [$home, $away])
                  ->whereIn('away_team_id', [$home, $away]);
        })->exists();

        abort_if($exists, 422, 'This matchup already exists in the schedule.');

        // 4. Validation: Schedule conflict check
        $day = Carbon::parse($input['scheduled_at'])->toDateString();
        $hasConflict = $season->games()
            ->whereDate('scheduled_at', $day)
            ->where(fn($q) => $q->whereIn('home_team_id', [$home, $away])->orWhereIn('away_team_id', [$home, $away]))
            ->exists();

        abort_if($hasConflict, 422, 'Teams are already booked for this date.');

        $match = $season->games()->create(array_merge($input, ['status' => 'scheduled']));

        return response()->json($match->load('homeTeam', 'awayTeam'), 201);
    }

    /**
     * Fetch detailed game information and player stats.
     */
    public function show(Game $game): JsonResponse
    {
        return response()->json($game->load(['homeTeam', 'awayTeam', 'result.playerStats.player']));
    }

    /**
     * Finalize game score.
     */
    public function submitResult(Request $request, Game $game): JsonResponse
    {
        if ($game->status === 'done') {
            return response()->json(['message' => 'Outcome already recorded.'], 422);
        }

        $scores = $request->validate([
            'home_score' => ['required', 'integer', 'min:0'],
            'away_score' => ['required', 'integer', 'min:0'],
        ]);

        $game->result()->create($scores);
        $game->update(['status' => 'done']);

        return response()->json(['message' => 'Score updated.', 'data' => $game->result], 201);
    }

    /**
     * Batch insert individual player statistics.
     */
    public function submitStats(Request $request, Game $game): JsonResponse
    {
        abort_unless($game->status === 'done', 422, 'Record the game score before adding stats.');

        $request->validate([
            'stats'               => ['required', 'array', 'min:1'],
            'stats.*.player_id'   => ['required', 'exists:players,id'],
            'stats.*.points'      => ['required', 'integer', 'min:0'],
            'stats.*.assists'     => ['required', 'integer', 'min:0'],
            'stats.*.rebounds'    => ['required', 'integer', 'min:0'],
            'stats.*.fouls'       => ['required', 'integer', 'min:0'],
        ]);

        $resultId = $game->result->id;
        
        $payload = collect($request->stats)->map(function ($stat) use ($resultId) {
            return array_merge($stat, [
                'game_result_id' => $resultId,
                'created_at'     => now(),
                'updated_at'     => now(),
            ]);
        });

        PlayerStat::insert($payload->all());

        return response()->json(['message' => 'Box score populated.'], 201);
    }
}