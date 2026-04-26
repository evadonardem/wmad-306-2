import { Head, Link } from '@inertiajs/react';
import {
    Box,
    Container,
    Typography,
    Button,
    Stack,
    Grid,
    Avatar,
    useTheme,
    Paper,
} from '@mui/material';
import {
    Assignment,
    AutoGraph,
    ShieldMoon,
    Hub,
    ArrowForward,
    DataThresholding,
} from '@mui/icons-material';

export default function Welcome({ auth, laravelVersion, phpVersion }) {
    const theme = useTheme();
    const isDarkMode = theme.palette.mode === 'dark';

    // Text Logo Component
    const TextLogo = () => (
        <Stack direction="row" spacing={1.5} alignItems="center">
            <Avatar
                sx={{
                    bgcolor: theme.palette.primary.main,
                    width: 32,
                    height: 32,
                    boxShadow: '0 4px 14px 0 rgba(0,118,255,0.39)',
                }}
            >
                <Assignment sx={{ fontSize: 20 }} />
            </Avatar>
            <Typography
                variant="h6"
                sx={{
                    fontWeight: 800,
                    letterSpacing: '-0.5px',
                    color: theme.palette.text.primary,
                }}
            >
                Project Tracker
            </Typography>
        </Stack>
    );

    return (
        <Box sx={{ bgcolor: 'background.default', minHeight: '100vh', transition: 'background 0.3s' }}>
            <Head title="Welcome | Project Tracker" />

            {/* Navbar */}
            <Box component="nav" sx={{ py: 3, borderBottom: 1, borderColor: 'divider' }}>
                <Container maxWidth="lg">
                    <Stack direction="row" justifyContent="space-between" alignItems="center">
                        <TextLogo />
                        <Stack direction="row" spacing={2}>
                            {auth.user ? (
                                <Button component={Link} href={route('dashboard')} variant="text">
                                    Dashboard
                                </Button>
                            ) : (
                                <>
                                    <Button component={Link} href={route('login')} color="inherit">
                                        Log in
                                    </Button>
                                    <Button 
                                        component={Link} 
                                        href={route('register')} 
                                        variant="contained" 
                                        disableElevation
                                        sx={{ borderRadius: 2 }}
                                    >
                                        Register
                                    </Button>
                                </>
                            )}
                        </Stack>
                    </Stack>
                </Container>
            </Box>

            {/* Hero Section */}
            <Container maxWidth="lg" sx={{ pt: { xs: 8, md: 12 }, pb: 10 }}>
                <Grid container spacing={6} alignItems="center">
                    <Grid item xs={12} md={7}>
                        <Typography
                            variant="overline"
                            sx={{ color: 'primary.main', fontWeight: 700, mb: 1, display: 'block' }}
                        >
                            Management Evolved
                        </Typography>
                        <Typography
                            variant="h1"
                            sx={{
                                fontSize: { xs: '2.8rem', md: '4rem' },
                                fontWeight: 800,
                                lineHeight: 1.1,
                                mb: 3,
                                letterSpacing: '-1px',
                            }}
                        >
                            Built for teams that <br />
                            <Box component="span" sx={{ color: 'primary.main' }}>deliver results.</Box>
                        </Typography>
                        <Typography variant="body1" sx={{ color: 'text.secondary', mb: 4, fontSize: '1.1rem', maxWidth: 500 }}>
                            A high-performance interface to organize, track, and scale your professional projects without the clutter.
                        </Typography>
                        <Stack direction="row" spacing={2}>
                            <Button 
                                component={Link} 
                                href={route('register')}
                                size="large" 
                                variant="contained" 
                                endIcon={<ArrowForward />}
                                sx={{ px: 4, py: 1.5, borderRadius: 3 }}
                            >
                                Get Started
                            </Button>
                        </Stack>
                    </Grid>

                    {/* Abstract UI Visual */}
                    <Grid item xs={12} md={5} sx={{ display: { xs: 'none', md: 'block' } }}>
                        <Paper
                            elevation={0}
                            sx={{
                                p: 4,
                                bgcolor: isDarkMode ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.02)',
                                borderRadius: 6,
                                border: 1,
                                borderColor: 'divider',
                                position: 'relative',
                            }}
                        >
                            <Stack spacing={3}>
                                {[1, 2, 3].map((i) => (
                                    <Box key={i} sx={{ display: 'flex', gap: 2 }}>
                                        <Box sx={{ width: 12, height: 12, borderRadius: '50%', bgcolor: 'primary.main', mt: 0.5 }} />
                                        <Box sx={{ flex: 1 }}>
                                            <Box sx={{ height: 10, width: '70%', bgcolor: 'action.hover', borderRadius: 1, mb: 1 }} />
                                            <Box sx={{ height: 8, width: '40%', bgcolor: 'action.disabledBackground', borderRadius: 1 }} />
                                        </Box>
                                    </Box>
                                ))}
                            </Stack>
                        </Paper>
                    </Grid>
                </Grid>
            </Container>

            {/* Bento-style Features Grid */}
            <Box sx={{ py: 10, bgcolor: 'action.hover' }}>
                <Container maxWidth="lg">
                    <Grid container spacing={4}>
                        <Grid item xs={12} md={4}>
                            <FeatureCard 
                                icon={<AutoGraph color="primary" />} 
                                title="Velocity Analytics" 
                                desc="Predictive timelines based on your team's historical performance."
                            />
                        </Grid>
                        <Grid item xs={12} md={4}>
                            <FeatureCard 
                                icon={<Hub sx={{ color: '#9c27b0' }} />} 
                                title="Unified Workflow" 
                                desc="Integrate your tools and keep every task in one single source of truth."
                            />
                        </Grid>
                        <Grid item xs={12} md={4}>
                            <FeatureCard 
                                icon={<ShieldMoon color="success" />} 
                                title="Private by Design" 
                                desc="End-to-end encryption for project briefs and internal discussions."
                            />
                        </Grid>
                        <Grid item xs={12} md={4}>
                            <FeatureCard 
                                icon={<DataThresholding color="warning" />} 
                                title="More Placeholders" 
                                desc=" I do not know what to add here nor have a description for this one yet."
                            />
                        </Grid>
                    </Grid>
                </Container>
            </Box>

            {/* Footer */}
            <Box sx={{ py: 6, borderTop: 1, borderColor: 'divider' }}>
                <Container maxWidth="lg">
                    <Stack spacing={2} alignItems="center">
                        <TextLogo />
                        <Typography variant="body2" color="text.secondary">
                            Built with Laravel {laravelVersion} • PHP {phpVersion}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                            © 2026 . Project Tracker . Calderon Lorenz
                        </Typography>
                    </Stack>
                </Container>
            </Box>
        </Box>
    );
}

function FeatureCard({ icon, title, desc }) {
    return (
        <Paper
            elevation={0}
            sx={{
                p: 4,
                height: '100%',
                borderRadius: 4,
                border: 1,
                borderColor: 'divider',
                transition: 'transform 0.2s',
                '&:hover': { transform: 'translateY(-4px)' }
            }}
        >
            <Box sx={{ mb: 2 }}>{icon}</Box>
            <Typography variant="subtitle1" sx={{ fontWeight: 700, mb: 1 }}>{title}</Typography>
            <Typography variant="body2" color="text.secondary">{desc}</Typography>
        </Paper>
    );
}