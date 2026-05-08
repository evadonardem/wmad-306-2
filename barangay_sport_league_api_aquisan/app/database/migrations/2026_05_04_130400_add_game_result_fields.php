<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('game_results', function (Blueprint $table) {
            $table->foreignId('game_id')->constrained()->cascadeOnDelete();
            $table->integer('home_score')->default(0);
            $table->integer('away_score')->default(0);
            $table->json('stats')->nullable();
            $table->unique('game_id');
        });
    }

    public function down(): void
    {
        Schema::table('game_results', function (Blueprint $table) {
            $table->dropUnique(['game_id']);
            $table->dropForeign(['game_id']);
            $table->dropColumn(['game_id', 'home_score', 'away_score', 'stats']);
        });
    }
};
