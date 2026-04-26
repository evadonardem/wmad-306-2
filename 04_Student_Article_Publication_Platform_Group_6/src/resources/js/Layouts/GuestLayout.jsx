import AIAssistantWidget from '@/Components/AIAssistantWidget';
import ApplicationLogo from '@/Components/ApplicationLogo';
import ThemeModeToggle from '@/Components/ThemeModeToggle';
import { Link, usePage } from '@inertiajs/react';
import { Box, Button, Container, Stack, Typography } from '@mui/material';
import { alpha, useTheme } from '@mui/material/styles';

export default function GuestLayout({ children }) {
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';
    const { auth } = usePage().props;

    return (
        <Box
            sx={{
                minHeight: '100vh',
                display: 'flex',
                flexDirection: 'column',
                // A very subtle gradient background to make the white cards pop
                background: isDark 
                    ? `linear-gradient(145deg, ${alpha('#2f6fdb', 0.1)}, ${theme.palette.background.default} 40%)`
                    : `linear-gradient(145deg, #f8fafc 0%, #eef2f6 100%)`,
            }}
        >
            {/* Minimal Top Navigation */}
            <Box component="nav" sx={{ p: { xs: 2.5, md: 4 }, width: '100%' }}>
                <Stack direction="row" justifyContent="space-between" alignItems="center">
                    <Stack 
                        component={Link} 
                        href={route('welcome')} 
                        direction="row" 
                        spacing={1.5} 
                        sx={{ textDecoration: 'none', alignItems: 'center' }}
                    >
                        <ApplicationLogo style={{ width: 36, height: 36 }} />
                        <Typography 
                            variant="h6" 
                            sx={{ 
                                fontWeight: 800, 
                                color: 'text.primary', 
                                letterSpacing: '-0.02em', 
                                display: { xs: 'none', sm: 'block' } 
                            }}
                        >
                            Campus Press
                        </Typography>
                    </Stack>

                    <Stack direction="row" spacing={2} alignItems="center">
                        <ThemeModeToggle />
                        <Button
                            component={Link}
                            href={auth?.user ? route('dashboard') : route('welcome')}
                            variant="outlined"
                            sx={{
                                borderRadius: '2rem',
                                fontWeight: 700,
                                textTransform: 'none',
                                borderColor: alpha(theme.palette.text.primary, 0.2),
                                color: 'text.primary',
                                '&:hover': {
                                    borderColor: '#2f6fdb',
                                    bgcolor: alpha('#2f6fdb', 0.05),
                                }
                            }}
                        >
                            {auth?.user ? 'Dashboard' : 'Home'}
                        </Button>
                    </Stack>
                </Stack>
            </Box>

            {/* Main Content Area */}
            <Box sx={{ flexGrow: 1, display: 'flex', alignItems: 'center', pb: { xs: 4, md: 8 } }}>
                <Container maxWidth="lg" sx={{ display: 'flex', justifyContent: 'center' }}>
                    {children}
                </Container>
            </Box>

            <AIAssistantWidget />
        </Box>
    );
}