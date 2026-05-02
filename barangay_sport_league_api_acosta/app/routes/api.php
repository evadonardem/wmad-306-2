<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\PlayerController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\StatsController;
use App\Http\Controllers\TeamController;
use Illuminate\Http\Request;
use Illuminate\Routing\Route as RoutingRoute;
use Illuminate\Support\Facades\Route;

// API Info Route
Route::get('/', function () {
    $routes = collect(Route::getRoutes())
        ->filter(function (RoutingRoute $route) {
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

// Authentication Routes (Public)
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// Protected Routes (Require Authentication)
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('logout', [AuthController::class, 'logout']);

    // Leagues
    Route::apiResource('leagues', LeagueController::class);

    // Seasons (Nested under Leagues)
    Route::apiResource('leagues.seasons', SeasonController::class);

    // Teams (Nested under Leagues > Seasons)
    Route::apiResource('leagues.seasons.teams', TeamController::class);

    // Players (Nested under Leagues > Seasons > Teams)
    Route::apiResource('leagues.seasons.teams.players', PlayerController::class);

    // Games (Nested under Leagues > Seasons)
    Route::apiResource('leagues.seasons.games', GameController::class);

    // Game Results
    Route::post('leagues/{league}/seasons/{season}/games/{game}/result', [GameController::class, 'submitResult']);

    // Standings
    Route::get('leagues/{league}/seasons/{season}/standings', [StandingsController::class, 'index']);

    // Stats & Leaderboards
    Route::get('leagues/{league}/seasons/{season}/leaderboard', [StatsController::class, 'playerLeaderboard']);
    Route::get('leagues/{league}/seasons/{season}/top-scorers', [StatsController::class, 'topScorers']);
    Route::get('leagues/{league}/seasons/{season}/stats', [StatsController::class, 'gameStats']);
    
    // Exercise 11 — Season Summary (Ex 1) - Flat route
    Route::get('seasons/{season}/summary', [StatsController::class, 'seasonSummary']);
    
    // Exercise 11 — Player Profile (Ex 3) - Flat route
    Route::get('players/{player}/profile', [StatsController::class, 'playerProfile']);
});
