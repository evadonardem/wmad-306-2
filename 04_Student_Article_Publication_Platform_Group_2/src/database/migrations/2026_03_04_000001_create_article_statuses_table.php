<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('article_statuses', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();   // e.g. draft, submitted, revision, published
            $table->string('label');             // e.g. Draft, Submitted, Needs Revision, Published
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('article_statuses');
    }
};
