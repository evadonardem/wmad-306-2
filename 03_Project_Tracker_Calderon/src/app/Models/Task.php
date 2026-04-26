<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    /** @use HasFactory<\Database\Factories\TaskFactory> */
    use HasFactory;

    protected $fillable = [
        'project_id',
        'title',
        'description',
        'priority',
        'status',
        'due_date',
    ];

    protected $casts = [
        'due_date' => 'date',
    ];

    public const PRIORITIES = [
        'less important' => 'Less Important',
        'important' => 'Important',
        'very important' => 'Very Important',
    ];

    public const STATUSES = [
        'pending' => 'Pending',
        'on going' => 'On Going',
        'completed' => 'Completed',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function getPriorityColorAttribute()
    {
        return match($this->priority) {
            'very important' => 'error',
            'important' => 'warning',
            'less important' => 'success',
            default => 'default',
        };
    }

    public function getStatusColorAttribute()
    {
        return match($this->status) {
            'completed' => 'success',
            'on going' => 'info',
            'pending' => 'default',
            default => 'default',
        };
    }

    public function getDueDateStatusAttribute()
    {
        if (!$this->due_date) {
            return null;
        }

        $today = now()->startOfDay();
        $dueDate = \Carbon\Carbon::parse($this->due_date)->startOfDay();

        if ($dueDate < $today) {
            return 'overdue';
        } elseif ($dueDate->eq($today)) {
            return 'due-today';
        } elseif ($dueDate->diffInDays($today) <= 3) {
            return 'due-soon';
        }

        return 'normal';
    }
}
