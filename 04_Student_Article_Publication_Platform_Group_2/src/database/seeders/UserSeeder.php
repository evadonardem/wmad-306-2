<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create an admin
        $admin = User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Admin User',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );
        $admin->assignRole('admin');

        // Create a writer
        $writer = User::firstOrCreate(
            ['email' => 'writer@example.com'],
            [
                'name' => 'John Writer',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );
        $writer->assignRole('writer');

        // Create a second writer
        $writer2 = User::firstOrCreate(
            ['email' => 'writer2@example.com'],
            [
                'name' => 'Jane Writer',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );
        $writer2->assignRole('writer');

        // Create an editor
        $editor = User::firstOrCreate(
            ['email' => 'editor@example.com'],
            [
                'name' => 'Emily Editor',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );
        $editor->assignRole('editor');

        // Create a student
        $student = User::firstOrCreate(
            ['email' => 'student@example.com'],
            [
                'name' => 'Sam Student',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );
        $student->assignRole('student');

        // Create a second student
        $student2 = User::firstOrCreate(
            ['email' => 'student2@example.com'],
            [
                'name' => 'Alex Student',
                'password' => Hash::make('password'),
                'email_verified_at' => now(),
            ]
        );
        $student2->assignRole('student');
    }
}
