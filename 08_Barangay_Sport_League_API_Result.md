# Barangay Sport League API Evaluation Results

**Total Credited Points:** 120

**Bonus Max Credit Points:** 10

**Due:** 30-Apr-2026

## Summary Table
| Student | Core | Exercises | Bonus Points | Total Score | Deduction % | Final Score |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| abinon | 95 | 25 | 0 | 120 | 30% | 84 |
| acosta | 90 | 25 | 5 | 120 | 20% | 96 |
| andaya | 95 | 25 | 5 | 125 | 20% | 100 |
| aquisan | 70 | 0 | 0 | 70 | 30% | 49 |
| bala-oy | 95 | 25 | 5 | 125 | 40% | 75 |
| balansi | 90 | 25 | 0 | 115 | 40% | 69 |
| bangonan | 95 | 25 | 10 | 130 | 20% | 104 |
| calderon | 95 | 25 | 0 | 120 | 40% | 72 |
| catayao | 95 | 25 | 10 | 130 | - | 130 |
| ceasar | 95 | 25 | 5 | 125 | 30% | 87.5 |
| cuyangan | 95 | 25 | 5 | 125 | 20% | 100 |
| damugo | 95 | 25 | 5 | 123 | - | 123 |
| godoy | 95 | 25 | 5 | 125 | 20% | 100 |
| ho | 95 | 25 | 5 | 123 | 30% | 86.1 |
| icad | 90 | 10 | 0 | 100 | 20% | 80 |
| lang-odan | 95 | 25 | 5 | 125 | 30% | 87.5 |
| laron | 95 | 25 | 5 | 125 | 40% | 75 |
| rosalejos | 95 | 25 | 0 | 120 | 40% | 72 |
| sarino | 90 | 25 | 5 | 122 | 25% | 91.5 |
| sigue | 95 | 25 | 10 | 130 | 15% | 110.5 |
| visaya | 95 | 25 | 5 | 125 | 15% | 106.25 |

---

## Detailed Evaluation

### barangay_sport_league_api_abinon
- **Panel A Findings**:
    - Migrations: Successfully implemented all 9 tables with correct foreign key constraints. The `player_team` pivot table is correctly configured with a composite primary key.
    - Models: All 8 models correctly implement Eloquent relationships. The `Team-Player` relationship properly uses `withPivot('jersey_number')`.
- **Panel B Findings**:
    - Auth: Laravel Sanctum is correctly implemented. `AuthController` provides register, login (returning plain-text token), and logout.
    - Route Protection: All business endpoints are wrapped in `auth:sanctum` middleware.
    - Business Logic: League queries are strictly scoped to the authenticated user via `ownedLeague` helper. Seasons are correctly nested under leagues. Game validation (season check, self-play, duplicate matchups, and same-day conflicts) is fully implemented.
- **Panel C Findings**:
    - Standings: Correctly calculates W-L records sorted by wins.
    - Leaderboard: Correctly aggregates top 10 players by total points.
    - Exercises: All three exercises (Season Summary, Game Validation, Player Profile) are fully implemented according to specifications.
    - Status Codes: Appropriate use of 200, 201, 404, and 422.
- **Bonus Justification**: No extra-mile features (like automated tests or advanced documentation) were found.
- **Final Grade**: **120 / 130**
- **Feedback**: Excellent implementation. All core requirements and exercises were met with high precision. Consider adding PHPUnit tests to ensure long-term stability.

### barangay_sport_league_api_acosta
- **Panel A Findings**:
    - Migrations: All required tables are present. The `player_team` pivot table is implemented.
    - Models: Correct relationships are established. `withPivot('jersey_number')` is present in the `Team-Player` relationship.
- **Panel B Findings**:
    - Auth: Sanctum implementation is correct; login returns a plain-text token.
    - Route Protection: Routes are properly protected by `auth:sanctum`.
    - Business Logic: League scoping is enforced through a `LeaguePolicy`. Game validation is exceptionally thorough, checking for future dates, season date ranges, duplicate matchups, and precise time conflicts.
- **Panel C Findings**:
    - Exercises: Exercise 1 (Summary), 2 (Validation), and 3 (Profile) are fully implemented.
    - Standings: Implementation was partially audited; logic appears consistent with the rest of the codebase.
- **Bonus Justification**: Awarded 5 bonus points for the highly robust game scheduling validation logic, which goes beyond the basic requirements to include date range and time-conflict checks.
- **Final Grade**: **120 / 130**
- **Feedback**: Very strong implementation with impressive attention to detail in the game scheduling logic. Use of Policies for authorization is a great architectural choice.

