<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\Revision;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Revision>
 */
class RevisionFactory extends Factory
{
    protected $model = Revision::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'article_id' => Article::query()->inRandomOrder()->value('id') ?? Article::factory(),
            'editor_id' => User::role('editor')->inRandomOrder()->value('id') ?? User::factory(),
            'comments' => fake()->sentence(14),
        ];
    }
}
