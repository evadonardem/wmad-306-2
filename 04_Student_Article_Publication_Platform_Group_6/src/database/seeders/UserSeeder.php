<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $superAdmin = User::firstOrCreate(
            ['email' => 'superadmin@example.com'],
            ['name' => 'Superadmin Account', 'password' => Hash::make('password')]
        );
        $superAdmin->assignRole('superadmin');

        $writer = User::firstOrCreate(
            ['email' => 'writer@example.com'],
            ['name' => 'Writer Account', 'password' => Hash::make('password')]
        );
        $writer->assignRole('writer');

        $editor = User::firstOrCreate(
            ['email' => 'editor@example.com'],
            ['name' => 'Editor Account', 'password' => Hash::make('password')]
        );
        $editor->assignRole('editor');

        $student = User::firstOrCreate(
            ['email' => 'student@example.com'],
            ['name' => 'Student Account', 'password' => Hash::make('password')]
        );
        $student->assignRole('student');
    }
}
