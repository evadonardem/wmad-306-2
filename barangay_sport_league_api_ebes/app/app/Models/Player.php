<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Player extends Model
{
    protected $fillable = ['name', 'birthdate', 'position'];

    public function teams(): BelongsToMany {
        return $this->belongsToMany(Team::class, 'player_team')
                    ->withPivot('jersey_number');
    }

    public function stats(): HasMany {
        return $this->hasMany(PlayerStat::class);
    }
}