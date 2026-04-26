# Creating an Admin User

## Method 1: Using Database Seeder

Run this command in your project directory:
```bash
php artisan db:seed --class=AdminSeeder
```

## Method 2: Using Laravel Tinker

1. Open Tinker:
```bash
php artisan tinker
```

2. Run these commands:
```php
// Find your user
$user = App\Models\User::where('email', 'your-email@example.com')->first();

// Or create a new admin user
$user = App\Models\User::create([
    'name' => 'Admin User',
    'email' => 'admin@example.com',
    'password' => bcrypt('admin123')
]);

// Assign admin role
$user->assignRole('admin');

// Verify the role
$user->roles; // Should show admin role
```

## Method 3: Direct SQL

```sql
-- First, find the admin role ID
SELECT id FROM roles WHERE name = 'admin';

-- Then assign the role to your user (replace X with your user ID and Y with role ID)
INSERT INTO model_has_roles (role_id, model_type, model_id) 
VALUES (Y, 'App\Models\User', X);
```

## Access the Dashboard

After getting admin role, navigate to:
```
http://localhost:8000/admin/dashboard
```

Or if using a different port:
```
http://localhost:3000/admin/dashboard
```

## Default Admin Credentials (if using seeder)

- **Email**: admin@example.com
- **Password**: admin123

⚠️ **Important**: Change the default password in production!
