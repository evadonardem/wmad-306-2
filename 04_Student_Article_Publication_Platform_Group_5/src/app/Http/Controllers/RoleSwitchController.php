<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RoleSwitchController extends Controller
{
    public function switchRole($role)
    {
        $user = Auth::user();

        $allowedRoles = ['writer', 'editor', 'student'];
        if (!in_array($role, $allowedRoles, true)) {
            return redirect()->back()->with('error', 'Invalid role specified.');
        }
        
        if (!$user->hasRole($role)) {
            $user->assignRole($role);
        }

        // Redirect to appropriate dashboard based on role
        switch ($role) {
            case 'writer':
                return redirect()->route('writer.dashboard');
            case 'editor':
                return redirect()->route('editor.dashboard');
            case 'student':
                return redirect()->route('student.dashboard');
            default:
                return redirect('/')->with('error', 'Invalid role specified.');
        }
    }
}
