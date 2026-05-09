<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Player extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'birthdate', 'position'];

    public function teams(): BelongsToMany
    {
        return $this->belongsToMany(Team::class, 'player_team')
                    ->withPivot('jersey_number')
                    ->withTimestamps();
    }

    public function stats()
    {
        return $this->hasMany(PlayerStat::class);
    }
}
