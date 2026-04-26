<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\RoleRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Gate;
use Inertia\Inertia;

class AdminController extends Controller
{
    /**
     * Display the admin dashboard.
     */
    public function dashboard()
    {
        // Debug: Log current user
        \Log::info('Admin dashboard accessed by: ' . auth()->user()->email);
        \Log::info('User roles: ' . auth()->user()->roles->pluck('name')->join(', '));
        $stats = [
            'total_users' => User::count(),
            'students' => User::role('student')->count(),
            'writers' => User::role('writer')->count(),
            'editors' => User::role('editor')->count(),
            'pending_requests' => RoleRequest::pending()->count(),
        ];

        $recentUsers = User::latest()
            ->take(5)
            ->get(['id', 'name', 'email', 'created_at']);

        $pendingRequests = RoleRequest::with('user')
            ->pending()
            ->latest()
            ->take(10)
            ->get();

        return Inertia::render('Admin/Dashboard', [
            'stats' => $stats,
            'recentUsers' => $recentUsers,
            'pendingRequests' => $pendingRequests,
        ]);
    }

    /**
     * Display all users for management.
     */
    public function users()
    {
        // Debug: Log current user
        \Log::info('Admin users page accessed by: ' . auth()->user()->email);
        \Log::info('User roles: ' . auth()->user()->roles->pluck('name')->join(', '));
        
        $users = User::with('roles')
            ->latest()
            ->get();

        return Inertia::render('Admin/Users', [
            'users' => $users,
        ]);
    }

    /**
     * Update user role.
     */
    public function updateUserRole(Request $request, User $user)
    {
        $request->validate([
            'role' => 'required|in:student,writer,editor,admin',
        ]);

        // Remove all existing roles
        $user->roles()->detach();
        
        // Assign new role
        $user->assignRole($request->role);

        return back()->with('success', "User role updated to {$request->role} successfully.");
    }

    /**
     * Display all role requests.
     */
    public function roleRequests()
    {
        // Debug: Log current user
        \Log::info('Admin role requests page accessed by: ' . auth()->user()->email);
        \Log::info('User roles: ' . auth()->user()->roles->pluck('name')->join(', '));
        
        $requests = RoleRequest::with(['user', 'approvedBy'])
            ->latest()
            ->get();

        return Inertia::render('Admin/RoleRequests', [
            'requests' => $requests,
        ]);
    }

    /**
     * Approve a role request.
     */
    public function approveRoleRequest(RoleRequest $roleRequest)
    {
        Gate::authorize('manage-role-requests');

        $roleRequest->update([
            'status' => 'approved',
            'approved_by' => Auth::id(),
        ]);

        // Assign the requested role to the user
        $roleRequest->user->assignRole($roleRequest->requested_role);

        return back()->with('success', 'Role request approved successfully.');
    }

    /**
     * Reject a role request.
     */
    public function rejectRoleRequest(Request $request, RoleRequest $roleRequest)
    {
        Gate::authorize('manage-role-requests');

        $request->validate([
            'admin_notes' => 'nullable|string|max:500',
        ]);

        $roleRequest->update([
            'status' => 'rejected',
            'approved_by' => Auth::id(),
            'admin_notes' => $request->admin_notes,
        ]);

        return back()->with('success', 'Role request rejected.');
    }

    /**
     * Display user details.
     */
    public function userDetail(User $user)
    {
        $user->load(['roles', 'articles', 'roleRequests' => function($query) {
            $query->latest();
        }]);

        return Inertia::render('Admin/UserDetail', [
            'user' => $user,
        ]);
    }

    /**
     * Delete a user.
     */
    public function deleteUser(User $user)
    {
        Gate::authorize('delete-users');

        if ($user->id === Auth::id()) {
            return back()->with('error', 'You cannot delete your own account.');
        }

        $user->delete();

        return back()->with('success', 'User deleted successfully.');
    }
}
