<?php

namespace App\Policies;

use App\Models\Comment;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class CommentPolicy
{
    /**
     * Determine whether user can view any models.
     */
    public function viewAny(User $user): bool
    {
        // Only editors can view all comments
        return $user->isEditor();
    }

    /**
     * Determine whether user can view the model.
     */
    public function view(User $user, Comment $comment): bool
    {
        // Students can view comments on published articles
        if ($user->isStudent()) {
            return $comment->article->isPublished();
        }

        // Writers can view comments on their own articles
        if ($user->isWriter()) {
            return $comment->article->writer_id === $user->id;
        }

        // Editors can view any comment
        if ($user->isEditor()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether user can create models.
     */
    public function create(User $user): bool
    {
        // Only students can create comments
        return $user->isStudent();
    }

    /**
     * Determine whether user can comment on a specific article.
     */
    public function comment(User $user, $article): bool
    {
        // Only students can comment on published articles
        return $user->isStudent() && $article->isPublished();
    }

    /**
     * Determine whether user can update the model.
     */
    public function update(User $user, Comment $comment): bool
    {
        // Students can only update their own comments
        if ($user->isStudent()) {
            return $comment->student_id === $user->id;
        }

        // Editors can update any comment
        if ($user->isEditor()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether user can delete the model.
     */
    public function delete(User $user, Comment $comment): bool
    {
        // Students can only delete their own comments
        if ($user->isStudent()) {
            return $comment->student_id === $user->id;
        }

        // Writers can delete comments on their own articles
        if ($user->isWriter()) {
            return $comment->article->writer_id === $user->id;
        }

        // Editors can delete any comment
        if ($user->isEditor()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether user can restore the model.
     */
    public function restore(User $user, Comment $comment): bool
    {
        // Only editors can restore comments
        return $user->isEditor();
    }

    /**
     * Determine whether user can permanently delete the model.
     */
    public function forceDelete(User $user, Comment $comment): bool
    {
        // Only editors can permanently delete comments
        return $user->isEditor();
    }
}
