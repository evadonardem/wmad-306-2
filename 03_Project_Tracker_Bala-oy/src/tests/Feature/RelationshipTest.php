<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;

class RelationshipTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_project_task_relationship_and_task_persistence()
    {
        // create a user, project, and task via factories
        $user = User::factory()->create();
        $project = Project::factory()->for($user)->create();
        $task = Task::factory()->for($project)->create([
            'priority' => 'low',
            'status' => 0,
        ]);

        // relationships
        $this->assertTrue($user->projects->contains($project));
        $this->assertTrue($project->tasks->contains($task));

        // update task status & priority and persist
        $task->status = 1;
        $task->priority = 'high';
        $task->save();

        // database has updated values
        $this->assertDatabaseHas('tasks', [
            'id' => $task->id,
            'status' => 1,
            'priority' => 'high',
        ]);

        // reload and verify
        $reloaded = Task::find($task->id);
        $this->assertEquals(1, $reloaded->status);
        $this->assertEquals('high', $reloaded->priority);
    }
}
