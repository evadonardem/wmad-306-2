<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Build the players table.
     */
    public function up(): void
    {
        Schema::create('players', function (Blueprint $table) {
            $table->bigIncrements('id');

            // Identity and demographics
            $table->string('name', 255)->index();
            $table->dateTime('birthdate');
            
            // Playing style
            $table->string('position', 100);

            $table->timestamps();
        });
    }

    /**
     * Rollback the players table.
     */
    public function down(): void
    {
        Schema::dropIfExists('players');
    }
};