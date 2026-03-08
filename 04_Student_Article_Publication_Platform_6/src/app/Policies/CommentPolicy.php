<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\User;

class CommentPolicy
{
    public function comment(User $user, Article $article): bool
    {
        return $user->hasRole('student') && $article->status?->name === 'published';
    }
}
