<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Spatie\Permission\Models\Role;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin role if it doesn't exist
        $adminRole = Role::firstOrCreate(['name' => 'admin']);

        // Create or update admin user
        $admin = User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'name' => 'System Administrator',
                'password' => bcrypt('admin123'), // Change this in production!
            ]
        );

        // Assign admin role
        $admin->assignRole($adminRole);

        echo "Admin user created/updated successfully!\n";
        echo "Email: admin@example.com\n";
        echo "Password: admin123\n";
        echo "Please change the password in production!\n";
    }
}
