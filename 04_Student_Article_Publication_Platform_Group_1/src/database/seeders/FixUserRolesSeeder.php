<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class FixUserRolesSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('Fixing user roles for existing users...');

        // Get all users without roles
        $users = User::all();

        foreach ($users as $user) {
            $role = 'student'; // Default role
            
            // Determine role based on email or name
            if (str_contains($user->email, 'writer') || str_contains($user->name, 'writer')) {
                $role = 'writer';
            } elseif (str_contains($user->email, 'editor') || str_contains($user->name, 'editor')) {
                $role = 'editor';
            } elseif (str_contains($user->email, 'admin') || str_contains($user->name, 'admin')) {
                $role = 'admin';
            }

            // Update the role column
            $user->role = $role;
            $user->save();

            // Assign Spatie role if method exists
            if (method_exists($user, 'assignRole')) {
                $user->syncRoles([$role]);
            }

            $this->command->info("Updated user {$user->email} with role: {$role}");
        }

        $this->command->info('User roles fixed successfully!');
    }
}
