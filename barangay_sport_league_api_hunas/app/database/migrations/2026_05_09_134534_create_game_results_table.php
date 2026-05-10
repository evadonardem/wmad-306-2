<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('game_results', function (Blueprint $table) {
            $table->bigIncrements('id');

            // Explicit foreign key with unique constraint to ensure 1-to-1 relationship
            $table->unsignedBigInteger('game_id');
            $table->foreign('game_id')
                  ->references('id')
                  ->on('games')
                  ->onDelete('cascade');
            
            $table->unique('game_id', 'unique_game_result');

            // Score data using unsigned types (scores can't be negative)
            $table->unsignedSmallInteger('home_score')->default(0);
            $table->unsignedSmallInteger('away_score')->default(0);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('game_results');
    }
};