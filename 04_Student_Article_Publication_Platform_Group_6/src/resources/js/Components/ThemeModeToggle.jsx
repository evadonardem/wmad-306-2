import { useThemeMode } from '@/Components/ThemeModeContext';
import DarkModeRoundedIcon from '@mui/icons-material/DarkModeRounded';
import LightModeRoundedIcon from '@mui/icons-material/LightModeRounded';
import { IconButton, Tooltip } from '@mui/material';

export default function ThemeModeToggle({ size = 'medium' }) {
    const { mode, toggleMode } = useThemeMode();
    const isDark = mode === 'dark';

    return (
        <Tooltip title={isDark ? 'Switch to light mode' : 'Switch to dark mode'}>
            <IconButton onClick={toggleMode} size={size} color="primary" aria-label="Toggle theme">
                {isDark ? <LightModeRoundedIcon /> : <DarkModeRoundedIcon />}
            </IconButton>
        </Tooltip>
    );
}
