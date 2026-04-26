<?php

namespace Database\Seeders;

use App\Models\Article;
use App\Models\Comment;
use App\Models\Revision;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Seed roles & permissions
        $this->call(RoleSeeder::class);

        // 2. Seed article statuses
        $this->call(ArticleStatusSeeder::class);

        // 3. Seed categories
        $this->call(CategorySeeder::class);

        // 4. Seed users with roles
        $this->call(UserSeeder::class);

        // 5. Generate sample articles
        Article::factory()->count(3)->draft()->create();
        Article::factory()->count(3)->submitted()->create();
        Article::factory()->count(2)->needsRevision()->create();
        $publishedArticles = Article::factory()->count(5)->published()->create();

        // 6. Generate sample revisions for articles that need revision
        $needsRevisionArticles = Article::whereHas('status', fn ($q) => $q->where('name', 'needs_revision'))->get();
        foreach ($needsRevisionArticles as $article) {
            Revision::factory()->count(rand(1, 2))->create([
                'article_id' => $article->id,
            ]);
        }

        // 7. Generate sample comments on published articles
        foreach ($publishedArticles as $article) {
            Comment::factory()->count(rand(1, 4))->create([
                'article_id' => $article->id,
            ]);
        }
    }
}
