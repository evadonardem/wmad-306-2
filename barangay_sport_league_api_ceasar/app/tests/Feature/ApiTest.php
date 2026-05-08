<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;

class ApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_api_flow()
    {
        $user = User::factory()->create();
        $token = $user->createToken('api-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
             ->postJson('/api/leagues', [
                 'name' => 'PBA 2026',
                 'sport' => 'Basketball',
                 'description' => 'Philippine Basketball Association'
             ]);
        
        $response->assertStatus(201);
        echo "\n[1] LEAGUE CREATED SUCCESSFULLY:\n";
        echo json_encode($response->json(), JSON_PRETTY_PRINT);

        $leagueId = $response->json('id');

        $response2 = $this->withHeader('Authorization', 'Bearer ' . $token)
             ->postJson("/api/leagues/{$leagueId}/seasons", [
                 'name' => 'Governor\'s Cup',
                 'start_date' => '2026-06-01',
                 'end_date' => '2026-12-01',
                 'status' => 'active'
             ]);
             
        $response2->assertStatus(201);
        $seasonId = $response2->json('id');
        echo "\n\n[2] SEASON CREATED SUCCESSFULLY:\n";
        echo json_encode($response2->json(), JSON_PRETTY_PRINT);

        $response3 = $this->withHeader('Authorization', 'Bearer ' . $token)
             ->getJson("/api/seasons/{$seasonId}/summary");
             
        $response3->assertStatus(404);
        echo "\n\n[3] EXERCISE 1 (SUMMARY ENDPOINT CHECK):\n";
        echo json_encode($response3->json(), JSON_PRETTY_PRINT) . "\n\n";
    }
}
