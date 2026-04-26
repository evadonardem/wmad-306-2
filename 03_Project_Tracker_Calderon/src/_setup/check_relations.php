<?php

require __DIR__ . '/../vendor/autoload.php';
$app = require_once __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Project;
use App\Models\Task;

echo "--- Relation & persistence check ---\n";

echo "Users: " . User::count() . "\n";

$user = User::first();
if (! $user) {
    echo "FAIL: no users present\n";
    exit(1);
}

echo "First user: id={$user->id} email={$user->email} projects_count=" . $user->projects()->count() . "\n";

$projects = $user->projects;
if ($projects->isEmpty()) {
    echo "NOTE: user has no projects\n";
} else {
    foreach ($projects as $p) {
        echo "Project id={$p->id} title={$p->title} tasks_count=" . $p->tasks()->count() . "\n";
    }
}

$project = Project::first();
if (! $project) {
    echo "FAIL: no projects present\n";
    exit(1);
}

echo "First project id={$project->id} title={$project->title}\n";

$tasks = $project->tasks;
echo "Tasks on project: " . $tasks->count() . "\n";
foreach ($tasks as $t) {
    echo "Task id={$t->id} title={$t->title} priority={$t->priority} status={$t->status}\n";
}

$task = Task::first();
if (! $task) {
    echo "FAIL: no tasks present\n";
    exit(1);
}

echo "Updating first task (id={$task->id}) status -> done, priority -> 3\n";
$task->status = 'done';
$task->priority = 3;
$task->save();

$reloaded = Task::find($task->id);
echo "Reloaded task: id={$reloaded->id} status={$reloaded->status} priority={$reloaded->priority}\n";

if ($reloaded->status === 'done' && (int) $reloaded->priority === 3) {
    echo "OK: status and priority persisted\n";
    exit(0);
}

echo "FAIL: status/priority did not persist\n";
exit(1);
