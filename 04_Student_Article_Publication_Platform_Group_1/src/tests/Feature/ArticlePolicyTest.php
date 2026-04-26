<?php

namespace Tests\Feature;

use App\Models\Article;
use App\Models\User;
use App\Models\ArticleStatus;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ArticlePolicyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    /**
     * Test writer can create articles.
     */
    public function test_writer_can_create_articles(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');

        $this->assertTrue($writer->can('create', Article::class));
    }

    /**
     * Test student cannot create articles.
     */
    public function test_student_cannot_create_articles(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');

        $this->assertFalse($student->can('create', Article::class));
    }

    /**
     * Test editor cannot create articles.
     */
    public function test_editor_cannot_create_articles(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');

        $this->assertFalse($editor->can('create', Article::class));
    }

    /**
     * Test writer can submit their own draft article.
     */
    public function test_writer_can_submit_own_draft_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);

        $this->assertTrue($writer->can('submit', $article));
    }

    /**
     * Test writer cannot submit other writer's article.
     */
    public function test_writer_cannot_submit_other_writer_article(): void
    {
        $writer1 = User::factory()->create();
        $writer1->assignRole('writer');
        $writer2 = User::factory()->create();
        $writer2->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer2->id,
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);

        $this->assertFalse($writer1->can('submit', $article));
    }

    /**
     * Test writer cannot submit submitted article.
     */
    public function test_writer_cannot_submit_submitted_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);

        $this->assertFalse($writer->can('submit', $article));
    }

    /**
     * Test editor can publish submitted article.
     */
    public function test_editor_can_publish_submitted_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);

        $this->assertTrue($editor->can('publish', $article));
    }

    /**
     * Test editor cannot publish draft article.
     */
    public function test_editor_cannot_publish_draft_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);

        $this->assertFalse($editor->can('publish', $article));
    }

    /**
     * Test editor can request revision for submitted article.
     */
    public function test_editor_can_request_revision_submitted_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);

        $this->assertTrue($editor->can('requestRevision', $article));
    }

    /**
     * Test editor cannot request revision for published article.
     */
    public function test_editor_cannot_request_revision_published_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);

        $this->assertFalse($editor->can('requestRevision', $article));
    }

    /**
     * Test student can view published article.
     */
    public function test_student_can_view_published_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);

        $this->assertTrue($student->can('view', $article));
    }

    /**
     * Test student cannot view draft article.
     */
    public function test_student_cannot_view_draft_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);

        $this->assertFalse($student->can('view', $article));
    }

    /**
     * Test writer can view their own article.
     */
    public function test_writer_can_view_own_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'category_id' => null,
        ]);

        $this->assertTrue($writer->can('view', $article));
    }

    /**
     * Test writer cannot view other writer's article.
     */
    public function test_writer_cannot_view_other_writer_article(): void
    {
        $writer1 = User::factory()->create();
        $writer1->assignRole('writer');
        $writer2 = User::factory()->create();
        $writer2->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer2->id,
            'category_id' => null,
        ]);

        $this->assertFalse($writer1->can('view', $article));
    }

    /**
     * Test editor can view any article.
     */
    public function test_editor_can_view_any_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create(['category_id' => null]);

        $this->assertTrue($editor->can('view', $article));
    }

    /**
     * Test writer can update their own article.
     */
    public function test_writer_can_update_own_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'category_id' => null,
        ]);

        $this->assertTrue($writer->can('update', $article));
    }

    /**
     * Test writer cannot update other writer's article.
     */
    public function test_writer_cannot_update_other_writer_article(): void
    {
        $writer1 = User::factory()->create();
        $writer1->assignRole('writer');
        $writer2 = User::factory()->create();
        $writer2->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer2->id,
            'category_id' => null,
        ]);

        $this->assertFalse($writer1->can('update', $article));
    }

    /**
     * Test writer can delete their own draft article.
     */
    public function test_writer_can_delete_own_draft_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);

        $this->assertTrue($writer->can('delete', $article));
    }

    /**
     * Test writer cannot delete published article.
     */
    public function test_writer_cannot_delete_published_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);

        $this->assertFalse($writer->can('delete', $article));
    }

    /**
     * Test editor can delete any article.
     */
    public function test_editor_can_delete_any_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create(['category_id' => null]);

        $this->assertTrue($editor->can('delete', $article));
    }
}
