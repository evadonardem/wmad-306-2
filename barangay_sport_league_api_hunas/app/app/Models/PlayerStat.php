<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class PlayerStat extends Model
{
    use HasFactory;

    protected $guarded = ['id'];

    protected $casts = [
        'points'   => 'integer',
        'assists'  => 'integer',
        'rebounds' => 'integer',
        'fouls'    => 'integer',
    ];

    public function gameResult(): BelongsTo
    {
        return $this->belongsTo(GameResult::class);
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class);
    }

    protected function contributionScore(): Attribute
    {
        return Attribute::make(
            get: fn () => $this->points + $this->assists + $this->rebounds
        );
    }
}