<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;
use App\Policies\ProjectPolicy;
use App\Policies\TaskPolicy;
use Illuminate\Foundation\Testing\RefreshDatabase;

class PolicyTest extends TestCase
{
    use RefreshDatabase;

    public function test_policies_enforce_ownership()
    {
        // create two users
        $owner = User::factory()->create();
        $other = User::factory()->create();

        // create a project for owner
        $project = Project::factory()->create(['user_id' => $owner->id]);

        // create a task for that project
        $task = Task::factory()->create(['project_id' => $project->id]);

        $projectPolicy = new ProjectPolicy();
        $taskPolicy = new TaskPolicy();

        // owner can update/delete
        $this->assertTrue($projectPolicy->update($owner, $project));
        $this->assertTrue($projectPolicy->delete($owner, $project));

        $this->assertTrue($taskPolicy->update($owner, $task));
        $this->assertTrue($taskPolicy->delete($owner, $task));

        // other user cannot
        $this->assertFalse($projectPolicy->update($other, $project));
        $this->assertFalse($projectPolicy->delete($other, $project));

        $this->assertFalse($taskPolicy->update($other, $task));
        $this->assertFalse($taskPolicy->delete($other, $task));
    }
}
