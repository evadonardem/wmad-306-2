<?php

namespace Database\Seeders;

use App\Models\Task;
use App\Models\Project;
use Illuminate\Database\Seeder;

class TaskSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $projects = Project::all();

        foreach ($projects as $project) {
            // Only seed tasks for projects that don't already have tasks
            $existing = $project->tasks()->count();
            if ($existing === 0) {
                $count = rand(5, 10);
                Task::factory()->count($count)->create([
                    'project_id' => $project->id,
                ]);
            }
        }
    }
}
