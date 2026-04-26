<?php

namespace Database\Seeders;

use App\Models\ArticleStatus;
use Illuminate\Database\Seeder;

class ArticleStatusSeeder extends Seeder
{
    public function run(): void
    {
        $statuses = [
            ['name' => 'Draft', 'label' => 'Draft'],
            ['name' => 'Submitted', 'label' => 'Submitted for Review'],
            ['name' => 'Needs Revision', 'label' => 'Needs Revision'],
            ['name' => 'Published', 'label' => 'Published'],
            ['name' => 'Commented', 'label' => 'Commented'],
        ];

        foreach ($statuses as $status) {
            ArticleStatus::firstOrCreate(
                ['name' => $status['name']],
                ['label' => $status['label']]
            );
        }

        $this->command->info('Article statuses seeded successfully!');
    }
}
