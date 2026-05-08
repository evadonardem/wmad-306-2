<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['points', 'assists', 'rebounds', 'fouls'])]
class PlayerStat extends Model
{
    use HasFactory;

    public function gameResult()
    {
        return $this->belongsTo(GameResult::class);
    }

    public function player()
    {
        return $this->belongsTo(Player::class);
    }
}
