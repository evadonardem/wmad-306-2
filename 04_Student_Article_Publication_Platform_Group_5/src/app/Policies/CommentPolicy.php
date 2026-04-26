<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\Comment;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class CommentPolicy
{
    public function comment(User $user, Article $article): Response
    {
        return $user->hasRole('student') && $article->isPublished()
            ? Response::allow()
            : Response::deny('Only students can comment on published articles.');
    }

    public function update(User $user, Comment $comment): Response
    {
        return $user->id === $comment->student_id
            ? Response::allow()
            : Response::deny('You can only edit your own comments.');
    }

    public function delete(User $user, Comment $comment): Response
    {
        return $user->id === $comment->student_id || $user->hasRole('editor')
            ? Response::allow()
            : Response::deny('You can only delete your own comments.');
    }
}
