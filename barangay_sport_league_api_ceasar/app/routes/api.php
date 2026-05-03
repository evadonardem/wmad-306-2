<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\PlayerController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\StandingsController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    Route::apiResource('leagues', LeagueController::class);
    Route::apiResource('leagues.seasons', SeasonController::class)->shallow();
    Route::apiResource('seasons.teams', TeamController::class)->shallow();
    Route::apiResource('seasons.games', GameController::class)->shallow();
    
    // Players (if needed individually, but the spec only mentions teams/{id}/players)
    Route::apiResource('players', PlayerController::class);

    // Teams & Players Pivot
    Route::post('teams/{team}/players', [TeamController::class, 'addPlayer']);
    Route::delete('teams/{team}/players/{player}', [TeamController::class, 'removePlayer']);

    // Games & Results
    Route::post('games/{game}/result', [GameController::class, 'submitResult']);
    Route::post('games/{game}/stats', [GameController::class, 'submitStats']);

    // Standings & Leaderboard
    Route::get('seasons/{season}/standings', [StandingsController::class, 'standings']);
    Route::get('seasons/{season}/leaderboard', [StandingsController::class, 'leaderboard']);

    // Exercises
    Route::get('seasons/{season}/summary', [SeasonController::class, 'summary']);
    Route::get('players/{player}/profile', [PlayerController::class, 'profile']);
});
