<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;

class TaskPersistenceTest extends TestCase
{
    use RefreshDatabase;

    public function test_status_and_priority_persist_after_update()
    {
        $user = User::factory()->create();
        $project = Project::factory()->create(['user_id' => $user->id]);
        $task = Task::factory()->create([
            'project_id' => $project->id,
            'status' => 'todo',
            'priority' => 1,
        ]);

        $task->status = 'in_progress';
        $task->priority = 3;
        $task->save();

        $fresh = Task::find($task->id);
        $this->assertEquals('in_progress', $fresh->status);
        $this->assertEquals(3, $fresh->priority);
    }
}
