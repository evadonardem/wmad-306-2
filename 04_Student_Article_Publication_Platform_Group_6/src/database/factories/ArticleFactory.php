<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Article>
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
        return [
            'title' => fake()->sentence(6),
            'content' => collect(fake()->paragraphs(4))->implode("\n\n"),
            'cover_image_url' => fake()->optional(0.75)->imageUrl(1280, 720, 'education', true),
            'status_id' => ArticleStatus::query()->inRandomOrder()->value('id') ?? ArticleStatus::query()->first()?->id,
            'writer_id' => User::role('writer')->inRandomOrder()->value('id') ?? User::factory(),
            'editor_id' => User::role('editor')->inRandomOrder()->value('id'),
            'category_id' => Category::query()->inRandomOrder()->value('id') ?? Category::query()->first()?->id,
        ];
    }
}
