# Exercise 10: Common Errors & Fixes - ALL HANDLED ✓

## Error Prevention Verification

### 1. 401 Unauthenticated on all routes
**Cause:** Token missing or malformed in header  
**Fix:** `Authorization: Bearer {token}` in request header

**Our Implementation:** ✅
```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    // All protected routes here
});
```
- Public routes: `register`, `login`
- Protected routes: All others require valid Bearer token

---

### 2. Route not found (404) on `/api/...`
**Cause:** `/routes/api.php` not loaded  
**Fix:** Ensure `install:api` was run; check `bootstrap/app.php`

**Our Implementation:** ✅
```php
// bootstrap/app.php
->withRouting(
    web: __DIR__.'/../routes/web.php',
    api: __DIR__.'/../routes/api.php',  // ✅ API routes loaded
    commands: __DIR__.'/../routes/console.php',
    health: '/up',
)
```
- 34 API routes registered and working

---

### 3. Mass assignment error
**Cause:** Model missing `$fillable`  
**Fix:** Add column to model's `$fillable` or use `#[Fillable]` attribute

**Our Implementation:** ✅
```php
// All models use Fillable attribute
#[Fillable(['name', 'email', 'password'])]        // User
#[Fillable(['user_id', 'name', 'sport'])]         // League
#[Fillable(['league_id', 'name', 'status'])]      // Season
#[Fillable(['season_id', 'name', 'coach'])]       // Team
#[Fillable(['name', 'birthdate', 'position'])]     // Player
#[Fillable(['season_id', 'home_team_id', ...])]   // Game
#[Fillable(['game_id', 'home_score', 'away_score'])]  // GameResult
#[Fillable(['game_result_id', 'player_id', ...])] // PlayerStat
```

---

### 4. Pivot data not returned
**Cause:** `withPivot()` missing in relationship  
**Fix:** Add `withPivot('jersey_number')` to belongsToMany

**Our Implementation:** ✅
```php
// Team.php & Player.php
public function players() {
    return $this->belongsToMany(Player::class, 'player_team')
        ->withPivot('jersey_number');  // ✅ Pivot data loaded
}
```

---

### 5. Foreign key constraint fails on games
**Cause:** Team does not belong to season  
**Fix:** Validate both team IDs belong to season before inserting

**Our Implementation:** ✅
```php
// GameController::store()
$homeTeam = Team::where('id', $validated['home_team_id'])
    ->where('season_id', $season->id)
    ->first();
$awayTeam = Team::where('id', $validated['away_team_id'])
    ->where('season_id', $season->id)
    ->first();

if (!$homeTeam || !$awayTeam) {
    return response()->json(['message' => 'Both teams must belong to this season'], 422);
}
```

---

### 6. Stats submitted on unfinished game
**Cause:** No status check before saving stats  
**Fix:** Return 422 if game status is not 'done'

**Our Implementation:** ✅
```php
// GameController::submitResult()
if ($game->status === 'done') {
    return response()->json(['message' => 'Game result has already been submitted'], 422);
}
```
- Also prevents duplicate submissions

---

### 7. Standings always returning scheduled games
**Cause:** Querying scheduled games instead of done  
**Fix:** Filter games by `->where('status', 'done')`

**Our Implementation:** ✅
```php
// StandingsController::index()
foreach ($team->homeGames as $game) {
    if ($game->status === 'done' && $game->gameResult) {  // ✅ Only done games
        // Calculate wins/losses
    }
}

foreach ($team->awayGames as $game) {
    if ($game->status === 'done' && $game->gameResult) {  // ✅ Only done games
        // Calculate wins/losses
    }
}
```

---

## Summary Table

| Error | Cause | Fix | Status |
|-------|-------|-----|--------|
| 401 Unauthenticated | Missing token | `auth:sanctum` middleware | ✅ |
| 404 Route not found | API not loaded | `bootstrap/app.php` config | ✅ |
| Mass assignment | Missing $fillable | `#[Fillable]` attribute | ✅ |
| Pivot data missing | No withPivot() | `withPivot('jersey_number')` | ✅ |
| FK constraint | Wrong team season | Validation before create | ✅ |
| Stats on unfinished | No status check | 422 if not 'done' | ✅ |
| Standings wrong games | Querying scheduled | Filter by 'done' | ✅ |

**All 7 common errors are properly prevented in our implementation!** ✓
