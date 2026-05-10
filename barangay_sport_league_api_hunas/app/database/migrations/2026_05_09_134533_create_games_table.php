<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('games', function (Blueprint $table) {
            $table->bigIncrements('id');

            // Link to the parent season
            $table->unsignedBigInteger('season_id')->index();
            $table->foreign('season_id')
                  ->references('id')
                  ->on('seasons')
                  ->onDelete('cascade');

            // Competitor relationships
            $table->unsignedBigInteger('home_team_id');
            $table->unsignedBigInteger('away_team_id');
            
            $table->foreign('home_team_id')->references('id')->on('teams')->onDelete('cascade');
            $table->foreign('away_team_id')->references('id')->on('teams')->onDelete('cascade');

            // Logistics
            $table->timestamp('scheduled_at')->nullable();
            $table->string('venue', 255)->charset('utf8mb4');
            
            // Match progress
            $table->string('status', 50)->default('scheduled');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('games');
    }
};