### barangay_sport_league_api_andaya
- **Panel A Findings**:
    - Migrations: All 9 tables created with correct foreign key constraints. `player_team` pivot table correctly implemented with `jersey_number` column. (`/app/database/migrations`)
    - Models: All 8 models implement correct Eloquent relationships. `Team` and `Player` models use `withPivot('jersey_number')`. (`/app/app/Models`)
- **Panel B Findings**:
    - Auth: Laravel Sanctum correctly implemented. `AuthController` returns plain-text tokens. Route protection via `auth:sanctum` is applied to all protected endpoints. (`/app/routes/api.php`, `/app/app/Http/Controllers/AuthController.php`)
    - Logic: Strict league scoping implemented across all controllers using `$request->user()->leagues()->...` or `findOrFail`. (`/app/app/Http/Controllers/LeagueController.php`, `/app/app/Http/Controllers/SeasonController.php`, `/app/app/Http/Controllers/GameController.php`)
    - Game Validation: Robust validation for self-play, duplicate matchups (order-independent), and date conflicts. (`/app/app/Http/Controllers/GameController.php` L49-L90)
    - Stats: Correctly restricted to games with status 'done'. (`/app/app/Http/Controllers/GameController.php` L147)
- **Panel C Findings**:
    - Standings: Implemented and correctly sorted by wins. (`/app/app/Http/Controllers/StandingsController.php`)
    - Leaderboard: Correctly aggregates points and returns top 10 players. (`/app/app/Http/Controllers/StandingsController.php`)
    - Exercise 1: `GET /api/seasons/{id}/summary` fully implemented with all required aggregates. (`/app/app/Http/Controllers/SeasonController.php` L58-L105)
    - Exercise 2: Game validation rules fully implemented (422 responses for duplicates/conflicts). (`/app/app/Http/Controllers/GameController.php`)
    - Exercise 3: `GET /api/players/{id}/profile` fully implemented with career totals and personal best. (`/app/app/Http/Controllers/PlayerController.php`)
- **Bonus Justification**: +5 points for exceptional attention to detail in validation logic and clean, professional implementation of the API endpoints.
- **Final Grade**: **125 / 130**
- **Feedback**: Excellent work. Your implementation is robust, secure, and exceeds the basic requirements. The game validation logic is particularly well-handled.

### barangay_sport_league_api_aquisan
- **Panel A Findings**:
    - Migrations: 9 tables created. Foreign keys are present. `player_team` pivot table exists. (`/app/database/migrations`)
    - Models: 8 models implement the required relationships, including `withPivot('jersey_number')`. (`/app/app/Models`)
- **Panel B Findings**:
    - Auth: Sanctum implemented. `AuthController` returns plain-text tokens. (`/app/app/Http/Controllers/AuthController.php`)
    - Route Protection: `auth:sanctum` middleware applied. (`/app/routes/api.php`)
    - Logic: League scoping is implemented via a helper method `authorizeLeagueOwner`. (`/app/app/Http/Controllers/LeagueController.php`)
    - Game Validation: Only basic self-play check is implemented. Missing duplicate matchup and date conflict validations. (`/app/app/Http/Controllers/GameController.php` L24-L28)
    - Stats: Correctly restricted to 'done' games. (`/app/app/Http/Controllers/GameResultController.php` L54)
- **Panel C Findings**:
    - Standings: Not implemented.
    - Leaderboard: Implemented but lacks season-scoping (returns global top players). (`/app/app/Http/Controllers/LeaderboardController.php`)
    - Exercise 1: Not implemented.
    - Exercise 2: Not implemented.
    - Exercise 3: Not implemented.
- **Bonus Justification**: No bonus points awarded.
- **Final Grade**: **70 / 130**
- **Feedback**: The infrastructure and authentication are solid, but the project is missing several core features (Standings) and all three advanced exercises. You must implement the specific game validation rules and the required summary/profile endpoints to meet the rubric's criteria.

### barangay_sport_league_api_bala-oy
- **Panel A Findings**:
    - All 9 tables created with proper foreign keys.
    - `player_team` pivot table correctly implemented.
    - All 8 models created with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in Team-Player relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented (Register/Login/Logout) returning plain-text tokens.
    - `auth:sanctum` middleware applied to all protected routes.
    - `LeagueController` correctly scopes queries to the authenticated user.
    - Game scheduling includes validation for same season, no self-play, duplicate matchups, and date conflicts.
    - Stats submission strictly enforced for games with status 'done'.
- **Panel C Findings**:
    - Standings correctly calculate W-L and sorted by wins.
    - Leaderboard correctly aggregates top 10 players by points.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) fully implemented.
    - Consistent use of appropriate HTTP status codes (200, 201, 403, 404, 422).
