<?php

use App\Models\User;
use App\Models\League;
use App\Models\Season;
use Illuminate\Support\Facades\Http;

echo "\n--- CREATING ADMIN USER & GETTING TOKEN ---\n";
$user = User::firstOrCreate(
    ['email' => 'admin@test.com'],
    ['name' => 'Test Admin', 'password' => bcrypt('password')]
);
$token = $user->createToken('api-token')->plainTextToken;
echo "Token generated: Bearer {$token}\n\n";

echo "--- TESTING /api/leagues ENDPOINT ---\n";
$response = Http::withToken($token)->withHeaders(['Accept' => 'application/json'])
    ->post('http://nginx/api/leagues', [
        'name' => 'PBA 2026',
        'sport' => 'Basketball',
        'description' => 'Philippine Basketball Association'
    ]);
echo "POST /api/leagues -> " . $response->status() . "\n";
echo $response->body() . "\n\n";

$leagueId = $response->json('id');

echo "--- TESTING /api/leagues/{league}/seasons ENDPOINT ---\n";
$response = Http::withToken($token)->withHeaders(['Accept' => 'application/json'])
    ->post("http://nginx/api/leagues/{$leagueId}/seasons", [
        'name' => 'Governor\'s Cup',
        'start_date' => '2026-06-01',
        'end_date' => '2026-12-01',
        'status' => 'active'
    ]);
echo "POST /api/leagues/{$leagueId}/seasons -> " . $response->status() . "\n";
echo $response->body() . "\n\n";

$seasonId = $response->json('id');

echo "--- TESTING GET /api/leagues ENDPOINT ---\n";
$response = Http::withToken($token)->withHeaders(['Accept' => 'application/json'])
    ->get('http://nginx/api/leagues');
echo "GET /api/leagues -> " . $response->status() . "\n";
echo json_encode($response->json(), JSON_PRETTY_PRINT) . "\n\n";

echo "--- TESTING GET /api/seasons/{season}/summary ENDPOINT (EXERCISE 1) ---\n";
$response = Http::withToken($token)->withHeaders(['Accept' => 'application/json'])
    ->get("http://localhost/api/seasons/{$seasonId}/summary");
echo "GET /api/seasons/{$seasonId}/summary -> " . $response->status() . "\n";
echo json_encode($response->json(), JSON_PRETTY_PRINT) . "\n\n";

