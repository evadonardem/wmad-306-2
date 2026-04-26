<?php

namespace Tests\Feature;

use App\Models\Article;
use App\Models\User;
use App\Models\Comment;
use App\Models\ArticleStatus;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;
use Illuminate\Support\Facades\Auth;

class StudentControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed();
    }

    /**
     * Test student can view their dashboard.
     */
    public function test_student_can_view_dashboard(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        Auth::login($student);

        $response = $this->get('/student/dashboard');

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page->component('Student/Dashboard'));
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
        
        Auth::login($student);

        $response = $this->get("/student/articles/{$article->id}");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Student/Show')
            ->where('article.id', $article->id));
    }

    /**
     * Test student cannot view non-published article.
     */
    public function test_student_cannot_view_non_published_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($student);

        $response = $this->get("/student/articles/{$article->id}");

        $response->assertStatus(404);
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
        
        Auth::login($student);

        $response = $this->post("/student/articles/{$article->id}/comment", [
            'content' => 'Great article!',
        ]);

        $response->assertRedirect();
        $this->assertDatabaseHas('comments', [
            'article_id' => $article->id,
            'student_id' => $student->id,
            'content' => 'Great article!',
        ]);
        $response->assertSessionHas('success', 'Comment added successfully!');
    }

    /**
     * Test student cannot comment on non-published article.
     */
    public function test_student_cannot_comment_on_non_published_article(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($student);

        $response = $this->post("/student/articles/{$article->id}/comment", [
            'content' => 'This should not work.',
        ]);

        $response->assertStatus(404);
        $this->assertDatabaseMissing('comments', [
            'article_id' => $article->id,
            'student_id' => $student->id,
        ]);
    }

    /**
     * Test student can search published articles.
     */
    public function test_student_can_search_published_articles(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        // Create published articles
        Article::factory()->create([
            'title' => 'Technology Trends',
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        Article::factory()->create([
            'title' => 'Science Discoveries',
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        Article::factory()->create([
            'title' => 'Draft Article',
            'status_id' => ArticleStatus::where('name', 'Draft')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($student);

        $response = $this->get('/student/search?query=Technology');

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Student/Search')
            ->where('query', 'Technology'));
    }

    /**
     * Test student search redirects to dashboard with no query.
     */
    public function test_student_search_redirects_with_no_query(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        Auth::login($student);

        $response = $this->get('/student/search');

        $response->assertRedirect('/student/dashboard');
    }

    /**
     * Test student dashboard includes featured articles.
     */
    public function test_student_dashboard_includes_featured_articles(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        // Create articles with comments
        $article1 = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        $article2 = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        // Add comments to articles
        Comment::factory()->create(['article_id' => $article1->id]);
        Comment::factory()->create(['article_id' => $article1->id]);
        Comment::factory()->create(['article_id' => $article2->id]);
        
        Auth::login($student);

        $response = $this->get('/student/dashboard');

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Student/Dashboard')
            ->has('featuredArticles'));
    }

    /**
     * Test student can view article with comments.
     */
    public function test_student_can_view_article_with_comments(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        // Add comments
        Comment::factory()->create(['article_id' => $article->id]);
        Comment::factory()->create(['article_id' => $article->id]);
        
        Auth::login($student);

        $response = $this->get("/student/articles/{$article->id}");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Student/Show')
            ->has('article.comments', 2));
    }

    /**
     * Test student can view related articles.
     */
    public function test_student_can_view_related_articles(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        // Create related articles
        Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($student);

        $response = $this->get("/student/articles/{$article->id}");

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Student/Show')
            ->has('relatedArticles', 3));
    }

    /**
     * Test unauthenticated user cannot access student routes.
     */
    public function test_unauthenticated_cannot_access_student_routes(): void
    {
        $response = $this->get('/student/dashboard');

        $response->assertRedirect('/login');
    }

    /**
     * Test non-student cannot access student routes.
     */
    public function test_non_student_cannot_access_student_routes(): void
    {
        $writer = User::factory()->create();
        $writer->assignRole('writer');
        
        Auth::login($writer);

        $response = $this->get('/student/dashboard');

        $response->assertStatus(403);
    }

    /**
     * Test comment validation.
     */
    public function test_comment_validation(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        $article = Article::factory()->create([
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($student);

        // Test missing content
        $response = $this->post("/student/articles/{$article->id}/comment", []);

        $response->assertSessionHasErrors('content');
        
        // Test content too long
        $response = $this->post("/student/articles/{$article->id}/comment", [
            'content' => str_repeat('a', 1001),
        ]);

        $response->assertSessionHasErrors('content');
    }

    /**
     * Test search functionality finds matching articles.
     */
    public function test_search_finds_matching_articles(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        // Create articles
        Article::factory()->create([
            'title' => 'Advanced Technology',
            'content' => 'This is about technology',
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        Article::factory()->create([
            'title' => 'Science Research',
            'content' => 'This is about science',
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        Article::factory()->create([
            'title' => 'Technology Basics',
            'content' => 'Introduction to technology',
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($student);

        // Search for "technology"
        $response = $this->get('/student/search?query=technology');

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Student/Search')
            ->has('articles.data')); // Should contain matching published articles
    }

    /**
     * Test search returns no results for non-matching query.
     */
    public function test_search_returns_no_results_for_non_matching_query(): void
    {
        $student = User::factory()->create();
        $student->assignRole('student');
        
        Article::factory()->create([
            'title' => 'Technology Article',
            'status_id' => ArticleStatus::where('name', 'Published')->first()->id,
            'category_id' => null,
        ]);
        
        Auth::login($student);

        $response = $this->get('/student/search?query=nonexistent');

        $response->assertStatus(200);
        $response->assertInertia(fn ($page) => $page
            ->component('Student/Search')
            ->has('articles.data', 0));
    }
}
