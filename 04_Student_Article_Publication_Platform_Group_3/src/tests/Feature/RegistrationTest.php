<?php

use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Spatie\Permission\Models\Role;

test('user can register with role and is redirected to appropriate dashboard', function () {
    // Ensure roles exist
    Role::firstOrCreate(['name' => 'writer']);
    Role::firstOrCreate(['name' => 'editor']);
    Role::firstOrCreate(['name' => 'student']);

    // Test writer registration
    $response = $this->post('/register', [
        'name' => 'Test Writer',
        'email' => 'writer@test.com',
        'password' => 'password',
        'password_confirmation' => 'password',
        'role' => 'writer',
    ]);

    $response->assertRedirect('/dashboard');
    
    $user = User::where('email', 'writer@test.com')->first();
    expect($user)->not->toBeNull();
    expect($user->hasRole('writer'))->toBeTrue();
    expect($user->role)->toBe('writer');
});

test('user can register as editor', function () {
    // Ensure role exists
    Role::firstOrCreate(['name' => 'editor']);

    $response = $this->post('/register', [
        'name' => 'Test Editor',
        'email' => 'editor@test.com',
        'password' => 'password',
        'password_confirmation' => 'password',
        'role' => 'editor',
    ]);

    $response->assertRedirect('/dashboard');
    
    $user = User::where('email', 'editor@test.com')->first();
    expect($user)->not->toBeNull();
    expect($user->hasRole('editor'))->toBeTrue();
    expect($user->role)->toBe('editor');
});

test('user can register as student', function () {
    // Ensure role exists
    Role::firstOrCreate(['name' => 'student']);

    $response = $this->post('/register', [
        'name' => 'Test Student',
        'email' => 'student@test.com',
        'password' => 'password',
        'password_confirmation' => 'password',
        'role' => 'student',
    ]);

    $response->assertRedirect('/dashboard');
    
    $user = User::where('email', 'student@test.com')->first();
    expect($user)->not->toBeNull();
    expect($user->hasRole('student'))->toBeTrue();
    expect($user->role)->toBe('student');
});

test('registration fails with invalid role', function () {
    $response = $this->post('/register', [
        'name' => 'Test User',
        'email' => 'invalid@test.com',
        'password' => 'password',
        'password_confirmation' => 'password',
        'role' => 'invalid_role',
    ]);

    $response->assertSessionHasErrors('role');
});
