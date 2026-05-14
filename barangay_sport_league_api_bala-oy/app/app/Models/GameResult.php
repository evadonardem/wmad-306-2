<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GameResult extends Model
{
    use HasFactory;

    protected $table = 'game_results';
    protected $fillable = ['game_id', 'home_score', 'away_score'];

    /**
     * Get the game this result belongs to.
     */
    public function game(): BelongsTo
    {
        return $this->belongsTo(Game::class);
    }

    /**
     * Get all player stats for this game result.
     */
    public function playerStats(): HasMany
    {
        return $this->hasMany(PlayerStat::class);
    }
}
