<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('teams', function (Blueprint $table) {
            $table->bigIncrements('id');

            // Linking to the season via explicit foreign key
            $table->unsignedBigInteger('season_id')->index();
            $table->foreign('season_id')
                  ->references('id')
                  ->on('seasons')
                  ->onDelete('cascade');

            // Organization data
            $table->string('name', 200);
            $table->string('coach', 150)->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('teams');
    }
};