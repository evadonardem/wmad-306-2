<?php

namespace App\Http\Controllers;

use Inertia\Inertia;

class UserController extends Controller
{
    public function index()
    {
        return Inertia::render('Pages/Users/List');
    }
}
