<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Comment;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;
use Inertia\Response;

class AdminController extends Controller
{
    /**
     * Display the admin dashboard with all users and their roles.
     */
    public function index(): Response
    {
        // Check if user has permission to manage users
        abort_unless(Auth::user()->can('manage users'), 403);

        $publishedStatusId = ArticleStatus::where('name', 'published')->value('id');

        $users = User::with('roles')
            ->latest()
            ->paginate(10)
            ->withQueryString();

        $users->getCollection()->transform(function ($user) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'roles' => $user->roles->pluck('name')->toArray(),
            ];
        });

        $availableRoles = ['student', 'writer', 'editor', 'admin'];

        $roleDistribution = collect($availableRoles)->map(function ($role) {
            return [
                'role' => $role,
                'count' => User::role($role)->count(),
            ];
        })->values();

        $statusDistribution = ArticleStatus::query()
            ->withCount('articles')
            ->get()
            ->map(function ($status) {
                return [
                    'status' => $status->name,
                    'count' => $status->articles_count,
                ];
            })->values();

        $platformStats = [
            'totalUsers' => User::count(),
            'multiRoleUsers' => User::has('roles', '>', 1)->count(),
            'totalArticles' => Article::count(),
            'publishedArticles' => Article::where('status_id', $publishedStatusId)->count(),
            'totalComments' => Comment::count(),
            'newUsersThisMonth' => User::whereYear('created_at', now()->year)
                ->whereMonth('created_at', now()->month)
                ->count(),
            'newArticlesThisMonth' => Article::whereYear('created_at', now()->year)
                ->whereMonth('created_at', now()->month)
                ->count(),
        ];

        $recentPublishedArticles = Article::with('writer:id,name')
            ->where('status_id', $publishedStatusId)
            ->latest('updated_at')
            ->limit(5)
            ->get()
            ->map(function ($article) {
                return [
                    'id' => $article->id,
                    'title' => $article->title,
                    'writer' => $article->writer?->name,
                    'published_at' => $article->updated_at,
                ];
            })->values();

        $recentComments = Comment::with(['student:id,name', 'article:id,title'])
            ->latest()
            ->limit(5)
            ->get()
            ->map(function ($comment) {
                return [
                    'id' => $comment->id,
                    'student' => $comment->student?->name,
                    'article' => $comment->article?->title,
                    'content' => $comment->content,
                    'created_at' => $comment->created_at,
                ];
            })->values();

        return Inertia::render('Admin/Dashboard', [
            'users' => $users,
            'availableRoles' => $availableRoles,
            'platformStats' => $platformStats,
            'roleDistribution' => $roleDistribution,
            'statusDistribution' => $statusDistribution,
            'recentPublishedArticles' => $recentPublishedArticles,
            'recentComments' => $recentComments,
        ]);
    }

    /**
     * Update a user's roles.
     */
    public function updateRoles(Request $request, User $user): RedirectResponse
    {
        // Check if user has permission to manage users
        abort_unless(Auth::user()->can('manage users'), 403);

        $request->validate([
            'roles' => 'required|array',
            'roles.*' => 'string|in:student,writer,editor,admin',
        ]);

        // Sync all roles for the user
        $user->syncRoles($request->roles);

        return redirect()->back()->with('success', 'User roles updated successfully.');
    }
}
