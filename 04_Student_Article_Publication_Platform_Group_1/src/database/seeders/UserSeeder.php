<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create Writer users
        $writer1 = User::firstOrCreate(
            ['email' => 'writer@example.com'],
            [
                'name' => 'John Smith',
                'password' => Hash::make('password'),
            ]
        );
        $writer1->assignRole('writer');

        $writer2 = User::firstOrCreate(
            ['email' => 'jane.writer@example.com'],
            [
                'name' => 'Jane Johnson',
                'password' => Hash::make('password'),
            ]
        );
        $writer2->assignRole('writer');

        // Create Editor users
        $editor1 = User::firstOrCreate(
            ['email' => 'editor@example.com'],
            [
                'name' => 'Michael Davis',
                'password' => Hash::make('password'),
            ]
        );
        $editor1->assignRole('editor');

        $editor2 = User::firstOrCreate(
            ['email' => 'sarah.editor@example.com'],
            [
                'name' => 'Sarah Wilson',
                'password' => Hash::make('password'),
            ]
        );
        $editor2->assignRole('editor');

        // Create Student users
        $student1 = User::firstOrCreate(
            ['email' => 'student@example.com'],
            [
                'name' => 'Robert Brown',
                'password' => Hash::make('password'),
            ]
        );
        $student1->assignRole('student');

        $student2 = User::firstOrCreate(
            ['email' => 'emily.student@example.com'],
            [
                'name' => 'Emily Martinez',
                'password' => Hash::make('password'),
            ]
        );
        $student2->assignRole('student');

        $student3 = User::firstOrCreate(
            ['email' => 'david.student@example.com'],
            [
                'name' => 'David Lee',
                'password' => Hash::make('password'),
            ]
        );
        $student3->assignRole('student');

        // Create an admin user with all roles for testing
        $admin = User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'Admin User',
                'password' => Hash::make('password'),
            ]
        );
        $admin->assignRole(['writer', 'editor', 'student']);

        $this->command->info('Test users created successfully!');
        $this->command->info('');
        $this->command->info('=== WRITER ACCOUNTS ===');
        $this->command->info('Writer 1: writer@example.com / password');
        $this->command->info('Writer 2: jane.writer@example.com / password');
        $this->command->info('');
        $this->command->info('=== EDITOR ACCOUNTS ===');
        $this->command->info('Editor 1: editor@example.com / password');
        $this->command->info('Editor 2: sarah.editor@example.com / password');
        $this->command->info('');
        $this->command->info('=== STUDENT ACCOUNTS ===');
        $this->command->info('Student 1: student@example.com / password');
        $this->command->info('Student 2: emily.student@example.com / password');
        $this->command->info('Student 3: david.student@example.com / password');
        $this->command->info('');
        $this->command->info('=== ADMIN ACCOUNT ===');
        $this->command->info('Admin: admin@example.com / password (has all roles)');
    }
}
