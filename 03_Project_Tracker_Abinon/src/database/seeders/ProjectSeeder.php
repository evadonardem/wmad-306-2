<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Project;

class ProjectSeeder extends Seeder
{
    public function run(): void
    {
        // Get all users
        $users = User::all();

        // For each user, create 5–10 projects
        foreach ($users as $user) {
            Project::factory()
                ->count(rand(5, 10))  // random between 5 and 10
                ->create([
                    'user_id' => $user->id,  // associate with this user
                ]);
        }
    }
}
