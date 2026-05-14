<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\PlayerController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\SeasonController;
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

Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('logout', [AuthController::class, 'logout']);

    Route::get('leagues', [LeagueController::class, 'index']);
    Route::post('leagues', [LeagueController::class, 'store']);
    Route::get('leagues/{league}', [LeagueController::class, 'show']);
    Route::put('leagues/{league}', [LeagueController::class, 'update']);
    Route::delete('leagues/{league}', [LeagueController::class, 'destroy']);

    Route::get('leagues/{league}/seasons', [SeasonController::class, 'index']);
    Route::post('leagues/{league}/seasons', [SeasonController::class, 'store']);
    Route::get('seasons/{id}', [SeasonController::class, 'show']);
    Route::put('seasons/{id}', [SeasonController::class, 'update']);

    Route::get('seasons/{id}/teams', [TeamController::class, 'index']);
    Route::post('seasons/{id}/teams', [TeamController::class, 'store']);
    Route::get('teams/{id}', [TeamController::class, 'show']);
    Route::put('teams/{id}', [TeamController::class, 'update']);
    Route::post('teams/{id}/players', [TeamController::class, 'addPlayer']);
    Route::delete('teams/{id}/players/{playerId}', [TeamController::class, 'removePlayer']);

    Route::get('seasons/{id}/games', [GameController::class, 'index']);
    Route::post('seasons/{id}/games', [GameController::class, 'store']);
    Route::get('seasons/{id}/summary', [ReportController::class, 'summary']);
    Route::get('games/{id}', [GameController::class, 'show']);
    Route::post('games/{id}/result', [GameController::class, 'submitResult']);
    Route::post('games/{id}/stats', [GameController::class, 'submitStats']);
    Route::get('players/{id}/profile', [PlayerController::class, 'profile']);

    Route::get('seasons/{id}/standings', [ReportController::class, 'standings']);
    Route::get('seasons/{id}/leaderboard', [ReportController::class, 'leaderboard']);
});
