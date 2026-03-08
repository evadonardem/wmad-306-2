<?php

namespace App\Http\Controllers;

use App\Models\RoleRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class RoleRequestController extends Controller
{
    /**
     * STUDENT: Submit a request to become a writer or editor.
     */
    public function store(Request $request)
    {
        $request->validate([
            'role_name' => 'required|in:writer,editor,student',
            'request_type' => 'nullable|in:add,switch,step_down',
            'justification' => 'required|string|max:1000',
        ]);

        $user = Auth::user();
        $requestType = $request->input('request_type', 'add');
        $targetRole = $request->role_name;

        if ($requestType === 'step_down' && $targetRole !== 'student') {
            return back()->with('error', 'Step-down requests must target the student role.');
        }

        if ($requestType !== 'step_down' && $targetRole === 'student') {
            return back()->with('error', 'Student role is only valid for step-down requests.');
        }

        $hasWriterOrEditorRole = $user->hasRole('writer') || $user->hasRole('editor');

        if ($requestType === 'step_down' && ! $hasWriterOrEditorRole) {
            return back()->with('error', 'You can only step down if you currently hold a writer or editor role.');
        }

        if ($requestType === 'switch' && ! $hasWriterOrEditorRole) {
            return back()->with('error', 'Switch requests are only available to writer/editor staff.');
        }

        if ($requestType === 'add' && $targetRole === 'student') {
            return back()->with('error', 'You are already part of the student role.');
        }

        // Prevent duplicate pending requests for same action/target.
        $alreadyHasPending = RoleRequest::where('user_id', $user->id)
            ->where('role_name', $targetRole)
            ->where('request_type', $requestType)
            ->where('status', 'pending')
            ->exists();

        if ($alreadyHasPending) {
            return back()->with('error', 'You already have a pending request for this action.');
        }

        if ($requestType === 'add' && $user->hasRole($targetRole)) {
            return back()->with('error', "You already have the {$targetRole} role.");
        }

        if ($requestType === 'switch' && $user->hasRole($targetRole) && ! $user->hasRole($targetRole === 'writer' ? 'editor' : 'writer')) {
            return back()->with('error', "You are already assigned as {$targetRole}.");
        }

        RoleRequest::create([
            'user_id' => $user->id,
            'role_name' => $targetRole,
            'request_type' => $requestType,
            'justification' => $request->justification,
            'status' => 'pending',
        ]);

        return back()->with('success', 'Your application has been submitted successfully and is pending review.');
    }

    /**
     * SUPER ADMIN: View all pending requests.
     */
    public function index()
    {
        $pendingRequests = RoleRequest::with('user')
            ->where('status', 'pending')
            ->latest()
            ->get();

        $manageableUsers = User::query()
            ->with('roles:id,name')
            ->whereHas('roles', fn ($query) => $query->whereIn('name', ['student', 'writer', 'editor']))
            ->orderBy('name')
            ->get();

        // FIX #2: Updated this string to exactly match your React file: Admin/RoleRequests
        return Inertia::render('Admin/RoleRequests', [
            'pendingRequests' => $pendingRequests,
            'manageableUsers' => $manageableUsers,
        ]);
    }

    /**
     * SUPER ADMIN: Approve a request.
     */
    public function approve(RoleRequest $roleRequest)
    {
        if ($roleRequest->status !== 'pending') {
            return back()->with('error', 'This request has already been processed.');
        }

        $targetUser = $roleRequest->user;
        $targetRole = $roleRequest->role_name;
        $requestType = $roleRequest->request_type ?? 'add';

        if ($requestType === 'step_down') {
            $targetUser->removeRole('writer');
            $targetUser->removeRole('editor');
            if (! $targetUser->hasRole('student')) {
                $targetUser->assignRole('student');
            }
        } elseif ($requestType === 'switch') {
            $rolesToDrop = collect(['writer', 'editor'])->reject(fn (string $role) => $role === $targetRole);
            foreach ($rolesToDrop as $roleToDrop) {
                $targetUser->removeRole($roleToDrop);
            }

            if (! $targetUser->hasRole($targetRole)) {
                $targetUser->assignRole($targetRole);
            }
        } else {
            if (! $targetUser->hasRole($targetRole)) {
                $targetUser->assignRole($targetRole);
            }
        }

        // 1. Mark as approved and record who did it
        $roleRequest->update([
            'status' => 'approved',
            'actioned_by' => Auth::id(),
        ]);

        if ($requestType === 'step_down') {
            return back()->with('success', "Request approved. {$targetUser->name} has stepped down to student.");
        }

        if ($requestType === 'switch') {
            return back()->with('success', "Request approved. {$targetUser->name} has switched to {$targetRole}.");
        }

        return back()->with('success', "Application approved. {$targetUser->name} now also has the {$targetRole} role.");
    }

    /**
     * SUPER ADMIN: Reject a request.
     */
    public function reject(RoleRequest $roleRequest)
    {
        if ($roleRequest->status !== 'pending') {
            return back()->with('error', 'This request has already been processed.');
        }

        $roleRequest->update([
            'status' => 'rejected',
            'actioned_by' => Auth::id(),
        ]);

        return back()->with('success', 'Application has been rejected.');
    }

    /**
     * SUPER ADMIN: Remove a role directly from a user.
     */
    public function removeRole(Request $request, User $user)
    {
        $validated = $request->validate([
            'role_name' => ['required', 'in:student,writer,editor'],
        ]);

        $roleName = $validated['role_name'];

        if (! $user->hasRole($roleName)) {
            return back()->with('error', "{$user->name} does not currently have the {$roleName} role.");
        }

        if (
            $roleName === 'student'
            && ! $user->hasRole('writer')
            && ! $user->hasRole('editor')
            && ! $user->hasAnyRole(['superadmin', 'super-admin'])
        ) {
            return back()->with('error', "Cannot remove student from {$user->name}; they must keep at least one platform role.");
        }

        $user->removeRole($roleName);

        if (
            ! $user->hasAnyRole(['student', 'writer', 'editor'])
            && ! $user->hasAnyRole(['superadmin', 'super-admin'])
        ) {
            $user->assignRole('student');

            return back()->with('success', "Removed {$roleName} from {$user->name}. Student role was auto-assigned to keep account access.");
        }

        return back()->with('success', "Removed {$roleName} role from {$user->name}.");
    }
}
