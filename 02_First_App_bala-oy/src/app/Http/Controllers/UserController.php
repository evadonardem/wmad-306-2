<?php

namespace App\Http\Controllers;

use App\Models\User;
use Inertia\Inertia;

class UserController extends Controller
{
    /**
     * Display a listing of the users.
     */
    public function index()
    {
        $users = User::orderBy('id')
            ->get(['id', 'name', 'email', 'created_at']);

        return Inertia::render('Users', [
            'users' => $users,
        ]);
    }
}
