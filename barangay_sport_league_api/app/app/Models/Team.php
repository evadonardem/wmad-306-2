<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Team extends Model
{
    //// Team.php
public function players() {
    return $this->belongsToMany(Player::class)
        ->withPivot('jersey_number');
}
}
