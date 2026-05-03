# Barangay Sports League API - Postman Testing Guide

## Setup Instructions

### 1. Environment Setup
- **Base URL**: `http://localhost:8000/api`
- **Content-Type**: `application/json`
- **Authorization**: `Bearer Token` (for protected routes)

### 2. Authentication Flow

#### Register New Admin
```
POST {{base_url}}/register
Content-Type: application/json

{
    "name": "Admin User",
    "email": "admin@example.com",
    "password": "password123",
    "password_confirmation": "password123"
}
```

**Expected Response (201)**:
```json
{
    "user": {
        "id": 1,
        "name": "Admin User",
        "email": "admin@example.com",
        "created_at": "...",
        "updated_at": "..."
    },
    "token": "1|abc123def456..."
}
```

#### Login
```
POST {{base_url}}/login
Content-Type: application/json

{
    "email": "admin@example.com",
    "password": "password123"
}
```

**Expected Response (200)**:
```json
{
    "token": "1|abc123def456...",
    "user": {
        "id": 1,
        "name": "Admin User",
        "email": "admin@example.com"
    }
}
```

#### Copy Token for Authorization
1. Copy the token from login/register response
2. In Postman, go to **Authorization** tab
3. Select **Bearer Token** type
4. Paste the token in the token field

### 3. Create League (Protected)
```
POST {{base_url}}/leagues
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "name": "Barangay Basketball League 2024",
    "sport": "Basketball",
    "description": "Annual basketball tournament"
}
```

### 4. Create Season (Protected)
```
POST {{base_url}}/leagues/1/seasons
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "name": "Season 2024",
    "start_date": "2024-01-15",
    "end_date": "2024-03-15",
    "status": "active"
}
```

### 5. Create Teams (Protected)
```
POST {{base_url}}/seasons/1/teams
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "name": "Team Alpha",
    "coach": "Coach Smith"
}
```

### 6. Create Players (Protected)
```
POST {{base_url}}/teams/1/players
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "player_id": 1,
    "jersey_number": 23
}
```

### 7. Schedule Game (Protected)
```
POST {{base_url}}/seasons/1/games
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "home_team_id": 1,
    "away_team_id": 2,
    "scheduled_at": "2024-02-15T14:00:00Z",
    "venue": "Barangay Court A"
}
```

### 8. Submit Game Result (Protected)
```
POST {{base_url}}/games/1/result
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "home_score": 85,
    "away_score": 78
}
```

### 9. Submit Player Stats (Protected)
```
POST {{base_url}}/games/1/stats
Authorization: Bearer {{token}}
Content-Type: application/json

{
    "stats": [
        {
            "player_id": 1,
            "points": 25,
            "assists": 8,
            "rebounds": 10,
            "fouls": 3
        },
        {
            "player_id": 2,
            "points": 18,
            "assists": 5,
            "rebounds": 7,
            "fouls": 2
        }
    ]
}
```

### 10. View Standings (Protected)
```
GET {{base_url}}/seasons/1/standings
Authorization: Bearer {{token}}
```

### 11. View Leaderboard (Protected)
```
GET {{base_url}}/seasons/1/leaderboard
Authorization: Bearer {{token}}
```

### 12. View Player Profile (Protected)
```
GET {{base_url}}/players/1/profile
Authorization: Bearer {{token}}
```

## Postman Collection Setup

### Environment Variables
Create environment variables in Postman:
- `base_url`: `http://localhost:8000/api`
- `token`: Your authentication token

### Collection Structure
Create folders for better organization:
- 📁 **Authentication** (register, login, logout)
- 📁 **Leagues** (CRUD operations)
- 📁 **Seasons** (CRUD operations)
- 📁 **Teams** (CRUD + player management)
- 📁 **Games** (schedule, results, stats)
- 📁 **Analytics** (standings, leaderboard, profiles)

## Testing Tips

### 1. Start Fresh
1. Register new admin user
2. Login to get token
3. Use token for all subsequent requests

### 2. Test Validation
- Try creating duplicate games (should return 422)
- Try scheduling same team on same date (should return 422)
- Try invalid data (should return validation errors)

### 3. Test Scenarios
- Create multiple teams and players
- Schedule several games
- Submit results and stats
- Check standings calculations
- Verify leaderboard aggregation

### 4. Response Analysis
- Check HTTP status codes (200, 201, 404, 422)
- Verify response structure matches expected format
- Test error messages are descriptive

## Common Issues & Solutions

### 401 Unauthorized
- **Cause**: Missing or invalid token
- **Fix**: Ensure Authorization header is set with valid Bearer token

### 404 Not Found
- **Cause**: Resource doesn't exist or doesn't belong to user
- **Fix**: Verify resource exists and user has access

### 422 Validation Error
- **Cause**: Invalid input data
- **Fix**: Check response for specific validation errors

### 500 Server Error
- **Cause**: Server-side error
- **Fix**: Check Laravel logs: `php artisan log:tail`

## Running the Server

Start Laravel development server:
```bash
cd c:\Users\User\wmad-306-2\barangay_sport_league_api\app
php artisan serve
```

Server will run at: `http://localhost:8000`

## Database Setup

If you haven't run migrations:
```bash
php artisan migrate
```

For fresh start:
```bash
php artisan migrate:fresh
```

This guide will help you systematically test all API endpoints and verify the implementation works correctly!
