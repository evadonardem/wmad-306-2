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
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->longText('content');
            $table->foreignId('status_id')->constrained('article_statuses')->cascadeOnUpdate()->restrictOnDelete();
            $table->foreignId('writer_id')->constrained('users')->cascadeOnUpdate()->cascadeOnDelete();
            $table->foreignId('editor_id')->nullable()->constrained('users')->cascadeOnUpdate()->nullOnDelete();
            $table->foreignId('category_id')->constrained('categories')->cascadeOnUpdate()->restrictOnDelete();
            $table->softDeletes();
            $table->timestamps();

            $table->index('status_id');
            $table->index('writer_id');
            $table->index('editor_id');
            $table->index('category_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
