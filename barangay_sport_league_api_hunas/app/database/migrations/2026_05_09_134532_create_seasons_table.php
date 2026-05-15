<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations for the seasons table.
     */
    public function up(): void
    {
        Schema::create('seasons', function (Blueprint $table) {
            // Primary Key
            $table->bigIncrements('id');

            // Foreign Key Definition
            $table->unsignedBigInteger('league_id')->index();
            $table->foreign('league_id')
                  ->references('id')
                  ->on('leagues')
                  ->onDelete('cascade');

            // Details
            $table->string('name', 255);
            $table->dateTime('start_date');
            $table->dateTime('end_date');

            // State
            $table->string('status')->default('active')->comment('active or done');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('seasons');
    }
};