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
use App\Http\Controllers\PlayerStatController;
use App\Http\Controllers\ExerciseController;

/*
|--------------------------------------------------------------------------
| Public Routes (No Token Required)
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

/*
|--------------------------------------------------------------------------
| Protected Routes (Auth Token Required)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);

    // Standard API Resources (Task 5)
    Route::apiResource('leagues', LeagueController::class);
    Route::apiResource('seasons', SeasonController::class);
    Route::apiResource('teams', TeamController::class);
    Route::apiResource('games', GameController::class);
    Route::apiResource('players', PlayerController::class);

    Route::post('games/{game}/stats', [PlayerStatController::class, 'store']);

    // Leaderboard & Exercises
    Route::get('leaderboard', [ExerciseController::class, 'leaderboard']);
    Route::get('seasons/{season}/summary', [ExerciseController::class, 'seasonSummary']);
    Route::get('players/{player}/profile', [ExerciseController::class, 'playerProfile']);

    // Custom Implementation Routes (Task 5.3 & 8)
    // Add player to team with jersey number
    Route::post('/teams/{team}/players', [TeamController::class, 'addPlayer']);
    
    // View standings for a specific season
    Route::get('/seasons/{season}/standings', [StandingsController::class, 'index']);

});