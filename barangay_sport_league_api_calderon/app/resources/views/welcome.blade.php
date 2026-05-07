<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Barangay Sport League | Admin</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700,800&display=swap" rel="stylesheet" />
    <style>
        :root {
            --laravel-red: #FF2D20;
            --slate-50: #0f172a;
            --slate-100: #1e293b;
            --slate-200: #334155;
            --slate-300: #475569;
            --slate-700: #94a3b8;
            --slate-800: #e2e8f0;
            --slate-900: #f8fafc;
            --gold: #fbbf24;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Figtree', sans-serif; background-color: var(--slate-50); color: var(--slate-900); line-height: 1.5; min-height: 100vh; }
        
        .container { max-width: 1200px; margin: 0 auto; padding: 2rem; }
        .hidden { display: none !important; }

        /* Auth Styles */
        .auth-card { background: var(--slate-100); padding: 2.5rem; border-radius: 1rem; box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.5); max-width: 450px; margin: 6rem auto; border: 1px solid var(--slate-200); }
        .auth-card h2 { margin-bottom: 2rem; text-align: center; color: var(--laravel-red); font-weight: 800; font-size: 2rem; }
        
        /* Form Styles */
        .form-group { margin-bottom: 1.25rem; }
        .password-wrapper { position: relative; }
        .password-toggle { position: absolute; right: 1rem; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--slate-700); cursor: pointer; padding: 0.25rem; display: flex; align-items: center; justify-content: center; }
        label { display: block; font-size: 0.875rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--slate-700); }
        input, select, textarea { width: 100%; background: var(--slate-50); color: var(--slate-900); padding: 0.75rem 1rem; border: 1px solid var(--slate-200); border-radius: 0.5rem; outline: none; transition: all 0.2s; font-size: 1rem; }
        input:focus { border-color: var(--laravel-red); box-shadow: 0 0 0 2px rgba(255, 45, 32, 0.2); }
        
        .btn { display: inline-flex; align-items: center; justify-content: center; padding: 0.75rem 1.25rem; border-radius: 0.5rem; font-weight: 700; cursor: pointer; border: none; transition: all 0.2s; text-decoration: none; font-size: 0.9375rem; gap: 0.5rem; }
        .btn-primary { background-color: var(--laravel-red); color: white; }
        .btn-secondary { background-color: var(--slate-200); color: var(--slate-900); }
        .btn-sm { padding: 0.4rem 0.8rem; font-size: 0.8125rem; }
        .btn:hover { opacity: 0.9; transform: translateY(-1px); }

        /* Navigation */
        nav { background: var(--slate-100); border-bottom: 1px solid var(--slate-200); padding: 1rem 0; sticky: top; z-index: 40; }
        .nav-content { display: flex; justify-content: space-between; align-items: center; max-width: 1200px; margin: 0 auto; padding: 0 2rem; }
        .logo { font-weight: 900; color: var(--laravel-red); font-size: 1.5rem; letter-spacing: -0.025em; }

        /* Tabs */
        .tabs { display: flex; border-bottom: 1px solid var(--slate-200); margin-bottom: 2rem; gap: 2rem; }
        .tab-btn { background: none; border: none; padding: 1rem 0; color: var(--slate-700); font-weight: 700; cursor: pointer; position: relative; font-size: 0.9375rem; }
        .tab-btn.active { color: var(--laravel-red); }
        .tab-btn.active::after { content: ''; position: absolute; bottom: -1px; left: 0; right: 0; height: 2px; background: var(--laravel-red); }

        /* Cards & Grids */
        .card { background: var(--slate-100); border: 1px solid var(--slate-200); border-radius: 0.75rem; padding: 1.5rem; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem; }
        
        /* Liquipedia-style Matches */
        .match-row { background: var(--slate-100); border: 1px solid var(--slate-200); border-radius: 0.5rem; display: flex; align-items: center; padding: 1rem; margin-bottom: 0.75rem; transition: background 0.2s; }
        .match-row:hover { background: var(--slate-200); }
        .match-team { flex: 1; text-align: center; font-weight: 700; font-size: 1.125rem; }
        .match-score { width: 100px; text-align: center; font-family: monospace; font-size: 1.5rem; font-weight: 800; background: var(--slate-50); padding: 0.25rem; border-radius: 0.25rem; margin: 0 1rem; }
        .match-info { font-size: 0.75rem; color: var(--slate-700); text-align: center; min-width: 150px; }

        /* Tables */
        table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
        th { text-align: left; padding: 1rem; background: var(--slate-200); color: var(--slate-900); font-size: 0.75rem; text-transform: uppercase; font-weight: 800; }
        td { padding: 1rem; border-bottom: 1px solid var(--slate-200); }
        tr:last-child td { border-bottom: none; }
        
        /* Stats Input Table */
        .stats-table input { width: 60px; padding: 0.25rem; font-size: 0.875rem; text-align: center; }

        .badge { display: inline-block; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.7rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em; }
        .badge-active { background: #065f46; color: #34d399; }
        .badge-done { background: var(--slate-300); color: var(--slate-900); }
        .badge-scheduled { background: #92400e; color: #fbbf24; }

        .header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
    </style>
</head>
<body>

    <div id="auth-view" class="hidden">
        <div class="auth-card">
            <h2 id="auth-title">Login</h2>
            <form id="auth-form">
                <div id="name-group" class="form-group hidden">
                    <label>Admin Name</label>
                    <input type="text" id="auth-name">
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" id="auth-email" required placeholder="admin@example.com">
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <div class="password-wrapper">
                        <input type="password" id="auth-password" required placeholder="••••••••">
                        <button type="button" class="password-toggle" onclick="togglePassword('auth-password', this)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        </button>
                    </div>
                </div>
                <div id="conf-password-group" class="form-group hidden">
                    <label>Confirm Password</label>
                    <div class="password-wrapper">
                        <input type="password" id="auth-conf-password" placeholder="••••••••">
                        <button type="button" class="password-toggle" onclick="togglePassword('auth-conf-password', this)">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                        </button>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary" id="auth-submit" style="width: 100%; margin-top: 1rem;">Sign In</button>
            </form>
            <p style="text-align: center; margin-top: 1.5rem; font-size: 0.875rem; color: var(--slate-700);">
                <a href="#" id="toggle-auth" style="color: var(--laravel-red); font-weight: 700;">Need an account? Create one</a>
            </p>
        </div>
    </div>

    <div id="main-view" class="hidden">
        <nav>
            <div class="nav-content">
                <div class="logo">
                    BARANGAY LEAGUE
                    <div style="font-size: 0.6rem; color: var(--slate-700); font-weight: 600; letter-spacing: 0.1em; margin-top: -0.25rem;">BY CALDERON</div>
                </div>
                <div style="display: flex; align-items: center; gap: 1.5rem;">
                    <span id="user-display" style="font-weight: 600; font-size: 0.875rem;"></span>
                    <button class="btn btn-secondary btn-sm" onclick="logout()">Logout</button>
                </div>
            </div>
        </nav>

        <div class="container">
            <!-- Global Nav -->
            <div id="nav-breadcrumb" class="hidden" style="margin-bottom: 1.5rem;">
                <button onclick="showLeagues()" class="btn btn-secondary btn-sm">&larr; Back to Leagues</button>
            </div>

            <!-- Leagues Section -->
            <section id="leagues-section">
                <div class="header-actions">
                    <h1>My Leagues</h1>
                    <button class="btn btn-primary" onclick="showCreateLeague()">+ Create League</button>
                </div>
                <div id="leagues-list" class="grid"></div>
            </section>

            <!-- Season Dashboard (The Liquipedia Core) -->
            <section id="season-dashboard" class="hidden">
                <div class="header-actions">
                    <div>
                        <h4 id="league-breadcrumb" style="color: var(--laravel-red); font-weight: 800; font-size: 0.75rem; text-transform: uppercase;"></h4>
                        <h1 id="season-title">Season Name</h1>
                    </div>
                    <div id="season-actions"></div>
                </div>

                <div class="tabs">
                    <button class="tab-btn active" onclick="switchTab('standings')">Standings</button>
                    <button class="tab-btn" onclick="switchTab('matches')">Matches</button>
                    <button class="tab-btn" onclick="switchTab('teams')">Teams</button>
                    <button class="tab-btn" onclick="switchTab('leaderboard')">Leaderboard</button>
                </div>

                <div id="tab-content">
                    <!-- Dynamic Content -->
                </div>
            </section>
        </div>
    </div>

    <!-- Modals -->
    <div id="modal-overlay" class="hidden" style="position: fixed; inset: 0; background: rgba(0,0,0,0.8); display: flex; align-items: center; justify-content: center; z-index: 100; padding: 1rem;">
        <div class="card" style="width: 100%; max-width: 600px; max-height: 90vh; overflow-y: auto;">
            <h2 id="modal-title" style="margin-bottom: 1.5rem; color: var(--laravel-red);">Action</h2>
            <form id="modal-form">
                <div id="modal-fields"></div>
                <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                    <button type="button" class="btn btn-secondary" onclick="closeModal()" style="flex: 1;">Cancel</button>
                    <button type="submit" class="btn btn-primary" style="flex: 2;">Confirm</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        let token = localStorage.getItem('bsl_token');
        let currentSeason = null;
        let currentLeague = null;
        let activeTab = 'standings';

        // --- Core Fetcher ---
        async function api(path, options = {}) {
            const res = await fetch(`/api${path}`, {
                ...options,
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    ...options.headers
                }
            });
            if (res.status === 401) logout();
            return res.ok ? res.json() : Promise.reject(await res.json());
        }

        // --- Auth ---
        window.onload = () => token ? checkAuth() : showAuth('login');

        function logout() { localStorage.removeItem('bsl_token'); location.reload(); }
        
        async function checkAuth() {
            try {
                const user = await api('/leagues'); // Simple check
                document.getElementById('main-view').classList.remove('hidden');
                showLeagues();
            } catch (e) { showAuth('login'); }
        }

        function showAuth(mode) {
            document.getElementById('auth-view').classList.remove('hidden');
            const isLogin = mode === 'login';
            document.getElementById('auth-title').innerText = isLogin ? 'Sign In' : 'Create Admin';
            document.getElementById('name-group').classList.toggle('hidden', isLogin);
            document.getElementById('conf-password-group').classList.toggle('hidden', isLogin);
            document.getElementById('toggle-auth').innerText = isLogin ? 'Need an account? Register' : 'Already have an account? Login';
            document.getElementById('auth-form').onsubmit = async (e) => {
                e.preventDefault();
                const data = {
                    email: document.getElementById('auth-email').value,
                    password: document.getElementById('auth-password').value,
                };
                if (!isLogin) {
                    data.name = document.getElementById('auth-name').value;
                    data.conf_password = document.getElementById('auth-conf-password').value;
                }
                try {
                    const res = await fetch(`/api/${mode}`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(data)
                    });
                    const result = await res.json();
                    if (res.ok) { localStorage.setItem('bsl_token', result.token); location.reload(); }
                    else alert(result.message);
                } catch (err) { alert('Auth Error'); }
            };
        }

        document.getElementById('toggle-auth').onclick = (e) => {
            e.preventDefault();
            showAuth(document.getElementById('auth-title').innerText.includes('Sign In') ? 'register' : 'login');
        };

        // --- Leagues & Seasons ---
        async function showLeagues() {
            document.getElementById('leagues-section').classList.remove('hidden');
            document.getElementById('season-dashboard').classList.add('hidden');
            document.getElementById('nav-breadcrumb').classList.add('hidden');

            const leagues = await api('/leagues');
            const list = document.getElementById('leagues-list');
            list.innerHTML = leagues.map(l => `
                <div class="card">
                    <h2 style="color: var(--laravel-red)">${l.name}</h2>
                    <p style="color: var(--slate-700); font-size: 0.875rem; margin: 0.5rem 0;">${l.sport}</p>
                    <div style="margin-top: 1.5rem;">
                        <label style="font-size: 0.7rem; text-transform: uppercase;">Active Seasons</label>
                        <div id="seasons-for-${l.id}" class="season-links">Loading...</div>
                    </div>
                    <button class="btn btn-primary btn-sm" style="width: 100%; margin-top: 1rem;" onclick="showCreateSeason(${l.id})">+ Add Season</button>
                </div>
            `).join('');

            leagues.forEach(async l => {
                const data = await api(`/leagues/${l.id}`);
                const sList = document.getElementById(`seasons-for-${l.id}`);
                sList.innerHTML = data.seasons.map(s => `
                    <a href="#" onclick="viewSeason(${s.id})" style="display: block; color: var(--slate-900); text-decoration: none; padding: 0.5rem; background: var(--slate-50); border-radius: 0.25rem; margin-top: 0.25rem; font-weight: 600; border-left: 3px solid var(--laravel-red);">
                        ${s.name} <span class="badge badge-${s.status}" style="float: right;">${s.status}</span>
                    </a>
                `).join('') || '<p style="font-size: 0.875rem; color: var(--slate-300);">No seasons yet</p>';
            });
        }

        async function viewSeason(id) {
            currentSeason = await api(`/seasons/${id}`);
            document.getElementById('leagues-section').classList.add('hidden');
            document.getElementById('season-dashboard').classList.remove('hidden');
            document.getElementById('nav-breadcrumb').classList.remove('hidden');
            document.getElementById('season-title').innerText = currentSeason.name;
            document.getElementById('league-breadcrumb').innerText = `League Portal`;
            switchTab(activeTab);
        }

        // --- Tabs ---
        function switchTab(tab) {
            activeTab = tab;
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b.innerText.toLowerCase() === tab));
            const content = document.getElementById('tab-content');
            content.innerHTML = '<p>Loading...</p>';
            
            if (tab === 'standings') renderStandings();
            if (tab === 'matches') renderMatches();
            if (tab === 'teams') renderTeams();
            if (tab === 'leaderboard') renderLeaderboard();
        }

        // --- Standings & Leaderboard ---
        async function renderStandings() {
            const data = await api(`/seasons/${currentSeason.id}/standings`);
            document.getElementById('tab-content').innerHTML = `
                <div class="card">
                    <table>
                        <thead>
                            <tr><th>Rank</th><th>Team</th><th>W</th><th>L</th><th>GP</th><th>Win %</th></tr>
                        </thead>
                        <tbody>
                            ${data.map((t, i) => `
                                <tr>
                                    <td style="font-weight: 800; color: ${i === 0 ? 'var(--gold)' : 'inherit'}">#${i + 1}</td>
                                    <td style="font-weight: 700;">${t.name}</td>
                                    <td style="color: #34d399; font-weight: 700;">${t.wins}</td>
                                    <td style="color: #f87171;">${t.losses}</td>
                                    <td>${t.games_played}</td>
                                    <td>${t.games_played > 0 ? ((t.wins / t.games_played) * 100).toFixed(1) : 0}%</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `;
        }

        async function renderLeaderboard() {
            const data = await api(`/seasons/${currentSeason.id}/leaderboard`);
            document.getElementById('tab-content').innerHTML = `
                <div class="grid">
                    <div class="card" style="grid-column: span 2;">
                        <h3>Points Leaderboard</h3>
                        <table>
                            <thead><tr><th>Player</th><th>Total Points</th><th>Actions</th></tr></thead>
                            <tbody>
                                ${data.map(p => `
                                    <tr>
                                        <td style="font-weight: 700;">${p.name}</td>
                                        <td><span class="badge badge-active" style="font-size: 1rem;">${p.total_points} PTS</span></td>
                                        <td><button class="btn btn-secondary btn-sm" onclick="viewPlayerProfile(${p.player_id})">View Profile</button></td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            `;
        }

        // --- Matches ---
        async function renderMatches() {
            const games = await api(`/seasons/${currentSeason.id}/games`);
            document.getElementById('tab-content').innerHTML = `
                <div class="header-actions">
                    <h3>Season Fixtures</h3>
                    <button class="btn btn-primary btn-sm" onclick="showScheduleGame()">Schedule New Game</button>
                </div>
                <div id="matches-list">
                    ${games.map(g => `
                        <div class="match-row">
                            <div class="match-team">${g.home_team_id}</div>
                            <div class="match-score">
                                ${g.status === 'done' ? `Loading...` : 'VS'}
                            </div>
                            <div class="match-team">${g.away_team_id}</div>
                            <div class="match-info">
                                <div>${new Date(g.scheduled_at).toLocaleDateString()}</div>
                                <div>${g.venue}</div>
                                <span class="badge badge-${g.status}">${g.status}</span>
                            </div>
                            <div style="margin-left: 1rem;">
                                ${g.status === 'scheduled' ? `<button class="btn btn-primary btn-sm" onclick="showSubmitResult(${g.id})">Finish</button>` : `<button class="btn btn-secondary btn-sm" onclick="showSubmitStats(${g.id})">Stats</button>`}
                            </div>
                        </div>
                    `).join('') || '<p>No games scheduled.</p>'}
                </div>
            `;
            // Fetch actual team names and scores
            games.forEach(async g => {
                const fullGame = await api(`/games/${g.id}`);
                const rows = document.querySelectorAll('.match-row');
                // Find correct row (this is simplified for brevity)
                const row = Array.from(rows).find(r => r.innerHTML.includes(`Finish(${g.id})`) || r.innerHTML.includes(`Stats(${g.id})`));
                if (row) {
                    row.querySelector('.match-team:first-child').innerText = fullGame.home_team.name;
                    row.querySelector('.match-team:nth-child(3)').innerText = fullGame.away_team.name;
                    if (g.status === 'done') {
                        row.querySelector('.match-score').innerHTML = `${fullGame.result.home_score} : ${fullGame.result.away_score}`;
                    }
                }
            });
        }

        // --- Teams & Players ---
        async function renderTeams() {
            const teams = await api(`/seasons/${currentSeason.id}/teams`);
            document.getElementById('tab-content').innerHTML = `
                <div class="header-actions">
                    <h3>Teams in Season</h3>
                    <button class="btn btn-primary btn-sm" onclick="showCreateTeam()">Register Team</button>
                </div>
                <div class="grid">
                    ${teams.map(t => `
                        <div class="card">
                            <div style="display: flex; justify-content: space-between;">
                                <h3>${t.name}</h3>
                                <button class="btn btn-secondary btn-sm" onclick="showAddPlayer(${t.id})">+ Player</button>
                            </div>
                            <p style="font-size: 0.875rem; color: var(--slate-700);">Coach: ${t.coach}</p>
                            <div id="players-for-${t.id}" style="margin-top: 1rem;">Loading players...</div>
                        </div>
                    `).join('') || '<p>No teams registered.</p>'}
                </div>
            `;
            teams.forEach(async t => {
                const data = await api(`/teams/${t.id}`);
                const pList = document.getElementById(`players-for-${t.id}`);
                pList.innerHTML = `
                    <table class="btn-sm">
                        ${data.players.map(p => `
                            <tr>
                                <td style="padding: 0.25rem 0;">#${p.pivot.jersey_number} ${p.name}</td>
                                <td style="padding: 0.25rem 0; text-align: right;">
                                    <button onclick="removePlayer(${t.id}, ${p.id})" style="background: none; border: none; color: #f87171; cursor: pointer;">&times;</button>
                                </td>
                            </tr>
                        `).join('')}
                    </table>
                `;
            });
        }

        // --- Action Handlers (Modals) ---
        function showCreateLeague() {
            showModal('New League', `
                <div class="form-group"><label>Name</label><input type="text" id="l-name" required></div>
                <div class="form-group"><label>Sport</label><input type="text" id="l-sport" required></div>
                <div class="form-group"><label>Description</label><textarea id="l-desc"></textarea></div>
            `, async () => {
                await api('/leagues', { method: 'POST', body: JSON.stringify({
                    name: document.getElementById('l-name').value,
                    sport: document.getElementById('l-sport').value,
                    description: document.getElementById('l-desc').value
                })});
                showLeagues();
            });
        }

        function showCreateSeason(leagueId) {
            showModal('New Season', `
                <div class="form-group"><label>Season Name</label><input type="text" id="s-name" required></div>
                <div class="form-group"><label>Start Date</label><input type="date" id="s-start" required></div>
                <div class="form-group"><label>End Date</label><input type="date" id="s-end" required></div>
            `, async () => {
                await api(`/leagues/${leagueId}/seasons`, { method: 'POST', body: JSON.stringify({
                    name: document.getElementById('s-name').value,
                    start_date: document.getElementById('s-start').value,
                    end_date: document.getElementById('s-end').value
                })});
                showLeagues();
            });
        }

        function showCreateTeam() {
            showModal('Register Team', `
                <div class="form-group"><label>Team Name</label><input type="text" id="t-name" required></div>
                <div class="form-group"><label>Coach</label><input type="text" id="t-coach" required></div>
            `, async () => {
                await api(`/seasons/${currentSeason.id}/teams`, { method: 'POST', body: JSON.stringify({
                    name: document.getElementById('t-name').value,
                    coach: document.getElementById('t-coach').value
                })});
                renderTeams();
            });
        }

        function showAddPlayer(teamId) {
            showModal('Add Player', `
                <div class="form-group"><label>Player Name</label><input type="text" id="p-name" required></div>
                <div class="form-group"><label>Birthdate</label><input type="date" id="p-birth" required></div>
                <div class="form-group"><label>Position</label><input type="text" id="p-pos" required></div>
                <div class="form-group"><label>Jersey Number</label><input type="number" id="p-num" required></div>
            `, async () => {
                await api(`/teams/${teamId}/players`, { method: 'POST', body: JSON.stringify({
                    name: document.getElementById('p-name').value,
                    birthdate: document.getElementById('p-birth').value,
                    position: document.getElementById('p-pos').value,
                    jersey_number: document.getElementById('p-num').value
                })});
                renderTeams();
            });
        }

        async function removePlayer(teamId, playerId) {
            if (confirm('Remove player from team?')) {
                await api(`/teams/${teamId}/players/${playerId}`, { method: 'DELETE' });
                renderTeams();
            }
        }

        async function showScheduleGame() {
            const teams = await api(`/seasons/${currentSeason.id}/teams`);
            showModal('Schedule Game', `
                <div class="form-group"><label>Home Team</label><select id="g-home">${teams.map(t => `<option value="${t.id}">${t.name}</option>`)}</select></div>
                <div class="form-group"><label>Away Team</label><select id="g-away">${teams.map(t => `<option value="${t.id}">${t.name}</option>`)}</select></div>
                <div class="form-group"><label>Date & Time</label><input type="datetime-local" id="g-at" required></div>
                <div class="form-group"><label>Venue</label><input type="text" id="g-venue" required></div>
            `, async () => {
                const homeId = document.getElementById('g-home').value;
                const awayId = document.getElementById('g-away').value;
                
                if (homeId === awayId) {
                    alert('Error: A team cannot play against itself!');
                    return false;
                }

                await api(`/seasons/${currentSeason.id}/games`, { method: 'POST', body: JSON.stringify({
                    home_team_id: homeId,
                    away_team_id: awayId,
                    scheduled_at: document.getElementById('g-at').value,
                    venue: document.getElementById('g-venue').value
                })});
                renderMatches();
                return true;
            });
        }

        function showSubmitResult(gameId) {
            showModal('Final Score', `
                <div class="form-group"><label>Home Score</label><input type="number" id="r-home" required></div>
                <div class="form-group"><label>Away Score</label><input type="number" id="r-away" required></div>
            `, async () => {
                await api(`/games/${gameId}/result`, { method: 'POST', body: JSON.stringify({
                    home_score: document.getElementById('r-home').value,
                    away_score: document.getElementById('r-away').value
                })});
                renderMatches();
            });
        }

        async function showSubmitStats(gameId) {
            const game = await api(`/games/${gameId}`);
            // Combine players from both teams
            const homePlayers = (await api(`/teams/${game.home_team_id}`)).players;
            const awayPlayers = (await api(`/teams/${game.away_team_id}`)).players;
            const allPlayers = [...homePlayers, ...awayPlayers];

            showModal('Input Player Stats', `
                <div style="overflow-x: auto;">
                    <table class="stats-table">
                        <thead><tr><th>Player</th><th style="text-align: center;">Points (PTS)</th></tr></thead>
                        <tbody>
                            ${allPlayers.map(p => `
                                <tr data-player-id="${p.id}">
                                    <td>${p.name}</td>
                                    <td style="text-align: center;"><input type="number" class="st-pts" value="0" style="width: 80px;"></td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            `, async () => {
                const stats = Array.from(document.querySelectorAll('.stats-table tbody tr')).map(tr => ({
                    player_id: tr.dataset.playerId,
                    points: tr.querySelector('.st-pts').value,
                    assists: 0,
                    rebounds: 0,
                    fouls: 0,
                }));
                await api(`/games/${gameId}/stats`, { method: 'POST', body: JSON.stringify({ stats })});
                alert('Stats saved successfully!');
            });
        }

        async function viewPlayerProfile(id) {
            const p = await api(`/players/${id}/profile`);
            showModal('Player Profile', `
                <div style="text-align: center; margin-bottom: 2rem;">
                    <h1 style="color: var(--laravel-red)">${p.name}</h1>
                    <span class="badge badge-active">${p.position}</span>
                </div>
                <div class="grid" style="grid-template-columns: repeat(2, 1fr); gap: 1rem; text-align: center;">
                    <div class="card"><h3>${p.career_totals.total_points}</h3><label>Career Points</label></div>
                    <div class="card"><h3>${p.career_totals.total_games_played}</h3><label>Games</label></div>
                </div>
                <h4 style="margin-top: 2rem;">History</h4>
                <div class="card" style="margin-top: 0.5rem; padding: 0.75rem;">
                    ${p.teams_history.map(t => `
                        <div style="display: flex; justify-content: space-between; font-size: 0.875rem;">
                            <span>${t.team_name} (${t.season_name})</span>
                            <span style="font-weight: 700;">#${t.jersey_number}</span>
                        </div>
                    `).join('')}
                </div>
            `, () => {});
        }

        // --- Modal Helpers ---
        function showModal(title, html, onSave) {
            document.getElementById('modal-title').innerText = title;
            document.getElementById('modal-fields').innerHTML = html;
            document.getElementById('modal-overlay').classList.remove('hidden');
            document.getElementById('modal-form').onsubmit = async (e) => {
                e.preventDefault();
                const shouldClose = await onSave();
                if (shouldClose !== false) closeModal();
            };
        }
        function closeModal() { document.getElementById('modal-overlay').classList.add('hidden'); }

        function togglePassword(id, btn) {
            const input = document.getElementById(id);
            const isPassword = input.type === 'password';
            input.type = isPassword ? 'text' : 'password';
            
            // Toggle Icon (Eye vs Eye-Off)
            btn.innerHTML = isPassword 
                ? `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>`
                : `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>`;
        }
    </script>
</body>
</html>
