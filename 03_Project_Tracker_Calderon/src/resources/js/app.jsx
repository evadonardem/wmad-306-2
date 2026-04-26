import '../css/app.css';
import './bootstrap';
import { createInertiaApp } from '@inertiajs/react';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { createRoot } from 'react-dom/client';
import ThemeProvider from './Components/ThemeProvider';
import { Box, useTheme } from '@mui/material';

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

// Global background wrapper component
const GlobalBackground = ({ children }) => {
    const theme = useTheme();
    
    return (
        <Box
            sx={{
                minHeight: '100vh',
                background: theme.palette.mode === 'light' 
                    ? 'linear-gradient(135deg, #E3F2FD 0%, #BBDEFB 25%, #90CAF9 50%, #64B5F6 75%, #42A5F5 100%)'
                    : 'linear-gradient(135deg, #0D47A1 0%, #1565C0 25%, #1976D2 50%, #1E88E5 75%, #2196F3 100%)',
            }}
        >
            {children}
        </Box>
    );
};

createInertiaApp({
    title: (title) => `${title} - ${appName}`,
    resolve: (name) =>
        resolvePageComponent(
            `./Pages/${name}.jsx`,
            import.meta.glob('./Pages/**/*.jsx'),
        ),
    setup({ el, App, props }) {
        const root = createRoot(el);

        root.render(
            <ThemeProvider>
                <GlobalBackground>
                    <App {...props} />
                </GlobalBackground>
            </ThemeProvider>
        );
    },
    progress: {
        color: '#4B5563',
    },
});
