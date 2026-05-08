<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\LeagueController;
use App\Http\Controllers\SeasonController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\StandingsController;
use App\Http\Controllers\PlayerController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    Route::apiResource('leagues', LeagueController::class);
    
    Route::get('/leagues/{leagueId}/seasons', [SeasonController::class, 'index']);
    Route::post('/leagues/{leagueId}/seasons', [SeasonController::class, 'store']);
    Route::get('/seasons/{id}', [SeasonController::class, 'show']);
    Route::put('/seasons/{id}', [SeasonController::class, 'update']);
    Route::get('/seasons/{id}/summary', [SeasonController::class, 'summary']);
    
    Route::get('/seasons/{seasonId}/teams', [TeamController::class, 'index']);
    Route::post('/seasons/{seasonId}/teams', [TeamController::class, 'store']);
    Route::get('/teams/{id}', [TeamController::class, 'show']);
    Route::put('/teams/{id}', [TeamController::class, 'update']);
    Route::post('/teams/{id}/players', [TeamController::class, 'addPlayer']);
    Route::delete('/teams/{id}/players/{playerId}', [TeamController::class, 'removePlayer']);
    
    Route::get('/seasons/{seasonId}/games', [GameController::class, 'index']);
    Route::post('/seasons/{seasonId}/games', [GameController::class, 'store']);
    Route::get('/games/{id}', [GameController::class, 'show']);
    Route::post('/games/{id}/result', [GameController::class, 'submitResult']);
    Route::post('/games/{id}/stats', [GameController::class, 'submitStats']);
    
    Route::get('/seasons/{seasonId}/standings', [StandingsController::class, 'standings']);
    
    Route::get('/players/{id}/profile', [PlayerController::class, 'profile']);
    Route::get('/seasons/{seasonId}/leaderboard', [StandingsController::class, 'leaderboard']);
});
