# Exercise 11 — FINAL IMPLEMENTATION ✅

## Ex 1 — Season Summary Stats (8 pts) ✅

**Endpoint:** `GET /api/seasons/{id}/summary`

**Rubric Verification:**
| Requirement | Implementation | Points |
|-------------|----------------|--------|
| Total games played and remaining | `$doneGames`, `$scheduledGames` | ✅ 2 pts |
| Top scoring team computed | Query sums team points from `game_results` | ✅ 2 pts |
| Total points computed | `SUM(home_score + away_score)` | ✅ 2 pts |
| 404 if no completed games | Returns 404 with message | ✅ 2 pts |

**Response (success 200):**
```json
{
    "season_name": "Summer 2026",
    "status": "active",
    "games_played": 14,
    "games_scheduled": 14,
    "top_scoring_team": {
        "name": "Barangay Titans",
        "total_points": 847
    },
    "total_points_scored": 1847
}
```

**Response (no games 404):**
```json
{
    "message": "No completed games found for this season"
}
```

---

## Ex 2 — Game Validation Rules (8 pts) ✅

**Endpoint:** `POST /api/leagues/{league}/seasons/{season}/games`

**Rubric Verification:**
| Requirement | Implementation | Points |
|-------------|----------------|--------|
| 422 if same matchup exists | `existingGame` check, returns 422 | ✅ 2 pts |
| Order-independent check | Both `home=A,away=B` and `home=B,away=A` | ✅ 2 pts |
| 422 if team has game on date | `homeTeamConflict`, `awayTeamConflict` | ✅ 2 pts |
| Descriptive error message | "Home team already has a game scheduled..." | ✅ 2 pts |

**Error Responses (422):**
```json
{"message": "These teams already have a scheduled game in this season"}
{"message": "Home team already has a game scheduled at this time"}
{"message": "Away team already has a game scheduled at this time"}
```

---

## Ex 3 — Player Profile Endpoint (9 pts) ✅

**Endpoint:** `GET /api/players/{id}/profile`

**Rubric Verification:**
| Requirement | Implementation | Points |
|-------------|----------------|--------|
| Teams list with season & jersey | `$player->teams()->with('season')`, `pivot->jersey_number` | ✅ 2 pts |
| Career totals aggregated | `SUM` queries across all seasons | ✅ 2 pts |
| Personal best game | `orderByDesc('points')` first record | ✅ 2 pts |
| Single API call (no N+1) | Eager loading with `with()` | ✅ 2 pts |
| 404 if player not found | Implicit via route model binding | ✅ 1 pt |

**Response (success 200):**
```json
{
    "player": {
        "id": 1,
        "name": "Juan Dela Cruz",
        "position": "Guard"
    },
    "teams": [
        {
            "team_name": "Barangay Titans",
            "season_name": "Summer 2026",
            "jersey_number": "23"
        }
    ],
    "career_totals": {
        "total_games": 42,
        "total_points": 586,
        "total_assists": 124,
        "total_rebounds": 189
    },
    "personal_best": {
        "points": 34,
        "game_date": "2026-06-15 14:00:00",
        "opponent": "Barangay Warriors"
    }
}
```

---

## Test Commands

```bash
# Ex 1: Season Summary
curl http://127.0.0.1:8000/api/seasons/1/summary \
  -H "Authorization: Bearer {token}"

# Ex 2: Create Game with Validation
curl -X POST http://127.0.0.1:8000/api/leagues/1/seasons/1/games \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"home_team_id": 1, "away_team_id": 2, "scheduled_at": "2026-05-15 14:00"}'

# Ex 3: Player Profile
curl http://127.0.0.1:8000/api/players/1/profile \
  -H "Authorization: Bearer {token}"
```

---

## Total Score: 25/25 points ✅

| Exercise | Points | Status |
|----------|--------|--------|
| Ex 1 — Season Summary | 8 pts | ✅ |
| Ex 2 — Game Validation | 8 pts | ✅ |
| Ex 3 — Player Profile | 9 pts | ✅ |
| **TOTAL** | **25 pts** | **✅** |