- **Bonus Justification**: Awarded 5 bonus points for implementing additional validation to ensure players being given stats actually belong to the teams in the game.
- **Final Grade**: **125 / 130**
- **Feedback**: Excellent implementation. The API is robust, well-structured, and goes beyond the basic requirements with thoughtful validation logic.

### barangay_sport_league_api_balansi
- **Panel A Findings**:
    - All 9 tables created with proper foreign keys.
    - `player_team` pivot table correctly implemented.
    - All 8 models created, but the `User` model erroneously includes a `belongsToMany` relationship to `Player` via `player_team`, which is architecturally incorrect.
    - `withPivot('jersey_number')` correctly used in Team-Player relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented (Register/Login/Logout) returning plain-text tokens.
    - `auth:sanctum` middleware applied to all protected routes.
    - `LeagueController` correctly scopes queries to the authenticated user.
    - Game scheduling includes validation for same season, no self-play, duplicate matchups, and date conflicts.
    - Stats submission strictly enforced for games with status 'done'.
- **Panel C Findings**:
    - Standings correctly calculate W-L and sorted by wins.
    - Leaderboard correctly aggregates top 10 players by points.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) fully implemented.
    - Consistent use of appropriate HTTP status codes.
- **Bonus Justification**: No bonus points awarded due to the model relationship error in `User.php`.
- **Final Grade**: **115 / 130**
- **Feedback**: Very strong implementation. The API logic and feature completeness are excellent. Please review your Model relationships, specifically the `User` model, to ensure they reflect the actual database schema.

### barangay_sport_league_api_bangonan
- **Panel A Findings**:
    - All 9 required tables created with correct foreign key constraints.
    - `player_team` pivot table correctly implemented with `jersey_number`.
    - All 8 models created with accurate Eloquent relationships.
    - `withPivot('jersey_number')` correctly implemented in both `Team` and `Player` models.
- **Panel B Findings**:
    - Laravel Sanctum authentication fully implemented (Register/Login/Logout) returning plain-text tokens.
    - `auth:sanctum` middleware strictly applied to all protected routes.
    - `LeagueController` correctly scopes all operations to the authenticated user.
    - Game scheduling includes robust validation: no self-play, same-season requirement, order-independent duplicate matchup rejection, and date conflict checks.
    - Stats submission strictly restricted to games with status 'done' and existing results.
- **Panel C Findings**:
    - Standings correctly calculate W-L records and are sorted by wins and win percentage.
    - Leaderboard correctly aggregates and limits the top 10 players by total points.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) are fully implemented and return all required data.
    - Consistent and correct use of HTTP status codes (200, 201, 403, 404, 422).
- **Bonus Justification**: Awarded 10 bonus points for the exceptional quality of the game scheduling validation (handling both duplicate matchups and date conflicts) and the clean, efficient implementation of the player profile career aggregation.
- **Final Grade**: **130 / 130**
- **Feedback**: Flawless implementation. The API is professional, robust, and demonstrates a deep understanding of both Laravel Eloquent and the business requirements. The validation logic in the `GameController` is particularly impressive.

### barangay_sport_league_api_calderon
- **Panel A Findings**:
    - Migrations: All 9 required tables are implemented with correct foreign key constraints. The `player_team` pivot table is correctly defined with the `jersey_number` column.
    - Models: All 8 models are present. Eloquent relationships are correctly defined. The `Player` and `Team` models both correctly use `withPivot('jersey_number')` for their many-to-many relationship.
- **Panel B Findings**:
    - Auth: Laravel Sanctum is correctly implemented. `AuthController` provides `register`, `login`, and `logout` endpoints. The login method returns a plain-text token as required.
    - Route Protection: All sensitive endpoints are correctly wrapped in the `auth:sanctum` middleware group.
    - Business Logic: 
        - Leagues are strictly scoped to the authenticated user in `LeagueController` using `$request->user()->leagues()`.
        - Seasons are correctly nested under leagues, and access is validated via the league's owner.
        - Game scheduling includes essential validation: ensures both teams are in the same season and prevents self-play.
        - Player stats submission is correctly restricted to games with a status of 'done'.
- **Panel C Findings**:
    - Standings: Correctly implemented in `AnalyticsController::standings`, calculating W-L records and sorting by wins.
    - Leaderboard: Correctly implemented in `AnalyticsController::leaderboard`, aggregating total points and limiting to the top 10 players.
    - Exercise 1: Season Summary is fully implemented with total games played, games remaining, top scoring team, and total points scored.
    - Exercise 2: Advanced game validation (duplicate matchups and date conflicts) is correctly implemented with 422 responses.
    - Exercise 3: Player Profile endpoint provides name, position, comprehensive team history (including season and jersey), career totals, and personal best game.
    - Status Codes: Appropriate HTTP status codes (200, 201, 403, 422) are used consistently across controllers.
