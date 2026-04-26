import { Link } from '@inertiajs/react';
import {
    AppBar,
    Toolbar,
    Box,
    Typography,
    Button,
    Container
} from '@mui/material';
import { Zap } from 'lucide-react';

export default function GuestLayout({ children }) {
    return (
        <Box sx={{
            minHeight: '100vh',
            background: 'linear-gradient(135deg, #0F172A 0%, #1E293B 50%, #0F172A 100%)',
            position: 'relative',
            overflow: 'hidden',
            '&::before': {
                content: '""',
                position: 'absolute',
                width: '500px',
                height: '500px',
                background: 'radial-gradient(circle, rgba(59, 130, 246, 0.1) 0%, transparent 70%)',
                borderRadius: '50%',
                top: '-100px',
                right: '-100px',
                animation: 'float 6s ease-in-out infinite'
            },
            '&::after': {
                content: '""',
                position: 'absolute',
                width: '400px',
                height: '400px',
                background: 'radial-gradient(circle, rgba(5, 150, 105, 0.08) 0%, transparent 70%)',
                borderRadius: '50%',
                bottom: '-50px',
                left: '-50px',
                animation: 'float 8s ease-in-out infinite reverse'
            }
        }}>
            {/* Enhanced Navigation Bar */}
            <AppBar position="sticky" sx={{
                background: 'rgba(15, 23, 42, 0.7)',
                backdropFilter: 'blur(20px)',
                border: '1px solid rgba(148, 163, 184, 0.1)',
                boxShadow: 'none',
                zIndex: 1000
            }}>
                <Toolbar sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Box sx={{
                            p: 1,
                            background: 'linear-gradient(135deg, #3B82F6 0%, #059669 100%)',
                            borderRadius: 2,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center'
                        }}>
                            <Zap size={24} color="white" />
                        </Box>
                        <Typography variant="h6" sx={{
                            fontWeight: 'bold',
                            color: '#F1F5F9',
                            fontSize: { xs: '1rem', md: '1.25rem' }
                        }}>
                            Article Hub
                        </Typography>
                    </Box>
                    <Box sx={{ display: 'flex', gap: 2 }}>
                        <Button
                            component={Link}
                            href="/"
                            variant="text"
                            sx={{
                                color: '#CBD5E1',
                                '&:hover': {
                                    color: '#3B82F6',
                                    background: 'rgba(59, 130, 246, 0.1)'
                                },
                                transition: 'all 0.3s ease'
                            }}
                        >
                            Home
                        </Button>
                        <Button
                            component={Link}
                            href="/register"
                            variant="text"
                            sx={{
                                color: '#CBD5E1',
                                '&:hover': {
                                    color: '#059669',
                                    background: 'rgba(5, 150, 105, 0.1)'
                                },
                                transition: 'all 0.3s ease'
                            }}
                        >
                            Register
                        </Button>
                    </Box>
                </Toolbar>
            </AppBar>

            {/* Main content area */}
            <Box
                sx={{
                    minHeight: 'calc(100vh - 64px)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    position: 'relative',
                    zIndex: 1,
                    p: { xs: 2, md: 4 }
                }}
            >
                <Container maxWidth="sm">
                    {children}
                </Container>
            </Box>
        </Box>
    );
}
