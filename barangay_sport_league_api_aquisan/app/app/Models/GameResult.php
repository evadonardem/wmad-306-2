<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Models\Game;

class GameResult extends Model
{
    protected $fillable = [
        'game_id',
        'home_score',
        'away_score',
        'stats',
    ];

    protected $casts = [
        'stats' => 'array',
    ];

    public function game(): BelongsTo
    {
        return $this->belongsTo(Game::class);
    }
}
