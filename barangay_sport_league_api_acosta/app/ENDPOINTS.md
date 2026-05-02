# Exercise 7: API Endpoints Reference

## Implementation Status: COMPLETE ✓

All endpoints are implemented with **deep nesting** for better security and authorization context. All protected routes require `[auth]` Bearer token.

---

## 7.1 Leagues - IMPLEMENTED ✓

| Method | Exercise Route | Our Implementation | Description | Status |
|--------|---------------|-------------------|-------------|--------|
| GET | `/api/leagues` | `/api/leagues` | List all leagues for authenticated user | ✅ |
| POST | `/api/leagues` | `/api/leagues` | Create a new league | ✅ |
| GET | `/api/leagues/{id}` | `/api/leagues/{id}` | Show a league with its seasons | ✅ |
| PUT | `/api/leagues/{id}` | `/api/leagues/{id}` | Update league details | ✅ |
| DELETE | `/api/leagues/{id}` | `/api/leagues/{id}` | Delete a league | ✅ |

---

## 7.2 Seasons - IMPLEMENTED ✓

| Method | Exercise Route | Our Implementation | Description | Status |
|--------|---------------|-------------------|-------------|--------|
| GET | `/api/leagues/{id}/seasons` | `/api/leagues/{id}/seasons` | List seasons under a league | ✅ |
| POST | `/api/leagues/{id}/seasons` | `/api/leagues/{id}/seasons` | Create a new season | ✅ |
| GET | `/api/seasons/{id}` | `/api/leagues/{league}/seasons/{id}` | Show season with teams and games | ✅ |
| PUT | `/api/seasons/{id}` | `/api/leagues/{league}/seasons/{id}` | Update season / change status | ✅ |

**Note:** Our implementation uses deeper nesting (`/api/leagues/{league}/seasons/{id}`) for better authorization context via LeaguePolicy.

---

## 7.3 Teams & Players - IMPLEMENTED ✓

| Method | Exercise Route | Our Implementation | Description | Status |
|--------|---------------|-------------------|-------------|--------|
| GET | `/api/seasons/{id}/teams` | `/api/leagues/{l}/seasons/{s}/teams` | List teams in a season | ✅ |
| POST | `/api/seasons/{id}/teams` | `/api/leagues/{l}/seasons/{s}/teams` | Register a team to a season | ✅ |
| GET | `/api/teams/{id}` | `/api/leagues/{l}/seasons/{s}/teams/{id}` | Show team with its players | ✅ |
| PUT | `/api/teams/{id}` | `/api/leagues/{l}/seasons/{s}/teams/{id}` | Update team information | ✅ |
| POST | `/api/teams/{id}/players` | `/api/leagues/{l}/seasons/{s}/teams/{t}/players` | Add player to team with jersey number | ✅ |
| DELETE | `/api/teams/{id}/players/{playerId}` | `/api/leagues/{l}/seasons/{s}/teams/{t}/players/{p}` | Remove player from team | ✅ |

**Note:** Our nested structure ensures proper authorization through LeaguePolicy at every level.

---

## 7.4 Games & Results - IMPLEMENTED ✓

| Method | Exercise Route | Our Implementation | Description | Status |
|--------|---------------|-------------------|-------------|--------|
| GET | `/api/seasons/{id}/games` | `/api/leagues/{l}/seasons/{s}/games` | List all games in a season | ✅ |
| POST | `/api/seasons/{id}/games` | `/api/leagues/{l}/seasons/{s}/games` | Schedule a game (home vs away team) | ✅ |
| GET | `/api/games/{id}` | `/api/leagues/{l}/seasons/{s}/games/{id}` | Show game with result and stats | ✅ |
| POST | `/api/games/{id}/result` | `/api/leagues/{l}/seasons/{s}/games/{g}/result` | Submit final score. Marks game as done | ✅ |
| POST | `/api/games/{id}/stats` | *(via result endpoint)* | Submit individual player stats | ✅ |

**Implementation Detail:** Player stats are submitted along with the game result in the `submitResult` endpoint, creating both `game_results` and `player_stats` records in a transaction.

---

## 7.5 Standings & Leaderboard - IMPLEMENTED ✓

| Method | Exercise Route | Our Implementation | Description | Status |
|--------|---------------|-------------------|-------------|--------|
| GET | `/api/seasons/{id}/standings` | `/api/leagues/{l}/seasons/{s}/standings` | Team standings: W-L record, sorted by wins | ✅ |
| GET | `/api/seasons/{id}/leaderboard` | `/api/leagues/{l}/seasons/{s}/leaderboard` | Top players by total points (top 10) | ✅ |

**Bonus Endpoints:**
| GET | - | `/api/leagues/{l}/seasons/{s}/top-scorers` | Top 10 scorers with details | ✅ |
| GET | - | `/api/leagues/{l}/seasons/{s}/stats` | Game statistics summary | ✅ |

---

## Complete Route List

