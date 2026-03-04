<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\User;

class CommentPolicy
{
    /**
     * Students (and any authenticated user with the student role) can comment on published articles.
     */
    public function comment(User $user, Article $article): bool
    {
        return $user->hasRole('student') && $article->isPublished();
    }
}
