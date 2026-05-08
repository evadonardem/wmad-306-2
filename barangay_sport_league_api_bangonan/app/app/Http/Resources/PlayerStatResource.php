<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PlayerStatResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'game_result_id' => $this->game_result_id,
            'player_id' => $this->player_id,
            'points' => $this->points,
            'assists' => $this->assists,
            'rebounds' => $this->rebounds,
            'fouls' => $this->fouls,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'player' => new PlayerResource($this->whenLoaded('player')),
        ];
    }
}
