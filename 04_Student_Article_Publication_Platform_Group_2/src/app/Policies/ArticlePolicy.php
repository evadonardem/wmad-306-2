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
     * Writers can update their own draft or needs-revision articles.
     */
    public function update(User $user, Article $article): bool
    {
        return $user->hasRole('writer')
            && $article->writer_id === $user->id
            && ($article->isDraft() || $article->needsRevision());
    }

    /**
     * Writers can submit their own draft articles.
     */
    public function submit(User $user, Article $article): bool
    {
        return $user->hasRole('writer')
            && $article->writer_id === $user->id
            && ($article->isDraft() || $article->needsRevision());
    }

    /**
     * Editors can review submitted articles.
     */
    public function review(User $user, Article $article): bool
    {
        return $user->hasRole('editor') && $article->isSubmitted();
    }

    /**
     * Editors can request revisions on submitted articles.
     */
    public function requestRevision(User $user, Article $article): bool
    {
        return $user->hasRole('editor') && $article->isSubmitted();
    }

    /**
     * Editors can publish submitted articles.
     */
    public function publish(User $user, Article $article): bool
    {
        return $user->hasRole('editor') && $article->isSubmitted();
    }

    /**
     * Writers can delete their own draft articles.
     */
    public function delete(User $user, Article $article): bool
    {
        return $user->hasRole('writer')
            && $article->writer_id === $user->id
            && $article->isDraft();
    }

    /**
     * Anyone authenticated can view published articles.
     * Writers can view their own articles regardless of status.
     * Editors can view submitted articles.
     */
    public function view(User $user, Article $article): bool
    {
        if ($article->isPublished()) {
            return true;
        }

        if ($user->hasRole('writer') && $article->writer_id === $user->id) {
            return true;
        }

        if ($user->hasRole('editor') && ($article->isSubmitted() || $article->needsRevision())) {
            return true;
        }

        return false;
    }
}
