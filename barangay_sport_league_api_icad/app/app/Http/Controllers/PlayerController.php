<?php

namespace App\Http\Controllers;

use App\Models\Player;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    public function index()
    {
        return response()->json(Player::all());
    }

    public function store(Request $request)
    {
        $fields = $request->validate([
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'birth_date' => 'required|date',
        ]);

        $player = Player::create($fields);

        return response()->json($player, 201);
    }
}