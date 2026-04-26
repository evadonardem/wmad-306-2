<?php

require_once __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\ArticleStatus;
use App\Models\Category;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

echo "Checking and creating demo data...\n";

// Ensure article statuses exist
$statuses = [
    ['name' => 'draft', 'label' => 'Draft'],
    ['name' => 'submitted', 'label' => 'Submitted'],
    ['name' => 'needs_revision', 'label' => 'Needs Revision'],
    ['name' => 'published', 'label' => 'Published']
];

foreach ($statuses as $status) {
    ArticleStatus::firstOrCreate($status);
    echo "Article status '{$status['name']}' ensured.\n";
}

// Ensure categories exist
$categories = [
    ['name' => 'Technology'],
    ['name' => 'Science'],
    ['name' => 'Literature'],
    ['name' => 'Business']
];

foreach ($categories as $category) {
    Category::firstOrCreate($category);
    echo "Category '{$category['name']}' ensured.\n";
}

// Ensure roles exist
$roles = ['writer', 'editor', 'student', 'admin'];
foreach ($roles as $roleName) {
    Role::firstOrCreate(['name' => $roleName]);
    echo "Role '{$roleName}' ensured.\n";
}

// Create users
$users = [
    [
        'name' => 'Writer User',
        'email' => 'writer@example.com',
        'password' => Hash::make('password'),
        'role' => 'writer'
    ],
    [
        'name' => 'Editor User',
        'email' => 'editor@example.com',
        'password' => Hash::make('password'),
        'role' => 'editor'
    ],
    [
        'name' => 'Student User',
        'email' => 'student@example.com',
        'password' => Hash::make('password'),
        'role' => 'student'
    ],
    [
        'name' => 'Admin User',
        'email' => 'admin@example.com',
        'password' => Hash::make('password'),
        'role' => 'admin'
    ]
];

foreach ($users as $userData) {
    $user = User::firstOrCreate([
        'email' => $userData['email']
    ], [
        'name' => $userData['name'],
        'password' => $userData['password']
    ]);

    $user->assignRole($userData['role']);
    echo "User '{$userData['email']}' created/updated with role '{$userData['role']}'.\n";
}

echo "\nDemo data created successfully!\n";
echo "Email: student@example.com, Password: password\n";
echo "Email: writer@example.com, Password: password\n";
echo "Email: editor@example.com, Password: password\n";
echo "Email: admin@example.com, Password: password\n";
