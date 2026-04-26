<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class RedirectIfAuthenticated
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // If user is not authenticated, allow access to login/register
        if (!Auth::check()) {
            return $next($request);
        }

        // User is authenticated, redirect to appropriate dashboard based on role
        $user = Auth::user();
        
        if ($user->role === 'writer') {
            return redirect(route('writer.dashboard', absolute: false));
        } elseif ($user->role === 'editor') {
            return redirect(route('editor.dashboard', absolute: false));
        } else {
            // Default to student/reader dashboard
            return redirect(route('student.dashboard', absolute: false));
        }
    }
}
