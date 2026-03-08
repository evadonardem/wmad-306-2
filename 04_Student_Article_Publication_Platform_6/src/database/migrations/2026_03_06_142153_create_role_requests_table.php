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
        Schema::create('role_requests', function (Blueprint $table) {
            $table->id();
            
            // The user applying for the role
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            
            // The role they are requesting (e.g., 'writer' or 'editor')
            $table->string('role_name');
            
            // The user's pitch/portfolio link/reasoning
            $table->text('justification')->nullable();
            
            // Track the progress of the application
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            
            // The Super Admin who made the final decision
            $table->foreignId('actioned_by')->nullable()->constrained('users')->nullOnDelete();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('role_requests');
    }
};