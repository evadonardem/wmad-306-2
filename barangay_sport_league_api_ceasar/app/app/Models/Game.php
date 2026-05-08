<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Game extends Model
{
    use HasFactory;

    protected $fillable = ['season_id', 'home_team_id', 'away_team_id', 'scheduled_at', 'venue', 'status'];

    public function season()
    {
        return $this->belongsTo(Season::class);
    }

    public function homeTeam(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function result()
    {
        return $this->hasOne(GameResult::class);
    }
}
