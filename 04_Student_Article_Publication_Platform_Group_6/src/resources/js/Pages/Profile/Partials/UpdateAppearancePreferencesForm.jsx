import CoolButton from '@/Components/CoolButton';
import { useThemeMode } from '@/Components/ThemeModeContext';
import {
    Box,
    Divider,
    FormControlLabel,
    MenuItem,
    Stack,
    Switch,
    TextField,
    Typography,
} from '@mui/material';
import { useEffect, useState } from 'react';

const STORAGE_KEY = 'campus_press_ui_preferences';

export default function UpdateAppearancePreferencesForm() {
    const { mode, setMode } = useThemeMode();
    const [preferences, setPreferences] = useState(() => {
        const raw = localStorage.getItem(STORAGE_KEY);
        if (!raw) {
            return {
                compactCards: false,
                largerText: false,
                dashboardDensity: 'comfortable',
            };
        }

        try {
            return JSON.parse(raw);
        } catch {
            return {
                compactCards: false,
                largerText: false,
                dashboardDensity: 'comfortable',
            };
        }
    });

    useEffect(() => {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(preferences));
        document.body.dataset.dashboardDensity = preferences.dashboardDensity;
        document.body.dataset.largerText = preferences.largerText ? '1' : '0';
        document.body.dataset.compactCards = preferences.compactCards ? '1' : '0';
    }, [preferences]);

    return (
        <Box 
            sx={{
                // PURE MUI STYLING TO MATCH OTHER FORMS
                bgcolor: 'background.paper',
                borderRadius: '2rem', // Rounded corners
                p: { xs: 3, sm: 4 }, // Padding
                boxShadow: 'none', // Remove shadow
                border: '1px solid',
                borderColor: 'divider', // Proper outlined border
                overflow: 'hidden',
            }}
        >
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1, display: 'flex', alignItems: 'center', gap: 1.5 }}>
                <span>✨</span> Appearance & Reading
            </Typography>
            <Typography color="text.secondary" sx={{ mb: 4 }}>
                Personalize your reading and dashboard experience to match your workflow.
            </Typography>

            <Stack spacing={3}>
                {/* Theme Mode Section */}
                <Box>
                    <Typography variant="subtitle2" sx={{ fontWeight: 700, mb: 2, color: 'text.secondary', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                        Theme Settings
                    </Typography>
                    <TextField
                        select
                        label="Theme mode"
                        value={mode}
                        onChange={(event) => {
                            const nextMode = event.target.value;
                            setMode(nextMode);
                            localStorage.setItem('campus_press_theme_mode', nextMode);
                        }}
                        fullWidth
                        sx={{
                            '& .MuiOutlinedInput-root': { borderRadius: 3 }
                        }}
                    >
                        <MenuItem value="light">☀️ Light mode</MenuItem>
                        <MenuItem value="dark">🌙 Dark mode</MenuItem>
                    </TextField>
                </Box>

                <Divider sx={{ borderColor: 'divider' }} />

                {/* Dashboard Layout Section */}
                <Box>
                    <Typography variant="subtitle2" sx={{ fontWeight: 700, mb: 2, color: 'text.secondary', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                        Layout & Typography
                    </Typography>
                    <Stack spacing={2.5}>
                        <TextField
                            select
                            label="Dashboard density"
                            value={preferences.dashboardDensity}
                            onChange={(event) =>
                                setPreferences((previous) => ({
                                    ...previous,
                                    dashboardDensity: event.target.value,
                                }))
                            }
                            fullWidth
                            sx={{
                                '& .MuiOutlinedInput-root': { borderRadius: 3 }
                            }}
                        >
                            <MenuItem value="comfortable">🛋️ Comfortable (Default)</MenuItem>
                            <MenuItem value="compact">🗜️ Compact</MenuItem>
                        </TextField>

                        <Box sx={{ p: 2, borderRadius: 3, bgcolor: 'background.default', border: '1px solid', borderColor: 'divider' }}>
                            <FormControlLabel
                                sx={{ width: '100%', margin: 0, justifyContent: 'space-between' }}
                                labelPlacement="start"
                                control={
                                    <Switch
                                        checked={preferences.compactCards}
                                        onChange={(event) =>
                                            setPreferences((previous) => ({
                                                ...previous,
                                                compactCards: event.target.checked,
                                            }))
                                        }
                                    />
                                }
                                label={
                                    <Box>
                                        <Typography sx={{ fontWeight: 600 }}>Compact article cards</Typography>
                                        <Typography variant="caption" color="text.secondary">Show smaller thumbnails on the homepage feed</Typography>
                                    </Box>
                                }
                            />
                        </Box>

                        <Box sx={{ p: 2, borderRadius: 3, bgcolor: 'background.default', border: '1px solid', borderColor: 'divider' }}>
                            <FormControlLabel
                                sx={{ width: '100%', margin: 0, justifyContent: 'space-between' }}
                                labelPlacement="start"
                                control={
                                    <Switch
                                        checked={preferences.largerText}
                                        onChange={(event) =>
                                            setPreferences((previous) => ({
                                                ...previous,
                                                largerText: event.target.checked,
                                            }))
                                        }
                                    />
                                }
                                label={
                                    <Box>
                                        <Typography sx={{ fontWeight: 600 }}>Larger text size</Typography>
                                        <Typography variant="caption" color="text.secondary">Increase font size across all articles for better readability</Typography>
                                    </Box>
                                }
                            />
                        </Box>
                    </Stack>
                </Box>

                <Box sx={{ pt: 2, display: 'flex', justifyContent: 'flex-start' }}>
                    <CoolButton tone="outline" onClick={() => {
                        const defaults = {
                            compactCards: false,
                            largerText: false,
                            dashboardDensity: 'comfortable',
                        };
                        setPreferences(defaults);
                        setMode('light');
                        localStorage.setItem('campus_press_theme_mode', 'light');
                    }}>
                        Reset display preferences
                    </CoolButton>
                </Box>
            </Stack>
        </Box>
    );
}