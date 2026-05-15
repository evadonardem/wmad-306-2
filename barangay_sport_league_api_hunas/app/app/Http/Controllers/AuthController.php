<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Handle account registration.
     */
    public function register(Request $request): JsonResponse
    {
        $fields = $request->validate([
            'name'     => ['required', 'string', 'max:255'],
            'email'    => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $account = User::create([
            'name'     => $fields['name'],
            'email'    => $fields['email'],
            'password' => Hash::make($fields['password']),
        ]);

        return response()->json([
            'user'  => $account,
            'token' => $account->createToken('auth_token')->plainTextToken,
        ], 201);
    }

    /**
     * Authenticate user and generate token.
     */
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email'    => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if (!Auth::attempt($credentials)) {
            return response()->json([
                'message' => 'The provided credentials do not match our records.'
            ], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'user_profile' => $user,
        ]);
    }

    /**
     * Terminate the current session.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->tokens()->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Session terminated successfully.'
        ]);
    }
}