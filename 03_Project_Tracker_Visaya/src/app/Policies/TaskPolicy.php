<?php

namespace App\Policies;

use App\Models\Task;
use App\Models\User;
use App\Models\Project;

class TaskPolicy
{
    /**
     * Determine whether the user can view the task.
     */
    public function view(User $user, Task $task): bool
    {
        return $user->getKey() === $task->project->user_id;
    }

    /**
     * Determine whether the user can create a task for the given project.
     */
    public function create(User $user, Project $project): bool
    {
        return $user->getKey() === $project->user_id;
    }

    /**
     * Determine whether the user can update the task.
     */
    public function update(User $user, Task $task): bool
    {
        return $user->getKey() === $task->project->user_id;
    }

    /**
     * Determine whether the user can delete the task.
     */
    public function delete(User $user, Task $task): bool
    {
        return $user->getKey() === $task->project->user_id;
    }
}
