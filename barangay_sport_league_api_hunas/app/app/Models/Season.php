<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Season extends Model
{
    use HasFactory;

    protected $guarded = ['id'];

    protected $casts = [
        'start_date' => 'date',
        'end_date'   => 'date',
    ];

    public function league(): BelongsTo
    {
        return $this->belongsTo(League::class);
    }

    public function teams(): HasMany
    {
        return $this->hasMany(Team::class);
    }

    public function games(): HasMany
    {
        return $this->hasMany(Game::class);
    }

    public function scopeActive(Builder $query): void
    {
        $query->where('status', 'active');
    }

    public function getDurationAttribute(): int
    {
        return $this->start_date->diffInDays($this->end_date);
    }
}