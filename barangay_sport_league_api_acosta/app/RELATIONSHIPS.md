# Exercise 5: Eloquent Relationships

## 5.1 Relationship Map - VERIFIED ✓

```
User
  hasMany --> League
              hasMany --> Season
                          hasMany --> Team
                                      belongsToMany --> Player (pivot: jersey_number)
                          hasMany --> Game
                                      belongsTo (home_team_id) --> Team
                                      belongsTo (away_team_id) --> Team
                                      hasOne --> GameResult
                                                  hasMany --> PlayerStat
                                                              belongsTo --> Player
```

## 5.2 belongsToMany with Pivot - IMPLEMENTED ✓

### Team Model (`app/Models/Team.php`)
```php
public function players()
{
    return $this->belongsToMany(Player::class, 'player_team')
        ->withPivot('jersey_number');
}
```

### Player Model (`app/Models/Player.php`)
```php
public function teams(): BelongsToMany
{
    return $this->belongsToMany(Team::class, 'player_team')
        ->withPivot('jersey_number');
}
```

**Key Point:** Jersey number is stored on the `player_team` pivot table, allowing players to have different numbers on different teams across seasons.

## 5.3 Game Foreign Keys - IMPLEMENTED ✓

### Game Model (`app/Models/Game.php`)
```php
public function homeTeam(): BelongsTo
{
    return $this->belongsTo(Team::class, 'home_team_id');
}

public function awayTeam(): BelongsTo
{
    return $this->belongsTo(Team::class, 'away_team_id');
}
```

**Key Point:** Two foreign keys point to the same `teams` table with explicit foreign key names.

## Complete Relationship Summary

| Model | Relationship | Type | Target | Notes |
|-------|-------------|------|--------|-------|
| **User** | leagues | hasMany | League | One user owns many leagues |
| **League** | user | belongsTo | User | League belongs to user |
| **League** | seasons | hasMany | Season | League has many seasons |
| **Season** | league | belongsTo | League | Season belongs to league |
| **Season** | teams | hasMany | Team | Season has many teams |
| **Season** | games | hasMany | Game | Season has many games |
| **Team** | season | belongsTo | Season | Team belongs to season |
| **Team** | players | belongsToMany | Player | Many-to-many via player_team pivot |
| **Team** | homeGames | hasMany | Game | Foreign key: home_team_id |
| **Team** | awayGames | hasMany | Game | Foreign key: away_team_id |
| **Player** | teams | belongsToMany | Team | Many-to-many via player_team pivot |
| **Player** | stats | hasMany | PlayerStat | Player has many stats |
| **Game** | season | belongsTo | Season | Game belongs to season |
| **Game** | homeTeam | belongsTo | Team | Foreign key: home_team_id |
| **Game** | awayTeam | belongsTo | Team | Foreign key: away_team_id |
| **Game** | gameResult | hasOne | GameResult | One result per game |
| **GameResult** | game | belongsTo | Game | Result belongs to game |
| **GameResult** | playerStats | hasMany | PlayerStat | Result has many player stats |
| **PlayerStat** | gameResult | belongsTo | GameResult | Stat belongs to result |
| **PlayerStat** | player | belongsTo | Player | Stat belongs to player |

## Testing Relationships

Example queries that work with these relationships:

```php
// Get all players on a team with their jersey numbers
$team = Team::find(1);
foreach ($team->players as $player) {
    echo $player->name . ' - Jersey #' . $player->pivot->jersey_number;
}

// Get all teams a player has played for
$player = Player::find(1);
$teams = $player->teams;

// Get game with both teams
$game = Game::find(1);
echo $game->homeTeam->name . ' vs ' . $game->awayTeam->name;

// Get game result with player stats
$game = Game::find(1);
$result = $game->gameResult;
foreach ($result->playerStats as $stat) {
    echo $stat->player->name . ' scored ' . $stat->points;
}

// Get all games in a season with results
$season = Season::find(1);
$games = $season->games()->with(['homeTeam', 'awayTeam', 'gameResult'])->get();
```

All relationships have been implemented correctly! ✓
