<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\PlayerController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\TeamController;
use Illuminate\Routing\Route as RoutingRoute;
use Illuminate\Support\Facades\Route;

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

// Public routes (no authentication required)
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// Protected routes (authentication required)
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('logout', [AuthController::class, 'logout']);

    // Leagues - CRUD endpoints
    Route::get('leagues', [LeagueController::class, 'index']);
    Route::post('leagues', [LeagueController::class, 'store']);
    Route::get('leagues/{league}', [LeagueController::class, 'show']);
    Route::put('leagues/{league}', [LeagueController::class, 'update']);
    Route::delete('leagues/{league}', [LeagueController::class, 'destroy']);

    // Seasons - CRUD endpoints under leagues
    Route::get('leagues/{league}/seasons', [SeasonController::class, 'index']);
    Route::post('leagues/{league}/seasons', [SeasonController::class, 'store']);
    Route::get('seasons/{season}', [SeasonController::class, 'show']);
    Route::put('seasons/{season}', [SeasonController::class, 'update']);

    // Teams - CRUD endpoints under seasons
    Route::get('seasons/{season}/teams', [TeamController::class, 'indexByseason']);
    Route::post('seasons/{season}/teams', [TeamController::class, 'storeInSeason']);
    Route::get('teams/{team}', [TeamController::class, 'show']);
    Route::put('teams/{team}', [TeamController::class, 'update']);

    // Player management on teams
    Route::post('teams/{team}/players', [TeamController::class, 'addPlayer']);
    Route::delete('teams/{team}/players/{player}', [TeamController::class, 'removePlayer']);

    // Games - Schedule and results under seasons
    Route::get('seasons/{season}/games', [GameController::class, 'indexBySeason']);
    Route::post('seasons/{season}/games', [GameController::class, 'storeInSeason']);
    Route::get('games/{game}', [GameController::class, 'show']);
    Route::post('games/{game}/result', [GameController::class, 'submitResult']);
    Route::post('games/{game}/stats', [GameController::class, 'submitPlayerStats']);

    // Season summary
    Route::get('seasons/{season}/summary', [SeasonController::class, 'summary']);

    // Player profile
    Route::get('players/{player}/profile', [PlayerController::class, 'profile']);

    // Standings and Leaderboard
    Route::get('seasons/{season}/standings', [StandingsController::class, 'standings']);
    Route::get('seasons/{season}/leaderboard', [StandingsController::class, 'leaderboard']);
});
