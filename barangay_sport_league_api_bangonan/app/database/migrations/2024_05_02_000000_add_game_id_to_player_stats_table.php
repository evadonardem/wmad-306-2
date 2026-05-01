<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('player_stats', function (Blueprint $table) {
            $table->foreignId('game_id')->after('id')->nullable();
        });
        
        // Update existing records to set game_id from game_result relationship
        DB::statement('UPDATE player_stats ps 
                       INNER JOIN game_results gr ON ps.game_result_id = gr.id 
                       SET ps.game_id = gr.game_id');
        
        // Now add the foreign key constraint
        Schema::table('player_stats', function (Blueprint $table) {
            $table->foreignId('game_id')->change()->constrained()->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('player_stats', function (Blueprint $table) {
            $table->dropForeign(['game_id']);
            $table->dropColumn('game_id');
        });
    }
};
