<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\PlayerController;

// Public auth routes (no token needed)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// All routes below require a valid Sanctum token
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Players
    Route::post('players',                         [PlayerController::class, 'store']);
    Route::get('players/{player}/profile',         [PlayerController::class, 'profile']);

    // Leagues
    Route::apiResource('leagues', LeagueController::class);

    // Seasons (nested + standalone)
    Route::get('leagues/{league}/seasons',         [SeasonController::class, 'index']);
    Route::post('leagues/{league}/seasons',        [SeasonController::class, 'store']);
    Route::get('seasons/{season}',                 [SeasonController::class, 'show']);
    Route::put('seasons/{season}',                 [SeasonController::class, 'update']);
    Route::get('seasons/{season}/summary',         [SeasonController::class, 'summary']);

    // Teams & Players
    Route::get('seasons/{season}/teams',           [TeamController::class, 'index']);
    Route::post('seasons/{season}/teams',          [TeamController::class, 'store']);
    Route::get('teams/{team}',                     [TeamController::class, 'show']);
    Route::put('teams/{team}',                     [TeamController::class, 'update']);
    Route::post('teams/{team}/players',            [TeamController::class, 'addPlayer']);
    Route::delete('teams/{team}/players/{player}', [TeamController::class, 'removePlayer']);

    // Games & Results
    Route::get('seasons/{season}/games',           [GameController::class, 'index']);
    Route::post('seasons/{season}/games',          [GameController::class, 'store']);
    Route::get('games/{game}',                     [GameController::class, 'show']);
    Route::post('games/{game}/result',             [GameController::class, 'submitResult']);
    Route::post('games/{game}/stats',              [GameController::class, 'submitStats']);

    // Standings & Leaderboard
    Route::get('seasons/{season}/standings',       [StandingsController::class, 'standings']);
    Route::get('seasons/{season}/leaderboard',     [StandingsController::class, 'leaderboard']);
    Route::get('seasons/{season}/leaderboard',     [StandingsController::class, 'leaderboard']);
});