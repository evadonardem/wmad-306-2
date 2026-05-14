<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PlayerStat extends Model
{
    use HasFactory;

    protected $table = 'player_stats';
    protected $fillable = ['game_result_id', 'player_id', 'points', 'assists', 'rebounds', 'fouls'];

    /**
     * Get the game result this stat belongs to.
     */
    public function gameResult(): BelongsTo
    {
        return $this->belongsTo(GameResult::class);
    }

    /**
     * Get the player for this stat.
     */
    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }
}
