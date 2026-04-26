<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProjectApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_project_crud_endpoints()
    {
        // prepare user
        $user = User::factory()->create();

        // create
        $response = $this->actingAs($user)->postJson('/projects', [
            'title' => 'Test Project',
            'description' => 'Desc',
        ]);

        $response->assertStatus(201)->assertJsonStructure(['id','user_id','title','description']);
        $projectId = $response->json('id');

        // show
        $this->actingAs($user)->getJson("/projects/{$projectId}")
            ->assertStatus(200)
            ->assertJsonFragment(['title' => 'Test Project']);

        // update
        $this->actingAs($user)->putJson("/projects/{$projectId}", [
            'title' => 'Updated',
            'description' => 'Updated desc',
        ])->assertStatus(200)->assertJsonFragment(['title' => 'Updated']);

        // delete
        $this->actingAs($user)->deleteJson("/projects/{$projectId}")
            ->assertStatus(200)->assertJson(['message' => 'Project deleted']);
    }
}
