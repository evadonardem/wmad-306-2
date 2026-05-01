<?php

namespace App\Http\Controllers;

use App\Models\Player;
use App\Models\Season;
use App\Models\Team;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function index(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        $request->user()->leagues()->findOrFail($season->league_id);

        $teams = $season->teams()->with('players')->get();
        return response()->json($teams);
    }

    public function store(Request $request, $seasonId)
    {
        $season = Season::findOrFail($seasonId);
        $request->user()->leagues()->findOrFail($season->league_id);

        $request->validate([
            'name'  => 'required|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $team = $season->teams()->create($request->only('name', 'coach'));

        return response()->json($team, 201);
    }

    public function show(Request $request, $id)
    {
        $team = Team::with(['players' => function ($q) {
            $q->withPivot('jersey_number');
        }])->findOrFail($id);

        $season = Season::findOrFail($team->season_id);
        $request->user()->leagues()->findOrFail($season->league_id);

        return response()->json($team);
    }

    public function update(Request $request, $id)
    {
        $team = Team::findOrFail($id);
        $season = Season::findOrFail($team->season_id);
        $request->user()->leagues()->findOrFail($season->league_id);

        $request->validate([
            'name'  => 'sometimes|string|max:255',
            'coach' => 'nullable|string|max:255',
        ]);

        $team->update($request->only('name', 'coach'));

        return response()->json($team);
    }

    public function addPlayer(Request $request, $teamId)
    {
        $team = Team::findOrFail($teamId);
        $season = Season::findOrFail($team->season_id);
        $request->user()->leagues()->findOrFail($season->league_id);

        $request->validate([
            'player_id'    => 'required|exists:players,id',
            'jersey_number' => 'required|integer',
        ]);

        $team->players()->attach($request->player_id, [
            'jersey_number' => $request->jersey_number,
        ]);

        return response()->json(['message' => 'Player added to team.'], 201);
    }

    public function removePlayer(Request $request, $teamId, $playerId)
    {
        $team = Team::findOrFail($teamId);
        $season = Season::findOrFail($team->season_id);
        $request->user()->leagues()->findOrFail($season->league_id);

        $team->players()->detach($playerId);

        return response()->json(['message' => 'Player removed from team.']);
    }

    public function createPlayer(Request $request)
    {
        $request->validate([
            'name'      => 'required|string|max:255',
            'birthdate' => 'nullable|date',
            'position'  => 'nullable|string|max:100',
        ]);

        $player = Player::create($request->only('name', 'birthdate', 'position'));

        return response()->json($player, 201);
    }
    public function playerProfile(Request $request, $playerId)
{
    $player = \App\Models\Player::find($playerId);

    if (! $player) {
        return response()->json(['message' => 'Player not found.'], 404);
    }

    // Teams with season name and jersey number from pivot
    $teams = $player->teams()
        ->withPivot('jersey_number')
        ->with('season:id,name')
        ->get()
        ->map(function ($team) {
            return [
                'team_id'      => $team->id,
                'team_name'    => $team->name,
                'season_name'  => $team->season->name,
                'jersey_number'=> $team->pivot->jersey_number,
            ];
        });

    // Career totals
    $careerStats = \App\Models\PlayerStat::where('player_id', $playerId)
        ->selectRaw('
            COUNT(DISTINCT game_result_id) as total_games_played,
            SUM(points)   as total_points,
            SUM(assists)  as total_assists,
            SUM(rebounds) as total_rebounds
        ')
        ->first();

    // Personal best game (most points in a single game)
    $bestStat = \App\Models\PlayerStat::where('player_id', $playerId)
        ->with(['gameResult.game'])
        ->orderByDesc('points')
        ->first();

    $personalBest = null;
    if ($bestStat) {
        $personalBest = [
            'game_id'    => $bestStat->gameResult->game->id,
            'points'     => $bestStat->points,
            'scheduled_at' => $bestStat->gameResult->game->scheduled_at,
        ];
    }

    return response()->json([
        'id'           => $player->id,
        'name'         => $player->name,
        'position'     => $player->position,
        'birthdate'    => $player->birthdate,
        'teams'        => $teams,
        'career_totals' => [
            'games_played'   => (int) ($careerStats->total_games_played ?? 0),
            'total_points'   => (int) ($careerStats->total_points   ?? 0),
            'total_assists'  => (int) ($careerStats->total_assists  ?? 0),
            'total_rebounds' => (int) ($careerStats->total_rebounds ?? 0),
        ],
        'personal_best_game' => $personalBest,
    ]);
}
}