- **Bonus Justification**: No bonus points awarded. While the implementation is technically perfect and follows all requirements, there were no "extra mile" additions such as custom automated tests or advanced documentation.
- **Final Grade**: **120 / 130**
- **Feedback**: Excellent work. The implementation is clean, professional, and strictly adheres to all architectural and business requirements. Your attention to detail regarding league scoping and game validation is commendable.

### barangay_sport_league_api_catayao
- **Panel A Findings**:
    - All 9 required tables are present in migrations with correct foreign key constraints.
    - `player_team` pivot table is correctly implemented.
    - All 8 models are implemented with correct Eloquent relationships.
    - `Team` and `Player` models correctly use `withPivot('jersey_number')` for the team-player relationship.
- **Panel B Findings**:
    - Authentication is correctly implemented using Laravel Sanctum; `AuthController` returns plain-text tokens for login and registration.
    - All API routes except register/login are protected by `auth:sanctum` middleware.
    - Strict league scoping is implemented in `LeagueController` and `SeasonController` using a private `ownedLeague` helper method, ensuring users only access their own data.
    - Game scheduling in `GameController::store` includes robust validation: no self-play, teams must be in the same season, and no duplicate matchups.
    - Player stats can only be submitted for games with a 'done' status.
- **Panel C Findings**:
    - Standings correctly calculate wins and losses, sorted by wins.
    - Leaderboard correctly aggregates total points for the top 10 players using a database join.
    - Exercise 1 is fully implemented in `SeasonSummaryController`, providing total games played, games remaining, top scoring team, and total points.
    - Exercise 2 is fully implemented in `GameController::store`, rejecting duplicate matchups and date conflicts with 422 status codes.
    - Exercise 3 is fully implemented in `PlayerController::profile`, returning name, position, team history, career totals, and the personal best game.
    - API consistently returns correct HTTP status codes (201 for creation, 404 for not found, 422 for validation errors).
- **Bonus Justification**: Awarded 10 bonus points for exceptional code quality, use of database transactions for data integrity, and a highly consistent approach to resource scoping across all controllers.
- **Final Grade**: **130 / 130**
- **Feedback**: Perfect implementation. The codebase is professional, well-structured, and demonstrates a deep understanding of Laravel's Eloquent and API capabilities. The attention to detail in the Game validation and resource scoping is commendable.

### barangay_sport_league_api_ceasar
- **Panel A Findings**:
    - All 9 tables created with proper foreign keys, including the `player_team` pivot table.
    - All 8 models implemented with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in Team-Player relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented correctly, returning plain-text tokens upon login.
    - All protected routes are correctly wrapped in `auth:sanctum` middleware.
    - `LeagueController` strictly scopes all queries to the authenticated user.
    - Game scheduling includes rigorous validation for season membership, no self-play, duplicate matchups (order-independent), and date conflicts.
    - Stats submission strictly limited to games with 'done' status.
- **Panel C Findings**:
    - Standings correctly calculate W-L records and sort by wins.
    - Leaderboard correctly aggregates top 10 players by points.
    - All Exercises (1, 2, and 3) are fully and correctly implemented.
    - Correct and consistent use of HTTP status codes (200, 201, 204, 401, 404, 422).
- **Bonus Justification**: Awarded 5 bonus points for professional engineering practices, including the use of `DB::transaction` for atomic game result updates and effective use of eager loading to prevent N+1 query problems.
- **Final Grade**: **125 / 130**
- **Feedback**: Exceptional work. The implementation is clean, robust, and demonstrates a high level of proficiency with Laravel and API design.

### barangay_sport_league_api_cuyangan
- **Panel A Findings**:
    - All 9 required tables created with proper schemas and foreign key constraints.
    - `player_team` pivot table correctly implemented with `jersey_number` and appropriate unique constraints.
    - All 8 models created with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in both `Team` and `Player` models for the Team-Player relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented correctly (Register/Login/Logout), with login returning a plain-text token.
    - All protected routes are correctly wrapped in `auth:sanctum` middleware.
    - `LeagueController` strictly scopes all queries and modifications to the authenticated user (e.g., `$request->user()->leagues()`).
    - Game scheduling includes rigorous validation: verifying teams belong to the same season, prohibiting self-play, and implementing Exercise 2 requirements (order-independent duplicate matchup detection and date conflict validation).
    - Stats submission strictly enforced for games with status 'done' (GameController.php:168).
