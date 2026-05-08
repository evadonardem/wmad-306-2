<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\PlayerController;
use Illuminate\Http\Request;
use Illuminate\Routing\Route as RoutingRoute;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/', function () {
        $routes = collect(Route::getRoutes())
            ->filter(function (RoutingRoute $route) {
                // Only include routes that start with 'api/'
                return str_starts_with($route->uri(), 'api');
            })
            ->map(function (RoutingRoute $route) {
            return [
                'method' => implode('|', $route->methods()),
                'uri'    => $route->uri(),
                'action' => $route->getActionName(),
            ];
        });

        return response()->json([
            'api' => config('app.name') . ' API',
            'total_api_routes' => $routes->count(),
            'routes' => $routes,
        ]);
    });

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('leagues', LeagueController::class);
    Route::apiResource('leagues.seasons', SeasonController::class);
    Route::apiResource('seasons.teams', TeamController::class);
    Route::post('/teams/{team}/players', [TeamController::class, 'addPlayer']);
    Route::delete('/teams/{team}/players/{player}', [TeamController::class, 'removePlayer']);
    Route::apiResource('seasons.games', GameController::class);
    Route::post('/games/{game}/result', [GameController::class, 'submitResult']);
    Route::post('/games/{game}/stats', [GameController::class, 'submitStats']);
    Route::get('/seasons/{season}/standings', [StandingsController::class, 'seasonStandings']);
    Route::get('/seasons/{season}/leaderboard', [StandingsController::class, 'playerLeaderboard']);
    Route::get('/seasons/{season}/players/leaderboard', [PlayerController::class, 'leaderboard']);
    Route::get('/seasons/{season}/summary', [StandingsController::class, 'seasonSummary']);
    Route::apiResource('players', PlayerController::class);
    Route::get('/players/{player}/profile', [PlayerController::class, 'profile']);
});
