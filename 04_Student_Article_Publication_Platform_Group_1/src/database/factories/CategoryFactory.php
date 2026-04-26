<?php

namespace Database\Factories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Category>
 */
class CategoryFactory extends Factory
{
    protected $model = Category::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $categories = [
            'Technology',
            'Science',
            'Literature',
            'History',
            'Mathematics',
            'Arts',
            'Sports',
            'Politics',
            'Education',
            'Health',
        ];

        return [
            'name' => $this->faker->unique()->randomElement($categories),
        ];
    }
}
