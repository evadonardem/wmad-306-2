<?php
namespace App\Policies;
use App\Models\Task;
use App\Models\User;

class TaskPolicy
{
    public function viewAny(User $u): bool { return true; }
    public function update(User $u, Task $t): bool { return $u->id === $t->project->user_id; }
    public function delete(User $u, Task $t): bool { return $u->id === $t->project->user_id; }
}