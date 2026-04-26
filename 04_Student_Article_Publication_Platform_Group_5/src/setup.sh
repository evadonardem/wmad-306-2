#!/bin/bash

echo "Setting up Article Publication Platform..."

# Create the database file
touch database/database.sqlite
echo "Database file created."

# Install dependencies
composer install
echo "Dependencies installed."

# Generate application key
php artisan key:generate
echo "Application key generated."

# Run migrations
php artisan migrate --force
echo "Database migrations completed."

# Seed the database with demo users and roles
php artisan db:seed --force
echo "Database seeded with demo data."

# Additional user seeding to ensure demo accounts exist
php seed-users.php
echo "Demo users verified/created."

# Clear caches
php artisan config:clear
php artisan route:clear
php artisan cache:clear
php artisan view:clear
echo "Caches cleared."

# Optimize for production
php artisan config:cache
php artisan route:cache
echo "Configuration optimized."

echo "Setup complete! You can now run 'php artisan serve' to start the application."
echo ""
echo "Demo Accounts (ALL PASSWORD: password):"
echo "- Student: student@example.com"
echo "- Writer: writer@example.com"
echo "- Editor: editor@example.com"
echo "- Admin: admin@example.com"
echo ""
echo "Debug URLs (when logged in):"
echo "- Debug roles: http://localhost:8000/debug-roles"
echo "- Test writer dashboard: http://localhost:8000/writer-dashboard-test"
