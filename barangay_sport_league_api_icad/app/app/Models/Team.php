<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Team extends Model
{
    protected $fillable = ['season_id', 'name', 'coach'];

    public function season()
    {
        return $this->belongsTo(Season::class);
    }

    // Many-to-Many relationship with Players (Task 5.3)
    public function players()
    {
        return $this->belongsToMany(Player::class)->withPivot('jersey_number')->withTimestamps();
    }

    public function homeGames() {
        return $this->hasMany(Game::class, 'home_team_id');
    }

    public function awayGames() {
        return $this->hasMany(Game::class, 'away_team_id');
    }
}
