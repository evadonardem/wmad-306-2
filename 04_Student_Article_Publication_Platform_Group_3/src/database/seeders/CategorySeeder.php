<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            'News', 'Feature', 'Editorial', 'Opinion', 'Informative', 'Persuasive', 
            'Argumentative', 'Analytical', 'Research', 'Review', 
            'Narrative', 'Descriptive', 'Compare and Contrast', 'Cause and Effect', 
            'Problem and Solution', 'Expository', 'Investigative', 'Profile', 'Human Interest', 
            'Case Study', 'Technical', 'Scientific', 'Business', 'Technology', 'Education', 
            'Health', 'Lifestyle', 'Entertainment', 'Sports', 'Travel', 'Politics', 
            'Environment', 'Culture', 'Finance', 'Personal Development', 'History', 'Law', 
            'Fashion', 'Food'
        ];

        foreach ($categories as $index => $name) {
            Category::create([
                'name' => $name,
                'slug' => Str::slug($name)
            ]);
        }
    }
}
