# Article Publication Platform - Setup Instructions

## Quick Setup

1. **Navigate to the project directory:**
   ```bash
   cd Group_5_Article/src
   ```

2. **Run the setup script:**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Start the development server:**
   ```bash
   php artisan serve
   ```

4. **Access the application:**
   Open your browser and go to `http://localhost:8000`

## Demo Accounts

After running the setup script, you can use these demo accounts:

- **Writer:** `writer@example.com` (password: `password`)
- **Editor:** `editor@example.com` (password: `password`)
- **Student:** `student@example.com` (password: `password`)
- **Admin:** `admin@example.com` (password: `password`)

## Manual Setup (if setup script doesn't work)

### Prerequisites
- PHP 8.2 or higher
- Composer
- SQLite extension for PHP

### Steps

1. **Install dependencies:**
   ```bash
   composer install
   ```

2. **Create database file:**
   ```bash
   touch database/database.sqlite
   ```

3. **Generate application key:**
   ```bash
   php artisan key:generate
   ```

4. **Run migrations:**
   ```bash
   php artisan migrate
   ```

5. **Seed the database:**
   ```bash
   php artisan db:seed
   ```

6. **Start the server:**
   ```bash
   php artisan serve
   ```

## Troubleshooting

### Login/Register Issues

If you're experiencing "check your credentials" errors:

1. **Ensure the database is set up:**
   - Make sure `database/database.sqlite` exists
   - Run `php artisan migrate` to create tables
   - Run `php artisan db:seed` to create demo users

2. **Clear caches:**
   ```bash
   php artisan config:clear
   php artisan route:clear
   php artisan cache:clear
   php artisan view:clear
   ```

3. **Check database connection:**
   - Verify the `.env` file has `DB_CONNECTION=sqlite`
   - Ensure the database file has proper permissions

4. **Verify users exist:**
   - Check that the seeder ran successfully
   - The demo users should be created in the database

### Common Issues

- **"CSRF token mismatch"**: The forms now handle CSRF tokens automatically
- **"Database not found"**: Make sure the SQLite database file exists
- **"Route not defined"**: Clear the route cache with `php artisan route:clear`

## Features

- **Role-based authentication** (Writer, Editor, Student, Admin)
- **Article creation and management**
- **Editorial workflow**
- **Comment system**
- **Modern React frontend with Material-UI**

## Development

The application uses:
- Laravel 11 (backend)
- React with Inertia.js (frontend)
- Material-UI (UI components)
- SQLite (database)
- Spatie Laravel Permission (role management)
