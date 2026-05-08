<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Models\Game;
use App\Models\Player;

class Team extends Model
{
    protected $fillable = ['name'];

    public function players(): BelongsToMany
    {
        return $this->belongsToMany(Player::class)
            ->withPivot('jersey_number');
    }

    public function homeGames(): HasMany
    {
        return $this->hasMany(Game::class, 'home_team_id');
    }

    public function awayGames(): HasMany
    {
        return $this->hasMany(Game::class, 'away_team_id');
    }

    public function wins(): int
    {
        return $this->homeGames()
                ->where('status', 'done')
                ->whereHas('result', function ($query) {
                    $query->whereColumn('home_score', '>', 'away_score');
                })
                ->count()
            + $this->awayGames()
                ->where('status', 'done')
                ->whereHas('result', function ($query) {
                    $query->whereColumn('away_score', '>', 'home_score');
                })
                ->count();
    }

    public function losses(): int
    {
        return $this->homeGames()
                ->where('status', 'done')
                ->whereHas('result', function ($query) {
                    $query->whereColumn('home_score', '<', 'away_score');
                })
                ->count()
            + $this->awayGames()
                ->where('status', 'done')
                ->whereHas('result', function ($query) {
                    $query->whereColumn('away_score', '<', 'home_score');
                })
                ->count();
    }

    public static function standings()
    {
        return static::all()->sortByDesc(function (Team $team) {
            return $team->wins();
        })->values();
    }
}
