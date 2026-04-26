<?php

namespace Database\Seeders;

use App\Models\ArticleStatus;
use Illuminate\Database\Seeder;

class ArticleStatusSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $statuses = [
            ['name' => 'draft', 'label' => 'Draft'],
            ['name' => 'submitted', 'label' => 'Submitted'],
            ['name' => 'needs_revision', 'label' => 'Needs Revision'],
            ['name' => 'published', 'label' => 'Published'],
            ['name' => 'commented', 'label' => 'Commented'],
        ];

        foreach ($statuses as $status) {
            ArticleStatus::firstOrCreate(['name' => $status['name']], $status);
        }
    }
}
