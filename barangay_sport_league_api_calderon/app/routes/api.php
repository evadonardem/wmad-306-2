<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\AnalyticsController;
use App\Http\Controllers\PlayerController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('leagues', LeagueController::class);
    Route::apiResource('leagues.seasons', SeasonController::class)->shallow();

    Route::apiResource('seasons.teams', TeamController::class)->shallow();
    Route::post('teams/{team}/players', [TeamController::class, 'addPlayer']);
    Route::delete('teams/{team}/players/{playerId}', [TeamController::class, 'removePlayer']);

    Route::apiResource('seasons.games', GameController::class)->shallow();
    Route::post('games/{game}/result', [GameController::class, 'submitResult']);
    Route::post('games/{game}/stats', [GameController::class, 'submitStats']);

    Route::get('seasons/{season}/standings', [AnalyticsController::class, 'standings']);
    Route::get('seasons/{season}/leaderboard', [AnalyticsController::class, 'leaderboard']);
    Route::get('seasons/{season}/summary', [AnalyticsController::class, 'summary']);

    Route::get('players/{player}/profile', [PlayerController::class, 'profile']);
});
