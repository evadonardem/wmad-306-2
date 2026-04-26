<?php
namespace App\Policies;
use App\Models\Project;
use App\Models\User;

class ProjectPolicy
{
    public function viewAny(User $u): bool { return true; }
    public function view(User $u, Project $p): bool { return $u->id === $p->user_id; }
    public function create(User $u): bool { return true; }
    public function update(User $u, Project $p): bool { return $u->id === $p->user_id; }
    public function delete(User $u, Project $p): bool { return $u->id === $p->user_id; }
}