<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string $role): Response
    {
        if (!auth()->check()) {
            return redirect()->route('login');
        }

        $user = auth()->user();

        // Check if user has the required role
        // Allow if user has the Spatie role OR the legacy `role` column matches.
        $hasSpatieRole = method_exists($user, 'hasRole') && $user->hasRole($role);
        $hasLegacyRole = isset($user->role) && strtolower($user->role) === strtolower($role);

        if ($hasSpatieRole || $hasLegacyRole) {
            return $next($request);
        }

        abort(403, 'Unauthorized access.');
    }
}
