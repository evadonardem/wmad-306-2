<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Writer
        $writer = User::factory()->create([
            'name'  => 'Writer User',
            'email' => 'writer@example.com',
        ]);
        $writer->assignRole('writer');

        // Editor
        $editor = User::factory()->create([
            'name'  => 'Editor User',
            'email' => 'editor@example.com',
        ]);
        $editor->assignRole('editor');

        // Student
        $student = User::factory()->create([
            'name'  => 'Student User',
            'email' => 'student@example.com',
        ]);
        $student->assignRole('student');
    }
}
