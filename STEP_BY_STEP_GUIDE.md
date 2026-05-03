# Barangay Sports League API - Step by Step Guide

## Step 1: Start the Laravel Server

1. Open your terminal/command prompt
2. Navigate to the project directory:
   ```
   cd c:\Users\User\wmad-306-2\barangay_sport_league_api\app
   ```
3. Run the Laravel development server:
   ```
   php artisan serve
   ```
4. You should see: `Server running on http://127.0.0.1:8000`

## Step 2: Set Up the Database

1. In the same terminal, run the migrations to create database tables:
   ```
   php artisan migrate
   ```
2. If you want to start fresh, use:
   ```
   php artisan migrate:fresh
   ```

## Step 3: Test in Postman - Authentication

### 3.1 Register a New User
1. Open Postman
2. Create a new request: **POST**
3. URL: `http://localhost:8000/api/register`
4. Go to **Headers** tab and add:
   - Key: `Content-Type`
   - Value: `application/json`
5. Go to **Body** tab → **raw** → **JSON**
6. Paste this JSON:
   ```json
   {
       "name": "Admin User",
       "email": "admin@example.com",
       "password": "password123",
       "password_confirmation": "password123"
   }
   ```
7. Click **Send**
8. You should get a 201 response with a token - **COPY THIS TOKEN**

### 3.2 Login (Optional - if you already have an account)
1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/login`
3. Headers: `Content-Type: application/json`
4. Body (JSON):
   ```json
   {
       "email": "admin@example.com",
       "password": "password123"
   }
   ```
5. Click **Send** and copy the token from response

## Step 4: Create a League

1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/leagues`
3. Go to **Authorization** tab:
   - Type: `Bearer Token`
   - Token: **Paste your token here**
4. Headers: `Content-Type: application/json`
5. Body (JSON):
   ```json
   {
       "name": "Barangay Basketball League",
       "sport": "Basketball",
       "description": "Annual basketball tournament"
   }
   ```
6. Click **Send** - you should get 201 response with league data

## Step 5: Create a Season

1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/leagues/1/seasons` (use your league ID)
3. Authorization: Bearer Token (same token)
4. Headers: `Content-Type: application/json`
5. Body (JSON):
   ```json
   {
       "name": "Season 2024",
       "start_date": "2024-01-15",
       "end_date": "2024-03-15",
       "status": "active"
   }
   ```
6. Click **Send** - copy the season ID from response

## Step 6: Create Teams

### 6.1 Create First Team
1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/seasons/1/teams` (use your season ID)
3. Authorization: Bearer Token
4. Headers: `Content-Type: application/json`
5. Body (JSON):
   ```json
   {
       "name": "Team Alpha",
       "coach": "Coach Smith"
   }
   ```
6. Click **Send** - copy the team ID

### 6.2 Create Second Team
1. Duplicate the previous request
2. Change the URL to use the same season ID
3. Body (JSON):
   ```json
   {
       "name": "Team Beta",
       "coach": "Coach Johnson"
   }
   ```
4. Click **Send** - copy this team ID too

## Step 7: Create Players

### 7.1 Create Player Records
1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/players` (Note: You might need to add this route first)
3. For now, let's check if players exist by viewing teams

### 7.2 Add Players to Teams
1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/teams/1/players` (use first team ID)
3. Authorization: Bearer Token
4. Headers: `Content-Type: application/json`
5. Body (JSON):
   ```json
   {
       "player_id": 1,
       "jersey_number": 23
   }
   ```
6. Click **Send**

## Step 8: Schedule a Game

1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/seasons/1/games` (use your season ID)
3. Authorization: Bearer Token
4. Headers: `Content-Type: application/json`
5. Body (JSON):
   ```json
   {
       "home_team_id": 1,
       "away_team_id": 2,
       "scheduled_at": "2024-02-15T14:00:00Z",
       "venue": "Barangay Court A"
   }
   ```
6. Click **Send** - copy the game ID

## Step 9: Submit Game Result

1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/games/1/result` (use your game ID)
3. Authorization: Bearer Token
4. Headers: `Content-Type: application/json`
5. Body (JSON):
   ```json
   {
       "home_score": 85,
       "away_score": 78
   }
   ```
6. Click **Send**

## Step 10: Submit Player Statistics

1. Create a new request: **POST**
2. URL: `http://localhost:8000/api/games/1/stats` (use your game ID)
3. Authorization: Bearer Token
4. Headers: `Content-Type: application/json`
5. Body (JSON):
   ```json
   {
       "stats": [
           {
               "player_id": 1,
               "points": 25,
               "assists": 8,
               "rebounds": 10,
               "fouls": 3
           }
       ]
   }
   ```
6. Click **Send**

## Step 11: View Results

### 11.1 Check Standings
1. Create a new request: **GET**
2. URL: `http://localhost:8000/api/seasons/1/standings` (use your season ID)
3. Authorization: Bearer Token
4. Click **Send** - you should see team standings

### 11.2 Check Leaderboard
1. Create a new request: **GET**
2. URL: `http://localhost:8000/api/seasons/1/leaderboard`
3. Authorization: Bearer Token
4. Click **Send** - you should see top players

### 11.3 View Player Profile
1. Create a new request: **GET**
2. URL: `http://localhost:8000/api/players/1/profile`
3. Authorization: Bearer Token
4. Click **Send** - you should see player career stats

## Step 12: Test Validation Rules

### 12.1 Test Duplicate Game
1. Try to schedule the same game again (same teams)
2. You should get a 422 error with message about duplicate matchup

### 12.2 Test Same Date Conflict
1. Try to schedule a game with same team on same date
2. You should get a 422 error about date conflict

## Troubleshooting

### If you get 401 Unauthorized:
- Check that your Authorization header is set correctly
- Verify your token is not expired
- Make sure you're using Bearer Token type

### If you get 404 Not Found:
- Verify the resource ID exists
- Check that the resource belongs to your user

### If you get 422 Validation Error:
- Check the response body for specific error messages
- Verify all required fields are present
- Check data types and formats

### If you get 500 Server Error:
- Check Laravel logs with: `php artisan log:tail`
- Verify database migrations ran successfully

## Success Indicators

✅ You can register and login successfully
✅ You can create leagues, seasons, and teams
✅ You can schedule games with validation
✅ You can submit results and player stats
✅ Standings show correct W-L records
✅ Leaderboard shows top players by points
✅ Validation rules prevent duplicate games and date conflicts

If all these steps work, your API is functioning correctly!
