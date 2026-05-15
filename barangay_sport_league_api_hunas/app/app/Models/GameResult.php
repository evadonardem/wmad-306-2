<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class GameResult extends Model
{
    use HasFactory;

    protected $guarded = ['id'];

  

    
    public function game(): BelongsTo
    {
        return $this->belongsTo(Game::class);
    }

    
    public function playerStats(): HasMany
    {
        return $this->hasMany(PlayerStat::class);
    }

   

    /**
     * Get the total points scored in the game.
     * Usage: $gameResult->total_score
     */
    protected function totalScore(): Attribute
    {
        return Attribute::make(
            get: fn () => $this->home_score + $this->away_score,
        );
    }

    protected function margin(): Attribute
    {
        return Attribute::make(
            get: fn () => abs($this->home_score - $this->away_score),
        );
    }
}