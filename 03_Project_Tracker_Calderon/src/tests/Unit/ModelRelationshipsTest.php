<?php

namespace Tests\Unit;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;

class ModelRelationshipsTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_has_projects_and_project_has_tasks()
    {
        $user = User::factory()->create();
        Project::factory()->count(2)->create(['user_id' => $user->id]);

        $project = Project::factory()->create(['user_id' => $user->id]);
        Task::factory()->count(3)->create(['project_id' => $project->id]);

        $this->assertEquals(3, $user->projects()->count()); // 2 + 1
        $this->assertEquals(3, $project->tasks()->count());

        $this->assertInstanceOf(Project::class, $user->projects()->first());
        $this->assertInstanceOf(Task::class, $project->tasks()->first());
    }
}
