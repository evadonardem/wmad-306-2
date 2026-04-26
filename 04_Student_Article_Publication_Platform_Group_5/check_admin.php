<?php

require_once __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

$kernel->bootstrap();

try {
    echo "=== Checking Admin Setup ===\n\n";
    
    // Check if users exist
    $users = App\Models\User::all();
    echo "Total users: " . $users->count() . "\n";
    
    foreach ($users as $user) {
        echo "- {$user->name} ({$user->email})\n";
        $roles = $user->roles->pluck('name')->join(', ') ?: 'no roles';
        echo "  Roles: {$roles}\n";
    }
    
    echo "\n=== Creating Admin User if not exists ===\n";
    
    // Check if admin role exists
    $adminRole = Spatie\Permission\Models\Role::where('name', 'admin')->first();
    if (!$adminRole) {
        echo "Creating admin role...\n";
        $adminRole = Spatie\Permission\Models\Role::create(['name' => 'admin']);
    }
    
    // Create admin user
    $admin = App\Models\User::where('email', 'admin@example.com')->first();
    if (!$admin) {
        echo "Creating admin user...\n";
        $admin = App\Models\User::create([
            'name' => 'System Administrator',
            'email' => 'admin@example.com',
            'password' => bcrypt('admin123')
        ]);
    }
    
    // Assign admin role
    if (!$admin->hasRole('admin')) {
        echo "Assigning admin role...\n";
        $admin->assignRole('admin');
    }
    
    echo "\n=== Admin Setup Complete ===\n";
    echo "Email: admin@example.com\n";
    echo "Password: admin123\n";
    echo "URL: " . url('/admin/dashboard') . "\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}
