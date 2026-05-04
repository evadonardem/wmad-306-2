<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;

class League extends Model
{
    protected $fillable = ['user_id', 'name', 'sport', 'description'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function seasons(): HasMany
    {
        return $this->hasMany(Season::class);
    }

    // Through relationships
    public function teams(): HasManyThrough
    {
        return $this->hasManyThrough(Team::class, Season::class);
    }

    public function games(): HasManyThrough
    {
        return $this->hasManyThrough(Game::class, Season::class);
    }
}