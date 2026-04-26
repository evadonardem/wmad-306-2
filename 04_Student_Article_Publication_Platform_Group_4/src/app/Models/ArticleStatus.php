<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ArticleStatus extends Model
{
    use HasFactory;

    // This tells Laravel it's safe to fill these specific columns
    protected $fillable = [
        'name',
        'label',
    ];
}