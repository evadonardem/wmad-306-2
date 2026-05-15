<?php

use App\Http\Controllers\{
    AuthController,
    GameController,
    LeagueController,
    PlayerController,
    SeasonController,
    StandingsController,
    TeamController
};
use Illuminate\Support\Facades\Route;


Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    Route::post('logout', [AuthController::class, 'logout']);

    // League Management
    Route::apiResource('leagues', LeagueController::class);

    // Season Management
    Route::prefix('leagues/{league}')->controller(SeasonController::class)->group(function () {
        Route::get('seasons', 'index');
        Route::post('seasons', 'store');
    });

    Route::prefix('seasons/{season}')->group(function () {
        Route::controller(SeasonController::class)->group(function () {
            Route::get('/', 'show');
            Route::put('/', 'update');
            Route::get('summary', 'summary');
        });

        Route::controller(TeamController::class)->group(function () {
            Route::get('teams', 'index');
            Route::post('teams', 'store');
        });

        Route::controller(GameController::class)->group(function () {
            Route::get('games', 'index');
            Route::post('games', 'store');
        });

        Route::controller(StandingsController::class)->group(function () {
            Route::get('standings', 'standings');
            Route::get('leaderboard', 'leaderboard');
        });
    });

    // Team & Roster Operations
    Route::prefix('teams/{team}')->controller(TeamController::class)->group(function () {
        Route::get('/', 'show');
        Route::put('/', 'update');
        Route::post('players', 'addPlayer');
        Route::delete('players/{player}', 'removePlayer');
    });

    // Player Directory
    Route::prefix('players')->controller(PlayerController::class)->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::get('{player}/profile', 'profile');
    });

    // Game Actions
    Route::prefix('games/{game}')->controller(GameController::class)->group(function () {
        Route::get('/', 'show');
        Route::post('result', 'submitResult');
        Route::post('stats', 'submitStats');
    });

});