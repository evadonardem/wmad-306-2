<?php

namespace App\Http\Controllers;

use App\Models\Game;
use App\Models\GameResult;
use App\Models\League;
use App\Models\Season;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class GameResultController extends Controller
{
    public function submitResult(Request $request, League $league, Season $season, Game $game): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);
        $this->authorizeSeasonForLeague($league, $season);
        $this->authorizeGameForSeason($season, $game);

        $data = $request->validate([
            'home_score' => ['required', 'integer', 'min:0'],
            'away_score' => ['required', 'integer', 'min:0'],
        ]);

        $result = GameResult::updateOrCreate(
            ['game_id' => $game->id],
            [
                'home_score' => $data['home_score'],
                'away_score' => $data['away_score'],
                'stats' => $game->result?->stats ?? null,
            ]
        );

        $game->update(['status' => 'done']);

        return response()->json($result);
    }

    public function submitStats(Request $request, League $league, Season $season, Game $game): JsonResponse
    {
        $this->authorizeLeagueOwner($request, $league);
        $this->authorizeSeasonForLeague($league, $season);
        $this->authorizeGameForSeason($season, $game);

        if ($game->status !== 'done') {
            return response()->json([
                'message' => 'Stats can only be submitted after the game is done.',
            ], 422);
        }

        $data = $request->validate([
            'stats' => ['required', 'array'],
        ]);

        $result = $game->result;

        if (! $result) {
            return response()->json([
                'message' => 'Game result must be submitted before stats.',
            ], 422);
        }

        $result->update(['stats' => $data['stats']]);

        return response()->json($result);
    }

    protected function authorizeLeagueOwner(Request $request, League $league): void
    {
        if ($league->user_id !== $request->user()->id) {
            abort(403);
        }
    }

    protected function authorizeSeasonForLeague(League $league, Season $season): void
    {
        if ($season->league_id !== $league->id) {
            abort(404);
        }
    }

    protected function authorizeGameForSeason(Season $season, Game $game): void
    {
        if ($game->season_id !== $season->id) {
            abort(404);
        }
    }
}
