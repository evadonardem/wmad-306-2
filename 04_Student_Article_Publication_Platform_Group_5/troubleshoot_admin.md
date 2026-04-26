# Admin Login Troubleshooting Guide

## Quick Fix Steps:

### 1. Run the Setup Script
```bash
php quick_admin_setup.php
```

### 2. If that doesn't work, try manual setup:

#### A. Run Migrations
```bash
php artisan migrate:fresh --seed
```

#### B. Create Admin User in Tinker
```bash
php artisan tinker
```

Then run:
```php
// Create admin role
$role = Spatie\Permission\Models\Role::firstOrCreate(['name' => 'admin']);

// Create admin user
$user = App\Models\User::firstOrCreate([
    'email' => 'admin@example.com'
], [
    'name' => 'Admin User',
    'password' => bcrypt('admin123')
]);

// Assign role
$user->assignRole($adminRole);

// Check if it worked
$user->hasRole('admin'); // Should return true
```

#### C. Check Routes
```bash
php artisan route:list | grep admin
```

You should see:
- GET|HEAD /admin/dashboard ....
- GET|HEAD /admin/users ....
- etc.

#### D. Test Login
1. Go to: `http://your-app-url/login`
2. Login with:
   - Email: `admin@example.com`
   - Password: `admin123`
3. Then go to: `http://your-app-url/admin/dashboard`

## Common Error Messages:

### "403 Forbidden"
- User doesn't have admin role
- Run the tinker commands above

### "404 Not Found"
- Routes not cached properly
- Run: `php artisan route:clear`

### "Role not found"
- Permission package not installed
- Run: `composer require spatie/laravel-permission`

### "Database connection failed"
- Check your .env file
- Make sure database is configured

## Still Having Issues?

Check these files:
1. `config/permission.php` - Permission config
2. `database/migrations/` - Role migrations
3. `app/Http/Kernel.php` - Middleware registered

## Debug Mode:
Add this to your .env file:
```env
APP_DEBUG=true
LOG_CHANNEL=daily
```

Then check `storage/logs/laravel.log` for errors.
