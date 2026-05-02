<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Game extends Model
{
    use HasFactory;

    protected $fillable = [
        'season_id',
        'home_team_id',
        'away_team_id',
        'home_team_score',
        'away_team_score',
        'scheduled_at',
        'venue',
        'status'
    ];

    public function result()
    {
        // This assumes you have a GameResult model
        return $this->hasOne(GameResult::class);
    }

    public function homeTeam()
    {
        return $this->belongsTo(Team::class, 'home_team_id');
    }

    public function awayTeam()
    {
        return $this->belongsTo(Team::class, 'away_team_id');
    }

    public function season()
    {
        return $this->belongsTo(Season::class);
    }
}