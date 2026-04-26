<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            'Web Development',
            'Mobile Development',
            'Data Science',
            'Machine Learning',
            'Artificial Intelligence',
            'Cloud Computing',
            'DevOps',
            'Cybersecurity',
            'Database Design',
            'User Experience',
            'Software Architecture',
            'Programming Languages',
            'Frontend Development',
            'Backend Development',
            'Testing & Quality Assurance',
            'Project Management',
            'Agile & Scrum',
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(['name' => $category]);
        }

        $this->command->info('Categories seeded successfully!');
        $this->command->info('Total categories: ' . count($categories));
    }
}
