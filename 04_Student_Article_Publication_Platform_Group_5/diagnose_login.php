<?php

echo "=== Login Diagnosis ===\n\n";

// Check if we're in Laravel directory
if (!file_exists('artisan')) {
    echo "❌ Error: Please run this from Laravel project root\n";
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
    
    // 1. Check database connection
    try {
        \Illuminate\Support\Facades\DB::connection()->getPdo();
        echo "✅ Database connection working\n";
    } catch (Exception $e) {
        echo "❌ Database connection failed: " . $e->getMessage() . "\n";
        exit(1);
    }
    
    // 2. Check roles table
    $roles = \Illuminate\Support\Facades\DB::table('roles')->orderBy('id')->get();
    echo "\n📋 Roles in database:\n";
    foreach ($roles as $role) {
        echo "   ID: {$role->id} - {$role->name}\n";
    }
    
    // 3. Check users table
    $users = \App\Models\User::all();
    echo "\n👥 Users in database ({$users->count()} total):\n";
    foreach ($users as $user) {
        echo "   {$user->name} ({$user->email})\n";
    }
    
    // 4. Check admin user specifically
    $adminUser = \App\Models\User::where('email', 'admin@example.com')->first();
    if ($adminUser) {
        echo "\n✅ Admin user found: {$adminUser->name}\n";
        
        // Check if admin role exists
        $adminRole = \Spatie\Permission\Models\Role::where('name', 'admin')->first();
        if ($adminRole) {
            echo "✅ Admin role exists (ID: {$adminRole->id})\n";
            
            // Check if user has admin role
            if ($adminUser->hasRole('admin')) {
                echo "✅ User has admin role assigned\n";
            } else {
                echo "❌ User does NOT have admin role\n";
                echo "   Assigning admin role...\n";
                $adminUser->assignRole('admin');
                echo "✅ Admin role assigned\n";
            }
            
            // Test password
            if (\Illuminate\Support\Facades\Hash::check('admin123', $adminUser->password)) {
                echo "✅ Password 'admin123' is correct\n";
            } else {
                echo "❌ Password 'admin123' is INCORRECT\n";
                echo "   Resetting password...\n";
                $adminUser->password = bcrypt('admin123');
                $adminUser->save();
                echo "✅ Password reset to 'admin123'\n";
            }
        } else {
            echo "❌ Admin role NOT found\n";
        }
    } else {
        echo "\n❌ Admin user NOT found\n";
        echo "   Creating admin user...\n";
        
        // Create admin role first
        $adminRole = \Spatie\Permission\Models\Role::firstOrCreate(['name' => 'admin']);
        
        // Create admin user
        $adminUser = \App\Models\User::create([
            'name' => 'System Administrator',
            'email' => 'admin@example.com',
            'password' => bcrypt('admin123')
        ]);
        
        // Assign role
        $adminUser->assignRole('admin');
        
        echo "✅ Admin user created and role assigned\n";
    }
    
    // 5. Check model_has_roles table
    echo "\n🔗 Role assignments:\n";
    $assignments = \Illuminate\Support\Facades\DB::table('model_has_roles')
        ->join('users', 'model_has_roles.model_id', '=', 'users.id')
        ->join('roles', 'model_has_roles.role_id', '=', 'roles.id')
        ->select('users.name', 'users.email', 'roles.name as role_name', 'roles.id as role_id')
        ->get();
    
    foreach ($assignments as $assignment) {
        echo "   {$assignment->name} ({$assignment->email}) -> {$assignment->role_name} (ID: {$assignment->role_id})\n";
    }
    
    echo "\n=== Login Test Information ===\n";
    echo "🔗 Login URL: " . url('/login') . "\n";
    echo "🔗 Admin Dashboard: " . url('/admin/dashboard') . "\n";
    echo "👤 Email: admin@example.com\n";
    echo "🔑 Password: admin123\n";
    
    echo "\n=== Next Steps ===\n";
    echo "1. Clear your browser cookies/cache\n";
    echo "2. Go to: " . url('/login') . "\n";
    echo "3. Login with admin@example.com / admin123\n";
    echo "4. If successful, go to: " . url('/admin/dashboard') . "\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "\nCommon fixes:\n";
    echo "1. Run: composer require spatie/laravel-permission\n";
    echo "2. Run: php artisan migrate\n";
    echo "3. Run: php artisan db:seed --class=RoleSeeder\n";
    echo "4. Check .env file for database settings\n";
}

echo "\n";
