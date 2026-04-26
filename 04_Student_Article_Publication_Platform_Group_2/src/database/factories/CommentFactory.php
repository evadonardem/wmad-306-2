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
            'article_id' => Article::inRandomOrder()->first()?->id ?? 1,
            'student_id' => User::role('student')->inRandomOrder()->first()?->id ?? 1,
            'content' => fake()->paragraph(2),
        ];
    }
}
