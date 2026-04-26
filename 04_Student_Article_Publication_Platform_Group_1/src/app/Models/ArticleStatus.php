<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ArticleStatus extends Model
{
    protected $fillable = [
        'name',
        'label',
    ];

    /**
     * Get all articles with this status.
     */
    public function articles(): HasMany
    {
        return $this->hasMany(Article::class);
    }

    // Helper methods for workflow
    public function isDraft(): bool
    {
        return $this->name === 'Draft';
    }

    public function isSubmitted(): bool
    {
        return $this->name === 'Submitted';
    }

    public function needsRevision(): bool
    {
        return $this->name === 'Needs Revision';
    }

    public function isPublished(): bool
    {
        return $this->name === 'Published';
    }

    public function isCommented(): bool
    {
        return $this->name === 'Commented';
    }
}
