<?php

namespace Database\Seeders;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Comment;
use App\Models\Revision;
use App\Models\User;
use App\Models\Category;
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
        $this->call([
            RoleSeeder::class,
            CategorySeeder::class,
            ArticleStatusSeeder::class,
            UserSeeder::class,
        ]);

        $submittedStatusId = ArticleStatus::query()->where('name', 'submitted')->value('id');
        $publishedStatusId = ArticleStatus::query()->where('name', 'published')->value('id');
        $needsRevisionStatusId = ArticleStatus::query()->where('name', 'needs_revision')->value('id');

        Article::factory()->count(4)->create([
            'status_id' => $submittedStatusId,
        ]);
        Article::factory()->count(4)->create([
            'status_id' => $publishedStatusId,
        ]);
        Article::factory()->count(2)->create([
            'status_id' => $needsRevisionStatusId,
        ]);

        Revision::factory()->count(4)->create();
        Comment::factory()->count(8)->create();

        User::factory(2)->create()->each(function (User $user): void {
            $user->assignRole('student');
        });

        $writerId = User::role('writer')->value('id');
        $editorId = User::role('editor')->value('id');
        $categories = Category::query()->pluck('id', 'name');

        $fakePublications = [
            [
                'title' => 'Campus Innovation Lab Opens New AI Wing',
                'content' => "The campus innovation lab opened a new AI wing this semester, giving students access to collaborative workspaces, GPU-enabled research stations, and mentoring sessions.\n\nFaculty members said the expansion will support interdisciplinary projects in education technology, media analytics, and student-led prototyping.",
                'category' => 'Technology',
                'cover_image_url' => 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1400&q=80',
            ],
            [
                'title' => 'Student Journal Club Launches Weekly Review Forum',
                'content' => "A new weekly review forum now gives student writers direct feedback from peer editors and faculty reviewers.\n\nThe initiative is designed to improve article quality before submission and shorten revision cycles for the editorial board.",
                'category' => 'Education',
                'cover_image_url' => 'https://images.unsplash.com/photo-1456324504439-367cee3b3c32?auto=format&fit=crop&w=1400&q=80',
            ],
            [
                'title' => 'Community Service Stories Lead This Month\'s Features',
                'content' => "This month, the publication spotlighted student volunteer programs focused on food drives, literacy outreach, and local community mentoring.\n\nEditors noted that engagement increased significantly on stories highlighting service impact and student reflections.",
                'category' => 'Campus Life',
                'cover_image_url' => 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=1400&q=80',
            ],
            [
                'title' => 'Editorial Team Publishes New Writing Standards',
                'content' => "The editorial team released updated writing standards to improve clarity, citation quality, and consistency across all published pieces.\n\nWriters are encouraged to run a pre-submission checklist before moving drafts into the review queue.",
                'category' => 'Culture',
                'cover_image_url' => 'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?auto=format&fit=crop&w=1400&q=80',
            ],
            [
                'title' => 'Research Spotlight: Data Literacy in First-Year Courses',
                'content' => "A faculty-led study found that introducing data literacy projects in first-year courses improved critical reading outcomes and presentation confidence.\n\nStudent writers are now documenting department-specific examples for cross-campus collaboration.",
                'category' => 'Science',
                'cover_image_url' => 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?auto=format&fit=crop&w=1400&q=80',
            ],
            [
                'title' => 'Photo Essay Series Captures Campus at Night',
                'content' => "The latest visual essay series features nighttime campus life, highlighting student study spaces, performance rehearsals, and late-evening collaboration zones.\n\nThe series will run as a monthly publication block with contributions from student photographers.",
                'category' => 'Culture',
                'cover_image_url' => 'https://images.unsplash.com/photo-1493612276216-ee3925520721?auto=format&fit=crop&w=1400&q=80',
            ],
        ];

        foreach ($fakePublications as $publication) {
            Article::query()->create([
                'title' => $publication['title'],
                'content' => $publication['content'],
                'cover_image_url' => $publication['cover_image_url'],
                'status_id' => $publishedStatusId,
                'writer_id' => $writerId,
                'editor_id' => $editorId,
                'category_id' => $categories[$publication['category']] ?? $categories->first(),
            ]);
        }
    }
}
