<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
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
        'category_id',
        'tags',
        'reviewer_notes',
    ];

    protected $casts = [
        'tags' => 'array',
    ];

    public function writer()
    {
        return $this->belongsTo(User::class, 'writer_id');
    }

    public function editor()
    {
        return $this->belongsTo(User::class, 'editor_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function status()
    {
        return $this->belongsTo(ArticleStatus::class, 'status_id');
    }

    public function revisions()
    {
        return $this->hasMany(Revision::class);
    }

    public function comments()
    {
        return $this->hasMany(Comment::class);
    }

    public function isPublished(): bool
    {
        return $this->status && $this->status->name === 'published';
    }

    public function isDraft(): bool
    {
        return $this->status && $this->status->name === 'draft';
    }

    public function isSubmitted(): bool
    {
        return $this->status && $this->status->name === 'submitted';
    }

    public function needsRevision(): bool
    {
        return $this->status && $this->status->name === 'needs_revision';
    }
}
