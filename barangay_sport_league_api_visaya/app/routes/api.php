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

// A safe, simple welcome route to test if your API is online
Route::get('/', function () {
    return response()->json([
        'message' => 'Welcome to the Barangay Sports League API',
        'status' => 'Online'
    ]);
});

// --------------------------------------------------------
// PUBLIC ROUTES (No token needed)
// --------------------------------------------------------
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// --------------------------------------------------------
// PROTECTED ROUTES (Requires a valid Sanctum token)
// --------------------------------------------------------
Route::middleware('auth:sanctum')->group(function () {
    
    // Revoke the token
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Part 7.1: League Routes
    Route::apiResource('leagues', LeagueController::class);
    
    // Part 7.2: Season Routes
    Route::get('/leagues/{id}/seasons', [SeasonController::class, 'index']);
    Route::post('/leagues/{id}/seasons', [SeasonController::class, 'store']);
    Route::get('/seasons/{id}', [SeasonController::class, 'show']);
    Route::put('/seasons/{id}', [SeasonController::class, 'update']);
    
    // Part 7.3: Team & Player Routes
    Route::get('/seasons/{id}/teams', [TeamController::class, 'index']);
    Route::post('/seasons/{id}/teams', [TeamController::class, 'store']);
    Route::get('/teams/{id}', [TeamController::class, 'show']);
    Route::put('/teams/{id}', [TeamController::class, 'update']);
    Route::post('/teams/{id}/players', [TeamController::class, 'addPlayer']);
    Route::delete('/teams/{id}/players/{playerId}', [TeamController::class, 'removePlayer']);
    
    // Part 7.4: Game & Result Routes
    Route::get('/seasons/{id}/games', [GameController::class, 'index']);
    Route::post('/seasons/{id}/games', [GameController::class, 'store']);
    Route::get('/games/{id}', [GameController::class, 'show']);
    Route::post('/games/{id}/result', [GameController::class, 'submitResult']);
    Route::post('/games/{id}/stats', [GameController::class, 'submitStats']);
    
    // Part 7.5: Standings & Leaderboard Routes
    Route::get('/seasons/{id}/standings', [StandingsController::class, 'standings']);
    Route::get('/seasons/{id}/leaderboard', [StandingsController::class, 'leaderboard']);
    Route::get('/seasons/{id}/summary', [StandingsController::class, 'summary']);

    // Exercise 3: Player profile endpoint
    Route::get('/players/{id}/profile', [PlayerController::class, 'profile']);
    
});