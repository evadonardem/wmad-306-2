<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Permissions
        $permissions = [
            'article.create',
            'article.edit',
            'article.submit',
            'article.revise',
            'article.review',
            'article.requestRevision',
            'article.publish',
            'comment.create',
            'comment.moderate',
        ];

        foreach ($permissions as $p) {
            Permission::firstOrCreate(['name' => $p]);
        }

        // Roles
        $writer = Role::firstOrCreate(['name' => 'writer']);
        $editor = Role::firstOrCreate(['name' => 'editor']);
        $student = Role::firstOrCreate(['name' => 'student']);

        $writer->syncPermissions([
            'article.create', 'article.edit', 'article.submit', 'article.revise',
        ]);

        $editor->syncPermissions([
            'article.review', 'article.requestRevision', 'article.publish', 'comment.moderate',
        ]);

        $student->syncPermissions([
            'comment.create',
        ]);
    }
}
