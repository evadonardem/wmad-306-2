<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class League extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 
        'sport', 
        'description'
    ];

   
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

   
    public function seasons(): HasMany
    {
        return $this->hasMany(Season::class);
    }

   
    public function getIsActiveAttribute(): bool
    {
        return $this->seasons()->where('status', 'active')->exists();
    }
}