<?php

namespace App\Policies;

use App\Models\Project;
use App\Models\User;

class ProjectPolicy
{
    public function viewAny(User $user): bool
    {
        return true; // authenticated users can view their projects list
    }

    public function view(User $user, Project $project): bool
    {
        return $user->id === $project->user_id;
    }

    public function create(User $user): bool
    {
        return true; // any logged-in user can create a project
    }

    public function update(User $user, Project $project): bool
    {
        return $user->id === $project->user_id;
    }

    public function delete(User $user, Project $project): bool
    {
        return $user->id === $project->user_id;
    }

    public function restore(User $user, Project $project): bool
    {
        return $user->id === $project->user_id;
    }

    public function forceDelete(User $user, Project $project): bool
    {
        return $user->id === $project->user_id;
    }
}
