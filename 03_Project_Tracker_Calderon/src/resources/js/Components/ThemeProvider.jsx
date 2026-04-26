import React, { createContext, useContext, useState, useEffect } from 'react';
import { ThemeProvider as MuiThemeProvider, createTheme } from '@mui/material/styles';
import { lightTheme, darkTheme } from '../Theme';

const ThemeContext = createContext();

export const useThemeContext = () => {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useThemeContext must be used within a ThemeProvider');
    }
    return context;
};

export const ThemeProvider = ({ children }) => {
    const [mode, setMode] = useState(() => {
        // Get theme from localStorage or default to light
        const savedMode = localStorage.getItem('themeMode');
        return savedMode || 'light';
    });

    const theme = mode === 'dark' ? darkTheme : lightTheme;

    const toggleTheme = () => {
        const newMode = mode === 'light' ? 'dark' : 'light';
        setMode(newMode);
        localStorage.setItem('themeMode', newMode);
    };

    useEffect(() => {
        // Apply theme to document root
        document.documentElement.setAttribute('data-theme', mode);
    }, [mode]);

    const value = {
        mode,
        theme,
        toggleTheme,
        isDark: mode === 'dark',
    };

    return (
        <ThemeContext.Provider value={value}>
            <MuiThemeProvider theme={theme}>
                {children}
            </MuiThemeProvider>
        </ThemeContext.Provider>
    );
};

export default ThemeProvider;
