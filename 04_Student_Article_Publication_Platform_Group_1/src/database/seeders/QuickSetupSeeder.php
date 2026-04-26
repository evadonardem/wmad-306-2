<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class QuickSetupSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('Starting quick setup for roles and users...');

        // Create permissions
        $permissions = [
            'create articles',
            'edit own articles',
            'submit articles',
            'revise own articles',
            'review submissions',
            'request revisions',
            'publish articles',
            'edit any article',
            'view published articles',
            'comment on articles',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles
        $writerRole = Role::firstOrCreate(['name' => 'writer']);
        $editorRole = Role::firstOrCreate(['name' => 'editor']);
        $studentRole = Role::firstOrCreate(['name' => 'student']);

        // Assign permissions to roles
        $writerRole->givePermissionTo([
            'create articles',
            'edit own articles', 
            'submit articles',
            'revise own articles',
        ]);

        $editorRole->givePermissionTo([
            'review submissions',
            'request revisions',
            'publish articles',
            'edit any article',
        ]);

        $studentRole->givePermissionTo([
            'view published articles',
            'comment on articles',
        ]);

        // Create or update test users
        $users = [
            [
                'email' => 'writer@test.com',
                'name' => 'Test Writer',
                'role' => 'writer',
                'spatieRole' => 'writer'
            ],
            [
                'email' => 'editor@test.com',
                'name' => 'Test Editor',
                'role' => 'editor',
                'spatieRole' => 'editor'
            ],
            [
                'email' => 'student@test.com',
                'name' => 'Test Student',
                'role' => 'student',
                'spatieRole' => 'student'
            ],
            [
                'email' => 'admin@test.com',
                'name' => 'Test Admin',
                'role' => 'admin',
                'spatieRole' => ['writer', 'editor', 'student']
            ]
        ];

        foreach ($users as $userData) {
            $user = User::firstOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'password' => Hash::make('password'),
                    'role' => $userData['role'],
                ]
            );

            // Assign Spatie role(s)
            if (is_array($userData['spatieRole'])) {
                $user->assignRole($userData['spatieRole']);
            } else {
                $user->assignRole($userData['spatieRole']);
            }

            $this->command->info("Created/Updated user: {$userData['email']} with role: {$userData['role']}");
        }

        $this->command->info('');
        $this->command->info('=== QUICK SETUP COMPLETE ===');
        $this->command->info('Test accounts created:');
        $this->command->info('Writer: writer@test.com / password');
        $this->command->info('Editor: editor@test.com / password');
        $this->command->info('Student: student@test.com / password');
        $this->command->info('Admin: admin@test.com / password (has all roles)');
        $this->command->info('');
        $this->command->info('Run: php artisan db:seed --class=QuickSetupSeeder');
    }
}
