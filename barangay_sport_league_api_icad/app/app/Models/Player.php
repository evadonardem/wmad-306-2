<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Player extends Model
{
    use HasFactory;

    protected $fillable = ['first_name', 'last_name', 'birth_date'];

    /**
     * Relationship to Teams (Many-to-Many)
     * We include 'jersey_number' because it's stored in the pivot table.
     */
    public function teams()
    {
        return $this->belongsToMany(Team::class, 'player_team')
                    ->withPivot('jersey_number')
                    ->withTimestamps();
    }
}