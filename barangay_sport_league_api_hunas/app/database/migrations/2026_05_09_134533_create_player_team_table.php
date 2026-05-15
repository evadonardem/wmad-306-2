<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('player_team', function (Blueprint $table) {
            $table->unsignedBigInteger('team_id');
            $table->unsignedBigInteger('player_id');
            
            $table->unsignedSmallInteger('jersey_number')->default(0);

            // Setting up foreign constraints manually
            $table->foreign('team_id')
                  ->references('id')
                  ->on('teams')
                  ->onDelete('cascade');

            $table->foreign('player_id')
                  ->references('id')
                  ->on('players')
                  ->onDelete('cascade');

            // Compound Primary Key
            $table->primary(['player_id', 'team_id'], 'pt_composite_primary');
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('player_team');
    }
};