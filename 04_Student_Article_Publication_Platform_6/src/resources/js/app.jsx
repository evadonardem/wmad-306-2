import '../css/app.css';
import './bootstrap';

import { ThemeModeContext } from '@/Components/ThemeModeContext';
import { createInertiaApp } from '@inertiajs/react';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { createRoot } from 'react-dom/client';
import { CssBaseline, ThemeProvider, alpha, createTheme } from '@mui/material';
import { useMemo, useState, useEffect } from 'react';

const appName = import.meta.env.VITE_APP_NAME || 'Campus Press';

const UI_PREFS_KEY = 'campus_press_ui_preferences';

function applyAppearancePreferencesToBody() {
    const raw = localStorage.getItem(UI_PREFS_KEY);
    if (!raw) return;
    try {
        const prefs = JSON.parse(raw);
        document.body.dataset.dashboardDensity = prefs.dashboardDensity ?? 'comfortable';
        document.body.dataset.largerText = prefs.largerText ? '1' : '0';
        document.body.dataset.compactCards = prefs.compactCards ? '1' : '0';
    } catch (_) {}
}

function AppThemeProvider({ children }) {
    const [mode, setMode] = useState(() => localStorage.getItem('campus_press_theme_mode') ?? 'light');

    useEffect(() => {
        applyAppearancePreferencesToBody();
        const onStorage = (e) => {
            if (e.key === UI_PREFS_KEY) applyAppearancePreferencesToBody();
        };
        window.addEventListener('storage', onStorage);
        return () => window.removeEventListener('storage', onStorage);
    }, []);

    const toggleMode = () => {
        setMode((current) => {
            const next = current === 'light' ? 'dark' : 'light';
            localStorage.setItem('campus_press_theme_mode', next);
            return next;
        });
    };

    // Sync MUI theme mode with Tailwind CSS dark mode
    useEffect(() => {
        if (mode === 'dark') {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }, [mode]);

    const theme = useMemo(() => {
        const isDark = mode === 'dark';

        return createTheme({
            palette: {
                mode,
                primary: {
                    main: '#2f6fdb',
                    dark: '#2157b4',
                    light: '#eaf1ff',
                    contrastText: '#ffffff',
                },
                secondary: {
                    main: '#2f6fdb',
                },
                background: {
                    default: isDark ? '#0e172a' : '#f4f7fb',
                    paper: isDark ? '#12213c' : '#ffffff',
                },
                text: {
                    primary: isDark ? '#e4edff' : '#1f2a44',
                    secondary: isDark ? '#9cb1da' : '#5f6f89',
                },
                divider: isDark ? 'rgba(126, 165, 234, 0.22)' : 'rgba(47, 111, 219, 0.16)',
            },
            typography: {
                fontFamily: '"Nunito Sans", "Segoe UI", sans-serif',
                h3: { fontFamily: '"Merriweather", serif', fontWeight: 700 },
                h4: { fontFamily: '"Merriweather", serif', fontWeight: 700 },
                h5: { fontFamily: '"Merriweather", serif', fontWeight: 700 },
                h6: { fontFamily: '"Merriweather", serif', fontWeight: 700 },
                body1: { lineHeight: 1.68 },
                body2: { lineHeight: 1.62 },
                button: { textTransform: 'none', fontWeight: 700 },
            },
            shape: {
                borderRadius: 10,
            },
            components: {
                MuiContainer: {
                    defaultProps: { maxWidth: 'lg' },
                },
                MuiPaper: {
                    styleOverrides: {
                        root: {
                            border: isDark ? '1px solid rgba(126,165,234,0.2)' : '1px solid rgba(47,111,219,0.12)',
                            boxShadow: isDark
                                ? '0 8px 24px rgba(0,0,0,0.28)'
                                : '0 8px 24px rgba(24,46,92,0.06)',
                        },
                    },
                },
                MuiCard: {
                    styleOverrides: {
                        root: {
                            border: isDark ? '1px solid rgba(126,165,234,0.2)' : '1px solid rgba(47,111,219,0.12)',
                            boxShadow: isDark
                                ? '0 8px 24px rgba(0,0,0,0.28)'
                                : '0 8px 24px rgba(24,46,92,0.06)',
                        },
                    },
                },
                MuiButton: {
                    defaultProps: {
                        disableElevation: true,
                        size: 'large',
                    },
                    styleOverrides: {
                        root: {
                            borderRadius: 999,
                            paddingInline: 20,
                        },
                        containedPrimary: {
                            backgroundColor: '#2f6fdb',
                            '&:hover': { backgroundColor: '#2157b4' },
                        },
                        outlinedPrimary: {
                            borderColor: isDark ? 'rgba(126,165,234,0.55)' : 'rgba(47,111,219,0.45)',
                            backgroundColor: alpha('#2f6fdb', isDark ? 0.18 : 0.03),
                        },
                    },
                },
                MuiOutlinedInput: {
                    styleOverrides: {
                        root: {
                            backgroundColor: isDark ? '#0f1d35' : '#ffffff',
                        },
                    },
                },
                MuiChip: {
                    styleOverrides: {
                        root: {
                            fontWeight: 700,
                        },
                    },
                },
            },
        });
    }, [mode]);

    return (
        <ThemeModeContext.Provider value={{ mode, setMode, toggleMode }}>
            <ThemeProvider theme={theme}>
                <CssBaseline />
                {children}
            </ThemeProvider>
        </ThemeModeContext.Provider>
    );
}

createInertiaApp({
    // Updated title logic right here:
    title: (title) => {
        if (!title || title === appName) {
            return appName;
        }
        return `${title} - ${appName}`;
    },
    resolve: (name) =>
        resolvePageComponent(
            `./Pages/${name}.jsx`,
            import.meta.glob('./Pages/**/*.jsx')
        ),
    setup({ el, App, props }) {
        const root = createRoot(el);

        root.render(
            <AppThemeProvider>
                <App {...props} />
            </AppThemeProvider>
        );
    },
    progress: {
        color: '#2f6fdb',
    },
});