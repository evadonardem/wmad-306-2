<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Category;
use App\Models\Comment;
use App\Models\Favorite;
use App\Models\RoleRequest;
use App\Notifications\CommentPostedNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class StudentController extends Controller
{
    public function dashboard(Request $request)
    {
        $publishedStatus = ArticleStatus::where('name', 'published')->first();
        
        // Handle case where published status doesn't exist
        if (!$publishedStatus) {
            return Inertia::render('Student/Dashboard', [
                'publishedArticles' => collect([]),
                'myComments' => collect([]),
                'favorites' => collect([]),
                'categories' => Category::all(),
                'selectedCategory' => $request->category_id,
                'error' => 'Article statuses not properly configured. Please contact administrator.'
            ]);
        }
        
        $query = Article::where('status_id', $publishedStatus->id)
            ->with(['writer', 'category', 'comments' => function($query) {
                $query->with('student')->latest();
            }]);
        
        // Filter by category if selected
        if ($request->has('category_id') && $request->category_id) {
            $query->where('category_id', $request->category_id);
        }
        
        $publishedArticles = $query->orderBy('created_at', 'desc')->get();
        
        $categories = Category::all();
        
        $myComments = Comment::where('student_id', Auth::id())
            ->with(['article', 'article.writer'])
            ->latest()
            ->get();

        // Get user's favorite articles
        $favorites = Favorite::where('student_id', Auth::id())
            ->with(['article.writer', 'article.category', 'article.status'])
            ->latest()
            ->get();

        return Inertia::render('Student/Dashboard', [
            'publishedArticles' => $publishedArticles,
            'myComments' => $myComments,
            'favorites' => $favorites,
            'categories' => $categories,
            'selectedCategory' => $request->category_id
        ]);
    }

    public function publishedArticles(Request $request)
    {
        $publishedStatus = ArticleStatus::where('name', 'published')->first();
        
        // Handle case where published status doesn't exist
        if (!$publishedStatus) {
            return Inertia::render('Student/PublishedArticles', [
                'publishedArticles' => collect([]),
                'categories' => Category::all(),
                'selectedCategory' => $request->category_id,
                'favorites' => collect([]),
                'error' => 'Article statuses not properly configured. Please contact administrator.'
            ]);
        }
        
        $query = Article::where('status_id', $publishedStatus->id)
            ->with(['writer', 'category', 'comments' => function($query) {
                $query->with('student')->latest();
            }]);

        // Filter by category if selected
        if ($request->has('category_id') && $request->category_id) {
            $query->where('category_id', $request->category_id);
        }

        $publishedArticles = $query->orderBy('created_at', 'desc')->get();

        $categories = Category::all();

        // Get user's favorite articles
        $favorites = Favorite::where('student_id', Auth::id())
            ->with(['article.writer', 'article.category', 'article.status'])
            ->latest()
            ->get();

        return Inertia::render('Student/PublishedArticles', [
            'publishedArticles' => $publishedArticles,
            'categories' => $categories,
            'selectedCategory' => $request->category_id,
            'favorites' => $favorites
        ]);
    }

    public function myComments()
    {
        $myComments = Comment::where('student_id', Auth::id())
            ->with(['article', 'article.writer'])
            ->latest()
            ->get();

        return Inertia::render('Student/MyComments', [
            'myComments' => $myComments
        ]);
    }

    public function show(Article $article)
    {
        if (!$article->isPublished()) {
            abort(403, 'This article is not published yet.');
        }

        // Check if article is favorited by current student
        $isFavorited = Favorite::where('student_id', Auth::id())
            ->where('article_id', $article->id)
            ->exists();

        $article->load(['writer', 'category', 'comments' => function($query) {
            $query->with('student')->latest();
        }]);

        return Inertia::render('Student/ShowArticle', [
            'article' => $article,
            'isFavorite' => $isFavorited
        ]);
    }

    public function comment(Request $request, Article $article)
    {
        $validated = $request->validate([
            'content' => 'required|string|max:1000'
        ]);

        $comment = Comment::create([
            'article_id' => $article->id,
            'student_id' => Auth::id(),
            'content' => $validated['content']
        ]);

        // Notify article writer
        $article->writer->notify(new CommentPostedNotification($comment, $article));

        return redirect()->back()->with('success', 'Comment posted successfully!');
    }

    public function favorites()
    {
        $favorites = Favorite::where('student_id', Auth::id())
            ->with(['article.writer', 'article.category', 'article.status'])
            ->latest()
            ->get();

        return Inertia::render('Student/Favorites', [
            'favorites' => $favorites
        ]);
    }

    public function toggleFavorite(Request $request, Article $article)
    {
        try {
            $existingFavorite = Favorite::where('student_id', Auth::id())
                ->where('article_id', $article->id)
                ->first();

            if ($existingFavorite) {
                // Remove from favorites
                $existingFavorite->delete();
                $isFavorited = false;
                $message = 'Article removed from favorites';
            } else {
                // Add to favorites
                Favorite::create([
                    'student_id' => Auth::id(),
                    'article_id' => $article->id
                ]);
                $isFavorited = true;
                $message = 'Article added to favorites';
            }

            return response()->json([
                'isFavorited' => $isFavorited,
                'message' => $message
            ]);
        } catch (\Exception $e) {
            // If there's an error (like table not existing), return an error response
            return response()->json([
                'error' => 'Favorites functionality not available. Please run migrations.',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function deleteComment(Request $request, Comment $comment)
    {
        // Check if the comment belongs to the current user
        if ($comment->student_id !== Auth::id()) {
            return redirect()->back()->with('error', 'You can only delete your own comments');
        }

        $comment->delete();
        return redirect()->back()->with('success', 'Comment deleted successfully!');
    }

    /**
     * Show the role request page.
     */
    public function roleRequest()
    {
        $existingRequests = RoleRequest::where('user_id', Auth::id())
            ->latest()
            ->get();

        return Inertia::render('Student/RoleRequest', [
            'existingRequests' => $existingRequests
        ]);
    }

    /**
     * Store a new role request.
     */
    public function storeRoleRequest(Request $request)
    {
        $request->validate([
            'requested_role' => 'required|in:writer,editor',
            'reason' => 'required|string|min:10|max:500'
        ]);

        // Check if user already has a pending request for this role
        $existingRequest = RoleRequest::where('user_id', Auth::id())
            ->where('requested_role', $request->requested_role)
            ->where('status', 'pending')
            ->first();

        if ($existingRequest) {
            return back()->with('error', 'You already have a pending request for this role.');
        }

        // Check if user already has this role
        if (Auth::user()->hasRole($request->requested_role)) {
            return back()->with('error', 'You already have this role.');
        }

        RoleRequest::create([
            'user_id' => Auth::id(),
            'requested_role' => $request->requested_role,
            'reason' => $request->reason,
            'status' => 'pending'
        ]);

        return back()->with('success', 'Your role request has been submitted for review.');
    }
}
