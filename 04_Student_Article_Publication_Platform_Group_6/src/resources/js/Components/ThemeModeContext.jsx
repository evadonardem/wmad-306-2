import { createContext, useContext } from 'react';

// Create the context with default fallback values
export const ThemeModeContext = createContext({
    mode: 'light',
    toggleMode: () => {},
    setMode: () => {},
});

// Export a custom hook so other components can easily consume the context
export const useThemeMode = () => useContext(ThemeModeContext);