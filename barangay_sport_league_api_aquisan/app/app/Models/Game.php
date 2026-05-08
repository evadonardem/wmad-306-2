<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use App\Models\GameResult;
use App\Models\Season;
use App\Models\Team;

class Game extends Model
{
    protected $fillable = [
        'season_id',
        'home_team_id',
        'away_team_id',
        'status',
        'scheduled_at',
    ];

    protected $attributes = [
        'status' => 'scheduled',
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
}
