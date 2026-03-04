<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\User;

class ArticlePolicy
{
    /**
     * Writers can create articles.
     */
    public function create(User $user): bool
    {
        return $user->hasRole('writer');
    }

    /**
     * Writers can update their own drafts / articles needing revision.
     */
    public function update(User $user, Article $article): bool
    {
        return $user->hasRole('writer')
            && $article->writer_id === $user->id
            && in_array($article->status?->name, ['draft', 'revision']);
    }

    /**
     * Writers can submit their own draft articles.
     */
    public function submit(User $user, Article $article): bool
    {
        return $user->hasRole('writer')
            && $article->writer_id === $user->id
            && in_array($article->status?->name, ['draft', 'revision']);
    }

    /**
     * Editors can request a revision on submitted articles.
     */
    public function requestRevision(User $user, Article $article): bool
    {
        return $user->hasRole('editor')
            && $article->status?->name === 'submitted';
    }

    /**
     * Editors can publish submitted articles.
     */
    public function publish(User $user, Article $article): bool
    {
        return $user->hasRole('editor')
            && $article->status?->name === 'submitted';
    }

    /**
     * Anyone can view published articles; writers can view their own.
     */
    public function view(?User $user, Article $article): bool
    {
        if ($article->isPublished()) {
            return true;
        }

        return $user && (
            ($user->hasRole('writer') && $article->writer_id === $user->id)
            || $user->hasRole('editor')
        );
    }
}
