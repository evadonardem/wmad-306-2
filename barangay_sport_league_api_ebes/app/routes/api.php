<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\PlayerController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\TeamController;
use Illuminate\Support\Facades\Route;

// ── Public Auth Routes ──────────────────────────────────────────────────────
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// ── Protected Routes ────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);

    // Leagues
    Route::apiResource('leagues', LeagueController::class);

    // Seasons (nested under league for create/list; standalone for show/update)
    Route::get('leagues/{league}/seasons',  [SeasonController::class, 'index']);
    Route::post('leagues/{league}/seasons', [SeasonController::class, 'store']);
    Route::get('seasons/{season}',          [SeasonController::class, 'show']);
    Route::put('seasons/{season}',          [SeasonController::class, 'update']);
    Route::get('seasons/{season}/summary',  [SeasonController::class, 'summary']);  // Ex 1

    // Teams
    Route::get('seasons/{season}/teams',  [TeamController::class, 'index']);
    Route::post('seasons/{season}/teams', [TeamController::class, 'store']);
    Route::get('teams/{team}',            [TeamController::class, 'show']);
    Route::put('teams/{team}',            [TeamController::class, 'update']);

    // Players on Team (roster management)
    Route::post('teams/{team}/players',                   [TeamController::class, 'addPlayer']);
    Route::delete('teams/{team}/players/{player}',        [TeamController::class, 'removePlayer']);

    // Standalone Players
    Route::get('players',        [PlayerController::class, 'index']);
    Route::post('players',       [PlayerController::class, 'store']);
    Route::get('players/{player}/profile', [PlayerController::class, 'profile']);  // Ex 3

    // Games
    Route::get('seasons/{season}/games',  [GameController::class, 'index']);
    Route::post('seasons/{season}/games', [GameController::class, 'store']);
    Route::get('games/{game}',            [GameController::class, 'show']);
    Route::post('games/{game}/result',    [GameController::class, 'submitResult']);
    Route::post('games/{game}/stats',     [GameController::class, 'submitStats']);

    // Standings & Leaderboard
    Route::get('seasons/{season}/standings',   [StandingsController::class, 'standings']);
    Route::get('seasons/{season}/leaderboard', [StandingsController::class, 'leaderboard']);
});