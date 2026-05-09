<?php

namespace App\Http\Controllers;

use App\Models\User;

class UserController extends Controller
{
    /**
     * Display a listing of the users.
     */
    public function index()
    {
        // Fetch all users from the database
        $users = User::all();

        // Return view with users data
        return view('users', ['users' => $users]);
    }
}
