<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Game extends Model
{
    use HasFactory;

    protected $fillable = [
        'season_id',
        'home_team_id',
        'away_team_id',
        'scheduled_at',
        'venue',
        'status',
    ];

    protected $casts = [
        'scheduled_at' => 'datetime',
    ];

    public function season()
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

    public function result()
    {
        return $this->hasOne(GameResult::class);
    }
}
