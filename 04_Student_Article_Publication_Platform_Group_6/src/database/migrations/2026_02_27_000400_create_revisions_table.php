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
        Schema::create('revisions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('article_id')->constrained('articles')->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreignId('editor_id')->constrained('users')->cascadeOnUpdate()->cascadeOnDelete();
            $table->text('comments');
            $table->timestamps();

            $table->index('article_id');
            $table->index('editor_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('revisions');
    }
};
