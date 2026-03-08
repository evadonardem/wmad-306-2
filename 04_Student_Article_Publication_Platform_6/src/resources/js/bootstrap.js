import axios from 'axios';
window.axios = axios;

window.axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

// Apply appearance preferences from localStorage before first paint (runs before React mount)
(function () {
    if (typeof document === 'undefined' || !document.body) return;
    try {
        const raw = localStorage.getItem('campus_press_ui_preferences');
        const prefs = raw ? JSON.parse(raw) : {};
        document.body.dataset.dashboardDensity = prefs.dashboardDensity ?? 'comfortable';
        document.body.dataset.largerText = prefs.largerText ? '1' : '0';
        document.body.dataset.compactCards = prefs.compactCards ? '1' : '0';
    } catch (_) {
        document.body.dataset.dashboardDensity = 'comfortable';
        document.body.dataset.largerText = '0';
        document.body.dataset.compactCards = '0';
    }
})();
