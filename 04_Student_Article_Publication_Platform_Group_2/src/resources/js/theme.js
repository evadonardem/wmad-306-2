import { createTheme } from '@mui/material/styles';

const theme = createTheme({
    palette: {
        primary: {
            main: '#255273',
            light: '#4A7BA7',
            dark: '#1A3A52',
            contrastText: '#FFFFFF',
        },
        secondary: {
            main: '#255273',
            light: '#4A7BA7',
            dark: '#1A3A52',
            contrastText: '#FFFFFF',
        },
        background: {
            default: '#F5F7F9',
            paper: '#FFFFFF',
        },
        text: {
            primary: '#2C3E50',
            secondary: '#828D99',
        },
        success: {
            main: '#2E7D32',
            light: '#E8F5E9',
        },
        warning: {
            main: '#ED6C02',
            light: '#FFF3E0',
        },
        error: {
            main: '#D32F2F',
            light: '#FFEBEE',
        },
        info: {
            main: '#2A7B9B',
            light: '#E1F5FE',
        },
        divider: '#E2E8F0',
        action: {
            hover: 'rgba(42, 123, 155, 0.06)',
            selected: 'rgba(27, 42, 74, 0.08)',
        },
        // Brand accent color for CTAs
        brand: {
            main: '#E65100',
            light: '#FF7043',
            dark: '#BF3600',
            contrastText: '#FFFFFF',
        },
    },
    typography: {
        fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
        h4: {
            fontWeight: 700,
            letterSpacing: '-0.02em',
        },
        h5: {
            fontWeight: 700,
            letterSpacing: '-0.01em',
        },
        h6: {
            fontWeight: 600,
            letterSpacing: '-0.01em',
        },
        subtitle1: {
            fontWeight: 600,
        },
        subtitle2: {
            fontWeight: 600,
            fontSize: '0.8125rem',
        },
        body2: {
            color: '#5A6B8A',
        },
        button: {
            textTransform: 'none',
            fontWeight: 600,
        },
        caption: {
            color: '#8896AB',
        },
    },
    shape: {
        borderRadius: 10,
    },
    spacing: 8,
    components: {
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                    padding: '8px 20px',
                    fontSize: '0.875rem',
                },
                contained: {
                    boxShadow: 'none',
                    '&:hover': {
                        boxShadow: '0 2px 8px rgba(27, 42, 74, 0.2)',
                    },
                },
                outlined: {
                    borderWidth: '1.5px',
                    '&:hover': {
                        borderWidth: '1.5px',
                    },
                },
            },
        },
        MuiCard: {
            styleOverrides: {
                root: {
                    borderRadius: 12,
                    boxShadow: '0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)',
                    border: '1px solid #E2E8F0',
                },
            },
        },
        MuiTextField: {
            defaultProps: {
                variant: 'outlined',
                size: 'medium',
            },
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-root': {
                        borderRadius: 8,
                        backgroundColor: '#FAFBFC',
                        '&:hover .MuiOutlinedInput-notchedOutline': {
                            borderColor: '#2A7B9B',
                        },
                        '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                            borderColor: '#1B2A4A',
                            borderWidth: '2px',
                        },
                        '&.Mui-focused': {
                            backgroundColor: '#FFFFFF',
                        },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                        color: '#1B2A4A',
                    },
                },
            },
        },
        MuiChip: {
            styleOverrides: {
                root: {
                    borderRadius: 6,
                    fontWeight: 500,
                    fontSize: '0.75rem',
                },
            },
        },
        MuiListItemButton: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                    margin: '2px 8px',
                    paddingLeft: 12,
                    paddingRight: 12,
                    '&.Mui-selected': {
                        backgroundColor: 'rgba(42, 123, 155, 0.1)',
                        color: '#2A7B9B',
                        '& .MuiListItemIcon-root': {
                            color: '#2A7B9B',
                        },
                        '&:hover': {
                            backgroundColor: 'rgba(42, 123, 155, 0.15)',
                        },
                    },
                    '&:hover': {
                        backgroundColor: 'rgba(27, 42, 74, 0.04)',
                    },
                },
            },
        },
        MuiListItemIcon: {
            styleOverrides: {
                root: {
                    minWidth: 36,
                    color: '#8896AB',
                },
            },
        },
        MuiDivider: {
            styleOverrides: {
                root: {
                    borderColor: '#E2E8F0',
                },
            },
        },
        MuiDialog: {
            styleOverrides: {
                paper: {
                    borderRadius: 16,
                },
            },
        },
        MuiAvatar: {
            styleOverrides: {
                root: {
                    backgroundColor: '#2A7B9B',
                    fontWeight: 600,
                },
            },
        },
        MuiAppBar: {
            styleOverrides: {
                root: {
                    boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
                },
            },
        },
        MuiDrawer: {
            styleOverrides: {
                paper: {
                    borderRight: '1px solid #E2E8F0',
                },
            },
        },
        MuiAutocomplete: {
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-root': {
                        borderRadius: 8,
                    },
                },
                tag: {
                    borderRadius: 6,
                },
            },
        },
        MuiLinearProgress: {
            styleOverrides: {
                root: {
                    borderRadius: 4,
                    height: 6,
                    backgroundColor: '#E2E8F0',
                },
                bar: {
                    borderRadius: 4,
                },
            },
        },
    },
});

export default theme;
