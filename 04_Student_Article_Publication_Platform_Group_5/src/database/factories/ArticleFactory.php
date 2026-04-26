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

    public function definition(): array
    {
        return [
            'title' => $this->faker->sentence(6),
            'content' => $this->faker->paragraphs(5, true),
            'status_id' => ArticleStatus::inRandomOrder()->first()->id,
            'writer_id' => User::role('writer')->inRandomOrder()->first()->id,
            'editor_id' => $this->faker->optional(0.7)->randomElement(
                User::role('editor')->pluck('id')->toArray()
            ),
            'category_id' => Category::inRandomOrder()->first()->id,
        ];
    }

    public function draft(): static
    {
        return $this->state(fn (array $attributes) => [
            'status_id' => ArticleStatus::where('name', 'draft')->first()->id,
        ]);
    }

    public function submitted(): static
    {
        return $this->state(fn (array $attributes) => [
            'status_id' => ArticleStatus::where('name', 'submitted')->first()->id,
        ]);
    }

    public function needsRevision(): static
    {
        return $this->state(fn (array $attributes) => [
            'status_id' => ArticleStatus::where('name', 'needs_revision')->first()->id,
        ]);
    }

    public function published(): static
    {
        return $this->state(fn (array $attributes) => [
            'status_id' => ArticleStatus::where('name', 'published')->first()->id,
            'editor_id' => User::role('editor')->inRandomOrder()->first()->id,
        ]);
    }
}
