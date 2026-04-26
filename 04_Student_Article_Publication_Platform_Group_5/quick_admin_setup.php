<?php

// Quick Admin Setup Script
// Run: php quick_admin_setup.php

echo "Starting admin setup...\n";

// 1. Check if we're in Laravel directory
if (!file_exists('artisan')) {
    echo "Error: Please run this script from the Laravel project root directory.\n";
    exit(1);
}

// 2. Run migrations
echo "Running migrations...\n";
system('php artisan migrate --force');

// 3. Create admin role and user
echo "Creating admin role and user...\n";
system('php artisan db:seed --class=AdminSeeder');

// 4. Clear cache
echo "Clearing cache...\n";
system('php artisan cache:clear');
system('php artisan config:clear');
system('php artisan route:clear');

echo "\n=== Setup Complete ===\n";
echo "Admin Login:\n";
echo "Email: admin@example.com\n";
echo "Password: admin123\n";
echo "URL: http://your-app-url/admin/dashboard\n";
echo "\n⚠️  Remember to change the default password!\n";
