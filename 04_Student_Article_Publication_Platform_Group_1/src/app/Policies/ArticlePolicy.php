<?php

namespace App\Policies;

use App\Models\Article;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class ArticlePolicy
{
    /**
     * Determine whether user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return $user->isStudent() || $user->isEditor() || $user->isWriter();
    }

    /**
     * Determine whether user can view the model.
     */
    public function view(User $user, Article $article): bool
    {
        // Students can only view published articles
        if ($user->isStudent()) {
            return $article->isPublished();
        }

        // Writers can view their own articles
        if ($user->isWriter()) {
            return $article->writer_id === $user->id;
        }

        // Editors can view any article
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
        return $user->isWriter();
    }

    /**
     * Determine whether user can update the model.
     */
    public function update(User $user, Article $article): bool
    {
        return $this->canBeEditedBy($user, $article);
    }

    /**
     * Determine whether user can delete the model.
     */
    public function delete(User $user, Article $article): bool
    {
        // Only writers can delete their own draft articles
        if ($user->isWriter()) {
            return $article->writer_id === $user->id && $article->isDraft();
        }

        // Editors can delete any article
        if ($user->isEditor()) {
            return true;
        }

        return false;
    }

    /**
     * Determine whether user can restore the model.
     */
    public function restore(User $user, Article $article): bool
    {
        return $user->isEditor() || ($user->isWriter() && $article->writer_id === $user->id);
    }

    /**
     * Determine whether user can permanently delete the model.
     */
    public function forceDelete(User $user, Article $article): bool
    {
        return $user->isEditor();
    }

    /**
     * Determine whether user can submit the article for review.
     */
    public function submit(User $user, Article $article): bool
    {
        return $user->isWriter() && 
               $article->writer_id === $user->id && 
               $article->isDraft();
    }

    /**
     * Determine whether user can review the article.
     */
    public function review(User $user, Article $article): bool
    {
        return $user->isEditor() && $article->isSubmitted();
    }

    /**
     * Determine whether user can publish the article.
     */
    public function publish(User $user, Article $article): bool
    {
        return $user->isEditor() && $article->isSubmitted();
    }

    /**
     * Determine whether user can request revisions for the article.
     */
    public function requestRevision(User $user, Article $article): bool
    {
        return $user->isEditor() && $article->isSubmitted();
    }

    /**
     * Determine whether user can edit any article.
     */
    public function editAny(User $user): bool
    {
        return $user->can('edit any article');
    }

    /**
     * Determine whether user can comment on articles.
     */
    public function comment(User $user, Article $article): bool
    {
        return $user->isStudent() && $article->isPublished();
    }

    /**
     * Determine whether user can view article revisions.
     */
    public function revisions(User $user, Article $article): bool
    {
        // Writers can view their own article revisions
        if ($user->isWriter()) {
            return $article->writer_id === $user->id;
        }

        // Editors can view any article revisions
        if ($user->isEditor()) {
            return true;
        }

        return false;
    }

    /**
     * Helper method to check if article can be edited by user.
     */
    private function canBeEditedBy(User $user, Article $article): bool
    {
        return $article->writer_id === $user->id || $user->can('edit any article');
    }
}
