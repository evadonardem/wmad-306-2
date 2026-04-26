<?php

namespace App\Http\Controllers\Writer;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Inertia\Inertia;

class DashboardController extends Controller
{
    /**
     * Redirect users to their specific dashboards based on their roles.
     */
    public function index()
{
    $user = auth()->user();

    // Check for both 'Editor' and 'editor'
    if ($user->hasRole('Editor') || $user->hasRole('editor')) {
        return redirect()->route('editor.dashboard');
    }

    // FIX: Check for both 'Student' and 'student'
    if ($user->hasRole('Student') || $user->hasRole('student')) {
        return redirect()->route('student.dashboard');
    }

    // Default for Writers
    $articles = $user->articles()->with(['status', 'category'])->get();

    // Ensure this path points to your folder
    return Inertia::render('Writer/Dashboard', [
        'articles' => $articles
    ]);
}
}