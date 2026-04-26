<?php

namespace Database\Seeders;

use App\Models\Project;
use App\Models\Task;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TaskSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $projects = Project::all();

        // if there are no projects, create a few for the first user
        if ($projects->isEmpty()) {
            $user = User::first() ?? User::factory()->create();
            $projects = Project::factory()->count(3)->create(['user_id' => $user->id]);
        }

        foreach ($projects as $project) {
            Task::factory()->count(rand(5, 10))->create([
                'project_id' => $project->id,
            ]);
        }
    }
}
