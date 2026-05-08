<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Models\Team;
use App\Models\PlayerStat;

class Player extends Model
{
    protected $fillable = ['name'];

    public function teams(): BelongsToMany
    {
        return $this->belongsToMany(Team::class)
            ->withPivot('jersey_number');
    }

    public function stats(): HasMany
    {
        return $this->hasMany(PlayerStat::class);
    }

    public function totalPoints(): int
    {
        return (int) $this->stats()->sum('points');
    }
}
