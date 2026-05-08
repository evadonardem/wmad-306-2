<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('teams', function (Blueprint $table) {
            $table->string('name')->nullable();
        });

        Schema::table('player_team', function (Blueprint $table) {
            $table->foreignId('player_id')->constrained()->cascadeOnDelete();
            $table->foreignId('team_id')->constrained()->cascadeOnDelete();
            $table->integer('jersey_number')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('player_team', function (Blueprint $table) {
            $table->dropForeign(['player_id']);
            $table->dropForeign(['team_id']);
            $table->dropColumn(['player_id', 'team_id', 'jersey_number']);
        });

        Schema::table('teams', function (Blueprint $table) {
            $table->dropColumn('name');
        });
    }
};
