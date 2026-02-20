<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Project>
 */
class ProjectFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
   public function definition()
{
    return [
        'name' => $this->faker->words(3, true),
        'description' => $this->faker->paragraph,
        'status' => $this->faker->randomElement([
            'pending',
            'in_progress',
            'completed',
            'on_hold'
        ]),
        'due_date' => $this->faker->dateTimeBetween('now', '+3 months'),
        'progress' => $this->faker->numberBetween(0, 100),
    ];
}

}
