# Barangay Sports League API

A REST API backend for a community basketball league management system built with Laravel and Sanctum authentication.

---

## 2. Prerequisites

Before you start, make sure you have the following installed and working on your development machine.

| Requirement | Version | Notes |
|-------------|---------|-------|
| PHP | 8.2+ | Required by Laravel 11 |
| Laravel | 11.x | Use the Laravel installer |
| Composer | 2.x | PHP package manager |
| MySQL / SQLite | 8.0+ / any | SQLite is fine for development |
| Postman / Insomnia | Latest stable | For testing API endpoints |
| VS Code / PHPStorm | Latest stable | Install PHP / Laravel plugins |

---

## 3. Installation

### Clone and Setup

```bash
# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Start development server
php artisan serve
```

The API will be available at `http://127.0.0.1:8000`

---

## 4. API Documentation

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/register` | Create new admin user, returns user + token | No |
| POST | `/api/login` | Authenticate and receive Sanctum API token | No |
| POST | `/api/logout` | Revoke the current token | Yes |

#### Register
```json
POST /api/register
{
    "name": "Barangay Captain",
    "email": "captain@barangay.ph",
    "password": "password123",
    "password_confirmation": "password123"
}
```

#### Login
```json
POST /api/login
{
    "email": "captain@barangay.ph",
    "password": "password123"
}
```

**Response:**
```json
{
    "user": { "id": 1, "name": "...", "email": "..." },
    "token": "1|your-api-token-here"
}
```

**For all protected routes, add header:**
```
Authorization: Bearer {your-token}
Accept: application/json
```

---

### League Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/leagues` | List all leagues (user scoped) |
| POST | `/api/leagues` | Create new league |
| GET | `/api/leagues/{id}` | Get league with seasons |
| PUT | `/api/leagues/{id}` | Update league |
| DELETE | `/api/leagues/{id}` | Delete league |

#### Create League
```json
POST /api/leagues
{
    "name": "Barangay 143 Basketball League",
    "description": "Annual basketball tournament"
}
```

---

### Season Endpoints (Nested under Leagues)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/leagues/{league}/seasons` | List seasons |
| POST | `/api/leagues/{league}/seasons` | Create season |
| GET | `/api/leagues/{league}/seasons/{id}` | Get season with teams/games |
| PUT | `/api/leagues/{league}/seasons/{id}` | Update season |
| DELETE | `/api/leagues/{league}/seasons/{id}` | Delete season |

#### Create Season
```json
POST /api/leagues/1/seasons
{
    "name": "Summer 2026 Tournament",
    "start_date": "2026-05-01",
    "end_date": "2026-08-15",
    "status": "upcoming"
}
```

---

### Team Endpoints (Nested under Seasons)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/leagues/{league}/seasons/{season}/teams` | List teams |
| POST | `/api/leagues/{league}/seasons/{season}/teams` | Create team |
| GET | `/api/leagues/{league}/seasons/{season}/teams/{id}` | Get team with players |
| PUT | `/api/leagues/{league}/seasons/{season}/teams/{id}` | Update team |
| DELETE | `/api/leagues/{league}/seasons/{season}/teams/{id}` | Delete team |

#### Create Team
```json
POST /api/leagues/1/seasons/1/teams
{
    "name": "Barangay Titans",
    "coach_name": "Coach Juan"
}
```

---

### Player Endpoints (Nested under Teams)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/leagues/{league}/seasons/{season}/teams/{team}/players` | List players |
| POST | `/api/leagues/{league}/seasons/{season}/teams/{team}/players` | Create player |
| GET | `/api/leagues/{league}/seasons/{season}/teams/{team}/players/{id}` | Get player |
| PUT | `/api/leagues/{league}/seasons/{season}/teams/{team}/players/{id}` | Update player |
| DELETE | `/api/leagues/{league}/seasons/{season}/teams/{team}/players/{id}` | Delete player |

#### Create Player
```json
POST /api/leagues/1/seasons/1/teams/1/players
{
    "name": "Juan Dela Cruz",
    "birthdate": "1995-06-15",
    "position": "Shooting Guard",
    "jersey_number": "23"
}
```

*Note: Players are standalone records attached to teams via the `player_team` pivot table. Jersey number is stored on the pivot.*

---

