<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create a Writer
        $writer = User::create([
            'name' => 'John Writer',
            'email' => 'writer@example.com',
            'password' => Hash::make('password'),
        ]);
        $writer->assignRole('Writer');

        // Create an Editor
        $editor = User::create([
            'name' => 'Jane Editor',
            'email' => 'editor@example.com',
            'password' => Hash::make('password'),
        ]);
        $editor->assignRole('Editor');
    }
}