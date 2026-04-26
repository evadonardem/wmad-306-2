<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Comment;
use App\Models\Article;
use Illuminate\Http\Request;

class CommentController extends Controller
{
    public function index(Article $article)
    {
        try {
            $comments = $article->comments()->with('student')->orderBy('created_at', 'desc')->get();
            
            return response()->json($comments->map(function ($comment) {
                return [
                    'id' => $comment->id,
                    'content' => $comment->content,
                    'user_id' => $comment->student_id,
                    'user' => $comment->student ? [
                        'name' => $comment->student->name
                    ] : null,
                    'article_id' => $comment->article_id,
                    'created_at' => $comment->created_at,
                    'updated_at' => $comment->updated_at,
                ];
            }));
        } catch (\Exception $e) {
            \Log::error('Error fetching comments: ' . $e->getMessage());
            return response()->json([], 500);
        }
    }

    public function store(Request $request, Article $article)
    {
        try {
            $request->validate([
                'content' => 'required|string|max:1000',
                'user_id' => 'required|exists:users,id'
            ]);

            $comment = Comment::create([
                'content' => $request->content,
                'article_id' => $article->id,
                'student_id' => $request->user_id,
            ]);

            $comment->load('student');

            return response()->json([
                'id' => $comment->id,
                'content' => $comment->content,
                'user_id' => $comment->student_id,
                'user' => $comment->student ? [
                    'name' => $comment->student->name
                ] : null,
                'article_id' => $comment->article_id,
                'created_at' => $comment->created_at,
                'updated_at' => $comment->updated_at,
            ], 201);
        } catch (\Exception $e) {
            \Log::error('Error creating comment: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to create comment'], 500);
        }
    }

    public function update(Request $request, Comment $comment)
    {
        try {
            $request->validate([
                'content' => 'required|string|max:1000'
            ]);

            $comment->update([
                'content' => $request->content
            ]);

            $comment->load('student');

            return response()->json([
                'id' => $comment->id,
                'content' => $comment->content,
                'user_id' => $comment->student_id,
                'user' => $comment->student ? [
                    'name' => $comment->student->name
                ] : null,
                'article_id' => $comment->article_id,
                'created_at' => $comment->created_at,
                'updated_at' => $comment->updated_at,
            ]);
        } catch (\Exception $e) {
            \Log::error('Error updating comment: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to update comment'], 500);
        }
    }

    public function destroy(Comment $comment)
    {
        try {
            $comment->delete();
            return response()->json(null, 204);
        } catch (\Exception $e) {
            \Log::error('Error deleting comment: ' . $e->getMessage());
            return response()->json(['error' => 'Failed to delete comment'], 500);
        }
    }
}
