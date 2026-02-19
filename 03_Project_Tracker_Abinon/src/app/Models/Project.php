<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;



class Project extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
    ];

    // Project → belongs to User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Project → has many Tasks
    public function tasks()
    {
        return $this->hasMany(Task::class);
    }
}
