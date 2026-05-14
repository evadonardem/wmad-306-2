<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Player extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'birthdate', 'position'];

    protected $casts = [
        'birthdate' => 'date',
    ];

    /**
     * Get all teams this player belongs to.
     */
    public function teams(): BelongsToMany
    {
        return $this->belongsToMany(Team::class, 'player_team')
            ->withPivot('jersey_number');
    }

    /**
     * Get all stats for this player.
     */
    public function stats(): HasMany
    {
        return $this->hasMany(PlayerStat::class);
    }
}
