<?php

namespace App\Policies;

use App\Models\League;
use App\Models\User;

class LeaguePolicy
{
    public function view(User $user, League $league): bool
    {
        return $user->id === $league->user_id;
    }

    public function update(User $user, League $league): bool
    {
        return $user->id === $league->user_id;
    }

    public function delete(User $user, League $league): bool
    {
        return $user->id === $league->user_id;
    }
}
