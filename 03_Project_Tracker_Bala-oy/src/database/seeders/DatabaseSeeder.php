<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;

class DatabaseSeeder extends Seeder {
    public function run(): void {
        $u = User::factory()->create(['email'=>'test@example.com']);
        $ps = Project::factory(rand(5,10))->create(['user_id'=>$u->id]);
        foreach($ps as $p){ Task::factory(rand(5,10))->create(['project_id'=>$p->id]); }
    }
}