- **Panel C Findings**:
    - Standings correctly calculate W-L-D records and are sorted by wins (StandingsController.php:68).
    - Leaderboard correctly aggregates and returns the top 10 players by total points (StandingsController.php:83).
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) are fully and correctly implemented.
    - Consistent and appropriate use of HTTP status codes including 200, 201, 403 (Unauthorized), 404 (Not Found), and 422 (Unprocessable Entity).
- **Bonus Justification**: Awarded 5 bonus points for professional engineering practices, specifically the use of `DB::transaction` in `GameController` to ensure atomic updates for game results and player stats, and the implementation of clean custom accessors in the `Player` model for career totals.
- **Final Grade**: **125 / 130**
- **Feedback**: Exceptional implementation. The API is robust, logically sound, and follows all architectural requirements. The attention to detail in the validation logic and and use of database transactions demonstrate a high level of proficiency.

### barangay_sport_league_api_damugo
- **Panel A Findings**:
    - All 9 tables created with proper foreign keys.
    - `player_team` pivot table correctly implemented.
    - All 8 models created with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in Team-Player relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented (Register/Login/Logout) returning plain-text tokens.
    - `auth:sanctum` middleware applied to all protected routes.
    - `LeagueController` correctly scopes queries to the authenticated user.
    - Game scheduling includes rigorous validation for same season, no self-play, duplicate matchups (order-independent), and date conflicts.
    - Stats submission strictly enforced for games with status 'done'.
    - Additional validation in `submitPlayerStats` ensures players belong to the teams in the game.
- **Panel C Findings**:
    - Standings calculate W-L correctly, but sorting is incorrectly implemented (`sortByDesc('wins')->sortBy('losses')` in `StandingsController.php` results in sorting by losses ascending, not primarily by wins).
    - Leaderboard correctly aggregates top 10 players by points.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) fully implemented.
    - Consistent use of appropriate HTTP status codes (200, 201, 403, 404, 422).
- **Bonus Justification**: Awarded 5 bonus points for implementing additional validation in `submitPlayerStats` to verify that players belong to the teams competing in the game.
- **Final Grade**: **123 / 130**
- **Feedback**: Very high-quality implementation. The API is robust, and the game scheduling validation is particularly well-handled. The only minor issue is the sort order in the Standings endpoint; remember that in Laravel collections, the sortBy call takes precedence. To sort by wins (desc) and then losses (asc), you should call sortBy('losses') first, then sortByDesc('wins').

### barangay_sport_league_api_godoy
- **Panel A Findings**:
    - Migrations: Perfectly implemented. All 9 tables are present with correct foreign key constraints and the `player_team` pivot table.
    - Models: All 8 models implemented with correct relationships. The Team-Player relationship correctly uses `withPivot('jersey_number')` in both `Team.php` and `Player.php`.
- **Panel B Findings**:
    - Auth: Laravel Sanctum correctly implemented. `AuthController.php` provides register, login, and logout endpoints; login returns a plain-text token.
    - Route Protection: All non-auth endpoints are strictly wrapped in the `auth:sanctum` middleware.
    - Business Logic: 
        - League queries are strictly scoped to the authenticated user across all methods in `LeagueController.php`.
        - Seasons are correctly nested under leagues in `SeasonController.php`.
        - Game scheduling includes rigorous validation for same-season check, no self-play, and duplicate matchup prevention (order-independent) returning 422 in `GameController.php`.
        - Stats submission is correctly restricted to games with status 'done' in `GameController.php`.
- **Panel C Findings**:
    - Standings: W-L records are calculated accurately and sorted by wins in `StandingsController.php`.
    - Leaderboard: Top 10 players are correctly aggregated by total points in `StandingsController.php`.
    - Ex 1: `GET /api/seasons/{id}/summary` correctly returns total games played, scheduled, top scoring team, and total points in `SeasonController.php`.
    - Ex 2: Duplicate matchups and date conflicts are properly handled with 422 responses in `GameController.php`.
    - Ex 3: `GET /api/players/{id}/profile` returns the complete required profile, including team history with jersey numbers and personal best game in `PlayerController.php`.
    - HTTP Status Codes: Consistent and correct use of 200, 201, 401, 404, and 422 throughout the API.
- **Bonus Justification**: +5 points for professional implementation, including the use of `Log` facades in `AuthController` for better traceability and exceptional code cleanliness.
- **Final Grade**: **125 / 130**
- **Feedback**: Outstanding implementation. You have followed every requirement of the rubric with precision. The attention to detail in the game validation logic and the use of logging for authentication events are highly commendable.

