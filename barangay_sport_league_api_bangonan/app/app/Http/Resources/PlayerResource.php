<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PlayerResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'birthdate' => $this->birthdate,
            'position' => $this->position,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'pivot' => $this->when($this->pivot !== null, function () {
                return [
                    'team_id' => $this->pivot->team_id ?? null,
                    'player_id' => $this->pivot->player_id ?? null,
                    'jersey_number' => $this->pivot->jersey_number ?? null,
                ];
            }),
        ];
    }
}
