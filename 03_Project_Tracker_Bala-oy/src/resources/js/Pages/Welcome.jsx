import { Head, Link } from '@inertiajs/react';
import { 
    Container, Box, Typography, Grid, Paper, Button, Stack, Fade
} from '@mui/material';
import { 
    // --- UPDATED FEATURE ICONS ---
    Folder as ProjectIcon, 
    AssignmentTurnedIn as TaskIcon, 
    VerifiedUser as SecuredIcon,
    // --- OTHERS ---
    ArrowForward as ArrowIcon,
    EmojiEvents as CrownIcon 
} from '@mui/icons-material';

const styles = {
    root: {
        minHeight: '100vh',
        background: 'radial-gradient(circle at 50% 0%, #c2e4f1 0%, #eef2f3 100%)', 
        position: 'relative',
        overflowX: 'hidden',
    },
    glassCard: {
        borderRadius: '32px', // Softer corners like the screenshot
        backgroundColor: '#c2e4f1',
        boxShadow: '0 10px 40px rgba(0, 0, 0, 0.03)',
        transition: 'all 0.3s ease',
        height: '380px',      
        width: '100%',
        maxWidth: '340px',    
        margin: '0 auto',     
        padding: '40px 32px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',     
        textAlign: 'center',      
        '&:hover': {
            transform: 'translateY(-8px)',
            boxShadow: '0 20px 50px rgba(0, 0, 0, 0.08)',
        }
    },
    heroButton: {
        borderRadius: '30px',
        textTransform: 'none',
        fontSize: '1.1rem',
        fontWeight: 600,
        px: 4,
        py: 1.5,
    },
    iconBox: (color) => ({
        width: 80, 
        height: 80,
        borderRadius: '24px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: color,
        color: '#fff',
        marginBottom: '32px', 
        boxShadow: `0 12px 24px ${color}44`, 
    })
};

export default function Welcome({ auth, laravelVersion, phpVersion }) {
    return (
        <Box sx={styles.root}>
            <Head title="Welcome" />

            {/* --- NAVIGATION BAR --- */}
            <Container maxWidth="lg" sx={{ pt: 4 }}>
                <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Box display="flex" alignItems="center" gap={1}>
                        <CrownIcon sx={{ color: '#0071e3' }} /> 
                        <Typography variant="h6" fontWeight="700" color="#1d1d1f">
                            RHJE
                        </Typography>
                    </Box>

                    <Box>
                        {auth.user ? (
                            <Button component={Link} href={route('dashboard')} variant="contained" sx={{ ...styles.heroButton, backgroundColor: '#0071e3' }}>
                                Go to Dashboard
                            </Button>
                        ) : (
                            <Stack direction="row" spacing={2}>
                                <Button component={Link} href={route('login')} variant="text" sx={{ textTransform: 'none', color: '#1d1d1f', fontWeight: 600 }}>
                                    Log in
                                </Button>
                                <Button component={Link} href={route('register')} variant="contained" sx={{ ...styles.heroButton, backgroundColor: '#1d1d1f', color: '#fff' }}>
                                    Register
                                </Button>
                            </Stack>
                        )}
                    </Box>
                </Box>
            </Container>

            {/* --- HERO SECTION --- */}
            <Container maxWidth="md" sx={{ textAlign: 'center', mt: 14, mb: 12 }}>
                <Fade in={true} timeout={1000}>
                    <Box>
                        <Typography variant="h1" fontWeight="800" sx={{ fontSize: { xs: '3rem', md: '4.5rem' }, letterSpacing: '-0.03em', color: '#1d1d1f', lineHeight: 1.1 }}>
                            Organize your work.<br />
                            <Box component="span" sx={{ background: 'linear-gradient(90deg, #0071e3, #40a9ff)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                                Amplify your output.
                            </Box>
                        </Typography>
                        
                        <Typography variant="h5" color="text.secondary" sx={{ mt: 3, mb: 5, maxWidth: '600px', mx: 'auto', lineHeight: 1.6 }}>
                            Simple project tracking, built for focus. Manage your projects and tasks.
                        </Typography>
                    </Box>
                </Fade>
            </Container>

            {/* --- FEATURE GRID --- */}
            <Container maxWidth="lg" sx={{ pb: 10 }}>
                <Grid container spacing={4} justifyContent="center">
                    
                    <Grid item xs={12} sm={6} md={4}>
                        <Paper sx={styles.glassCard} elevation={0}>
                            <Box sx={styles.iconBox('#5e5ce6')}>
                                <ProjectIcon sx={{ fontSize: 40 }} />
                            </Box>
                            <Typography variant="h5" fontWeight="700" gutterBottom>
                                Projects 📁
                            </Typography>
                            <Typography variant="body1" color="text.secondary">
                                High-level organization for your big ideas. Group related tasks and track milestones with ease.
                            </Typography>
                        </Paper>
                    </Grid>

                    <Grid item xs={12} sm={6} md={4}>
                        <Paper sx={styles.glassCard} elevation={0}>
                            <Box sx={styles.iconBox('#ff9f0a')}>
                                <TaskIcon sx={{ fontSize: 40 }} />
                            </Box>
                            <Typography variant="h5" fontWeight="700" gutterBottom>
                                Tasks 📝
                            </Typography>
                            <Typography variant="body1" color="text.secondary">
                                Stay focused on the details. Manage daily to-dos and check off progress in real-time.
                            </Typography>
                        </Paper>
                    </Grid>

                    <Grid item xs={12} sm={6} md={4}>
                        <Paper sx={styles.glassCard} elevation={0}>
                            <Box sx={styles.iconBox('#32d74b')}>
                                <SecuredIcon sx={{ fontSize: 40 }} />
                            </Box>
                            <Typography variant="h5" fontWeight="700" gutterBottom>
                                Secured 🔒
                            </Typography>
                            <Typography variant="body1" color="text.secondary">
                                Built with industry-standard protocols to ensure your workspace remains private and protected.
                            </Typography>
                        </Paper>
                    </Grid>

                </Grid>
            </Container>

            {/* --- FOOTER --- */}
            <Box sx={{ py: 6, textAlign: 'center', backgroundColor: 'transparent' }}>
                <Typography variant="body2" color="text.primary" fontWeight="600">
                    © {new Date().getFullYear()} Bala-oy Rhode B. All rights reserved.
                </Typography>
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 1 }}>
                    Powered by RHGE Tracker • Laravel v{laravelVersion}
                </Typography>
            </Box>
        </Box>
    );
}