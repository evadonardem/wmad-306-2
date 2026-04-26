<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // We call these in a specific order to avoid Foreign Key errors
        $this->call([
            RoleSeeder::class,           // 1. Roles must exist first
            ArticleStatusSeeder::class,  // 2. Statuses (Draft, etc.) must exist
            CategorySeeder::class,       // 3. Categories for the dropdown
            UserSeeder::class,           // 4. Users (who need Roles) created last
        ]);
    }
}