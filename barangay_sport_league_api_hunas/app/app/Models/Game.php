<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Game extends Model
{
    use HasFactory;

   
    protected $guarded = ['id'];

    
    protected $casts = [
        'scheduled_at' => 'datetime',
    ];

    

    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    public function homeTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam(): BelongsTo
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function result(): HasOne
    {
        return $this->hasOne(GameResult::class);
    }

    
    
    public function scopeCompleted(Builder $query): void
    {
        $query->where('status', 'done');
    }

    
    public function scopeUpcoming(Builder $query): void
    {
        $query->where('status', 'scheduled');
    }
}