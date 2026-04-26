<?php

namespace App\Http\Middleware;

use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that is loaded on the first page visit.
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determine the current asset version.
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        $user = $request->user();
        $roleNames = $user
            ? $user->getRoleNames()->map(static fn ($role) => strtolower((string) $role))->values()->all()
            : [];
        $legacyRole = strtolower((string) ($user?->getAttribute('role') ?? ''));
        $rolePriority = ['admin', 'editor', 'writer', 'student'];
        $primaryRole = 'student';

        if ($legacyRole !== '') {
            $primaryRole = $legacyRole;
        } elseif (! empty($roleNames)) {
            foreach ($rolePriority as $role) {
                if (in_array($role, $roleNames, true)) {
                    $primaryRole = $role;
                    break;
                }
            }

            if ($primaryRole === 'student') {
                $primaryRole = $roleNames[0];
            }
        }

        return [
            ...parent::share($request),
            'auth' => [
                'user' => $user ? [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $primaryRole,
                    'roles' => array_map(
                        static fn ($role) => ['name' => $role],
                        $roleNames
                    ),
                ] : null,
            ],
        ];
    }
}
