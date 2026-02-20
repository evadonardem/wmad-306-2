<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
  class Project extends Model
{
    protected $fillable = [
        'user_id',
        'name',
        'description',
        'status',
        'due_date',
        'progress'
    ];

    protected $casts = [
        'due_date' => 'date',
        'progress' => 'integer'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

}
