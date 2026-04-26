<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Project;
use App\Models\User;

class ProjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $users = User::all();

        // ensure at least one user exists
        if ($users->isEmpty()) {
            $users = User::factory()->count(10)->create();
        }

        foreach ($users as $user) {
            Project::factory()->count(rand(5, 10))->create([
                'user_id' => $user->id,
            ]);
        }
    }
}
