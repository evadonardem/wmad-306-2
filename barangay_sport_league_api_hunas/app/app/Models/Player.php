<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Player extends Model
{
    use HasFactory;

    protected $casts = [
        'birthdate' => 'date',
    ];

   
    
    public function teams(): BelongsToMany
    {
        return $this->belongsToMany(Team::class, 'player_team')
            ->withPivot('jersey_number')
            ->withTimestamps();
    }

   
    public function stats(): HasMany
    {
        return $this->hasMany(PlayerStat::class);
    }

   
    protected function age(): Attribute
    {
        return Attribute::make(
            get: fn () => $this->birthdate ? $this->birthdate->age : null,
        );
    }
}