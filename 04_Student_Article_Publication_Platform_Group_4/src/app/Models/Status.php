<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Status extends Model
{
    use HasFactory;

    // Allows you to create 'Draft', 'Pending', and 'Published' names
    protected $fillable = ['name'];

    /**
     * Get the articles for the status.
     * This allows the Editor to see all 3 pending articles.
     */
    public function articles()
    {
        return $this->hasMany(Article::class);
    }
}