<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Game extends Model
{
    protected $fillable = [
        'season_id','home_team_id','away_team_id',
        'scheduled_at','venue','status'
    ];

    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    // Two separate relationships for home and away teams
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
}