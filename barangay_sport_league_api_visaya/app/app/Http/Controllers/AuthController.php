<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // POST /api/register
    public function register(Request $request)
    {
        // 1. Check if the user sent the correct data
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|email|unique:users',
            'password' => 'required|confirmed|min:8', // 'confirmed' means it checks for password_confirmation!
        ]);

        // 2. Save the new user to the database
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password), // Always hide passwords using Hash!
        ]);

        // 3. Create the Sanctum keycard (Token)
        $token = $user->createToken('api-token')->plainTextToken;

        // 4. Return the user and the token (Status 201 means "Created")
        return response()->json(['token' => $token, 'user' => $user], 201);
    }

    // POST /api/login (This matches section 6.2 perfectly!)
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json(['token' => $token, 'user' => $user]);
    }

    // POST /api/logout
    public function logout(Request $request)
    {
        // Destroy the current keycard
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Successfully logged out']);
    }
}