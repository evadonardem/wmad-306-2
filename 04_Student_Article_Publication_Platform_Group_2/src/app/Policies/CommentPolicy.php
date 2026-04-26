<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\Comment;
use App\Models\User;

class CommentPolicy
{
    /**
     * Students can comment on published articles.
     */
    public function comment(User $user, Article $article): bool
    {
        return $user->hasRole('student') && $article->isPublished();
    }

    /**
     * Students can delete their own comments.
     */
    public function delete(User $user, Comment $comment): bool
    {
        return $user->hasRole('student') && $comment->student_id === $user->id;
    }
}
