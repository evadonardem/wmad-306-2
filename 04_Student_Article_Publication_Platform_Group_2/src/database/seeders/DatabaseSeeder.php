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
     *
     * Order matters to avoid FK errors:
     *  1. Roles & Permissions
     *  2. Article Statuses
     *  3. Categories
     *  4. Users (with roles)
     *  5. Sample articles, revisions, comments
     */
    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
            ArticleStatusSeeder::class,
            CategorySeeder::class,
            UserSeeder::class,
        ]);

        // Generate sample data
        $writer  = User::where('email', 'writer@example.com')->first();
        $editor  = User::where('email', 'editor@example.com')->first();
        $student = User::where('email', 'student@example.com')->first();

        // A few published articles with comments
        $publishedArticles = Article::factory()
            ->count(3)
            ->published()
            ->create(['writer_id' => $writer->id, 'editor_id' => $editor->id]);

        foreach ($publishedArticles as $article) {
            Comment::factory()->count(2)->create([
                'article_id' => $article->id,
                'student_id' => $student->id,
            ]);
        }

        // A draft article
        Article::factory()->draft()->create(['writer_id' => $writer->id]);

        // A submitted article with a revision
        $submittedArticle = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => \App\Models\ArticleStatus::where('name', 'submitted')->first()->id,
        ]);

        Revision::factory()->create([
            'article_id' => $submittedArticle->id,
            'editor_id'  => $editor->id,
        ]);
    }
}

