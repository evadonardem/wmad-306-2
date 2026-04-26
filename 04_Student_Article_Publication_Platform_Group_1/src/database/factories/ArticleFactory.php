<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\User;
use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Article>
 */
class ArticleFactory extends Factory
{
    protected $model = Article::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $titles = [
            'Understanding Modern Web Development',
            'The Future of Artificial Intelligence',
            'Best Practices for Clean Code',
            'Introduction to Machine Learning',
            'Building Scalable Applications',
            'The Art of User Experience Design',
            'Security in Modern Applications',
            'Performance Optimization Techniques',
            'Cloud Computing Fundamentals',
            'Mobile Development Trends',
            'Data Science for Beginners',
            'DevOps Culture and Practices',
            'Microservices Architecture',
            'Blockchain Technology Explained',
            'Responsive Design Principles',
            'API Development Best Practices',
            'Database Design Patterns',
            'Testing Strategies for Developers',
            'Agile Methodology in Practice',
            'Cybersecurity Essentials',
        ];

        $contents = [
            'In today\'s rapidly evolving technological landscape, understanding the fundamentals of modern web development has become increasingly important. This comprehensive guide explores the essential concepts, tools, and practices that every developer should master to build robust and maintainable applications. We\'ll dive deep into frameworks, libraries, and best practices that define modern web development.',
            
            'Artificial Intelligence is transforming industries across the globe, from healthcare to finance, education to entertainment. This article explores the current state of AI technology, its practical applications, and what the future might hold. We\'ll examine machine learning algorithms, neural networks, and the ethical considerations that come with these powerful technologies.',
            
            'Writing clean, maintainable code is an art that separates good developers from great ones. This comprehensive guide covers the principles of clean code, including naming conventions, function design, error handling, and documentation. Learn how to write code that not only works but is also readable, testable, and easy to maintain.',
            
            'Machine Learning is no longer just a buzzword—it\'s a fundamental technology that\'s reshaping how we solve complex problems. This introduction covers the basic concepts, algorithms, and practical applications of ML. Whether you\'re a beginner or looking to expand your skills, this article provides a solid foundation in machine learning.',
            
            'Building applications that can handle growth and scale is crucial in today\'s digital world. This article explores the principles of scalable architecture, including load balancing, caching strategies, database optimization, and microservices. Learn how to design systems that can grow with your user base without compromising performance.',
        ];

        return [
            'title' => $this->faker->randomElement($titles),
            'content' => $this->faker->randomElement($contents),
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'writer_id' => User::factory(),
            'editor_id' => null,
            'category_id' => null,
        ];
    }

    /**
     * Create a submitted article
     */
    public function submitted(): static
    {
        return $this->state(fn (array $attributes) => [
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
        ]);
    }

    /**
     * Create a published article
     */
    public function published(): static
    {
        return $this->state(fn (array $attributes) => [
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'editor_id' => User::factory(),
        ]);
    }

    /**
     * Create an article needing revision
     */
    public function needsRevision(): static
    {
        return $this->state(fn (array $attributes) => [
            'status_id' => ArticleStatus::where('name', 'Needs Revision')->first()->id,
            'editor_id' => User::factory(),
        ]);
    }
}
