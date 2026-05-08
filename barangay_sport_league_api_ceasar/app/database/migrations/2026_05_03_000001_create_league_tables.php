<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('leagues', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->string('sport');
            $table->text('description')->nullable();
            $table->timestamps();
        });

        Schema::create('seasons', function (Blueprint $table) {
            $table->id();
            $table->foreignId('league_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->date('start_date');
            $table->date('end_date');
            $table->string('status')->default('active'); // active | done
            $table->timestamps();
        });

        Schema::create('teams', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->string('coach')->nullable();
            $table->timestamps();
        });

        Schema::create('players', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->date('birthdate')->nullable();
            $table->string('position')->nullable();
            $table->timestamps();
        });

        Schema::create('player_team', function (Blueprint $table) {
            $table->foreignId('team_id')->constrained()->onDelete('cascade');
            $table->foreignId('player_id')->constrained()->onDelete('cascade');
            $table->string('jersey_number')->nullable();
            $table->primary(['team_id', 'player_id']);
        });

        Schema::create('games', function (Blueprint $table) {
            $table->id();
            $table->foreignId('season_id')->constrained()->onDelete('cascade');
            $table->foreignId('home_team_id')->constrained('teams')->onDelete('cascade');
            $table->foreignId('away_team_id')->constrained('teams')->onDelete('cascade');
            $table->dateTime('scheduled_at');
            $table->string('venue')->nullable();
            $table->string('status')->default('scheduled'); // scheduled | done
            $table->timestamps();
        });

        Schema::create('game_results', function (Blueprint $table) {
            $table->id();
            $table->foreignId('game_id')->unique()->constrained()->onDelete('cascade');
            $table->integer('home_score')->default(0);
            $table->integer('away_score')->default(0);
            $table->timestamps();
        });

        Schema::create('player_stats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('game_result_id')->constrained('game_results')->onDelete('cascade');
            $table->foreignId('player_id')->constrained()->onDelete('cascade');
            $table->integer('points')->default(0);
            $table->integer('assists')->default(0);
            $table->integer('rebounds')->default(0);
            $table->integer('fouls')->default(0);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('player_stats');
        Schema::dropIfExists('game_results');
        Schema::dropIfExists('games');
        Schema::dropIfExists('player_team');
        Schema::dropIfExists('players');
        Schema::dropIfExists('teams');
        Schema::dropIfExists('seasons');
        Schema::dropIfExists('leagues');
    }
};
