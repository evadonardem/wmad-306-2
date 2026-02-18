<?php

namespace Database\Seeders;

use App\Models\Project;
use App\Models\User;
use Illuminate\Database\Seeder;

class ProjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $users = User::all();

        foreach ($users as $user) {
            // Only seed projects for users who don't already have projects
            $existing = $user->projects()->count();
            if ($existing === 0) {
                $count = rand(5, 10);
                Project::factory()->count($count)->create([
                    'user_id' => $user->id,
                ]);
            }
        }
    }
}
