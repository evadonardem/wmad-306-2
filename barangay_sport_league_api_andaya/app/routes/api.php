<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\PlayerController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\TeamController;
use Illuminate\Http\Request;
use Illuminate\Routing\Route as RoutingRoute;
use Illuminate\Support\Facades\Route;

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

// Public auth routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Leagues
    Route::apiResource('leagues', LeagueController::class);
    
    // Seasons (nested under leagues)
    Route::get('/leagues/{leagueId}/seasons', [SeasonController::class, 'index']);
    Route::post('/leagues/{leagueId}/seasons', [SeasonController::class, 'store']);
    Route::get('/seasons/{id}', [SeasonController::class, 'show']);
    Route::put('/seasons/{id}', [SeasonController::class, 'update']);
    Route::get('/seasons/{id}/summary', [SeasonController::class, 'summary']);
    
    // Teams (nested under seasons)
    Route::get('/seasons/{seasonId}/teams', [TeamController::class, 'index']);
    Route::post('/seasons/{seasonId}/teams', [TeamController::class, 'store']);
    Route::get('/teams/{id}', [TeamController::class, 'show']);
    Route::put('/teams/{id}', [TeamController::class, 'update']);
    Route::post('/teams/{id}/players', [TeamController::class, 'addPlayer']);
    Route::delete('/teams/{id}/players/{playerId}', [TeamController::class, 'removePlayer']);
    
    // Games (nested under seasons)
    Route::get('/seasons/{seasonId}/games', [GameController::class, 'index']);
    Route::post('/seasons/{seasonId}/games', [GameController::class, 'store']);
    Route::get('/games/{id}', [GameController::class, 'show']);
    Route::post('/games/{id}/result', [GameController::class, 'submitResult']);
    Route::post('/games/{id}/stats', [GameController::class, 'submitStats']);
    
    // Standings & Leaderboard (nested under seasons)
    Route::get('/seasons/{id}/standings', [StandingsController::class, 'standings']);
    Route::get('/seasons/{id}/leaderboard', [StandingsController::class, 'leaderboard']);
    
    // Player profile
    Route::get('/players/{id}/profile', [PlayerController::class, 'profile']);
});
