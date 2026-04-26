import { createTheme } from '@mui/material/styles';

const lightTheme = createTheme({
    palette: {
        mode: 'light',
        background: {
            default: '#d8ccbc', 
            paper: '#7EACB5', 
        },
        primary: {
            main: '#BF4646',     
            light: '#D16D6D',
            dark: '#8E3434',
            contrastText: '#FFF4EA', 
        },
        secondary: {
            main: '#BF4646',   
            light: '#D16D6D',
            dark: '#8E3434',
            contrastText: '#FFF4EA',
        },
        text: {
            primary: '#FFF4EA',
            secondary: '#EDDCC6', 
        },
        success: {
            main: '#A5D6A7', 
            light: '#C8E6C9',
            dark: '#66BB6A',
        },
        warning: {
            main: '#FFE0B2',
            light: '#FFF3E0',
            dark: '#FFB74D',
        },
        error: {
            main: '#FFCDD2',
            light: '#FFEBEE',
            dark: '#EF5350',
        },
        info: {
            main: '#B2EBF2',
            light: '#E0F7FA',
            dark: '#4DD0E1',
        },
    },
    typography: {
        fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
        h1: { fontWeight: 700, fontSize: '2.5rem', lineHeight: 1.2 },
        h2: { fontWeight: 600, fontSize: '2rem', lineHeight: 1.3 },
        h3: { fontWeight: 600, fontSize: '1.75rem', lineHeight: 1.4 },
        h4: { fontWeight: 600, fontSize: '1.5rem', lineHeight: 1.4 },
        h5: { fontWeight: 600, fontSize: '1.25rem', lineHeight: 1.5 },
        h6: { fontWeight: 600, fontSize: '1.125rem', lineHeight: 1.5 },
        body1: { fontSize: '1rem', lineHeight: 1.6 },
        body2: { fontSize: '0.875rem', lineHeight: 1.6 },
    },
    shape: {
        borderRadius: 8,
    },
    components: {
        MuiCard: {
            styleOverrides: {
                root: {
                    boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                    borderRadius: 12,
                    border: '1px solid rgba(255, 244, 234, 0.2)', 
                },
            },
        },
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                    textTransform: 'none',
                    fontWeight: 700,
                },
            },
        },
        MuiOutlinedInput: {
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-notchedOutline': {
                        borderColor: 'rgba(255, 244, 234, 0.5)',
                    },
                    '&:hover .MuiOutlinedInput-notchedOutline': {
                        borderColor: '#FFF4EA',
                    },
                },
            },
        },
        MuiPaper: {
            styleOverrides: {
                root: {
                    backgroundImage: 'none',
                },
            },
        },
    },
});


const darkTheme = createTheme({
    palette: {
        mode: 'dark',
        background: {
            default: '#171717', 
            paper: '#444444',   
        },
        primary: {
            main: '#DA0037',  
            light: '#FF3B6B',
            dark: '#A30029',
            contrastText: '#EDEDED',
        },
        secondary: {
            main: '#444444',    
            light: '#6E6E6E',
            dark: '#1C1C1C',
            contrastText: '#EDEDED',
        },
        text: {
            primary: '#EDEDED', 
            secondary: '#A0A0A0', 
        },
        success: {
            main: '#66BB6A',
            light: '#81C784',
            dark: '#4CAF50',
        },
        warning: {
            main: '#FFB74D',
            light: '#FFCC80',
            dark: '#FF9800',
        },
        error: {
            main: '#EF5350',
            light: '#E57373',
            dark: '#F44336',
        },
        info: {
            main: '#64B5F6',
            light: '#90CAF9',
            dark: '#2196F3',
        },
    },
    typography: {
        fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
        h1: { fontWeight: 700, fontSize: '2.5rem', lineHeight: 1.2 },
        h2: { fontWeight: 600, fontSize: '2rem', lineHeight: 1.3 },
        h3: { fontWeight: 600, fontSize: '1.75rem', lineHeight: 1.4 },
        h4: { fontWeight: 600, fontSize: '1.5rem', lineHeight: 1.4 },
        h5: { fontWeight: 600, fontSize: '1.25rem', lineHeight: 1.5 },
        h6: { fontWeight: 600, fontSize: '1.125rem', lineHeight: 1.5 },
        body1: { fontSize: '1rem', lineHeight: 1.6 },
        body2: { fontSize: '0.875rem', lineHeight: 1.6 },
    },
    shape: {
        borderRadius: 8,
    },
    components: {
        MuiCard: {
            styleOverrides: {
                root: {
                    boxShadow: '0 4px 20px rgba(0,0,0,0.5)', 
                    borderRadius: 12,
                    backgroundImage: 'none',
                },
            },
        },
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 8,
                    textTransform: 'none',
                    fontWeight: 600,
                },
            },
        },
        MuiTextField: {
            styleOverrides: {
                root: {
                    '& .MuiOutlinedInput-root': {
                        borderRadius: 8,
                    },
                },
            },
        },
        MuiPaper: {
            styleOverrides: {
                root: {
                    backgroundImage: 'none',
                },
            },
        },
    },
});

export { lightTheme, darkTheme };
