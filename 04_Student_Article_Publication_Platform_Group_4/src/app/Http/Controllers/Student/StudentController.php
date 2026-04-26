<?php

namespace App\Http\Controllers\Student;

use App\Http\Controllers\Controller;
use App\Models\Article;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class StudentController extends Controller
{
    /**
     * Display the student library.
     */
    public function index(): Response
    {
        // Fetch published articles (status_id 3) with author and category info
        $articles = Article::where('status_id', 3)
            ->with(['user', 'category'])
            ->latest()
            ->get();

        // This 'Student/Dashboard' path fixes the "Page not found" error
        // It tells Inertia to look for: resources/js/Pages/Student/Dashboard.jsx
        return Inertia::render('Student/Dashboard', [
            'articles' => $articles
        ]);
    }
}