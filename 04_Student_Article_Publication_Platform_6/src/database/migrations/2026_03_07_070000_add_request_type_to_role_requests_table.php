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
        Schema::table('role_requests', function (Blueprint $table) {
            $table->enum('request_type', ['add', 'switch', 'step_down'])
                ->default('add')
                ->after('role_name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('role_requests', function (Blueprint $table) {
            $table->dropColumn('request_type');
        });
    }
};

