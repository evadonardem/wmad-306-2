<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
    ];

    /**
     * A project has many tasks.
     */
    public function tasks()
    {
        return $this->hasMany(Task::class);
    }

    /**
     * A project belongs to a user.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
