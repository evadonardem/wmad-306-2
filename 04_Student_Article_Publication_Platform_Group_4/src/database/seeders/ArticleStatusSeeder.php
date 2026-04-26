<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ArticleStatus; // Important: This links to the model we just fixed

class ArticleStatusSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // We use updateOrCreate so it doesn't crash if you run it twice
        ArticleStatus::updateOrCreate(
            ['name' => 'Draft'], 
            ['label' => 'Draft']
        );

        ArticleStatus::updateOrCreate(
            ['name' => 'Submitted'], 
            ['label' => 'Submitted']
        );

        ArticleStatus::updateOrCreate(
            ['name' => 'Published'], 
            ['label' => 'Published']
        );

        ArticleStatus::updateOrCreate(
            ['name' => 'Needs Revision'], 
            ['label' => 'Needs Revision']
        );
    }
}