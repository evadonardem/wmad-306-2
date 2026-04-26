<?php

namespace Tests\Feature;

use App\Models\Article;
use App\Models\User;
use App\Models\ArticleStatus;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use Illuminate\Support\Facades\Auth;

class WriterControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    /**
     * Test writer can view their dashboard.
     */
    public function test_writer_can_view_dashboard(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        
        Auth::login($writer);

        $response = $this->get('/writer/dashboard');

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page->component('Writer/Dashboard'));
    }

    /**
     * Test writer can create an article.
     */
    public function test_writer_can_store_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        
        Auth::login($writer);

        $response = $this->post('/writer/articles', [
            'title' => 'Test Article',
            'content' => 'Test content',
            'category_id' => null,
        ]);

        $response->assertRedirect('/writer/dashboard');
        $this->assertDatabaseHas('articles', [
            'title' => 'Test Article',
            'writer_id' => $writer->id,
        ]);
        $response->assertSessionHas('success', 'Article created successfully!');
    }

    /**
     * Test writer can edit their own article.
     */
    public function test_writer_can_edit_own_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create(['writer_id' => $writer->id, 'category_id' => null]);
        
        Auth::login($writer);

        $response = $this->get("/writer/articles/{$article->id}/edit");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Writer/Edit')
            ->where('article.id', $article->id));
    }

    /**
     * Test writer can update their own article.
     */
    public function test_writer_can_update_own_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create(['writer_id' => $writer->id, 'category_id' => null]);
        
        Auth::login($writer);

        $response = $this->put("/writer/articles/{$article->id}", [
            'title' => 'Updated Title',
            'content' => 'Updated content',
            'category_id' => null,
        ]);

        $response->assertRedirect('/writer/dashboard');
        $this->assertDatabaseHas('articles', [
            'title' => 'Updated Title',
            'id' => $article->id,
        ]);
    }

    /**
     * Test writer cannot edit other writer's article.
     */
    public function test_writer_cannot_edit_other_writer_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $otherWriter = User::factory()->create();
        $otherWriter->assignRole('writer');
        $article = Article::factory()->create(['writer_id' => $otherWriter->id, 'category_id' => null]);
        
        Auth::login($writer);

        $response = $this->get("/writer/articles/{$article->id}/edit");

        $response->assertStatus(403);
    }

    /**
     * Test writer can submit their article.
     */
    public function test_writer_can_submit_draft_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($writer);

        $response = $this->post("/writer/articles/{$article->id}/submit");

        $response->assertRedirect('/writer/dashboard');
        $this->assertDatabaseHas('articles', [
            'id' => $article->id,
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
        ]);
        $response->assertSessionHas('success', 'Article submitted for review!');
    }

    /**
     * Test writer cannot submit non-draft article.
     */
    public function test_writer_cannot_submit_non_draft_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($writer);

        $response = $this->post("/writer/articles/{$article->id}/submit");

        $response->assertRedirect('/writer/dashboard');
        $response->assertSessionHas('error', 'This article cannot be submitted.');
    }

    /**
     * Test writer can view article revisions.
     */
    public function test_writer_can_view_article_revisions(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create(['writer_id' => $writer->id, 'category_id' => null]);
        
        Auth::login($writer);

        $response = $this->get("/writer/articles/{$article->id}/revisions");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Writer/Revisions')
            ->where('article.id', $article->id));
    }

    /**
     * Test writer cannot view other writer's revisions.
     */
    public function test_writer_cannot_view_other_writer_revisions(): void
    {
        $writer1 = User::factory()->create();
        $writer1->assignRole('writer');
        $writer2 = User::factory()->create();
        $writer2->assignRole('writer');
        $article = Article::factory()->create(['writer_id' => $writer2->id, 'category_id' => null]);
        
        Auth::login($writer1);

        $response = $this->get("/writer/articles/{$article->id}/revisions");

        $response->assertStatus(403);
    }

    /**
     * Test writer can revise and resubmit article.
     */
    public function test_writer_can_revise_and_resubmit_article(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create([
            'writer_id' => $writer->id,
            'status_id' => ArticleStatus::where('name', 'Needs Revision')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($writer);

        $response = $this->post("/writer/articles/{$article->id}/revise", [
            'title' => 'Revised Title',
            'content' => 'Revised content',
            'category_id' => null,
        ]);

        $response->assertRedirect('/writer/dashboard');
        $this->assertDatabaseHas('articles', [
            'id' => $article->id,
            'status_id' => ArticleStatus::where('name', 'Submitted')->first()->id,
            'title' => 'Revised Title',
        ]);
        $response->assertSessionHas('success', 'Article revised and resubmitted!');
    }

    /**
     * Test unauthenticated user cannot access writer routes.
     */
    public function test_unauthenticated_cannot_access_writer_routes(): void
    {
        $response = $this->get('/writer/dashboard');

        $response->assertRedirect('/login');
    }

    /**
     * Test non-writer cannot access writer routes.
     */
    public function test_non_writer_cannot_access_writer_routes(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        Auth::login($student);

        $response = $this->get('/writer/dashboard');

        $response->assertStatus(403);
    }

    /**
     * Test store validation for article creation.
     */
    public function test_store_validation(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        
        Auth::login($writer);

        // Test missing title
        $response = $this->post('/writer/articles', [
            'content' => 'Test content',
        ]);

        $response->assertSessionHasErrors('title');
        
        // Test title too long
        $response = $this->post('/writer/articles', [
            'title' => str_repeat('a', 256),
            'content' => 'Test content',
        ]);

        $response->assertSessionHasErrors('title');
        
        // Test invalid category
        $response = $this->post('/writer/articles', [
            'title' => 'Test Article',
            'content' => 'Test content',
            'category_id' => 999,
        ]);

        $response->assertSessionHasErrors('category_id');
    }

    /**
     * Test update validation for article editing.
     */
    public function test_update_validation(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        $article = Article::factory()->create(['writer_id' => $writer->id]);
        
        Auth::login($writer);

        // Test missing title
        $response = $this->put("/writer/articles/{$article->id}", [
            'content' => 'Updated content',
        ]);

        $response->assertSessionHasErrors('title');
        
        // Test content too long
        $response = $this->put("/writer/articles/{$article->id}", [
            'title' => str_repeat('a', 256),
            'content' => 'Updated content',
        ]);

        $response->assertSessionHasErrors('title');
    }
}
