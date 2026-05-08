<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GameResultResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'game_id' => $this->game_id,
            'home_score' => $this->home_score,
            'away_score' => $this->away_score,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'player_stats' => PlayerStatResource::collection($this->whenLoaded('playerStats')),
        ];
    }
}
