<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\GameResultController;
use App\Http\Controllers\LeaderboardController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\TeamController;
use Illuminate\Http\Request;
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

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/leaderboard', [LeaderboardController::class, 'topPlayers']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/leagues', [LeagueController::class, 'index']);
    Route::post('/leagues', [LeagueController::class, 'store']);
    Route::get('/leagues/{league}', [LeagueController::class, 'show']);
    Route::put('/leagues/{league}', [LeagueController::class, 'update']);
    Route::delete('/leagues/{league}', [LeagueController::class, 'destroy']);

    Route::get('/leagues/{league}/seasons', [SeasonController::class, 'index']);
    Route::post('/leagues/{league}/seasons', [SeasonController::class, 'store']);
    Route::get('/leagues/{league}/seasons/{season}', [SeasonController::class, 'show']);
    Route::put('/leagues/{league}/seasons/{season}', [SeasonController::class, 'update']);
    Route::delete('/leagues/{league}/seasons/{season}', [SeasonController::class, 'destroy']);

    Route::get('/leagues/{league}/seasons/{season}/games', [GameController::class, 'index']);
    Route::post('/leagues/{league}/seasons/{season}/games', [GameController::class, 'store']);
    Route::post('/leagues/{league}/seasons/{season}/games/{game}/result', [GameResultController::class, 'submitResult']);
    Route::post('/leagues/{league}/seasons/{season}/games/{game}/stats', [GameResultController::class, 'submitStats']);

    Route::post('/teams/{team}/players', [TeamController::class, 'attachPlayer']);
    Route::delete('/teams/{team}/players/{player}', [TeamController::class, 'detachPlayer']);
});
