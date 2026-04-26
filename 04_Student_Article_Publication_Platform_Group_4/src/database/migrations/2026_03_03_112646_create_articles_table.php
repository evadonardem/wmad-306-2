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
            // Connects the article to the User (Writer)
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); 
            
            // Connects to your categories table
            $table->foreignId('category_id')->constrained()->onDelete('cascade'); 
            
            // RENAMED: This must be 'status_id' to match your Controller's Article::create()
            $table->foreignId('status_id')->constrained('article_statuses')->onDelete('cascade'); 
            
            $table->string('title');
            // Stores the Jodit Editor HTML content
            $table->text('content'); 
            $table->string('image')->nullable();
            $table->timestamps();
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