<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Article;
use App\Models\Comment;
use App\Models\Revision;
use App\Models\Category;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database with proper orchestration.
     */
    public function run(): void
    {
        $this->command->info('🌱 Starting DatabaseSeeder Orchestration...');
        $this->command->info('=====================================');
        
        // Track execution time
        $startTime = microtime(true);
        
        try {
            // Phase 1: Core Infrastructure (no dependencies)
            $this->seedCoreInfrastructure();
            
            // Phase 2: User Management (depends on roles)
            $this->seedUserManagement();
            
            // Phase 3: Content Management (depends on users, categories, statuses)
            $this->seedContentManagement();
            
            // Phase 4: Sample Data Generation
            $this->generateSampleData();
            
            // Phase 5: Summary and Documentation
            $this->displaySeedingSummary();
            
        } catch (\Exception $e) {
            $this->command->error('❌ Seeding failed: ' . $e->getMessage());
            $this->command->error('Stack trace: ' . $e->getTraceAsString());
            throw $e;
        }
        
        $executionTime = round((microtime(true) - $startTime), 2);
        $this->command->info('✅ DatabaseSeeder completed in ' . $executionTime . ' seconds');
        $this->command->info('=====================================');
    }

    /**
     * Phase 1: Seed core infrastructure (roles, statuses, categories)
     */
    private function seedCoreInfrastructure(): void
    {
        $this->command->info('📋 Phase 1: Seeding Core Infrastructure...');
        
        $this->call([
            RolePermissionSeeder::class,        // 1. Roles and permissions (no dependencies)
            ArticleStatusSeeder::class,        // 2. Article statuses (no dependencies)
            CategorySeeder::class,             // 3. Categories (no dependencies)
        ]);
        
        $this->command->info('✅ Core infrastructure seeded');
    }

    /**
     * Phase 2: Seed user management
     */
    private function seedUserManagement(): void
    {
        $this->command->info('👥 Phase 2: Seeding User Management...');
        
        $this->call([
            UserSeeder::class,                // 4. Users (depends on roles)
        ]);
        
        $this->command->info('✅ User management seeded');
    }

    /**
     * Phase 3: Seed content management
     */
    private function seedContentManagement(): void
    {
        $this->command->info('📚 Phase 3: Seeding Content Management...');
        
        // Content management is handled by sample data generation
        $this->command->info('✅ Content management ready');
    }

    /**
     * Phase 4: Generate comprehensive sample data
     */
    private function generateSampleData(): void
    {
        $this->command->info('🎯 Phase 4: Generating Sample Data...');
        
        // Verify required users exist
        $users = $this->validateRequiredUsers();
        if (!$users) {
            return;
        }

        // Create sample articles with different statuses
        $this->createSampleArticlesForWriter($users['writer']);
        
        // Create revisions and comments
        $this->createRelatedContent($users);
        
        $this->command->info('✅ Sample data generated');
    }

    /**
     * Validate that required users exist for sample data generation
     */
    private function validateRequiredUsers(): ?array
    {
        $writer = User::where('email', 'writer@example.com')->first();
        $editor = User::where('email', 'editor@example.com')->first();
        $student = User::where('email', 'student@example.com')->first();

        if (!$writer || !$editor || !$student) {
            $this->command->error('❌ Required users not found. Please run UserSeeder first.');
            $this->command->error('Missing users:');
            if (!$writer) $this->command->error('  - writer@example.com');
            if (!$editor) $this->command->error('  - editor@example.com');
            if (!$student) $this->command->error('  - student@example.com');
            return null;
        }

        return compact('writer', 'editor', 'student');
    }

    /**
     * Create sample articles for the writer user
     */
    private function createSampleArticlesForWriter($writer): void
    {
        $this->command->info('📝 Creating sample articles for writer...');
        
        // Get a random category for articles
        $category = Category::inRandomOrder()->first();
        
        // Create articles in different states to demonstrate the workflow
        $articles = [
            'draft' => Article::factory()->count(3)->create([
                'writer_id' => $writer->id,
                'category_id' => $category->id,
            ]),
            'submitted' => Article::factory()->count(2)->submitted()->create([
                'writer_id' => $writer->id,
                'category_id' => $category->id,
            ]),
            'needs_revision' => Article::factory()->count(2)->needsRevision()->create([
                'writer_id' => $writer->id,
                'category_id' => $category->id,
            ]),
            'published' => Article::factory()->count(4)->published()->create([
                'writer_id' => $writer->id,
                'category_id' => $category->id,
            ]),
        ];

        // Store articles for later use
        $this->sampleArticles = $articles;
        
        $this->command->info('✅ Sample articles created');
    }

    /**
     * Create revisions and comments for articles
     */
    private function createRelatedContent(array $users): void
    {
        $this->command->info('💬 Creating related content (revisions, comments)...');
        
        $editor = $users['editor'];
        $student = $users['student'];

        // Create revisions for articles that need revision
        if (isset($this->sampleArticles['needs_revision'])) {
            foreach ($this->sampleArticles['needs_revision'] as $article) {
                Revision::factory()->create([
                    'article_id' => $article->id,
                    'editor_id' => $editor->id,
                ]);
            }
        }

        // Create comments for published articles
        if (isset($this->sampleArticles['published'])) {
            foreach ($this->sampleArticles['published'] as $article) {
                Comment::factory()
                    ->count(rand(1, 5))
                    ->create([
                        'article_id' => $article->id,
                        'student_id' => $student->id,
                    ]);
            }
        }

        $this->command->info('✅ Related content created');
    }

    /**
     * Display comprehensive seeding summary
     */
    private function displaySeedingSummary(): void
    {
        $this->command->info('📊 Phase 5: Generating Seeding Summary...');
        $this->command->info('=====================================');
        
        // Database statistics
        $stats = [
            'Users' => User::count(),
            'Articles' => Article::count(),
            'Draft Articles' => Article::whereHas('status', fn($q) => $q->where('name', 'Draft'))->count(),
            'Submitted Articles' => Article::whereHas('status', fn($q) => $q->where('name', 'Submitted'))->count(),
            'Articles Needing Revision' => Article::whereHas('status', fn($q) => $q->where('name', 'Needs Revision'))->count(),
            'Published Articles' => Article::whereHas('status', fn($q) => $q->where('name', 'Published'))->count(),
            'Revisions' => Revision::count(),
            'Comments' => Comment::count(),
            'Categories' => Category::count(),
        ];

        $this->command->info('📈 DATABASE STATISTICS:');
        foreach ($stats as $key => $value) {
            $this->command->info("  {$key}: {$value}");
        }

        $this->command->info('');
        $this->command->info('🔑 TEST ACCOUNTS:');
        $this->command->info('=====================================');
        $this->command->info('');
        $this->command->info('👨‍💼 WRITER ACCOUNTS:');
        $this->command->info('  Email: writer@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: John Smith');
        $this->command->info('');
        $this->command->info('  Email: jane.writer@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: Jane Johnson');
        $this->command->info('');
        
        $this->command->info('👨‍⚖️  EDITOR ACCOUNTS:');
        $this->command->info('  Email: editor@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: Michael Davis');
        $this->command->info('');
        $this->command->info('  Email: sarah.editor@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: Sarah Wilson');
        $this->command->info('');
        
        $this->command->info('🎓 STUDENT ACCOUNTS:');
        $this->command->info('  Email: student@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: Robert Brown');
        $this->command->info('');
        $this->command->info('  Email: emily.student@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: Emily Martinez');
        $this->command->info('');
        $this->command->info('  Email: david.student@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: David Lee');
        $this->command->info('');
        
        $this->command->info('👑 ADMIN ACCOUNT:');
        $this->command->info('  Email: admin@example.com');
        $this->command->info('  Password: password');
        $this->command->info('  Name: Admin User');
        $this->command->info('  Roles: writer, editor, student');
        $this->command->info('');
        
        $this->command->info('🚀 QUICK START COMMANDS:');
        $this->command->info('=====================================');
        $this->command->info('Reset and seed everything:');
        $this->command->info('  php artisan migrate:fresh --seed');
        $this->command->info('');
        $this->command->info('Run seeders only:');
        $this->command->info('  php artisan db:seed');
        $this->command->info('');
        $this->command->info('Test with factories:');
        $this->command->info('  php artisan tinker');
        $this->command->info('  >>> Article::factory()->count(10)->create()');
        $this->command->info('=====================================');
    }
}
