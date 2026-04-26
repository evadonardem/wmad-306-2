<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;
use Inertia\Inertia;
use Inertia\Response;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RegisteredUserController extends Controller
{
    /**
     * Display the registration view.
     */
    public function create(): Response
    {
        return Inertia::render('Auth/Register');
    }

    /**
     * Handle an incoming registration request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:'.User::class,
            'role' => 'required|string|in:writer,editor,student',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        // Ensure the role exists in the permissions table and assign it to the user
        try {
            if (! Role::where('name', $request->role)->exists()) {
                Role::create(['name' => $request->role]);
                // Clear Spatie permission cache so middleware recognizes newly created roles immediately
                app(PermissionRegistrar::class)->forgetCachedPermissions();
            }
            $user->assignRole($request->role);
            // Also forget cache after assignment to be safe
            app(PermissionRegistrar::class)->forgetCachedPermissions();
        } catch (\Exception $e) {
            // If role assignment fails, log but don't block registration
            logger()->error('Role assignment failed for user '.$user->id.': '.$e->getMessage());
        }

        event(new Registered($user));

        Auth::login($user);

        // Redirect based on selected role
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
