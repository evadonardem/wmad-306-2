<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Technology', 'slug' => 'technology'],
            ['name' => 'Academic', 'slug' => 'academic'],
            ['name' => 'Lifestyle', 'slug' => 'lifestyle'],
            ['name' => 'News', 'slug' => 'news'],
        ];

        foreach ($categories as $category) {
            // This line actually saves the data to the database
            Category::updateOrCreate(['slug' => $category['slug']], $category);
        }
    }
}