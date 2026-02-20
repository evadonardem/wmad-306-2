<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TaskSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
   public function run()
{
    $projects = Project::all();

    foreach ($projects as $project) {
        Task::factory()->count(5)->create([
            'project_id' => $project->id
        ]);
    }
}
}
