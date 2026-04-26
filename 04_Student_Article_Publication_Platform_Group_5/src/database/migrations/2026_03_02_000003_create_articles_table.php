<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('content');
            $table->foreignId('status_id')->constrained('article_statuses');
            $table->foreignId('writer_id')->constrained('users');
            $table->foreignId('editor_id')->nullable()->constrained('users');
            $table->foreignId('category_id')->constrained('categories');
            $table->timestamps();
            $table->softDeletes();
            
            $table->index(['status_id', 'writer_id', 'editor_id', 'category_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