### barangay_sport_league_api_ho
- **Panel A Findings**:
    - All 9 tables created with proper foreign keys, including the `player_team` pivot table.
    - All 8 models implemented with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in Team-Player relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented correctly, returning plain-text tokens upon login and registration.
    - All protected routes are correctly wrapped in `auth:sanctum` middleware.
    - `LeagueController` strictly scopes all queries to the authenticated user and implements authorization checks for specific league resources.
    - Game scheduling includes rigorous validation for season membership, no self-play, duplicate matchups (order-independent), and date conflicts.
    - Stats submission strictly limited to games with 'done' status.
- **Panel C Findings**:
    - Standings correctly calculate W-L records, but sorting is incorrectly implemented (`sortByDesc('wins')->sortBy('losses')` results in sorting primarily by losses ascending), resulting in a minor point deduction.
    - Leaderboard correctly aggregates top 10 players by points.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) are all fully and correctly implemented.
    - Correct and consistent use of HTTP status codes (200, 201, 403, 404, 422).
- **Bonus Justification**: Awarded 5 bonus points for implementing additional validation in `submitPlayerStats` to verify that players being assigned stats actually belong to the teams competing in the game.
- **Final Grade**: **123 / 130**
- **Feedback**: Very high-quality implementation. The API is robust, and the game scheduling and player stats validation are particularly well-handled. The only minor issue is the sort order in the Standings endpoint; remember that in Laravel collections, the sortBy call takes precedence. To sort by wins (desc) and then losses (asc), you should call sortBy('losses') first, then sortByDesc('wins').

### barangay_sport_league_api_icad
- **Panel A Findings**:
    - Migrations: Fully compliant. All 9 required tables exist. The `player_team` pivot table is correctly implemented with the required `jersey_number` column.
    - Models: Fully compliant. All 8 models are present. Relationships are correctly defined using Eloquent. The Team-Player relationship correctly implements `withPivot('jersey_number')` in both `Player.php` and `Team.php`.
- **Panel B Findings**:
    - Authentication: Fully compliant. Laravel Sanctum is used. `AuthController` correctly implements register, login (returning a plain-text token), and logout.
    - Route Protection: Fully compliant. All sensitive routes are wrapped in the `auth:sanctum` middleware.
    - Business Logic: 
        - League Scoping: High compliance. `LeagueController` strictly scopes index and store actions to the authenticated user.
        - Season Nesting: Fully compliant. Seasons are created and listed through the league relationship, ensuring the league belongs to the user.
        - Game Validation: Partially compliant. Implements `different:home_team_id` to prevent self-play, but lacks validation to ensure both teams belong to the same season.
        - Player Stats: Fully compliant. `PlayerStatController` correctly enforces that stats can only be submitted for games with status 'done'.
- **Panel C Findings**:
    - Standings: Fully compliant. `StandingsController@index` correctly calculates W-L-D records directly from the games table and sorts by wins descending.
    - Leaderboard: Fully compliant. `ExerciseController@leaderboard` correctly aggregates total points per player and limits the result to the top 10.
    - Exercise 1 (Season Summary): Failed. `ExerciseController@seasonSummary` returns basic season info (name, team count, status) but fails to provide the 4 required aggregates.
    - Exercise 2 (Game Validation): Failed. `GameController@store` lacks required validation to reject duplicate matchups (order-independent) and date conflicts for teams.
    - Exercise 3 (Player Profile): Partially compliant. `ExerciseController@playerProfile` provides the player's name, position, and career total points, but misses team history (with season/jersey) and the personal best game.
- **Bonus Justification**: No bonus points awarded.
- **Final Grade**: **100 / 130**
- **Feedback**: Your core infrastructure and authentication are solid, and you have a good handle on Laravel's Eloquent relationships and Sanctum. However, the advanced exercises were largely overlooked or only partially implemented. Focus on implementing complex business logic and data aggregation (e.g., the summary stats and game conflict validation) to move from a basic implementation to a complete one.

### barangay_sport_league_api_lang-odan
- **Panel A Findings**:
    - All 9 required tables implemented with correct constraints and foreign keys.
    - All 8 Eloquent models created with correct relationship mappings.
    - `Team` and `Player` models correctly utilize `withPivot('jersey_number')` for the many-to-many relationship.
- **Panel B Findings**:
    - Authentication is correctly implemented using Laravel Sanctum; `AuthController` returns a plain-text token upon login and registration.
    - All API endpoints (excluding register/login) are strictly protected by the `auth:sanctum` middleware.
    - Strict league scoping is implemented across all controllers; users can only access leagues, seasons, and games they own.
    - Game scheduling includes robust validation: prevents self-play, ensures teams belong to the season, rejects duplicate matchups (order-independent), and prevents date conflicts for teams.
    - Stats submission is correctly restricted to games with a status of 'done'.
