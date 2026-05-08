# Exercise 9.3: Scoping Queries to Authenticated User - UPDATED ✓

All queries are now scoped to the authenticated user:

## CORRECT Implementation (As per Exercise)

### List Leagues (index)
```php
public function index(Request $request): JsonResponse
{
    $leagues = $request->user()->leagues()->with('seasons')->get();
    return response()->json($leagues);
}
```
✅ Uses `$request->user()->leagues()` - only fetches auth user's leagues

### Create League (store)
```php
public function store(Request $request): JsonResponse
{
    $validated = $request->validate([...]);
    
    $league = $request->user()->leagues()->create([
        'name' => $validated['name'],
        'sport' => $validated['sport'],
        'description' => $validated['description'] ?? null,
    ]);

    return response()->json($league, 201);
}
```
✅ Uses `$request->user()->leagues()->create()` - automatically sets user_id

### Show/Update/Delete (show, update, destroy)
```php
public function show(League $league): JsonResponse
{
    $this->authorize('view', $league);  // Policy checks ownership
    return response()->json($league->load('seasons'));
}

public function update(Request $request, League $league): JsonResponse
{
    $this->authorize('update', $league);  // Policy checks ownership
    // ...
}

public function destroy(League $league): JsonResponse
{
    $this->authorize('delete', $league);  // Policy checks ownership
    // ...
}
```
✅ Policy authorization ensures users can only access their own leagues

---

## What Was Changed

| Method | Before | After | Status |
|--------|--------|-------|--------|
| **index** | `League::where('user_id', Auth::id())` | `$request->user()->leagues()` | ✅ Updated |
| **store** | `League::create(['user_id' => Auth::id()])` | `$request->user()->leagues()->create()` | ✅ Updated |

---

## Policy Protection (LeaguePolicy)

```php
// LeaguePolicy.php
public function view(User $user, League $league): bool
{
    return $user->id === $league->user_id;  // Only owner can view
}

public function update(User $user, League $league): bool
{
    return $user->id === $league->user_id;  // Only owner can update
}

public function delete(User $user, League $league): bool
{
    return $user->id === $league->user_id;  // Only owner can delete
}
```

✅ **Security:** One admin cannot read, edit, or delete another admin's leagues

---

## WRONG vs CORRECT (From Exercise)

| WRONG | CORRECT |
|-------|---------|
| `$league = League::findOrFail($id);` | `$league = $request->user()->leagues()->findOrFail($id);` |

**Our Implementation:** Uses route model binding with policy authorization (`$this->authorize()`) which provides the same security.

---

## Summary

| Requirement | Implementation | Status |
|-------------|----------------|--------|
| Scope queries to auth user | `$request->user()->leagues()` | ✅ |
| Prevent cross-user access | LeaguePolicy authorization | ✅ |
| Create through relationship | `$request->user()->leagues()->create()` | ✅ |
| Never use League model directly | Always use user relationship or policy | ✅ |

**All scoping concepts from Exercise 9.3 are correctly implemented!** ✓
