<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\User;

class ArticlePolicy
{
    public function create(User $user): bool
    {
        return $user->hasRole('writer');
    }

    public function submit(User $user, Article $article): bool
    {
        return $user->id === $article->writer_id && in_array($article->status?->name, ['draft', 'needs_revision'], true);
    }

    public function requestRevision(User $user, Article $article): bool
    {
        return $user->hasRole('editor') && $article->status?->name === 'submitted';
    }

    public function publish(User $user, Article $article): bool
    {
        return $user->hasRole('editor') && $article->status?->name === 'submitted';
    }

    public function revise(User $user, Article $article): bool
    {
        return $user->id === $article->writer_id && $article->status?->name === 'needs_revision';
    }
}
