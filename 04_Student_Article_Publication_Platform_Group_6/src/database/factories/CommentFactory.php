<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\Comment;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Comment>
 */
class CommentFactory extends Factory
{
    protected $model = Comment::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'article_id' => Article::query()->inRandomOrder()->value('id') ?? Article::factory(),
            'student_id' => User::role('student')->inRandomOrder()->value('id') ?? User::factory(),
            'content' => fake()->sentence(16),
        ];
    }
}
