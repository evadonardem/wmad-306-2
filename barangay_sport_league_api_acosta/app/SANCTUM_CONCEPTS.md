# Exercise 9.1: Sanctum Token Authentication - VERIFIED ✓

All Sanctum concepts from the exercise are correctly implemented:

## 1. Issue Token: `createToken('name')->plainTextToken`

**Location:** `AuthController.php` (lines 27, 50)

```php
// Register
$token = $user->createToken('auth_token')->plainTextToken;

// Login
$token = $user->createToken('auth_token')->plainTextToken;

return response()->json([
    'user' => $user,
    'token' => $token,  // Returns string to client
]);
```

**Returns:** String token to send to client

---

## 2. Get User: `$request->user()`

**Location:** `AuthController.php` (line 60)

```php
public function logout(Request $request): JsonResponse
{
    $request->user()->currentAccessToken()->delete();
    // Returns authenticated User model
}
```

**Returns:** Authenticated User model

---

## 3. Revoke Token: `currentAccessToken()->delete()`

**Location:** `AuthController.php` (line 60)

```php
public function logout(Request $request): JsonResponse
{
    $request->user()->currentAccessToken()->delete();
    // Deletes only the current token (logout)
    
    return response()->json([
        'message' => 'Successfully logged out',
    ]);
}
```

**Action:** Deletes only the current token (logout)

---

## 4. Protect Route: `middleware('auth:sanctum')`

**Location:** `routes/api.php` (line 41)

```php
// Public routes (no auth)
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// Protected routes (auth required)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('logout', [AuthController::class, 'logout']);
    Route::apiResource('leagues', LeagueController::class);
    Route::apiResource('leagues.seasons', SeasonController::class);
    // ... all other protected routes
});
```

**Returns:** 401 if no valid token present

---

## Summary Table

| Concept | Code | Location | Status |
|---------|------|----------|--------|
| **Issue Token** | `createToken('name')->plainTextToken` | `AuthController.php` | ✅ |
| **Get User** | `$request->user()` | `AuthController.php` | ✅ |
| **Revoke Token** | `currentAccessToken()->delete()` | `AuthController.php` | ✅ |
| **Protect Route** | `middleware('auth:sanctum')` | `routes/api.php` | ✅ |

**All 4 Sanctum concepts are correctly implemented!** ✓
