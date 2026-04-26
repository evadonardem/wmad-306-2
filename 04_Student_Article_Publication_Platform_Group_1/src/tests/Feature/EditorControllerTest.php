<?php

namespace Tests\Feature;

use App\Models\Article;
use App\Models\User;
use App\Models\ArticleStatus;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use Illuminate\Support\Facades\Auth;

class EditorControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    /**
     * Test editor can view their dashboard.
     */
    public function test_editor_can_view_dashboard(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        
        Auth::login($editor);

        $response = $this->get('/editor/dashboard');

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page->component('Editor/Dashboard'));
    }

    /**
     * Test editor can review submitted article.
     */
    public function test_editor_can_review_submitted_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($editor);

        $response = $this->get("/editor/articles/{$article->id}/review");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Editor/Review')
            ->where('article.id', $article->id));
    }

    /**
     * Test editor can publish submitted article.
     */
    public function test_editor_can_publish_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($editor);

        $response = $this->post("/editor/articles/{$article->id}/publish");

        $response->assertRedirect('/editor/dashboard');
        $this->assertDatabaseHas('articles', [
            'id' => $article->id,
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'editor_id' => $editor->id,
        ]);
        $response->assertSessionHas('success', 'Article published successfully!');
    }

    /**
     * Test editor cannot publish non-submitted article.
     */
    public function test_editor_cannot_publish_non_submitted_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($editor);

        $response = $this->post("/editor/articles/{$article->id}/publish");

        $response->assertRedirect('/editor/dashboard');
        $response->assertSessionHas('error', 'This article cannot be published.');
    }

    /**
     * Test editor can request revision for submitted article.
     */
    public function test_editor_can_request_revision(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($editor);

        $response = $this->post("/editor/articles/{$article->id}/request-revision", [
            'comments' => 'Please add more details to the introduction.',
        ]);

        $response->assertRedirect('/editor/dashboard');
        $this->assertDatabaseHas('articles', [
            'id' => $article->id,
            'status_id' => ArticleStatus::where('name', 'Needs Revision')->first()->id,
            'editor_id' => $editor->id,
        ]);
        $this->assertDatabaseHas('revisions', [
            'article_id' => $article->id,
            'editor_id' => $editor->id,
            'comments' => 'Please add more details to the introduction.',
        ]);
        $response->assertSessionHas('success', 'Revision request sent to writer!');
    }

    /**
     * Test editor cannot request revision for non-submitted article.
     */
    public function test_editor_cannot_request_revision_for_non_submitted_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($editor);

        $response = $this->post("/editor/articles/{$article->id}/request-revision", [
            'comments' => 'Please add more details.',
        ]);

        $response->assertRedirect('/editor/dashboard');
        $response->assertSessionHas('error', 'This article cannot have revisions requested.');
    }

    /**
     * Test editor can edit any article.
     */
    public function test_editor_can_edit_any_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create(['category_id' => null]);
        
        Auth::login($editor);

        $response = $this->get("/editor/articles/{$article->id}/edit");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Editor/Edit')
            ->where('article.id', $article->id));
    }

    /**
     * Test editor can update article with revision tracking.
     */
    public function test_editor_can_update_article(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create(['category_id' => null]);
        
        Auth::login($editor);

        $response = $this->put("/editor/articles/{$article->id}/update", [
            'title' => 'Editor Updated Title',
            'content' => 'Editor updated content',
            'category_id' => null,
        ]);

        $response->assertRedirect('/editor/dashboard');
        $this->assertDatabaseHas('articles', [
            'title' => 'Editor Updated Title',
            'id' => $article->id,
        ]);
        $this->assertDatabaseHas('revisions', [
            'article_id' => $article->id,
            'editor_id' => $editor->id,
            'comments' => 'Article edited by editor',
        ]);
        $response->assertSessionHas('success', 'Article updated successfully!');
    }

    /**
     * Test editor can view article revisions.
     */
    public function test_editor_can_view_article_revisions(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create(['category_id' => null]);
        
        Auth::login($editor);

        $response = $this->get("/editor/articles/{$article->id}/revisions");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Editor/Revisions')
            ->where('article.id', $article->id));
    }

    /**
     * Test unauthenticated user cannot access editor routes.
     */
    public function test_unauthenticated_cannot_access_editor_routes(): void
    {
        $response = $this->get('/editor/dashboard');

        $response->assertRedirect('/login');
    }

    /**
     * Test non-editor cannot access editor routes.
     */
    public function test_non_editor_cannot_access_editor_routes(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        Auth::login($student);

        $response = $this->get('/editor/dashboard');

        $response->assertStatus(403);
    }

    /**
     * Test request revision validation.
     */
    public function test_request_revision_validation(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($editor);

        // Test missing comments
        $response = $this->post("/editor/articles/{$article->id}/request-revision", []);

        $response->assertSessionHasErrors('comments');
        
        // Test comments too long
        $response = $this->post("/editor/articles/{$article->id}/request-revision", [
            'comments' => str_repeat('a', 1001),
        ]);

        $response->assertSessionHasErrors('comments');
    }

    /**
     * Test update validation for article editing.
     */
    public function test_update_validation(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create(['category_id' => null]);
        
        Auth::login($editor);

        // Test missing title
        $response = $this->put("/editor/articles/{$article->id}/update", [
            'content' => 'Updated content',
        ]);

        $response->assertSessionHasErrors('title');
        
        // Test title too long
        $response = $this->put("/editor/articles/{$article->id}/update", [
            'title' => str_repeat('a', 256),
            'content' => 'Updated content',
        ]);

        $response->assertSessionHasErrors('title');
        
        // Test invalid category
        $response = $this->put("/editor/articles/{$article->id}/update", [
            'title' => 'Updated Title',
            'content' => 'Updated content',
            'category_id' => 999,
        ]);

        $response->assertSessionHasErrors('category_id');
    }

    /**
     * Test editor workflow complete cycle.
     */
    public function test_editor_workflow_complete_cycle(): void
    {
        $editor = User::factory()->create();
        $editor->assignRole('editor');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($editor);

        // Step 1: Request revision
        $response = $this->post("/editor/articles/{$article->id}/request-revision", [
            'comments' => 'Please improve the introduction.',
        ]);

        $response->assertRedirect('/editor/dashboard');
        $this->assertEquals(
            ArticleStatus::where('name', 'Needs Revision')->first()->id,
            $article->fresh()->status_id
        );

        // Step 2: Resubmit article (simulating writer action)
        $article->update(['status_id' => ArticleStatus::where('name', 'Submitted')->first()->id]);

        // Step 3: Publish article
        $response = $this->post("/editor/articles/{$article->id}/publish");

        $response->assertRedirect('/editor/dashboard');
        $this->assertEquals(
            ArticleStatus::where('name', 'Published')->first()->id,
            $article->fresh()->status_id
        );
        $this->assertEquals($editor->id, $article->fresh()->editor_id);
    }
}
