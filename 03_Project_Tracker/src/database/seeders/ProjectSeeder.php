<?php

namespace Database\Seeders;
use App\Models\User;
use App\Models\Project;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class ProjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
  
public function run()
{
    $users = User::all();

    foreach ($users as $user) {
        Project::factory()->count(5)->create([
            'user_id' => $user->id
        ]);
    }
}
}
