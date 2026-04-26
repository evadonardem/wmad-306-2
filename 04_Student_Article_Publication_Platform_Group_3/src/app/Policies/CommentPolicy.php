<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class CommentPolicy
{
    use HandlesAuthorization;

    public function comment(User $user, Article $article)
    {
        return $user->hasRole('student') && $article->isPublished();
    }
}
