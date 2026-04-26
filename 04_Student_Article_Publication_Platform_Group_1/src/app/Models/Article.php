<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Article extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'content',
        'status_id',
        'writer_id',
        'editor_id',
        'category_id',
    ];

    /**
     * Get the writer who created this article.
     */
    public function writer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'writer_id');
    }

    /**
     * Get the editor who processed this article.
     */
    public function editor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'editor_id');
    }

    /**
     * Get the category this article belongs to.
     */
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Get the status of this article.
     */
    public function status(): BelongsTo
    {
        return $this->belongsTo(ArticleStatus::class);
    }

    /**
     * Get all revisions for this article.
     */
    public function revisions(): HasMany
    {
        return $this->hasMany(Revision::class);
    }

    /**
     * Get all comments for this article.
     */
    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    // Scopes for common queries
    public function scopeDraft($query)
    {
        return $query->whereHas('status', fn($q) => $q->where('name', 'Draft'));
    }

    public function scopeSubmitted($query)
    {
        return $query->whereHas('status', fn($q) => $q->where('name', 'Submitted'));
    }

    public function scopeNeedsRevision($query)
    {
        return $query->whereHas('status', fn($q) => $q->where('name', 'Needs Revision'));
    }

    public function scopePublished($query)
    {
        return $query->whereHas('status', fn($q) => $q->where('name', 'Published'));
    }

    public function scopeByWriter($query, $userId)
    {
        return $query->where('writer_id', $userId);
    }

    public function scopeByCategory($query, $categoryId)
    {
        return $query->where('category_id', $categoryId);
    }

    // Helper methods for readability
    public function isDraft(): bool
    {
        return $this->status?->isDraft();
    }

    public function isSubmitted(): bool
    {
        return $this->status?->isSubmitted();
    }

    public function needsRevision(): bool
    {
        return $this->status?->needsRevision();
    }

    public function isPublished(): bool
    {
        return $this->status?->isPublished();
    }

    public function isCommented(): bool
    {
        return $this->status?->isCommented();
    }

    public function canBeEditedBy($user)
    {
        return $this->writer_id === $user->id || $user->can('edit any article');
    }
}
