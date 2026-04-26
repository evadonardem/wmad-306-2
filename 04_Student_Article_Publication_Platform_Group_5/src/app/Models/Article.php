<?php

namespace App\Models;

use App\Models\User;
use App\Models\ArticleStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Article extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'content',
        'status_id',
        'writer_id',
        'editor_id',
        'category_id'
    ];

    public function writer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'writer_id');
    }

    public function editor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'editor_id');
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function status(): BelongsTo
    {
        return $this->belongsTo(ArticleStatus::class, 'status_id');
    }

    public function revisions(): HasMany
    {
        return $this->hasMany(Revision::class);
    }

    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    public function messages(): HasMany
    {
        return $this->hasMany(ArticleMessage::class)->latest();
    }

    public function isPublished(): bool
    {
        if ($this->relationLoaded('status')) {
            return $this->status?->name === 'published';
        }

        return ArticleStatus::whereKey($this->status_id)->value('name') === 'published';
    }

    public function isDraft(): bool
    {
        if ($this->relationLoaded('status')) {
            return $this->status?->name === 'draft';
        }

        return ArticleStatus::whereKey($this->status_id)->value('name') === 'draft';
    }

    public function isSubmitted(): bool
    {
        if ($this->relationLoaded('status')) {
            return $this->status?->name === 'submitted';
        }

        return ArticleStatus::whereKey($this->status_id)->value('name') === 'submitted';
    }

    public function needsRevision(): bool
    {
        if ($this->relationLoaded('status')) {
            return $this->status?->name === 'needs_revision';
        }

        return ArticleStatus::whereKey($this->status_id)->value('name') === 'needs_revision';
    }
}
