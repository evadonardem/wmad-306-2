<?php

namespace Database\Seeders;

use App\Models\ArticleStatus;
use Illuminate\Database\Seeder;

class ArticleStatusSeeder extends Seeder
{
    public function run(): void
    {
        $statuses = [
            ['name' => 'draft',     'label' => 'Draft'],
            ['name' => 'submitted', 'label' => 'Submitted'],
            ['name' => 'revision',  'label' => 'Needs Revision'],
            ['name' => 'published', 'label' => 'Published'],
        ];

        foreach ($statuses as $s) {
            ArticleStatus::firstOrCreate(['name' => $s['name']], $s);
        }
    }
}
