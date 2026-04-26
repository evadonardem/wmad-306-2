<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('article_id')->constrained()->onDelete('cascade');
            $table->foreignId('student_id')->constrained('users');
            $table->text('content');
            $table->timestamps();
            
            $table->index(['article_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('comments');
    }
};
