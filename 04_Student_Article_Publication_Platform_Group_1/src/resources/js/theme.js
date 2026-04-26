import { createTheme } from '@mui/material/styles';

const theme = createTheme({
    palette: {
        mode: 'dark',
        primary: {
            main: '#3B82F6',
            light: '#60A5FA',
            dark: '#1E40AF',
            contrastText: '#ffffff',
        },
        secondary: {
            main: '#059669',
            light: '#6EE7B7',
            dark: '#065F46',
            contrastText: '#ffffff',
        },
        success: {
            main: '#10B981',
            light: '#6EE7B7',
            dark: '#059669',
            contrastText: '#ffffff',
        },
        warning: {
            main: '#F59E0B',
            light: '#FBBF24',
            dark: '#D97706',
            contrastText: '#000000',
        },
        error: {
            main: '#EF4444',
            light: '#F87171',
            dark: '#DC2626',
            contrastText: '#ffffff',
        },
        info: {
            main: '#0EA5E9',
            light: '#38BDF8',
            dark: '#0284C7',
            contrastText: '#ffffff',
        },
        background: {
            default: '#0F172A',
            paper: 'rgba(15, 23, 42, 0.7)',
        },
        text: {
            primary: '#F1F5F9',
            secondary: '#CBD5E1',
            disabled: 'rgba(148, 163, 184, 0.5)',
        },
        divider: 'rgba(148, 163, 184, 0.1)',
    },

    typography: {
        fontFamily: '"Inter", "Segoe UI", "Roboto", "Oxygen", "Ubuntu", sans-serif',
        h1: {
            fontSize: '2.5rem',
            fontWeight: 700,
            letterSpacing: '-0.02em',
        },
        h2: {
            fontSize: '2rem',
            fontWeight: 700,
            letterSpacing: '-0.01em',
        },
        h3: {
            fontSize: '1.5rem',
            fontWeight: 600,
        },
        h4: {
            fontSize: '1.25rem',
            fontWeight: 600,
        },
        h5: {
            fontSize: '1.125rem',
            fontWeight: 600,
        },
        h6: {
            fontSize: '1rem',
            fontWeight: 600,
        },
        body1: {
            fontSize: '1rem',
            lineHeight: 1.6,
        },
        body2: {
            fontSize: '0.875rem',
            lineHeight: 1.5,
        },
        caption: {
            fontSize: '0.75rem',
            lineHeight: 1.4,
        },
    },

    shape: {
        borderRadius: 12,
    },

    components: {
        MuiCard: {
            styleOverrides: {
                root: {
                    background: 'rgba(30, 41, 59, 0.7)',
                    backdropFilter: 'blur(20px)',
                    border: '1px solid rgba(148, 163, 184, 0.15)',
                    boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)',
                    transition: 'all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)',
                    '&:hover': {
                        background: 'rgba(30, 41, 59, 0.85)',
                        border: '1px solid rgba(59, 130, 246, 0.3)',
                        boxShadow: '0 20px 60px rgba(59, 130, 246, 0.2)',
                        transform: 'translateY(-8px) scale(1.02)',
                    },
                },
            },
        },

        MuiButton: {
            styleOverrides: {
                root: {
                    fontWeight: 600,
                    textTransform: 'none',
                    transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                    position: 'relative',
                    overflow: 'hidden',
                    '&::before': {
                        content: '""',
                        position: 'absolute',
                        top: 0,
                        left: '-100%',
                        width: '100%',
                        height: '100%',
                        background: 'linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent)',
                        transition: 'left 0.5s',
                    },
                    '&:hover::before': {
                        left: '100%',
                    },
                },
                contained: {
                    background: 'linear-gradient(135deg, #3B82F6 0%, #059669 100%)',
                    '&:hover': {
                        background: 'linear-gradient(135deg, #1E40AF 0%, #065F46 100%)',
                        transform: 'scale(1.05)',
                        boxShadow: '0 15px 40px rgba(59, 130, 246, 0.4)',
                    },
                    '&:active': {
                        transform: 'scale(0.98)',
                    },
                },
                outlined: {
                    borderColor: 'rgba(59, 130, 246, 0.5)',
                    color: '#3B82F6',
                    '&:hover': {
                        borderColor: '#059669',
                        background: 'rgba(59, 130, 246, 0.1)',
                        transform: 'scale(1.05)',
                    },
                },
            },
        },

        MuiChip: {
            styleOverrides: {
                root: {
                    background: 'rgba(59, 130, 246, 0.15)',
                    color: '#60A5FA',
                    border: '1px solid rgba(59, 130, 246, 0.3)',
                    fontWeight: 500,
                    transition: 'all 0.3s ease',
                    '&:hover': {
                        background: 'rgba(59, 130, 246, 0.25)',
                        transform: 'translateY(-2px) scale(1.05)',
                        boxShadow: '0 8px 20px rgba(59, 130, 246, 0.2)',
                    },
                },
                colorSuccess: {
                    background: 'rgba(16, 185, 129, 0.15)',
                    color: '#6EE7B7',
                    borderColor: 'rgba(16, 185, 129, 0.3)',
                },
                colorError: {
                    background: 'rgba(239, 68, 68, 0.15)',
                    color: '#F87171',
                    borderColor: 'rgba(239, 68, 68, 0.3)',
                },
                colorWarning: {
                    background: 'rgba(245, 158, 11, 0.15)',
                    color: '#FBBF24',
                    borderColor: 'rgba(245, 158, 11, 0.3)',
                },
            },
        },

        MuiPaper: {
            styleOverrides: {
                root: {
                    background: 'rgba(30, 41, 59, 0.6)',
                    backdropFilter: 'blur(15px)',
                    border: '1px solid rgba(148, 163, 184, 0.1)',
                    transition: 'all 0.3s ease',
                },
            },
        },

        MuiAppBar: {
            styleOverrides: {
                root: {
                    background: 'rgba(15, 23, 42, 0.8)',
                    backdropFilter: 'blur(20px)',
                    borderBottom: '1px solid rgba(148, 163, 184, 0.1)',
                    boxShadow: '0 4px 20px rgba(0, 0, 0, 0.3)',
                },
            },
        },

        MuiDrawer: {
            styleOverrides: {
                root: {
                    '& .MuiBackdrop-root': {
                        backdropFilter: 'blur(4px)',
                    },
                },
                paper: {
                    background: 'rgba(15, 23, 42, 0.95)',
                    backdropFilter: 'blur(20px)',
                    border: '1px solid rgba(148, 163, 184, 0.1)',
                },
            },
        },

        MuiListItem: {
            styleOverrides: {
                root: {
                    transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                    '&:hover': {
                        background: 'rgba(59, 130, 246, 0.1)',
                        transform: 'translateX(4px)',
                    },
                    '&.Mui-selected': {
                        background: 'linear-gradient(135deg, rgba(59, 130, 246, 0.2), rgba(5, 150, 105, 0.1))',
                        borderLeft: '3px solid #3B82F6',
                    },
                },
            },
        },

        MuiTextField: {
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-root': {
                        borderColor: 'rgba(148, 163, 184, 0.2)',
                        background: 'rgba(30, 41, 59, 0.5)',
                        transition: 'all 0.3s ease',
                        '&:hover': {
                            borderColor: 'rgba(59, 130, 246, 0.3)',
                        },
                        '&.Mui-focused': {
                            borderColor: '#3B82F6',
                            background: 'rgba(30, 41, 59, 0.7)',
                            boxShadow: '0 0 20px rgba(59, 130, 246, 0.3)',
                        },
                    },
                },
            },
        },

        MuiSelect: {
            styleOverrides: {
                root: {
                    background: 'rgba(30, 41, 59, 0.5)',
                    borderColor: 'rgba(148, 163, 184, 0.2)',
                    transition: 'all 0.3s ease',
                    '&:hover': {
                        borderColor: 'rgba(59, 130, 246, 0.3)',
                    },
                    '&.Mui-focused': {
                        borderColor: '#3B82F6',
                        boxShadow: '0 0 20px rgba(59, 130, 246, 0.3)',
                    },
                },
            },
        },

        MuiFormControl: {
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-root': {
                        background: 'rgba(30, 41, 59, 0.5)',
                        borderColor: 'rgba(148, 163, 184, 0.2)',
                        transition: 'all 0.3s ease',
                    },
                },
            },
        },

        MuiInputBase: {
            styleOverrides: {
                root: {
                    color: '#F1F5F9',
                    '& input::placeholder': {
                        opacity: 0.6,
                        color: '#CBD5E1',
                    },
                },
            },
        },

        MuiInputLabel: {
            styleOverrides: {
                root: {
                    color: 'rgba(203, 213, 225, 0.7)',
                    '&.Mui-focused': {
                        color: '#60A5FA',
                    },
                },
            },
        },

        MuiOutlinedInput: {
            styleOverrides: {
                root: {
                    '& fieldset': {
                        borderColor: 'rgba(148, 163, 184, 0.2)',
                    },
                    '&:hover fieldset': {
                        borderColor: 'rgba(59, 130, 246, 0.3)',
                    },
                    '&.Mui-focused fieldset': {
                        borderColor: '#3B82F6',
                    },
                },
                input: {
                    color: '#F1F5F9',
                },
            },
        },

        MuiDialog: {
            styleOverrides: {
                paper: {
                    background: 'rgba(15, 23, 42, 0.95)',
                    backdropFilter: 'blur(20px)',
                    border: '1px solid rgba(148, 163, 184, 0.15)',
                },
            },
        },

        MuiAlert: {
            styleOverrides: {
                root: {
                    background: 'linear-gradient(135deg, rgba(59, 130, 246, 0.2), rgba(5, 150, 105, 0.1))',
                    backdropFilter: 'blur(20px)',
                    border: '1px solid rgba(59, 130, 246, 0.3)',
                },
            },
        },
    },
});

export default theme;
