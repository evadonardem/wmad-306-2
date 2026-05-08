<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable(['game_result_id', 'player_id', 'points', 'assists', 'rebounds', 'fouls'])]
class PlayerStat extends Model
{
    use HasFactory;

    public function gameResult(): BelongsTo
    {
        return $this->belongsTo(GameResult::class);
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }
}
