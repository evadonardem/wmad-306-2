<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Player extends Model
{
    //// Player.php
public function teams() {
    return $this->belongsToMany(Team::class)
        ->withPivot('jersey_number');
}
}
