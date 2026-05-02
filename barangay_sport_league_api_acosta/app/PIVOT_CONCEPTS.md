# Exercise 9.2: belongsToMany with Pivot Data - VERIFIED ✓

All pivot data concepts from the exercise are correctly implemented:

## 1. Define withPivot(): `->withPivot('jersey_number')`

**Team Model** (`app/Models/Team.php`):
```php
public function players()
{
    return $this->belongsToMany(Player::class, 'player_team')
        ->withPivot('jersey_number');
}
```

**Player Model** (`app/Models/Player.php`):
```php
public function teams(): BelongsToMany
{
    return $this->belongsToMany(Team::class, 'player_team')
        ->withPivot('jersey_number');
}
```

✅ **Status:** Models use `withPivot('jersey_number')` to load the extra column

---

## 2. Attach Player with Pivot: `attach($id, $pivot)`

**Location:** `PlayerController.php` (lines 39-41)

```php
$team->players()->attach($player->id, [
    'jersey_number' => $validated['jersey_number'] ?? null,
]);
```

**Matches Exercise:** `$team->players()->attach($id, ['jersey_number' => 7])`

✅ **Status:** Correctly attaches player with jersey_number on pivot

---

## 3. Detach Player: `detach($playerId)`

**Location:** `PlayerController.php` (line 84)

```php
$team->players()->detach($player->id);
```

**Matches Exercise:** `$team->players()->detach($playerId)`

✅ **Status:** Correctly detaches player from team (removes pivot record)

---

## 4. Read Pivot Data: `->pivot->jersey_number`

**Usage Example:**
```php
$team = Team::find(1);
foreach ($team->players as $player) {
    echo $player->name . ' - Jersey #' . $player->pivot->jersey_number;
}
```

**Matches Exercise:** `$player->pivot->jersey_number`

✅ **Status:** Available via `->pivot->jersey_number` because of `withPivot()`

---

## Summary Table

| Concept | Code | Location | Status |
|---------|------|----------|--------|
| **Define withPivot()** | `->withPivot('jersey_number')` | `Team.php`, `Player.php` | ✅ |
| **Attach with Pivot** | `attach($id, ['jersey_number' => 7])` | `PlayerController.php` | ✅ |
| **Detach Player** | `detach($playerId)` | `PlayerController.php` | ✅ |
| **Read Pivot Data** | `->pivot->jersey_number` | Via withPivot() | ✅ |

**All belongsToMany with Pivot concepts are correctly implemented!** ✓
