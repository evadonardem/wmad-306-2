<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TeamResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'season_id' => $this->season_id,
            'name' => $this->name,
            'coach' => $this->coach,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'players' => PlayerResource::collection($this->whenLoaded('players')),
        ];
    }
}