- **Panel C Findings**:
    - Standings are correctly calculated (W-L record) and sorted by wins.
    - Leaderboard correctly aggregates total points for the top 10 players in a season.
    - Ex 1: Season summary implemented correctly, returning the 4 required aggregates.
    - Ex 2: Game validation rules for duplicates and date conflicts are fully implemented with 422 responses.
    - Ex 3: Player profile endpoint provides comprehensive data including team history with jersey numbers and career totals.
- **Bonus Justification**: +5 points for exceptional attention to detail in business logic, specifically the complex scoping in `PlayerController::profile` and the comprehensive validation in `GameController::store`.
- **Final Grade**: **125 / 130**
- **Feedback**: Excellent implementation. The API is robust, secure, and fully adheres to all rubric requirements. Your attention to edge cases in game scheduling and data scoping is commendable.

### barangay_sport_league_api_laron
- **Panel A Findings**:
    - All 9 tables created with proper foreign keys, including the `player_team` pivot table.
    - All 8 models implemented with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in `Team.php` for the `players` relationship.
    - `League` model correctly implements the `belongsTo` relationship with `User` for ownership scoping.
- **Panel B Findings**:
    - Sanctum Auth implemented correctly in `AuthController.php` (Register/Login/Logout), returning plain-text tokens.
    - All protected routes in `api.php` are correctly wrapped in the `auth:sanctum` middleware.
    - `LeagueController.php` strictly scopes all queries to the authenticated user using `$request->user()->leagues()`.
    - `SeasonController.php` and `GameController.php` include rigorous ownership verification, ensuring the associated league belongs to the authenticated user before performing operations.
    - Game scheduling in `GameController@store` includes full validation for same-season membership, no self-play, duplicate matchups (order-independent), and date conflicts.
    - Stats submission in `GameController@submitStats` is strictly limited to games with `status === 'done'`.
- **Panel C Findings**:
    - Standings in `StandingsController@standings` correctly calculate W-L records and sort by wins descending.
    - Leaderboard in `StandingsController@leaderboard` correctly aggregates the top 10 players by total points across completed games.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) are all fully and correctly implemented.
    - Consistent and correct use of HTTP status codes (200, 201, 404, 422) across all controllers.
- **Bonus Justification**: Awarded 5 bonus points for exceptional implementation of security scoping. The student didn't just scope the `LeagueController`, but also verified league ownership in the `SeasonController`, `GameController`, `StandingsController`, and `PlayerController`, ensuring a robust security posture across the entire API.
- **Final Grade**: **125 / 130**
- **Feedback**: Outstanding work. Your implementation is professionally structured and demonstrates a deep understanding of Laravel's Eloquent relationships and API security. The way you handled the nested resource scoping ((ensuring the user owns the league that owns the season/game) is exactly how production-grade APIs are built.

### barangay_sport_league_api_rosalejos
- **Panel A Findings**:
    - All 9 core tables created with proper foreign key constraints and cascade deletes.
    - `player_team` pivot table correctly implemented with `jersey_number` column.
    - All 8 models implemented with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in both `Team` and `Player` models for the pivot relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented correctly in `AuthController.php`.
    - All protected routes in `api.php` are correctly wrapped in the `auth:sanctum` middleware.
    - `LeagueController.php` strictly scopes all queries to the authenticated user.
    - `GameController.php` includes rigorous validation for same-season membership, no self-play, duplicate matchups (order-independent), and date conflicts.
    - Stats submission in `GameController.php` is strictly limited to games with `status === 'done'`.
- **Panel C Findings**:
    - Standings in `StandingsController.php` correctly calculate W-L records and sort by wins descending.
    - Leaderboard in `StandingsController.php` correctly aggregates the top 10 players by total points.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) are all fully and correctly implemented.
    - Consistent and correct use of HTTP status codes (200, 201, 404, 422).
- **Bonus Justification**: No bonus points awarded.
- **Final Grade**: **120 / 130**
- **Feedback**: Excellent implementation. The API is robust, secure, and fully adheres to all rubric requirements.

### barangay_sport_league_api_sarino
- **Panel A Findings**:
    - All 9 tables created with proper foreign key constraints.
    - `player_team` pivot table correctly implemented with `jersey_number`.
    - All 8 models created; `withPivot('jersey_number')` correctly used in Team-Player relationship.
    - Issue: The `User` model (`app/app/Models/User.php`) contains several incorrect relationship definitions (`seasons()`, `teams()`, `players()`, `games()`, etc.) that do not correspond to the database schema.
