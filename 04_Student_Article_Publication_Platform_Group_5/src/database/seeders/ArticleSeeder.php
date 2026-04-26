<?php

namespace Database\Seeders;

use App\Models\Article;
use App\Models\User;
use App\Models\Category;
use App\Models\ArticleStatus;
use Illuminate\Database\Seeder;

class ArticleSeeder extends Seeder
{
    public function run(): void
    {
        // Get users with writer role
        $writers = User::whereHas('roles', function($query) {
            $query->where('name', 'writer');
        })->get();

        // Get users with editor role
        $editors = User::whereHas('roles', function($query) {
            $query->where('name', 'editor');
        })->get();

        // Get categories
        $categories = Category::all();

        // Get article statuses
        $submittedStatus = ArticleStatus::where('name', 'submitted')->first();
        $needsRevisionStatus = ArticleStatus::where('name', 'needs_revision')->first();
        $publishedStatus = ArticleStatus::where('name', 'published')->first();

        if ($writers->isEmpty() || $categories->isEmpty() || !$submittedStatus || !$needsRevisionStatus || !$publishedStatus) {
            $this->command->warn('Missing required data for ArticleSeeder. Please run other seeders first.');
            return;
        }

        // Create sample articles
        $articles = [
            [
                'title' => 'Understanding Modern Web Development',
                'content' => 'Web development has evolved significantly over the past decade. Modern frameworks like React, Vue, and Angular have transformed how we build user interfaces. This article explores the current landscape of web development and best practices for creating responsive, performant applications.',
                'status_id' => $submittedStatus->id,
                'writer_id' => $writers->random()->id,
                'category_id' => $categories->random()->id,
            ],
            [
                'title' => 'The Future of Artificial Intelligence',
                'content' => 'Artificial Intelligence is reshaping industries across the globe. From healthcare to finance, AI applications are becoming increasingly sophisticated. This comprehensive guide examines the current state of AI technology and its potential impact on society.',
                'status_id' => $needsRevisionStatus->id,
                'writer_id' => $writers->random()->id,
                'editor_id' => $editors->first()->id,
                'category_id' => $categories->random()->id,
            ],
            [
                'title' => 'Best Practices for Database Design',
                'content' => 'Effective database design is crucial for application performance and scalability. This article covers normalization, indexing strategies, and optimization techniques that every developer should know when working with relational databases.',
                'status_id' => $publishedStatus->id,
                'writer_id' => $writers->random()->id,
                'editor_id' => $editors->first()->id,
                'category_id' => $categories->random()->id,
            ],
            [
                'title' => 'Introduction to Cloud Computing',
                'content' => 'Cloud computing has revolutionized how businesses deploy and scale applications. This beginner-friendly guide explains the fundamentals of cloud services, deployment models, and major cloud providers like AWS, Azure, and Google Cloud.',
                'status_id' => $submittedStatus->id,
                'writer_id' => $writers->random()->id,
                'category_id' => $categories->random()->id,
            ],
            [
                'title' => 'Cybersecurity Essentials for Developers',
                'content' => 'Security should be a primary concern for every developer. This article covers common vulnerabilities, secure coding practices, and tools that help protect applications from cyber threats. Learn about OWASP top 10 and how to mitigate security risks.',
                'status_id' => $needsRevisionStatus->id,
                'writer_id' => $writers->random()->id,
                'editor_id' => $editors->first()->id,
                'category_id' => $categories->random()->id,
            ],
        ];

        foreach ($articles as $articleData) {
            Article::create($articleData);
        }

        $this->command->info('ArticleSeeder completed successfully!');
    }
}
