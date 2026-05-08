<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('player_team', function (Blueprint $table) {
            $table->id();
            $table->foreignId('team_id')->constrained()->onDelete('cascade');
            $table->foreignId('player_id')->constrained()->onDelete('cascade');
            $table->string('jersey_number'); // Pivot data required by PDF
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('player_team');
    }
};
