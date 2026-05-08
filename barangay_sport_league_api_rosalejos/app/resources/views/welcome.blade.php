<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Barangay Sport League API Manual</title>
    <style>
        :root {
            --primary-red: #ff4d4d;
            --bg-gradient: linear-gradient(135deg, #2e004d 0%, #000000 100%);
            --card-bg: rgba(255, 255, 255, 0.05);
            --text-color: #e0e0e0;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            color: var(--text-color);
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 20px;
        }

        header {
            text-align: center;
            margin-bottom: 60px;
        }

        h1 {
            color: var(--primary-red);
            font-size: 3rem;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 2px;
        }

        .subtitle {
            font-size: 1.2rem;
            opacity: 0.8;
        }

        section {
            background: var(--card-bg);
            border-left: 4px solid var(--primary-red);
            padding: 30px;
            margin-bottom: 30px;
            border-radius: 0 10px 10px 0;
            backdrop-filter: blur(5px);
        }

        h2 {
            color: var(--primary-red);
            margin-top: 0;
            border-bottom: 1px solid rgba(255, 77, 77, 0.3);
            padding-bottom: 10px;
        }

        h3 {
            color: var(--primary-red);
            margin-top: 20px;
        }

        ul {
            list-style-type: none;
            padding-left: 0;
        }

        li {
            margin-bottom: 15px;
            padding-left: 20px;
            position: relative;
        }

        li::before {
            content: "•";
            color: var(--primary-red);
            position: absolute;
            left: 0;
            font-weight: bold;
        }

        code {
            background: rgba(255, 77, 77, 0.1);
            color: var(--primary-red);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'Courier New', Courier, monospace;
        }

        .endpoint {
            display: inline-block;
            background: #333;
            color: #fff;
            padding: 5px 10px;
            border-radius: 5px;
            margin-bottom: 10px;
            font-size: 0.9rem;
        }

        .method {
            font-weight: bold;
            color: var(--primary-red);
            margin-right: 10px;
        }

        footer {
            text-align: center;
            margin-top: 60px;
            opacity: 0.6;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1 style="margin-bottom: -2.5%">Barangay Sport League API</h1>
            <h3>by Sean Earl A. Rosalejos</h3>
            <p class="subtitle">A robust management system for local sports competitions</p>
        </header>

        <section id="description">
            <h2>Overview</h2>
            <p>This API provides a comprehensive suite of tools for administrators to manage sports leagues, seasons, teams, and players. It handles everything from secure authentication to complex game scheduling and automated standings computation.</p>
        </section>

        <section id="auth">
            <h2>Authentication</h2>
            <p>Built with <strong>Laravel Sanctum</strong>, the API ensures secure access through token-based authentication.</p>
            <ul>
                <li><strong>Registration:</strong> New admins can register and receive an access token immediately.</li>
                <li><strong>Login:</strong> Secure credentials verification with token issuance.</li>
                <li><strong>Protection:</strong> All management endpoints are protected. Clients must send a <code>Bearer Token</code> in the Authorization header.</li>
            </ul>
        </section>

        <section id="scheduling">
            <h2>Game Scheduling Logic</h2>
            <p>The system implements strict business rules to ensure fair and valid season progression:</p>
            <ul>
                <li><strong>Season Integrity:</strong> Both home and away teams must belong to the same season.</li>
                <li><strong>No Self-Play:</strong> A team cannot be scheduled to play against itself.</li>
                <li><strong>No Duplicate Matchups:</strong> Prevents scheduling the same two teams multiple times in the same season (regardless of home/away status).</li>
                <li><strong>Conflict Prevention:</strong> Ensures no team has more than one game scheduled on any given calendar date.</li>
            </ul>
        </section>

        <section id="standings">
            <h2>Results & Standings</h2>
            <p>Automated computation of league rankings based on game outcomes:</p>
            <ul>
                <li><strong>Status Management:</strong> Games transition from <code>scheduled</code> to <code>done</code> upon result submission.</li>
                <li><strong>Dynamic Computation:</strong> Win-Loss records are calculated in real-time by analyzing completed games.</li>
                <li><strong>Leaderboards:</strong> Aggregates individual player statistics (points, assists, rebounds) across the entire season to identify top performers.</li>
            </ul>
        </section>

        <section id="profiles">
            <h2>Player Career Profiles</h2>
            <p>Track player progress across multiple seasons and teams:</p>
            <ul>
                <li><strong>History:</strong> Comprehensive list of all teams and seasons a player has participated in.</li>
                <li><strong>Career Totals:</strong> Cumulative stats for games played, points, assists, and rebounds.</li>
                <li><strong>Personal Bests:</strong> Highlights the player's highest-scoring single-game performance.</li>
            </ul>
        </section>

        <section id="endpoints">
            <h2>Quick Reference</h2>
            <div>
                <span class="endpoint"><span class="method">POST</span>/api/register</span>
                <span class="endpoint"><span class="method">POST</span>/api/login</span>
                <span class="endpoint"><span class="method">GET</span>/api/leagues</span>
                <span class="endpoint"><span class="method">GET</span>/api/seasons/{id}/standings</span>
                <span class="endpoint"><span class="method">GET</span>/api/players/{id}/profile</span>
            </div>
        </section>

        <footer>
            &copy; {{ date('Y') }} Barangay Sport League API. Built for excellence.
        </footer>
    </div>
</body>
</html>
