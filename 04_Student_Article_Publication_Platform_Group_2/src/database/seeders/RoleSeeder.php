<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        // Create permissions
        $permissions = [
            'create articles',
            'edit articles',
            'submit articles',
            'revise articles',
            'review articles',
            'request revision',
            'publish articles',
            'view articles',
            'comment articles',
            'manage users',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles and assign permissions
        $admin = Role::firstOrCreate(['name' => 'admin']);
        $admin->syncPermissions([
            'manage users',
            'create articles',
            'edit articles',
            'submit articles',
            'revise articles',
            'review articles',
            'request revision',
            'publish articles',
            'view articles',
            'comment articles',
        ]);

        $writer = Role::firstOrCreate(['name' => 'writer']);
        $writer->syncPermissions([
            'create articles',
            'edit articles',
            'submit articles',
            'revise articles',
        ]);

        $editor = Role::firstOrCreate(['name' => 'editor']);
        $editor->syncPermissions([
            'review articles',
            'request revision',
            'publish articles',
        ]);

        $student = Role::firstOrCreate(['name' => 'student']);
        $student->syncPermissions([
            'view articles',
            'comment articles',
        ]);
    }
}
