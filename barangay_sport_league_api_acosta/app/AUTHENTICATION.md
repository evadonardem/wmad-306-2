# Exercise 6: Authentication with Laravel Sanctum

## 6.1 Auth Endpoints - IMPLEMENTED ✓

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| POST | `/api/register` | Register new admin user. Returns user + token. | ✅ Public |
| POST | `/api/login` | Authenticate and receive Sanctum API token. | ✅ Public |
| POST | `/api/logout` | Revoke the current token. Requires auth. | ✅ Protected |

## 6.2 Token Flow - IMPLEMENTED ✓

### Login Implementation (`AuthController.php`)
```php
public function login(Request $request): JsonResponse
{
    $validated = $request->validate([
        'email' => 'required|string|email',
        'password' => 'required|string',
    ]);

    $user = User::where('email', $validated['email'])->first();

    if (!$user || !Hash::check($validated['password'], $user->password)) {
        throw ValidationException::withMessages([
            'email' => ['The provided credentials are incorrect.'],
        ]);
    }

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'user' => $user,
        'token' => $token,
    ]);
}
```

**Key Points:**
- ✅ `createToken()` called on authenticated user
- ✅ Returns `plainTextToken` in response
- ✅ Client stores token and sends with subsequent requests via `Authorization: Bearer {token}` header

### Register Implementation
```php
public function register(Request $request): JsonResponse
{
    $validated = $request->validate([
        'name' => 'required|string|max:255',
        'email' => 'required|string|email|max:255|unique:users',
        'password' => 'required|string|min:8|confirmed',
    ]);

    $user = User::create([
        'name' => $validated['name'],
        'email' => $validated['email'],
        'password' => Hash::make($validated['password']),
    ]);

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'user' => $user,
        'token' => $token,
    ], 201);
}
```

### Logout Implementation
```php
public function logout(Request $request): JsonResponse
{
    $request->user()->currentAccessToken()->delete();

    return response()->json([
        'message' => 'Successfully logged out',
    ]);
}
```

## 6.3 Protecting Routes - IMPLEMENTED ✓

### Route Configuration (`routes/api.php`)
```php
// Public routes (no auth required)
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// Protected routes (auth required)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('logout', [AuthController::class, 'logout']);
    
    Route::apiResource('leagues', LeagueController::class);
    Route::apiResource('leagues.seasons', SeasonController::class);
    Route::apiResource('leagues.seasons.teams', TeamController::class);
    Route::apiResource('leagues.seasons.teams.players', PlayerController::class);
    Route::apiResource('leagues.seasons.games', GameController::class);
    Route::post('leagues/{league}/seasons/{season}/games/{game}/result', [GameController::class, 'submitResult']);
    Route::get('leagues/{league}/seasons/{season}/standings', [StandingsController::class, 'index']);
    Route::get('leagues/{league}/seasons/{season}/leaderboard', [StatsController::class, 'playerLeaderboard']);
    Route::get('leagues/{league}/seasons/{season}/top-scorers', [StatsController::class, 'topScorers']);
    Route::get('leagues/{league}/seasons/{season}/stats', [StatsController::class, 'gameStats']);
});
```

**Key Points:**
- ✅ All endpoints except `register` and `login` are protected with `auth:sanctum` middleware
- ✅ Routes wrapped in `Route::middleware('auth:sanctum')->group()`

## User Model Setup (`app/Models/User.php`)

```php
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;
    // ...
}
```

- ✅ `HasApiTokens` trait added for `createToken()` method

## Testing with Postman

### 1. Register
```http
POST http://127.0.0.1:8000/api/register
Content-Type: application/json

{
    "name": "Barangay Captain",
    "email": "captain@barangay.ph",
    "password": "password123",
    "password_confirmation": "password123"
}
```

**Response:**
```json
{
    "user": { "id": 1, "name": "Barangay Captain", "email": "captain@barangay.ph" },
    "token": "1|abcdefghijklmnopqrstuvwxyz123456"
}
```

### 2. Login
```http
POST http://127.0.0.1:8000/api/login
Content-Type: application/json

{
    "email": "captain@barangay.ph",
    "password": "password123"
}
```

**Response:**
```json
{
    "user": { "id": 1, "name": "Barangay Captain", "email": "captain@barangay.ph" },
    "token": "1|abcdefghijklmnopqrstuvwxyz123456"
}
```

### 3. Access Protected Route
```http
GET http://127.0.0.1:8000/api/leagues
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz123456
Accept: application/json
```

### 4. Logout
```http
POST http://127.0.0.1:8000/api/logout
Authorization: Bearer 1|abcdefghijklmnopqrstuvwxyz123456
Accept: application/json
```

## Summary

| Requirement | Status |
|-------------|--------|
| `register` endpoint (public) | ✅ Implemented |
| `login` endpoint (public) | ✅ Implemented |
| `logout` endpoint (protected) | ✅ Implemented |
| `createToken()` returns plainTextToken | ✅ Implemented |
| `auth:sanctum` middleware on protected routes | ✅ Implemented |
| `HasApiTokens` trait on User model | ✅ Implemented |

**All Sanctum authentication requirements are complete!** ✓
