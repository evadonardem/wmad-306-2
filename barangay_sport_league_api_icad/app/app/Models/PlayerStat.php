<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlayerStat extends Model
{
    protected $fillable = ['game_id', 'player_id', 'points', 'rebounds', 'assists'];

    public function game()
    {
        return $this->belongsTo(Game::class);
    }

    public function player()
    {
        return $this->belongsTo(Player::class);
    }
}
