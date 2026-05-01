<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlayerStat extends Model
{
    use HasFactory;

    protected $fillable = [
        'game_id',
        'game_result_id',
        'player_id',
        'points',
        'assists',
        'rebounds',
        'fouls',
    ];

    public function gameResult(): BelongsTo
    {
        return $this->belongsTo(GameResult::class);
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }

    public function game(): BelongsTo
    {
        return $this->belongsTo(Game::class);
    }
}
