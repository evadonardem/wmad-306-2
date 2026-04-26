import React, { createContext, useContext, useState, useEffect } from 'react';
import { createTheme, ThemeProvider } from '@mui/material/styles';

const ThemeContext = createContext();

export const useThemeContext = () => useContext(ThemeContext);

export const CustomThemeProvider = ({ children }) => {
    const [mode, setMode] = useState('light'); // 'light', 'dark', 'galaxy'
    const [mounted, setMounted] = useState(false);

    useEffect(() => {
        const savedMode = localStorage.getItem('theme-mode') || 'light';
        setMode(savedMode);
        setMounted(true);
    }, []);

    const updateMode = (newMode) => {
        setMode(newMode);
        localStorage.setItem('theme-mode', newMode);
    };

    const getTheme = () => {
        if (mode === 'dark') {
            return createTheme({
                palette: {
                    mode: 'dark',
                    background: {
                        default: '#0a0e27',
                        paper: '#151932',
                    },
                    primary: {
                        main: '#06b6d4',
                        light: '#22d3ee',
                        dark: '#0891b2',
                    },
                    secondary: {
                        main: '#10b981',
                        light: '#34d399',
                        dark: '#059669',
                    },
                    success: {
                        main: '#10b981',
                        light: '#34d399',
                        dark: '#059669',
                    },
                    warning: {
                        main: '#f59e0b',
                        light: '#fbbf24',
                        dark: '#d97706',
                    },
                    error: {
                        main: '#ef4444',
                        light: '#f87171',
                        dark: '#dc2626',
                    },
                    info: {
                        main: '#6366f1',
                        light: '#818cf8',
                        dark: '#4f46e5',
                    },
                    text: {
                        primary: '#f8fafc',
                        secondary: '#cbd5e1',
                        disabled: '#64748b',
                    },
                },
                typography: {
                    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
                    h1: {
                        fontWeight: 800,
                        fontSize: '3.5rem',
                        lineHeight: 1.1,
                    },
                    h2: {
                        fontWeight: 700,
                        fontSize: '2.5rem',
                        lineHeight: 1.2,
                    },
                    h3: {
                        fontWeight: 600,
                        fontSize: '1.875rem',
                    },
                    h4: {
                        fontWeight: 600,
                        fontSize: '1.5rem',
                    },
                    body1: {
                        fontSize: '1.125rem',
                        lineHeight: 1.6,
                    },
                    body2: {
                        fontSize: '0.875rem',
                        lineHeight: 1.5,
                    },
                },
                shape: {
                    borderRadius: 16,
                },
                components: {
                    MuiCard: {
                        styleOverrides: {
                            root: {
                                background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                                backdropFilter: 'blur(20px)',
                                border: '1px solid rgba(148, 163, 184, 0.1)',
                                borderRadius: 20,
                                transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                                '&:hover': {
                                    transform: 'translateY(-8px) scale(1.02)',
                                    boxShadow: '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 30px rgba(6, 182, 212, 0.1)',
                                    border: '1px solid rgba(6, 182, 212, 0.2)',
                                },
                            },
                        },
                    },
                    MuiButton: {
                        styleOverrides: {
                            root: {
                                textTransform: 'none',
                                fontWeight: 600,
                                fontSize: '0.875rem',
                                borderRadius: 12,
                                padding: '12px 24px',
                                transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                            },
                            contained: {
                                background: 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)',
                                boxShadow: '0 4px 14px 0 rgba(6, 182, 212, 0.39)',
                                '&:hover': {
                                    background: 'linear-gradient(135deg, #0891b2 0%, #059669 100%)',
                                    transform: 'translateY(-2px)',
                                    boxShadow: '0 6px 20px 0 rgba(6, 182, 212, 0.5)',
                                },
                            },
                            outlined: {
                                borderWidth: 2,
                                '&:hover': {
                                    borderWidth: 2,
                                    transform: 'translateY(-2px)',
                                },
                            },
                        },
                    },
                },
            });
        } else if (mode === 'galaxy') {
            return createTheme({
                palette: {
                    mode: 'dark',
                    background: {
                        default: '#000000',
                        paper: 'rgba(15, 23, 42, 0.8)',
                    },
                    primary: {
                        main: '#8b5cf6',
                        light: '#a78bfa',
                        dark: '#7c3aed',
                    },
                    secondary: {
                        main: '#ec4899',
                        light: '#f472b6',
                        dark: '#db2777',
                    },
                    success: {
                        main: '#10b981',
                        light: '#34d399',
                        dark: '#059669',
                    },
                    warning: {
                        main: '#f59e0b',
                        light: '#fbbf24',
                        dark: '#d97706',
                    },
                    error: {
                        main: '#ef4444',
                        light: '#f87171',
                        dark: '#dc2626',
                    },
                    info: {
                        main: '#06b6d4',
                        light: '#22d3ee',
                        dark: '#0891b2',
                    },
                    text: {
                        primary: '#f8fafc',
                        secondary: '#cbd5e1',
                        disabled: '#64748b',
                    },
                },
                typography: {
                    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
                    h1: {
                        fontWeight: 800,
                        fontSize: '3.5rem',
                        lineHeight: 1.1,
                        background: 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                        WebkitBackgroundClip: 'text',
                        WebkitTextFillColor: 'transparent',
                        backgroundClip: 'text',
                    },
                    h2: {
                        fontWeight: 700,
                        fontSize: '2.5rem',
                        lineHeight: 1.2,
                    },
                    h3: {
                        fontWeight: 600,
                        fontSize: '1.875rem',
                    },
                    h4: {
                        fontWeight: 600,
                        fontSize: '1.5rem',
                    },
                    body1: {
                        fontSize: '1.125rem',
                        lineHeight: 1.6,
                    },
                    body2: {
                        fontSize: '0.875rem',
                        lineHeight: 1.5,
                    },
                },
                shape: {
                    borderRadius: 16,
                },
                components: {
                    MuiCard: {
                        styleOverrides: {
                            root: {
                                background: 'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                                backdropFilter: 'blur(20px)',
                                border: '1px solid rgba(139, 92, 246, 0.2)',
                                borderRadius: 20,
                                transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                                '&:hover': {
                                    transform: 'translateY(-8px) scale(1.02)',
                                    boxShadow: '0 25px 50px rgba(139, 92, 246, 0.3), 0 0 30px rgba(236, 72, 153, 0.1)',
                                    border: '1px solid rgba(139, 92, 246, 0.4)',
                                },
                            },
                        },
                    },
                    MuiButton: {
                        styleOverrides: {
                            root: {
                                textTransform: 'none',
                                fontWeight: 600,
                                fontSize: '0.875rem',
                                borderRadius: 12,
                                padding: '12px 24px',
                                transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                            },
                            contained: {
                                background: 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                boxShadow: '0 4px 14px 0 rgba(139, 92, 246, 0.39)',
                                '&:hover': {
                                    background: 'linear-gradient(135deg, #7c3aed 0%, #db2777 100%)',
                                    transform: 'translateY(-2px)',
                                    boxShadow: '0 6px 20px 0 rgba(139, 92, 246, 0.5)',
                                },
                            },
                            outlined: {
                                borderWidth: 2,
                                '&:hover': {
                                    borderWidth: 2,
                                    transform: 'translateY(-2px)',
                                },
                            },
                        },
                    },
                },
            });
        } else {
            // Light mode (default)
            return createTheme({
                palette: {
                    mode: 'light',
                    background: {
                        default: '#ffffff',
                        paper: '#f8fafc',
                    },
                    primary: {
                        main: '#3b82f6',
                        light: '#60a5fa',
                        dark: '#2563eb',
                    },
                    secondary: {
                        main: '#10b981',
                        light: '#34d399',
                        dark: '#059669',
                    },
                    success: {
                        main: '#10b981',
                        light: '#34d399',
                        dark: '#059669',
                    },
                    warning: {
                        main: '#f59e0b',
                        light: '#fbbf24',
                        dark: '#d97706',
                    },
                    error: {
                        main: '#ef4444',
                        light: '#f87171',
                        dark: '#dc2626',
                    },
                    info: {
                        main: '#06b6d4',
                        light: '#22d3ee',
                        dark: '#0891b2',
                    },
                    text: {
                        primary: '#1e293b',
                        secondary: '#475569',
                        disabled: '#94a3b8',
                    },
                },
                typography: {
                    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
                    h1: {
                        fontWeight: 800,
                        fontSize: '3.5rem',
                        lineHeight: 1.1,
                        background: 'linear-gradient(135deg, #3b82f6 0%, #10b981 100%)',
                        WebkitBackgroundClip: 'text',
                        WebkitTextFillColor: 'transparent',
                        backgroundClip: 'text',
                    },
                    h2: {
                        fontWeight: 700,
                        fontSize: '2.5rem',
                        lineHeight: 1.2,
                    },
                    h3: {
                        fontWeight: 600,
                        fontSize: '1.875rem',
                    },
                    h4: {
                        fontWeight: 600,
                        fontSize: '1.5rem',
                    },
                    body1: {
                        fontSize: '1.125rem',
                        lineHeight: 1.6,
                    },
                    body2: {
                        fontSize: '0.875rem',
                        lineHeight: 1.5,
                    },
                },
                shape: {
                    borderRadius: 16,
                },
                components: {
                    MuiCard: {
                        styleOverrides: {
                            root: {
                                background: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',
                                backdropFilter: 'blur(20px)',
                                border: '1px solid rgba(226, 232, 240, 0.8)',
                                borderRadius: 20,
                                transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                                '&:hover': {
                                    transform: 'translateY(-8px) scale(1.02)',
                                    boxShadow: '0 25px 50px rgba(0, 0, 0, 0.1), 0 0 30px rgba(59, 130, 246, 0.1)',
                                    border: '1px solid rgba(59, 130, 246, 0.2)',
                                },
                            },
                        },
                    },
                    MuiButton: {
                        styleOverrides: {
                            root: {
                                textTransform: 'none',
                                fontWeight: 600,
                                fontSize: '0.875rem',
                                borderRadius: 12,
                                padding: '12px 24px',
                                transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                            },
                            contained: {
                                background: 'linear-gradient(135deg, #3b82f6 0%, #10b981 100%)',
                                boxShadow: '0 4px 14px 0 rgba(59, 130, 246, 0.39)',
                                '&:hover': {
                                    background: 'linear-gradient(135deg, #2563eb 0%, #059669 100%)',
                                    transform: 'translateY(-2px)',
                                    boxShadow: '0 6px 20px 0 rgba(59, 130, 246, 0.5)',
                                },
                            },
                            outlined: {
                                borderWidth: 2,
                                '&:hover': {
                                    borderWidth: 2,
                                    transform: 'translateY(-2px)',
                                },
                            },
                        },
                    },
                },
            });
        }
    };

    if (!mounted) {
        return null;
    }

    return (
        <ThemeContext.Provider value={{ mode, updateMode }}>
            <ThemeProvider theme={getTheme()}>
                {children}
            </ThemeProvider>
        </ThemeContext.Provider>
    );
};
