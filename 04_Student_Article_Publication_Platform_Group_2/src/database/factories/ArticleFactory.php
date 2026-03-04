<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class ArticleFactory extends Factory
{
    protected $model = Article::class;

    public function definition(): array
    {
        $title = fake()->sentence(6);

        return [
            'title'       => $title,
            'slug'        => Str::slug($title) . '-' . Str::random(6),
            'content'     => '<p>' . fake()->paragraphs(3, true) . '</p>',
            'status_id'   => ArticleStatus::inRandomOrder()->first()?->id ?? 1,
            'writer_id'   => User::role('writer')->inRandomOrder()->first()?->id ?? User::factory(),
            'editor_id'   => null,
            'category_id' => Category::inRandomOrder()->first()?->id,
        ];
    }

    public function published(): static
    {
        return $this->state(fn () => [
            'status_id'    => ArticleStatus::where('name', 'published')->first()?->id,
            'published_at' => fake()->dateTimeBetween('-1 month', 'now'),
        ]);
    }

    public function draft(): static
    {
        return $this->state(fn () => [
            'status_id' => ArticleStatus::where('name', 'draft')->first()?->id,
        ]);
    }
}
