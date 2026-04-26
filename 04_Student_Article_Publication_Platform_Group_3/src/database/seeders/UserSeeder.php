<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // writers
        $writer = User::firstOrCreate([
            'email' => 'writer@example.com',
        ], [
            'name' => 'Writer User',
            'password' => bcrypt('password'),
        ]);
        $writer->assignRole('writer');

        // editors
        $editor = User::firstOrCreate([
            'email' => 'editor@example.com',
        ], [
            'name' => 'Editor User',
            'password' => bcrypt('password'),
        ]);
        $editor->assignRole('editor');

        // students
        $student = User::firstOrCreate([
            'email' => 'student@example.com',
        ], [
            'name' => 'Student User',
            'password' => bcrypt('password'),
        ]);
        $student->assignRole('student');
    }
}
