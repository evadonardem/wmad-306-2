<?php

namespace Tests\Feature;

use App\Models\Comment;
use App\Models\Article;
use App\Models\User;
use App\Models\ArticleStatus;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CommentPolicyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    /**
     * Test student can create comments.
     */
    public function test_student_can_create_comments(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');

        $this->assertTrue($student->can('create', Comment::class));
    }

    /**
     * Test writer cannot create comments.
     */
    public function test_writer_cannot_create_comments(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');

        $this->assertFalse($writer->can('create', Comment::class));
    }

    /**
     * Test editor cannot create comments.
     */
    public function test_editor_cannot_create_comments(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');

        $this->assertFalse($editor->can('create', Comment::class));
    }

    /**
     * Test student can comment on published article.
     */
    public function test_student_can_comment_on_published_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);

        $this->assertTrue($student->can('comment', $article));
    }

    /**
     * Test student cannot comment on draft article.
     */
    public function test_student_cannot_comment_on_draft_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);

        $this->assertFalse($student->can('comment', $article));
    }

    /**
     * Test student can view comment on published article.
     */
    public function test_student_can_view_comment_on_published_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        $comment = Comment::factory()->create(['article_id' => $article->id]);

        $this->assertTrue($student->can('view', $comment));
    }

    /**
     * Test student cannot view comment on draft article.
     */
    public function test_student_cannot_view_comment_on_draft_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);
        $comment = Comment::factory()->create(['article_id' => $article->id]);

        $this->assertFalse($student->can('view', $comment));
    }

    /**
     * Test writer can view comment on their own article.
     */
    public function test_writer_can_view_comment_on_own_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'category_id' => null,
        ]);
        $comment = Comment::factory()->create(['article_id' => $article->id]);

        $this->assertTrue($writer->can('view', $comment));
    }

    /**
     * Test writer cannot view comment on other writer's article.
     */
    public function test_writer_cannot_view_comment_on_other_writer_article(): void
    {
        $writer1 = User::factory()->create();
        $writer1->assignRole('writer');
        $writer2 = User::factory()->create();
        $writer2->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer2->id,
            'category_id' => null,
        ]);
        $comment = Comment::factory()->create(['article_id' => $article->id]);

        $this->assertFalse($writer1->can('view', $comment));
    }

    /**
     * Test editor can view any comment.
     */
    public function test_editor_can_view_any_comment(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $comment = Comment::factory()->create();

        $this->assertTrue($editor->can('view', $comment));
    }

    /**
     * Test student can update their own comment.
     */
    public function test_student_can_update_own_comment(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $comment = Comment::factory()->create(['student_id' => $student->id]);

        $this->assertTrue($student->can('update', $comment));
    }

    /**
     * Test student cannot update other student's comment.
     */
    public function test_student_cannot_update_other_student_comment(): void
    {
        $student1 = User::factory()->create();
        $student1->assignRole('student');
        $student2 = User::factory()->create();
        $student2->assignRole('student');
        $comment = Comment::factory()->create(['student_id' => $student2->id]);

        $this->assertFalse($student1->can('update', $comment));
    }

    /**
     * Test editor can update any comment.
     */
    public function test_editor_can_update_any_comment(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $comment = Comment::factory()->create();

        $this->assertTrue($editor->can('update', $comment));
    }

    /**
     * Test student can delete their own comment.
     */
    public function test_student_can_delete_own_comment(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $comment = Comment::factory()->create(['student_id' => $student->id]);

        $this->assertTrue($student->can('delete', $comment));
    }

    /**
     * Test student cannot delete other student's comment.
     */
    public function test_student_cannot_delete_other_student_comment(): void
    {
        $student1 = User::factory()->create();
        $student1->assignRole('student');
        $student2 = User::factory()->create();
        $student2->assignRole('student');
        $comment = Comment::factory()->create(['student_id' => $student2->id]);

        $this->assertFalse($student1->can('delete', $comment));
    }

    /**
     * Test writer can delete comment on their own article.
     */
    public function test_writer_can_delete_comment_on_own_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'category_id' => null,
        ]);
        $comment = Comment::factory()->create(['article_id' => $article->id]);

        $this->assertTrue($writer->can('delete', $comment));
    }

    /**
     * Test writer cannot delete comment on other writer's article.
     */
    public function test_writer_cannot_delete_comment_on_other_writer_article(): void
    {
        $writer1 = User::factory()->create();
        $writer1->assignRole('writer');
        $writer2 = User::factory()->create();
        $writer2->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer2->id,
            'category_id' => null,
        ]);
        $comment = Comment::factory()->create(['article_id' => $article->id]);

        $this->assertFalse($writer1->can('delete', $comment));
    }

    /**
     * Test editor can delete any comment.
     */
    public function test_editor_can_delete_any_comment(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $comment = Comment::factory()->create();

        $this->assertTrue($editor->can('delete', $comment));
    }

    /**
     * Test editor can restore any comment.
     */
    public function test_editor_can_restore_any_comment(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $comment = Comment::factory()->create();

        $this->assertTrue($editor->can('restore', $comment));
    }

    /**
     * Test student cannot restore comment.
     */
    public function test_student_cannot_restore_comment(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $comment = Comment::factory()->create(['student_id' => $student->id]);

        $this->assertFalse($student->can('restore', $comment));
    }

    /**
     * Test writer cannot restore comment.
     */
    public function test_writer_cannot_restore_comment(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $comment = Comment::factory()->create();

        $this->assertFalse($writer->can('restore', $comment));
    }

    /**
     * Test editor can force delete any comment.
     */
    public function test_editor_can_force_delete_any_comment(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $comment = Comment::factory()->create();

        $this->assertTrue($editor->can('forceDelete', $comment));
    }

    /**
     * Test student cannot force delete comment.
     */
    public function test_student_cannot_force_delete_comment(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $comment = Comment::factory()->create(['student_id' => $student->id]);

        $this->assertFalse($student->can('forceDelete', $comment));
    }
}
