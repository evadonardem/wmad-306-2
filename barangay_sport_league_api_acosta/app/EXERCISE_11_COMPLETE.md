# Exercise 11 — All 3 Exercises COMPLETE ✅

## Ex 1 — Season Summary Stats (8 pts) ✅

**New Endpoint:** `GET /api/leagues/{league}/seasons/{season}/summary`

**Location:** `StatsController::seasonSummary()`

**Returns:**
```json
{
    "season_name": "Summer 2026",
    "status": "active",
    "date_range": ["2026-05-01", "2026-08-15"],
    "teams_count": 8,
    "players_count": 96,
    "games": {
        "total": 28,
        "completed": 14,
        "scheduled": 14
    },
    "total_points_scored": 1847,
    "top_team": {
        "name": "Barangay Titans",
        "wins": 12
    },
    "top_scorer": {
        "name": "Juan Dela Cruz",
        "points": 184
    }
}
```

---

## Ex 2 — Game Validation Rules (8 pts) ✅

**Enhanced Validation in:** `GameController::store()`

**New Validation Rules:**

| Rule | Description | Status |
|------|-------------|--------|
| Future Date | `scheduled_at` must be in future | ✅ |
| Season Range | Must be within season start/end dates | ✅ |
| No Duplicate Games | Same teams can't have multiple scheduled games | ✅ |
| No Time Conflicts | Home team can't be scheduled at same time | ✅ |
| No Time Conflicts | Away team can't be scheduled at same time | ✅ |

**Error Response (422):**
```json
{"message": "Game must be scheduled in the future"}
{"message": "Game must be scheduled within season dates"}
{"message": "These teams already have a scheduled game in this season"}
{"message": "Home team already has a game scheduled at this time"}
{"message": "Away team already has a game scheduled at this time"}
```

---

## Ex 3 — Player Profile Endpoint (9 pts) ✅

**Enhanced Endpoint:** `GET /api/leagues/{league}/seasons/{season}/teams/{team}/players/{player}`

**Location:** `PlayerController::show()`

**Returns:**
```json
{
    "player": {
        "id": 1,
        "name": "Juan Dela Cruz",
        "birthdate": "1995-06-15",
        "position": "Guard",
        "jersey_number": "23"
    },
    "current_team": {
        "id": 1,
        "name": "Barangay Titans",
        "season": "Summer 2026",
        "league": "Barangay League"
    },
    "career_stats": {
        "games_played": 14,
        "total_points": 286,
        "total_rebounds": 89,
        "total_assists": 124,
        "total_fouls": 23,
        "points_per_game": 20.4,
        "rebounds_per_game": 6.4,
        "assists_per_game": 8.9
    },
    "game_log": [
        {
            "date": "2026-05-15 14:00:00",
            "points": 24,
            "rebounds": 8,
            "assists": 5,
            "fouls": 2
        },
        ...
    ]
}
```

---

## Summary

| Exercise | Points | Difficulty | Endpoint | Status |
|----------|--------|------------|----------|--------|
| **Ex 1** | 8 pts | Easy ★★☆☆☆ | `GET /summary` | ✅ Complete |
| **Ex 2** | 8 pts | Medium ★★★☆☆ | Enhanced `store()` | ✅ Complete |
| **Ex 3** | 9 pts | Hard ★★★★☆ | Enhanced `show()` | ✅ Complete |

**Total: 25 points added!**

**Test Commands:**
```bash
# Ex 1: Season Summary
curl http://127.0.0.1:8000/api/leagues/1/seasons/1/summary \
  -H "Authorization: Bearer {token}"

# Ex 2: Create Game with Validation
curl -X POST http://127.0.0.1:8000/api/leagues/1/seasons/1/games \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"home_team_id": 1, "away_team_id": 2, "scheduled_at": "2026-05-15 14:00"}'

# Ex 3: Player Profile
curl http://127.0.0.1:8000/api/leagues/1/seasons/1/teams/1/players/1 \
  -H "Authorization: Bearer {token}"
```
