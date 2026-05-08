<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

#[Fillable(['name', 'birthdate', 'position'])]
class Player extends Model
{
    use HasFactory;

    protected $casts = [
        'birthdate' => 'date',
    ];

    public function teams(): BelongsToMany
    {
        return $this->belongsToMany(Team::class, 'player_team')
            ->withPivot('jersey_number');
    }

    public function stats()
    {
        return $this->hasMany(PlayerStat::class);
    }
}