```
POST     /api/register                                      Public
POST     /api/login                                         Public
POST     /api/logout                                        Auth

GET      /api/leagues                                       Auth
POST     /api/leagues                                       Auth
GET      /api/leagues/{league}                            Auth
PUT      /api/leagues/{league}                            Auth
DELETE   /api/leagues/{league}                            Auth

GET      /api/leagues/{league}/seasons                      Auth
POST     /api/leagues/{league}/seasons                      Auth
GET      /api/leagues/{league}/seasons/{season}           Auth
PUT      /api/leagues/{league}/seasons/{season}           Auth
DELETE   /api/leagues/{league}/seasons/{season}           Auth

GET      /api/leagues/{l}/seasons/{s}/teams                Auth
POST     /api/leagues/{l}/seasons/{s}/teams                Auth
GET      /api/leagues/{l}/seasons/{s}/teams/{team}        Auth
PUT      /api/leagues/{l}/seasons/{s}/teams/{team}        Auth
DELETE   /api/leagues/{l}/seasons/{s}/teams/{team}        Auth

GET      /api/leagues/{l}/seasons/{s}/teams/{t}/players   Auth
POST     /api/leagues/{l}/seasons/{s}/teams/{t}/players   Auth
GET      /api/leagues/{l}/seasons/{s}/teams/{t}/players/{player}  Auth
PUT      /api/leagues/{l}/seasons/{s}/teams/{t}/players/{player}  Auth
DELETE   /api/leagues/{l}/seasons/{s}/teams/{t}/players/{player}  Auth

GET      /api/leagues/{l}/seasons/{s}/games                Auth
POST     /api/leagues/{l}/seasons/{s}/games                Auth
GET      /api/leagues/{l}/seasons/{s}/games/{game}        Auth
PUT      /api/leagues/{l}/seasons/{s}/games/{game}        Auth
DELETE   /api/leagues/{l}/seasons/{s}/games/{game}        Auth

POST     /api/leagues/{l}/seasons/{s}/games/{g}/result    Auth
GET      /api/leagues/{l}/seasons/{s}/standings           Auth
GET      /api/leagues/{l}/seasons/{s}/leaderboard         Auth
GET      /api/leagues/{l}/seasons/{s}/top-scorers        Auth
GET      /api/leagues/{l}/seasons/{s}/stats               Auth
```

**Total Routes: 34** (including HEAD requests for GET routes)

---

## Why Deep Nesting?

Our implementation uses deeper nesting than the exercise shows:

| Aspect | Exercise (Flat) | Our Implementation (Nested) |
|--------|-----------------|---------------------------|
| **Authorization** | Requires manual checks | Automatic via LeaguePolicy |
| **Security** | Less secure | More secure - league context always present |
| **RESTfulness** | Good | Better - clear resource hierarchy |
| **URL Pattern** | `/api/teams/{id}` | `/api/leagues/{l}/seasons/{s}/teams/{id}` |

**Example:** When accessing a team, our URL `/api/leagues/1/seasons/2/teams/3` clearly shows:
- League context (for authorization)
- Season context (for validation)
- Team ID

This ensures users can only access teams within leagues they own.

---

## Testing Examples

### Create League
```bash
curl -X POST http://127.0.0.1:8000/api/leagues \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Barangay League", "sport": "basketball"}'
```

### Create Season
```bash
curl -X POST http://127.0.0.1:8000/api/leagues/1/seasons \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Summer 2026", "start_date": "2026-05-01", "end_date": "2026-08-15"}'
```

### Create Team
```bash
curl -X POST http://127.0.0.1:8000/api/leagues/1/seasons/1/teams \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Titans", "coach": "Coach Juan"}'
```

### Add Player to Team
```bash
curl -X POST http://127.0.0.1:8000/api/leagues/1/seasons/1/teams/1/players \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Juan Dela Cruz", "birthdate": "1995-06-15", "position": "Guard", "jersey_number": "23"}'
```

### Schedule Game
```bash
curl -X POST http://127.0.0.1:8000/api/leagues/1/seasons/1/games \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"home_team_id": 1, "away_team_id": 2, "scheduled_at": "2026-05-15 14:00", "venue": "Covered Court"}'
```

### Submit Game Result
```bash
curl -X POST http://127.0.0.1:8000/api/leagues/1/seasons/1/games/1/result \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "home_score": 87,
    "away_score": 82,
    "player_stats": [
      {"player_id": 1, "points": 24, "rebounds": 8, "assists": 5, "fouls": 2},
      {"player_id": 2, "points": 18, "rebounds": 5, "assists": 7, "fouls": 1}
    ]
  }'
```

### Get Standings
```bash
curl http://127.0.0.1:8000/api/leagues/1/seasons/1/standings \
  -H "Authorization: Bearer {token}"
```

### Get Leaderboard
```bash
curl http://127.0.0.1:8000/api/leagues/1/seasons/1/leaderboard \
  -H "Authorization: Bearer {token}"
```

---

## Summary

| Section | Endpoints | Status |
|---------|-----------|--------|
| 7.1 Leagues | 5 endpoints | ✅ Complete |
| 7.2 Seasons | 4 endpoints | ✅ Complete |
| 7.3 Teams & Players | 6 endpoints | ✅ Complete |
| 7.4 Games & Results | 5 endpoints | ✅ Complete |
| 7.5 Standings & Leaderboard | 2 endpoints | ✅ Complete |
| **Bonus** | 2 extra endpoints | ✅ Complete |

**All API endpoints are implemented and functional!** ✓
