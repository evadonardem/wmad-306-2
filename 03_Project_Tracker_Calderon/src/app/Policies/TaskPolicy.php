<?php

namespace App\Policies;

use App\Models\Task;
use App\Models\User;

class TaskPolicy
{
    /**
     * Any authenticated user can view their tasks list.
     */
    public function viewAny(User $user): bool
    {
        return true;
    }

    /**
     * Only owners of the parent project can view the task.
     */
    public function view(User $user, Task $task): bool
    {
        return $user->id === $task->project->user_id;
    }

    /**
     * Any authenticated user can create a task (project ownership checked in controller).
     */
    public function create(User $user): bool
    {
        return true;
    }

    public function update(User $user, Task $task): bool
    {
        return $user->id === $task->project->user_id;
    }

    public function delete(User $user, Task $task): bool
    {
        return $user->id === $task->project->user_id;
    }

    public function restore(User $user, Task $task): bool
    {
        return $user->id === $task->project->user_id;
    }

    public function forceDelete(User $user, Task $task): bool
    {
        return $user->id === $task->project->user_id;
    }
}