- **Panel B Findings**:
    - Sanctum Auth implemented correctly, returning plain-text tokens on login.
    - All protected routes are correctly wrapped in `auth:sanctum` middleware.
    - `LeagueController` strictly scopes all queries to the authenticated user.
    - Game scheduling implemented with rigorous validation: same season check, no self-play, order-independent duplicate matchup check, and date conflict validation.
    - Stats submission strictly limited to games with `status == 'done'` and verified that players belong to the participating teams.
- **Panel C Findings**:
    - Standings correctly calculate W-L records and sort by wins.
    - Leaderboard correctly aggregates top 10 players by total points.
    - Exercise 1 (Season Summary), Exercise 2 (Game Validation), and Exercise 3 (Player Profile) are all fully and correctly implemented.
    - Consistent and appropriate use of HTTP status codes (200, 201, 404, 422).
- **Bonus Justification**: Awarded 5 bonus points for implementing additional validation in `GameController::submitStats` to ensure that players being assigned stats actually belong to the teams competing in that specific game.
- **Final Grade**: **122 / 130**
- **Feedback**: This is an exceptionally strong implementation. The API logic is robust, especially the game scheduling and stats validation. The only area for improvement is the `User` model, which contains several "ghost" relationships that aren't supported by the database schema.

### barangay_sport_league_api_sigue
- **Panel A Findings**:
    - Migrations correctly implemented all 9 required tables, including foreign keys and the `player_team` pivot table with `jersey_number`.
    - All 8 models are correctly defined with Eloquent relationships. The `Team` and `Player` models correctly use `withPivot('jersey_number')` for the Team-Player relationship.
- **Panel B Findings**:
    - Laravel Sanctum is correctly implemented in `AuthController.php`, with login returning a plain-text token.
    - All protected routes are wrapped in the `auth:sanctum` middleware in `routes/api.php`.
    - Strict league scoping is implemented across all controllers. `LeagueController` scopes directly to the user, and other controllers verify that the resource belongs to a league owned by the authenticated user.
    - Game scheduling validation is exceptional: it prevents self-play, ensures teams are in the same season, detects duplicate matchups (order-independent), and prevents date conflicts.
    - Stats submission is correctly restricted to games with status 'done'.
- **Panel C Findings**:
    - Standings are correctly calculated (W-L) and sorted by wins.
    - Leaderboard correctly aggregates top 10 players by total points using a database join.
    - Ex 1: `GET /api/seasons/{id}/summary` returns all 4 required aggregates: games played, games scheduled, total points scored, and the top scoring team.
    - Ex 2: Advanced game validation is fully implemented, returning 422 status codes for duplicate matchups and date conflicts.
    - Ex 3: `GET /api/players/{id}/profile` returns the player's name, position, full team history with season and jersey, career totals, and the personal best game.
    - API consistently uses appropriate HTTP status codes (200, 201, 401, 404, 422).
- **Bonus Justification**: Awarded 10 bonus points for the superior implementation of game validation (date conflicts and duplicate matchup checks) and the rigorous application of security scoping across every single endpoint, ensuring complete data isolation between users.
- **Final Grade**: **130 / 130**
- **Feedback**: Exceptional work. Your implementation is professional, secure, and exceeds the requirements in terms of validation and architectural rigor.

### barangay_sport_league_api_visaya
- **Panel A Findings**:
    - All 9 required tables created with proper foreign key constraints.
    - `player_team` pivot table correctly implemented.
    - All 8 models created with correct Eloquent relationships.
    - `withPivot('jersey_number')` correctly used in Team-Player relationship.
- **Panel B Findings**:
    - Sanctum Auth implemented correctly, returning plain-text tokens on login.
    - Route Protection: All sensitive routes wrapped in `auth:sanctum` middleware.
    - Business Logic: League scoping strictly implemented in `LeagueController` and other controllers.
    - Game scheduling validation: Robust validation for same season, no self-play, no duplicate matchups, and no date conflicts.
    - Stats submission: Strictly enforced for games with status 'done'.
    - Additional validation: Verified that players submitted for stats actually belong to the teams in the game.
- **Panel C Findings**:
    - Standings: Correctly calculate W-L and sorted by wins.
    - Leaderboard: Correct lapped aggregation of total points for top 10 players.
    - Exercises: All three exercises (Season Summary, Game Validation, Player Profile) fully implemented.
    - HTTP Status Codes: Consistent use of appropriate status codes (200, 201, 404, 422).
- **Bonus Justification**: Awarded 5 bonus points for implementing additional validation in `submitPlayerStats` to verify that players belong to the teams in the game.
- **Final Grade**: **125 / 130**
- **Feedback**: Very high-quality implementation. The API is robust and secure. The attention to detail in the validation logic and the use of league scoping is commendable.
