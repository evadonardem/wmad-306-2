<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\LeaderboardController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\PlayerController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\SeasonSummaryController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\TeamController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', fn (Request $request) => response()->json($request->user()));
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('leagues', LeagueController::class);

    Route::get('/leagues/{league}/seasons', [SeasonController::class, 'index']);
    Route::post('/leagues/{league}/seasons', [SeasonController::class, 'store']);
    Route::get('/seasons/{season}', [SeasonController::class, 'show']);
    Route::put('/seasons/{season}', [SeasonController::class, 'update']);
    Route::patch('/seasons/{season}', [SeasonController::class, 'update']);
    Route::delete('/seasons/{season}', [SeasonController::class, 'destroy']);

    Route::get('/seasons/{season}/teams', [TeamController::class, 'index']);
    Route::post('/seasons/{season}/teams', [TeamController::class, 'store']);
    Route::get('/teams/{team}', [TeamController::class, 'show']);
    Route::put('/teams/{team}', [TeamController::class, 'update']);
    Route::patch('/teams/{team}', [TeamController::class, 'update']);
    Route::delete('/teams/{team}', [TeamController::class, 'destroy']);
    Route::post('/teams/{team}/players', [TeamController::class, 'addPlayer']);
    Route::delete('/teams/{team}/players/{player}', [TeamController::class, 'removePlayer']);

    Route::apiResource('players', PlayerController::class)->only(['index', 'store', 'destroy']);
    Route::get('/players/{player}/profile', [PlayerController::class, 'profile']);

    Route::get('/seasons/{season}/games', [GameController::class, 'index']);
    Route::post('/seasons/{season}/games', [GameController::class, 'store']);
    Route::get('/games/{game}', [GameController::class, 'show']);
    Route::delete('/games/{game}', [GameController::class, 'destroy']);
    Route::post('/games/{game}/result', [GameController::class, 'result']);
    Route::post('/games/{game}/stats', [GameController::class, 'stats']);

    Route::get('/seasons/{season}/standings', [StandingsController::class, 'index']);
    Route::get('/seasons/{season}/leaderboard', [LeaderboardController::class, 'index']);
    Route::get('/seasons/{season}/summary', [SeasonSummaryController::class, 'index']);
});
