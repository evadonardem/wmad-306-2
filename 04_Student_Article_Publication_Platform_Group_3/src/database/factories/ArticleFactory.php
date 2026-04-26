<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ArticleFactory extends Factory
{
    protected $model = Article::class;

    public function definition()
    {
        $title = $this->faker->sentence();
        return [
            'title' => $title,
            'slug' => \Illuminate\Support\Str::slug($title) . '-' . $this->faker->unique()->randomNumber(4),
            'content' => $this->faker->paragraphs(3, true),
            'status_id' => ArticleStatus::factory(),
            'writer_id' => User::factory(),
            'editor_id' => null,
            'category_id' => Category::factory(),
        ];
    }
}
