<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('player_stats', function (Blueprint $table) {
            $table->bigIncrements('id');

            // Explicit relationship definitions
            $table->unsignedBigInteger('game_result_id')->index();
            $table->unsignedBigInteger('player_id')->index();

            $table->foreign('game_result_id')
                  ->references('id')
                  ->on('game_results')
                  ->onDelete('cascade');

            $table->foreign('player_id')
                  ->references('id')
                  ->on('players')
                  ->onDelete('cascade');

            // Performance Metrics (using unsignedSmallInteger for optimization)
            $table->unsignedSmallInteger('points')->default(0);
            $table->unsignedSmallInteger('assists')->default(0);
            $table->unsignedSmallInteger('rebounds')->default(0);
            $table->unsignedSmallInteger('fouls')->default(0);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('player_stats');
    }
};