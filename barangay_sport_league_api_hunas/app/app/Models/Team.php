<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Team extends Model
{
    use HasFactory;

    protected $guarded = ['id'];

    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class);
    }

    public function players(): BelongsToMany
    {
        return $this->belongsToMany(Player::class, 'player_team')
            ->withPivot('jersey_number')
            ->withTimestamps();
    }

    public function homeGames(): HasMany
    {
        return $this->hasMany(Game::class, 'home_team_id');
    }

    public function awayGames(): HasMany
    {
        return $this->hasMany(Game::class, 'away_team_id');
    }

    public function getAllGamesAttribute(): Collection
    {
        return $this->homeGames->merge($this->awayGames);
    }

    public function getRosterCountAttribute(): int
    {
        return $this->players()->count();
    }
}