<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\PlayerController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('logout', [AuthController::class, 'logout']);

    // Leagues & Seasons
    Route::apiResource('leagues', LeagueController::class);
    Route::apiResource('leagues.seasons', SeasonController::class)->shallow();

    // Teams & Players
    Route::get('seasons/{season}/teams', [TeamController::class, 'index']);
    Route::post('seasons/{season}/teams', [TeamController::class, 'store']);
    Route::apiResource('teams', TeamController::class)->only(['show', 'update']);
    Route::post('teams/{team}/players', [TeamController::class, 'addPlayer']);
    Route::delete('teams/{team}/players/{player}', [TeamController::class, 'removePlayer']);

    // Games & Results
    Route::get('seasons/{season}/games', [GameController::class, 'index']);
    Route::post('seasons/{season}/games', [GameController::class, 'store']);
    Route::get('games/{game}', [GameController::class, 'show']);
    Route::post('games/{game}/result', [GameController::class, 'submitResult']);
    Route::post('games/{game}/stats', [GameController::class, 'submitStats']);

    // Standings, Leaderboard, Summary
    Route::get('seasons/{season}/standings', [StandingsController::class, 'getStandings']);
    Route::get('seasons/{season}/leaderboard', [StandingsController::class, 'getLeaderboard']);
    Route::get('seasons/{season}/summary', [StandingsController::class, 'getSeasonSummary']);

    // Player Profile & CRUD
    Route::apiResource('players', PlayerController::class);
    Route::get('players/{player}/profile', [PlayerController::class, 'showProfile']);
});
