<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Models\Player;
use App\Models\GameResult;

class PlayerStat extends Model
{
    protected $fillable = [
        'player_id',
        'game_result_id',
        'points',
    ];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }

    public function gameResult(): BelongsTo
    {
        return $this->belongsTo(GameResult::class);
    }
}
