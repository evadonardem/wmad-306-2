<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;
use Illuminate\Foundation\Testing\RefreshDatabase;

class RelationshipTest extends TestCase
{
    use RefreshDatabase;
    public function test_user_project_task_relationships_and_task_persistence()
    {
        // Create test data in the refreshed database
        $user = User::create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        $this->assertNotNull($user, 'Failed to create test user');

        $project = Project::create([
            'user_id' => $user->id,
            'title' => 'Test Project',
            'description' => 'Project for relationship test',
        ]);

        $this->assertNotNull($project, 'Failed to create test project');

        $projects = $user->projects;
        $this->assertInstanceOf(\Illuminate\Database\Eloquent\Collection::class, $projects);

        $tasks = $project->tasks;
        $this->assertInstanceOf(\Illuminate\Database\Eloquent\Collection::class, $tasks);

        // Create a temporary task and assert priority/status persist
        $task = Task::create([
            'project_id' => $project->id,
            'title' => 'relationship-test',
            'description' => 'temporary feature test task',
            'priority' => 3,
            'status' => 'todo',
        ]);

        $this->assertNotNull($task->id);

        $reloaded = Task::find($task->id);
        $this->assertEquals(3, $reloaded->priority);
        $this->assertEquals('todo', $reloaded->status);

        $reloaded->priority = 1;
        $reloaded->status = 'done';
        $reloaded->save();

        $updated = Task::find($task->id);
        $this->assertEquals(1, $updated->priority);
        $this->assertEquals('done', $updated->status);

        // Clean up
        $updated->delete();
        $this->assertNull(Task::find($task->id));
    }
}
