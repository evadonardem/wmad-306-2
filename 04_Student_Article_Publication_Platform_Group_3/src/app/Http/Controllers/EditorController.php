<?php

namespace App\Http\Controllers;

use App\Models\Article;
use App\Models\ArticleStatus;
use App\Models\Revision;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class EditorController extends Controller
{
    public function dashboard()
    {
        // Debug: Check user roles
        $user = auth()->user();
        $userRoles = $user->roles->pluck('name')->toArray();
        
        // Check if user has editor role, if not, redirect appropriately
        if (!in_array('editor', $userRoles)) {
            if (in_array('writer', $userRoles)) {
                return redirect()->route('writer.dashboard');
            } elseif (in_array('student', $userRoles)) {
                return redirect()->route('student.dashboard');
            } else {
                // If no valid role, redirect to main dashboard
                return redirect()->route('dashboard');
            }
        }
        
        $pending = Article::whereHas('status', function ($q) {
            $q->where('name', 'submitted');
        })->with('writer', 'category')->get();

        $published = Article::whereHas('status', function ($q) {
            $q->where('name', 'published');
        })->withCount('comments')->with('writer', 'category', 'comments.user')->get();

        $categories = \App\Models\Category::orderBy('name')->get();
        
        // Get notifications for editors
        $notifications = [];
        try {
            $notifications = $user->notifications()
                ->whereIn('type', [
                    \App\Notifications\ArticleSubmittedNotification::class,
                    \App\Notifications\ArticleRevisedNotification::class
                ])
                ->orderBy('created_at', 'desc')
                ->limit(10)
                ->get();
        } catch (\Exception $e) {
            // Notifications table doesn't exist yet, continue without notifications
        }
        
        return Inertia::render('Editor/Dashboard', compact('pending','published','categories','notifications'));
    }

    public function review(Article $article)
    {
        // Check if user has editor role instead of using policy
        $user = auth()->user();
        $userRoles = $user->roles->pluck('name')->toArray();
        
        if (!in_array('editor', $userRoles)) {
            abort(403);
        }
        
        // Load article with all necessary relationships
        $article->load(['writer', 'category', 'status']);
        
        return Inertia::render('Editor/Review', compact('article'));
    }

    public function requestRevision(Request $request, Article $article)
    {
        // Check if user has editor role instead of using policy
        $user = auth()->user();
        $userRoles = $user->roles->pluck('name')->toArray();
        
        if (!in_array('editor', $userRoles)) {
            abort(403);
        }
        
        $data = $request->validate(['comments' => 'required|string']);

        $revision = Revision::create([
            'article_id' => $article->id,
            'editor_id' => Auth::id(),
            'comments' => $data['comments'],
        ]);

        $status = ArticleStatus::firstOrCreate(['name' => 'needs_revision'], ['label' => 'Needs Revision']);
        $article->update(['status_id' => $status->id]);

        // notify writer
        try {
            $article->writer->notify(new \App\Notifications\RevisionRequestedNotification($revision));
        } catch (\Exception $e) {
            // Notifications table doesn't exist yet, continue without notification
        }

        return redirect()->back()->with('success','Revision requested');
    }

    public function publish(Article $article)
    {
        // Check if user has editor role instead of using policy
        $user = auth()->user();
        $userRoles = $user->roles->pluck('name')->toArray();
        
        if (!in_array('editor', $userRoles)) {
            abort(403);
        }
        
        $published = ArticleStatus::firstOrCreate(['name' => 'published'], ['label' => 'Published']);
        $article->update(['status_id' => $published->id, 'editor_id' => Auth::id()]);

        // notify writer
        try {
            $article->writer->notify(new \App\Notifications\ArticlePublishedNotification($article));
        } catch (\Exception $e) {
            // Notifications table doesn't exist yet, continue without notification
        }

        return redirect()->back()->with('success','Article published');
    }
}
