<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\Task;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TaskApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_task_crud_endpoints()
    {
        $user = User::factory()->create();
        $project = Project::factory()->create(['user_id' => $user->id]);

        // create
        $resp = $this->actingAs($user)->postJson('/tasks', [
            'project_id' => $project->id,
            'title' => 'Task 1',
            'description' => 'T1',
            'priority' => 'medium',
            'status' => false,
        ]);

        $resp->assertStatus(201)->assertJsonStructure(['id','project_id','title','priority','status']);
        $taskId = $resp->json('id');

        // show
        $this->actingAs($user)->getJson("/tasks/{$taskId}")
            ->assertStatus(200)->assertJsonFragment(['title'=>'Task 1']);

        // update
        $this->actingAs($user)->putJson("/tasks/{$taskId}", [
            'title' => 'Task 1 updated',
            'description' => 'T1u',
            'priority' => 'high',
            'status' => true,
        ])->assertStatus(200)->assertJsonFragment(['title'=>'Task 1 updated','priority'=>'high']);

        // delete
        $this->actingAs($user)->deleteJson("/tasks/{$taskId}")
            ->assertStatus(200)->assertJson(['message' => 'Task deleted']);
    }
}
