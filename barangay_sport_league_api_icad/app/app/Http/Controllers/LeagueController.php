<?php

namespace App\Http\Controllers;

use App\Models\League;
use Illuminate\Http\Request;

class LeagueController extends Controller
{
    /**
     * Task 5.1: Return only leagues belonging to the authenticated user.
     */
    public function index(Request $request)
    {
        return $request->user()->leagues;
    }

    /**
     * Task 5.1: Store a league and link it to the user.
     */
    public function store(Request $request)
    {
        $fields = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string'
        ]);

        // This automatically sets the user_id based on the token
        $league = $request->user()->leagues()->create($fields);

        return response()->json($league, 201);
    }

    /**
     * Display a specific league.
     */
    public function show(League $league)
    {
        // Security check: Only the owner can view
        if ($league->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return $league->load('seasons');
    }
}