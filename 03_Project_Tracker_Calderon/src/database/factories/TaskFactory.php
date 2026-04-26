<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Task>
 */
class TaskFactory extends Factory
{
    /**
     * Define model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => $this->faker->sentence(1, true),
            'description' => $this->faker->paragraph(1, true),
            'priority' => $this->faker->randomElement(['less important', 'important', 'very important']),
            'status' => $this->faker->randomElement(['pending', 'on going', 'completed']),
        ];
    }
}
