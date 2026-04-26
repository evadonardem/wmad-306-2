<?php

namespace Database\Factories;

use App\Models\Article;
use App\Models\Revision;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class RevisionFactory extends Factory
{
    protected $model = Revision::class;

    public function definition(): array
    {
        return [
            'article_id' => Article::inRandomOrder()->first()->id,
            'editor_id' => User::role('editor')->inRandomOrder()->first()->id,
            'comments' => $this->faker->paragraphs(3, true),
        ];
    }
}
