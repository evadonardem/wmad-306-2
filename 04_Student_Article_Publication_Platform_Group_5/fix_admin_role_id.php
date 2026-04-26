<?php

echo "=== Fixing Admin Role ID to 1 ===\n\n";

// Check if we're in Laravel directory
if (!file_exists('artisan')) {
    echo "❌ Error: Please run this from Laravel project root\n";
    exit(1);
}

// Load Laravel
require_once __DIR__ . '/bootstrap/app.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    echo "Current roles in database:\n";
    $roles = \Spatie\Permission\Models\Role::orderBy('id')->get();
    
    foreach ($roles as $role) {
        echo "ID: {$role->id} - {$role->name}\n";
    }
    
    echo "\n=== Fixing Admin Role ID ===\n";
    
    // Check if admin role exists
    $adminRole = \Spatie\Permission\Models\Role::where('name', 'admin')->first();
    
    if (!$adminRole) {
        echo "❌ Admin role not found. Creating with ID 1...\n";
        
        // Reset auto-increment and create admin role with ID 1
        \Illuminate\Support\Facades\DB::statement('ALTER TABLE roles AUTO_INCREMENT = 1');
        
        $adminRole = \Spatie\Permission\Models\Role::create([
            'name' => 'admin',
            'guard_name' => 'web'
        ]);
        
        echo "✅ Admin role created with ID: {$adminRole->id}\n";
    } else {
        echo "Current admin role ID: {$adminRole->id}\n";
        
        if ($adminRole->id != 1) {
            echo "❌ Admin role is not ID 1. Fixing...\n";
            
            // Get all role assignments for admin role
            $adminAssignments = \Illuminate\Support\Facades\DB::table('model_has_roles')
                ->where('role_id', $adminRole->id)
                ->get();
            
            // Delete current admin role
            $adminRoleId = $adminRole->id;
            $adminRole->delete();
            
            // Reset auto-increment
            \Illuminate\Support\Facades\DB::statement('ALTER TABLE roles AUTO_INCREMENT = 1');
            
            // Create new admin role with ID 1
            $newAdminRole = \Spatie\Permission\Models\Role::create([
                'name' => 'admin',
                'guard_name' => 'web'
            ]);
            
            // Reassign all old admin role assignments to new admin role
            foreach ($adminAssignments as $assignment) {
                \Illuminate\Support\Facades\DB::table('model_has_roles')
                    ->where('id', $assignment->id)
                    ->update(['role_id' => $newAdminRole->id]);
            }
            
            echo "✅ Admin role recreated with ID: {$newAdminRole->id}\n";
            echo "✅ Role assignments updated\n";
        } else {
            echo "✅ Admin role already has ID 1\n";
        }
    }
    
    // Ensure admin user has admin role
    $adminUser = \App\Models\User::where('email', 'admin@example.com')->first();
    if ($adminUser && !$adminUser->hasRole('admin')) {
        echo "Assigning admin role to admin user...\n";
        $adminUser->assignRole('admin');
        echo "✅ Admin user now has admin role\n";
    }
    
    echo "\n=== Final Role List ===\n";
    $finalRoles = \Spatie\Permission\Models\Role::orderBy('id')->get();
    foreach ($finalRoles as $role) {
        echo "ID: {$role->id} - {$role->name}\n";
    }
    
    echo "\n=== Complete ===\n";
    echo "Admin role now has ID 1 (highest priority)\n";
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace: " . $e->getTraceAsString() . "\n";
}

echo "\n";