### Game Endpoints (Nested under Seasons)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/leagues/{league}/seasons/{season}/games` | List games |
| POST | `/api/leagues/{league}/seasons/{season}/games` | Schedule game |
| GET | `/api/leagues/{league}/seasons/{season}/games/{id}` | Get game details |
| PUT | `/api/leagues/{league}/seasons/{season}/games/{id}` | Update game |
| DELETE | `/api/leagues/{league}/seasons/{season}/games/{id}` | Delete game |
| POST | `/api/leagues/{league}/seasons/{season}/games/{id}/result` | Submit game result |

#### Schedule Game
```json
POST /api/leagues/1/seasons/1/games
{
    "home_team_id": 1,
    "away_team_id": 2,
    "scheduled_at": "2026-05-15 14:00:00",
    "venue": "Barangay Covered Court"
}
```

#### Submit Game Result
```json
POST /api/leagues/1/seasons/1/games/1/result
{
    "home_score": 87,
    "away_score": 82,
    "player_stats": [
        {
            "player_id": 1,
            "points": 24,
            "rebounds": 8,
            "assists": 5,
            "fouls": 2
        },
        {
            "player_id": 2,
            "points": 18,
            "rebounds": 5,
            "assists": 7,
            "fouls": 1
        }
    ]
}
```

*Note: This creates a `game_results` record and associated `player_stats` records.*

---

### Stats & Standings Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/leagues/{league}/seasons/{season}/standings` | Get team standings (win-loss) |
| GET | `/api/leagues/{league}/seasons/{season}/leaderboard` | Get player leaderboard with stats |
| GET | `/api/leagues/{league}/seasons/{season}/top-scorers` | Get top 10 scorers |
| GET | `/api/leagues/{league}/seasons/{season}/stats` | Get game statistics |

#### Standings Response
```json
[
    {
        "team_id": 1,
        "team_name": "Barangay Titans",
        "wins": 5,
        "losses": 1,
        "games_played": 6,
        "win_percentage": 0.833
    },
    {
        "team_id": 2,
        "team_name": "Bayan Knights",
        "wins": 4,
        "losses": 2,
        "games_played": 6,
        "win_percentage": 0.667
    }
]
```

---

## 5. Testing with Postman/Insomnia

### Quick Test Sequence

1. **Register** → Copy the token from response
2. **Create League** → Note the `id`
3. **Create Season** → Use league `id`, note season `id`
4. **Create 2 Teams** → Use season `id`, note team `id`s
5. **Create Players** → Use team `id`s
6. **Schedule Game** → Use team `id`s
7. **Submit Result** → After game is played
8. **Check Standings** → See win-loss records

### Environment Variables (Postman)
```json
{
    "base_url": "http://127.0.0.1:8000/api",
    "token": "your-auth-token",
    "league_id": "1",
    "season_id": "1",
    "team_id": "1"
}
```

---

## 6. Project Structure

```
app/
├── Http/
│   └── Controllers/
│       ├── AuthController.php      # Login, register, logout
│       ├── LeagueController.php    # League CRUD
│       ├── SeasonController.php    # Season CRUD
│       ├── TeamController.php      # Team CRUD
│       ├── PlayerController.php    # Player CRUD
│       ├── GameController.php      # Games + standings
│       └── StatsController.php     # Leaderboards + stats
├── Models/
│   ├── User.php                    # HasApiTokens trait
│   ├── League.php                  # belongsTo User
│   ├── Season.php                  # belongsTo League
│   ├── Team.php                    # belongsTo Season
│   ├── Player.php                  # belongsTo Team
│   ├── Game.php                    # homeTeam, awayTeam, playerStats
│   └── PlayerStat.php              # belongsTo Game, Player
├── Policies/
│   └── LeaguePolicy.php            # Authorization rules
└── ...

database/migrations/
├── 2026_04_27_000001_create_leagues_table.php
├── 2026_04_27_000002_create_seasons_table.php
├── 2026_04_27_000003_create_teams_table.php
├── 2026_04_27_000004_create_players_table.php
├── 2026_04_27_000005_create_games_table.php
└── 2026_04_27_000006_create_player_stats_table.php

routes/api.php                      # All API routes
```

---

## 7. Key Features Implemented

- **Sanctum Authentication**: Token-based API authentication
- **Nested Resource Routes**: Leagues → Seasons → Teams → Players → Games
- **Authorization**: Users can only access their own leagues
- **Business Logic Validation**: Teams must belong to season when scheduling games
- **Computed Standings**: Win-loss records calculated from completed games
- **Player Leaderboard**: Aggregated stats with per-game averages
- **Transaction Safety**: Game results and stats saved together

---

## License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
