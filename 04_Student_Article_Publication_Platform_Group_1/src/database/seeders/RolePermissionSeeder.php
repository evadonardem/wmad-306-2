<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Define permissions for each role
        $permissions = [
            // Writer permissions
            'create articles',
            'edit own articles',
            'submit articles',
            'revise own articles',
            
            // Editor permissions
            'review submissions',
            'request revisions',
            'publish articles',
            'edit any article',
            
            // Student permissions
            'view published articles',
            'comment on articles',
        ];

        // Create permissions
        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles and assign permissions
        $writerRole = Role::firstOrCreate(['name' => 'writer']);
        $writerRole->givePermissionTo([
            'create articles',
            'edit own articles', 
            'submit articles',
            'revise own articles',
        ]);

        $editorRole = Role::firstOrCreate(['name' => 'editor']);
        $editorRole->givePermissionTo([
            'review submissions',
            'request revisions',
            'publish articles',
            'edit any article',
        ]);

        $studentRole = Role::firstOrCreate(['name' => 'student']);
        $studentRole->givePermissionTo([
            'view published articles',
            'comment on articles',
        ]);

        $this->command->info('Roles and permissions created successfully!');
    }
}
