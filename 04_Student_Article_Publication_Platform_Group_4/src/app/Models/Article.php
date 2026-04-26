<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Article extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'category_id',
        'status_id', // This links to your 3 pending articles
        'title',
        'content',
    ];

    /**
     * Get the status that owns the Article.
     * Changed from ArticleStatus to Status to match your database check.
     */
    public function status()
    {
        return $this->belongsTo(Status::class, 'status_id');
    }

    /**
     * Get the category that owns the Article (Technology, Lifestyle, etc.).
     */
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    /**
     * Get the user (Writer) that created the Article.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}