<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GameResult extends Model
{
    protected $fillable = ['game_id', 'home_team_score', 'away_team_score'];

    public function game()
    {
        return $this->belongsTo(Game::class);
    }
}
