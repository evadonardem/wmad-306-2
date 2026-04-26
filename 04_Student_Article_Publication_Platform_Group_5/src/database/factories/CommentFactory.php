<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\Comment;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class CommentFactory extends Factory
{
    protected $model = Comment::class;

    public function definition(): array
    {
        return [
            'article_id' => Article::where('status_id', 4)->inRandomOrder()->first()->id, // Only published articles
            'student_id' => User::role('student')->inRandomOrder()->first()->id,
            'content' => $this->faker->sentences(3, true),
        ];
    }
}
