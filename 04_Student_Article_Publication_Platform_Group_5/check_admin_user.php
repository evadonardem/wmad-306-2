<?php

echo "=== Checking Admin User Setup ===\n\n";

// Check if we're in Laravel directory
if (!file_exists('artisan')) {
    echo "❌ Error: Please run this from Laravel project root (where artisan file is)\n";
    echo "Current directory: " . getcwd() . "\n";
    exit(1);
}

// Load Laravel
require_once __DIR__ . '/bootstrap/app.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    echo "✅ Laravel loaded successfully\n\n";
    
    // Check if roles exist
    $roles = \Spatie\Permission\Models\Role::all();
    echo "Available roles:\n";
    foreach ($roles as $role) {
        echo "- {$role->name}\n";
    }
    
    // Check if admin role exists
    $adminRole = \Spatie\Permission\Models\Role::where('name', 'admin')->first();
    if (!$adminRole) {
        echo "\n❌ Admin role not found. Creating...\n";
        $adminRole = \Spatie\Permission\Models\Role::create(['name' => 'admin']);
        echo "✅ Admin role created\n";
    } else {
        echo "\n✅ Admin role exists\n";
    }
    
    // Check if admin user exists
    $adminUser = \App\Models\User::where('email', 'admin@example.com')->first();
    if (!$adminUser) {
        echo "\n❌ Admin user not found. Creating...\n";
        $adminUser = \App\Models\User::create([
            'name' => 'System Administrator',
            'email' => 'admin@example.com',
            'password' => bcrypt('admin123')
        ]);
        echo "✅ Admin user created\n";
    } else {
        echo "\n✅ Admin user exists: {$adminUser->name}\n";
    }
    
    // Check if user has admin role
    if ($adminUser->hasRole('admin')) {
        echo "✅ User has admin role\n";
    } else {
        echo "❌ User doesn't have admin role. Assigning...\n";
        $adminUser->assignRole('admin');
        echo "✅ Admin role assigned\n";
    }
    
    // Test login credentials
    echo "\n=== Login Credentials ===\n";
    echo "Email: admin@example.com\n";
    echo "Password: admin123\n";
    
    // Test if password is correct
    if (\Illuminate\Support\Facades\Hash::check('admin123', $adminUser->password)) {
        echo "✅ Password verification successful\n";
    } else {
        echo "❌ Password verification failed\n";
    }
    
    echo "\n=== Next Steps ===\n";
    echo "1. Go to your login page\n";
    echo "2. Login with: admin@example.com / admin123\n";
    echo "3. Then go to: " . url('/admin/dashboard') . "\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nTroubleshooting:\n";
    echo "1. Make sure spatie/laravel-permission is installed\n";
    echo "2. Run: composer require spatie/laravel-permission\n";
    echo "3. Run: php artisan migrate\n";
    echo "4. Run: php artisan db:seed --class=AdminSeeder\n";
}

echo "\n";
