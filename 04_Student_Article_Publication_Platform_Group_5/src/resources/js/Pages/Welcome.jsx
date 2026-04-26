import React, { useState, useEffect } from 'react';
import { Head, Link } from '@inertiajs/react';
import { useThemeContext } from '@/Context/ThemeContext';
import {
    Container,
    Typography,
    Box,
    Button,
    Grid,
    Card,
    Avatar,
    Fade,
    Chip,
    Stack,
    CssBaseline,
    IconButton,
    Tooltip,
    Paper,
    Divider,
    alpha
} from '@mui/material';
import {
    Edit,
    Visibility,
    School,
    Brightness4,
    Brightness7,
    Login,
    PersonAdd,
    ArrowForward,
    Star,
    TrendingUp,
    Groups,
    Lightbulb,
    AutoAwesome,
    RocketLaunch,
    Speed,
    Assignment,
    Timeline,
    Analytics
} from '@mui/icons-material';

export default function Welcome({ auth, laravelVersion, phpVersion }) {
    const { mode, setMode } = useThemeContext();
    const [mounted, setMounted] = useState(false);

    useEffect(() => {
        setMounted(true);
    }, []);

    const toggleTheme = () => {
        const newTheme = mode === 'light' ? 'dark' : mode === 'dark' ? 'galaxy' : 'light';
        setMode(newTheme);
    };

    const features = [
        {
            icon: <Edit />,
            title: 'Creative Writing',
            description: 'Express your ideas with our rich text editor',
            details: 'Write, edit, and save your articles with ease',
            color: mode === 'light' ? '#6366f1' : 
                     mode === 'dark' ? '#06b6d4' : 
                     '#8b5cf6',
            stats: '500+ Articles'
        },
        {
            icon: <Visibility />,
            title: 'Expert Review',
            description: 'Get professional feedback from editors',
            details: 'Collaborative review process with real-time feedback',
            color: mode === 'light' ? '#ec4899' : 
                     mode === 'dark' ? '#f59e0b' : 
                     '#ec4899',
            stats: '95% Satisfaction'
        },
        {
            icon: <School />,
            title: 'Student Engagement',
            description: 'Connect with campus readers',
            details: 'Join discussions and share your perspective',
            color: mode === 'light' ? '#10b981' : 
                     mode === 'dark' ? '#10b981' : 
                     '#10b981',
            stats: '1000+ Readers'
        }
    ];

    const stats = [
        { icon: <TrendingUp />, value: '500+', label: 'Articles Published' },
        { icon: <Groups />, value: '1000+', label: 'Active Readers' },
        { icon: <Star />, value: '4.8', label: 'Average Rating' },
        { icon: <Speed />, value: '24/7', label: 'Platform Uptime' },
        { icon: <Analytics />, value: '50+', label: 'Campus Partners' },
        { icon: <Assignment />, value: '100%', label: 'Content Quality' }
    ];

    return (
        <React.Fragment>
            <CssBaseline />
            <Head title="Campus Article Platform - Share Your Voice" />

            {/* Theme Toggle */}
            <Box sx={{ position: 'fixed', top: 20, right: 20, zIndex: 1000 }}>
                <Tooltip title={`Switch to ${mode === 'light' ? 'Dark' : mode === 'dark' ? 'Galaxy' : 'Light'} Mode`}>
                    <IconButton
                        onClick={toggleTheme}
                        sx={{
                            bgcolor: alpha(mode === 'light' ? '#ffffff' : 
                                          mode === 'dark' ? '#1e293b' : 
                                          '#0f172a', 0.9),
                            backdropFilter: 'blur(10px)',
                            border: `1px solid ${alpha(mode === 'light' ? '#e2e8f0' : 
                                                 mode === 'dark' ? '#374151' : 
                                                 '#1e293b', 0.2)}`,
                            '&:hover': {
                                bgcolor: alpha(mode === 'light' ? '#ffffff' : 
                                              mode === 'dark' ? '#1e293b' : 
                                              '#0f172a', 0.95),
                                transform: 'scale(1.05)'
                            },
                        }}
                    >
                        {mode === 'light' ? <Brightness7 /> : mode === 'dark' ? <Brightness4 /> : <AutoAwesome />}
                    </IconButton>
                </Tooltip>
            </Box>

            {/* Hero Section */}
            <Box
                sx={{
                    minHeight: '100vh',
                    background: mode === 'light'
                        ? 'linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #bae6fd 100%)'
                        : mode === 'dark' 
                        ? 'linear-gradient(135deg, #0a0e27 0%, #1e293b 50%, #334155 100%)'
                        : 'radial-gradient(circle at 20% 50%, rgba(139, 92, 246, 0.15) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(236, 72, 153, 0.1) 0%, transparent 50%), linear-gradient(135deg, #0a0e27 0%, #1e293b 100%)',
                    display: 'flex',
                    alignItems: 'center',
                    position: 'relative',
                    overflow: 'hidden',
                }}
            >
                {/* Animated Background Elements */}
                <Box
                    sx={{
                        position: 'absolute',
                        top: '10%',
                        left: '10%',
                        width: 400,
                        height: 400,
                        background: mode === 'light' 
                            ? 'radial-gradient(circle, rgba(99, 102, 241, 0.1) 0%, transparent 70%)'
                            : mode === 'dark'
                            ? 'radial-gradient(circle, rgba(6, 182, 212, 0.1) 0%, transparent 70%)'
                            : 'radial-gradient(circle, rgba(139, 92, 246, 0.15) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 8s ease-in-out infinite',
                    }}
                />
                <Box
                    sx={{
                        position: 'absolute',
                        bottom: '10%',
                        right: '10%',
                        width: 300,
                        height: 300,
                        background: mode === 'light' 
                            ? 'radial-gradient(circle, rgba(236, 72, 153, 0.1) 0%, transparent 70%)'
                            : mode === 'dark'
                            ? 'radial-gradient(circle, rgba(245, 158, 11, 0.1) 0%, transparent 70%)'
                            : 'radial-gradient(circle, rgba(236, 72, 153, 0.1) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 10s ease-in-out infinite reverse',
                    }}
                />

                <Container maxWidth="xl" sx={{ position: 'relative', zIndex: 1 }}>
                    <Fade in={mounted} timeout={1000}>
                        <Stack spacing={6} alignItems="center" textAlign="center">
                            {/* Badge */}
                            <Chip
                                icon={<AutoAwesome />}
                                label="Campus Publication Platform"
                                sx={{
                                    bgcolor: alpha(mode === 'light' ? '#6366f1' : 
                                                   mode === 'dark' ? '#06b6d4' : 
                                                   '#8b5cf6', 0.1),
                                    color: mode === 'light' ? '#6366f1' : 
                                           mode === 'dark' ? '#06b6d4' : 
                                           '#8b5cf6',
                                    fontWeight: 700,
                                    fontSize: '1rem',
                                    px: 3,
                                    py: 1.5,
                                    borderRadius: 20,
                                    border: `1px solid ${alpha(mode === 'light' ? '#6366f1' : 
                                                              mode === 'dark' ? '#06b6d4' : 
                                                              '#8b5cf6', 0.3)}`
                                }}
                            />

                            {/* Main Title - Bigger and More Impactful */}
                            <Typography 
                                variant="h1" 
                                component="h1"
                                sx={{
                                    fontSize: { xs: '3.5rem', md: '5.5rem', lg: '6.5rem' },
                                    fontWeight: 900,
                                    lineHeight: 1.1,
                                    background: mode === 'light' 
                                        ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 50%, #ec4899 100%)'
                                        : mode === 'dark'
                                        ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 50%, #f59e0b 100%)'
                                        : 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 50%, #f59e0b 100%)',
                                    WebkitBackgroundClip: 'text',
                                    WebkitTextFillColor: 'transparent',
                                    backgroundClip: 'text',
                                    textFillColor: 'transparent',
                                    letterSpacing: '-0.02em',
                                    textShadow: mode === 'light' 
                                        ? '0 4px 20px rgba(99, 102, 241, 0.1)'
                                        : mode === 'dark'
                                        ? '0 4px 20px rgba(6, 182, 212, 0.1)'
                                        : '0 4px 20px rgba(139, 92, 246, 0.2)',
                                    mb: 3,
                                    animation: 'glow 3s ease-in-out infinite alternate'
                                }}
                            >
                                Where Campus Voices
                                <br />
                                <Box component="span" sx={{ 
                                    fontSize: { xs: '4rem', md: '6rem', lg: '7rem' },
                                    display: 'block',
                                    mt: 1
                                }}>
                                    Go Viral (Locally)
                                </Box>
                            </Typography>

                            {/* Enhanced Subtitle */}
                            <Typography
                                variant="h4"
                                sx={{
                                    color: mode === 'light' ? '#64748b' : 
                                           mode === 'dark' ? '#cbd5e1' : 
                                           '#e2e8f0',
                                    maxWidth: 700,
                                    lineHeight: 1.6,
                                    fontSize: { xs: '1.1rem', md: '1.3rem' },
                                    fontWeight: 500,
                                    mb: 4
                                }}
                            >
                                Join our vibrant campus community where writers create, editors refine, 
                                and readers engage with compelling stories that matter.
                            </Typography>

                            {/* Enhanced CTA Buttons */}
                            <Stack
                                direction={{ xs: 'column', sm: 'row' }}
                                spacing={3}
                                sx={{ mt: 2 }}
                            >
                                <Button
                                    variant="contained"
                                    size="large"
                                    startIcon={<Login />}
                                    component={Link}
                                    href="/login"
                                    sx={{
                                        px: 5,
                                        py: 2.5,
                                        fontSize: '1.2rem',
                                        fontWeight: 700,
                                        background: mode === 'light' 
                                            ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)'
                                            : mode === 'dark'
                                            ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)'
                                            : 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                        boxShadow: mode === 'light' 
                                            ? '0 8px 32px rgba(99, 102, 241, 0.4)'
                                            : mode === 'dark'
                                            ? '0 8px 32px rgba(6, 182, 212, 0.3)'
                                            : '0 8px 32px rgba(139, 92, 246, 0.4)',
                                        '&:hover': {
                                            background: mode === 'light' 
                                                ? 'linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)'
                                                : mode === 'dark'
                                                ? 'linear-gradient(135deg, #0891b2 0%, #0e7490 100%)'
                                                : 'linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%)',
                                            transform: 'translateY(-4px) scale(1.02)',
                                            boxShadow: mode === 'light' 
                                                ? '0 12px 40px rgba(99, 102, 241, 0.5)'
                                                : mode === 'dark'
                                                ? '0 12px 40px rgba(6, 182, 212, 0.4)'
                                                : '0 12px 40px rgba(139, 92, 246, 0.5)'
                                        }
                                    }}
                                >
                                    Sign In to Continue
                                </Button>
                                <Button
                                    variant="outlined"
                                    size="large"
                                    startIcon={<PersonAdd />}
                                    component={Link}
                                    href="/register"
                                    sx={{
                                        px: 5,
                                        py: 2.5,
                                        fontSize: '1.2rem',
                                        fontWeight: 700,
                                        borderColor: mode === 'light' ? '#6366f1' : 
                                                     mode === 'dark' ? '#06b6d4' : 
                                                     '#8b5cf6',
                                        color: mode === 'light' ? '#6366f1' : 
                                               mode === 'dark' ? '#06b6d4' : 
                                               '#8b5cf6',
                                        borderWidth: 2,
                                        '&:hover': {
                                            borderColor: mode === 'light' ? '#4f46e5' : 
                                                         mode === 'dark' ? '#0891b2' : 
                                                         '#7c3aed',
                                            color: mode === 'light' ? '#4f46e5' : 
                                                   mode === 'dark' ? '#0891b2' : 
                                                   '#7c3aed',
                                            transform: 'translateY(-4px) scale(1.02)',
                                            backgroundColor: alpha(mode === 'light' ? '#6366f1' : 
                                                              mode === 'dark' ? '#06b6d4' : 
                                                              '#8b5cf6', 0.05)
                                        }
                                    }}
                                >
                                    Create Account
                                </Button>
                            </Stack>

                            {/* Enhanced Quick Stats */}
                            <Stack
                                direction={{ xs: 'column', sm: 'row' }}
                                spacing={4}
                                sx={{ mt: 6 }}
                            >
                                {stats.map((stat, index) => (
                                    <Stack key={index} alignItems="center" spacing={1.5}>
                                        <Avatar
                                            sx={{
                                                bgcolor: alpha(mode === 'light' ? '#6366f1' : 
                                                             mode === 'dark' ? '#06b6d4' : 
                                                             '#8b5cf6', 0.1),
                                                color: mode === 'light' ? '#6366f1' : 
                                                       mode === 'dark' ? '#06b6d4' : 
                                                       '#8b5cf6',
                                                width: 56,
                                                height: 56,
                                                fontSize: '1.5rem'
                                            }}
                                        >
                                            {stat.icon}
                                        </Avatar>
                                        <Box textAlign="center">
                                            <Typography variant="h3" fontWeight="800" sx={{ 
                                                color: mode === 'light' ? '#1e293b' : 
                                                       mode === 'dark' ? '#f8fafc' : 
                                                       '#e2e8f0',
                                                fontSize: '2rem'
                                            }}>
                                                {stat.value}
                                            </Typography>
                                            <Typography variant="body2" sx={{ 
                                                color: mode === 'light' ? '#64748b' : 
                                                       mode === 'dark' ? '#cbd5e1' : 
                                                       '#94a3b8',
                                                fontWeight: 600
                                            }}>
                                                {stat.label}
                                            </Typography>
                                        </Box>
                                    </Stack>
                                ))}
                            </Stack>
                        </Stack>
                    </Fade>
                </Container>
            </Box>

            {/* Features Preview */}
            <Box sx={{ py: { xs: 10, md: 14 }, bgcolor: mode === 'light' ? '#f8fafc' : 
                                                                              mode === 'dark' ? '#1e293b' : 
                                                                              '#0f172a' }}>
                <Container maxWidth="xl">
                    <Fade in={mounted} timeout={1500}>
                        <Stack spacing={6} textAlign="center">
                            <Chip
                                icon={<Lightbulb />}
                                label="What Makes Us Special"
                                sx={{
                                    bgcolor: alpha(mode === 'light' ? '#ec4899' : 
                                                   mode === 'dark' ? '#f59e0b' : 
                                                   '#f59e0b', 0.1),
                                    color: mode === 'light' ? '#ec4899' : 
                                           mode === 'dark' ? '#f59e0b' : 
                                           '#f59e0b',
                                    fontWeight: 700,
                                    fontSize: '1rem',
                                    mx: 'auto',
                                    width: 'fit-content',
                                    px: 3,
                                    py: 1.5,
                                    borderRadius: 20
                                }}
                            />
                            
                            <Typography variant="h2" component="h2" sx={{ 
                                fontSize: { xs: '2.5rem', md: '3rem' },
                                fontWeight: 800,
                                background: mode === 'light' 
                                    ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)'
                                    : mode === 'dark'
                                    ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)'
                                    : 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                WebkitBackgroundClip: 'text',
                                WebkitTextFillColor: 'transparent',
                                backgroundClip: 'text',
                                textFillColor: 'transparent',
                                mb: 3
                            }}>
                                Platform Sneak Preview
                            </Typography>
                            
                            <Typography
                                variant="h5"
                                sx={{ 
                                    color: mode === 'light' ? '#64748b' : 
                                           mode === 'dark' ? '#cbd5e1' : 
                                           '#e2e8f0',
                                    maxWidth: 700,
                                    mx: 'auto',
                                    lineHeight: 1.6,
                                    fontSize: { xs: '1.1rem', md: '1.2rem' }
                                }}
                            >
                                Discover how our platform brings together the entire campus publication ecosystem
                                in one seamless experience.
                            </Typography>

                            <Grid container spacing={4} sx={{ mt: 6 }}>
                                {features.map((feature, index) => (
                                    <Grid item xs={12} md={4} key={index}>
                                        <Card
                                            sx={{
                                                p: 4,
                                                height: '100%',
                                                display: 'flex',
                                                flexDirection: 'column',
                                                alignItems: 'center',
                                                textAlign: 'center',
                                                background: mode === 'light' 
                                                    ? 'linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(248, 250, 252, 0.9) 100%)'
                                                    : mode === 'dark'
                                                    ? 'linear-gradient(135deg, rgba(30, 41, 59, 0.8) 0%, rgba(51, 65, 85, 0.8) 100%)'
                                                    : 'linear-gradient(135deg, rgba(15, 23, 42, 0.8) 0%, rgba(30, 41, 59, 0.8) 100%)',
                                                border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                                         mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                                         '1px solid rgba(139, 92, 246, 0.2)',
                                                backdropFilter: 'blur(20px)',
                                                transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                                                '&:hover': {
                                                    transform: 'translateY(-12px) scale(1.02)',
                                                    boxShadow: mode === 'light' 
                                                        ? '0 25px 50px rgba(0, 0, 0, 0.15), 0 0 25px rgba(99, 102, 241, 0.1)'
                                                        : mode === 'dark'
                                                        ? '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 25px rgba(6, 182, 212, 0.1)'
                                                        : '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 25px rgba(139, 92, 246, 0.1)'
                                                }
                                            }}
                                        >
                                            <Avatar
                                                sx={{
                                                    bgcolor: feature.color,
                                                    width: 72,
                                                    height: 72,
                                                    mb: 3,
                                                    fontSize: '2rem'
                                                }}
                                            >
                                                {feature.icon}
                                            </Avatar>
                                            
                                            <Typography variant="h4" gutterBottom fontWeight="700" sx={{ 
                                                fontSize: { xs: '1.3rem', md: '1.5rem' },
                                                color: mode === 'light' ? '#1e293b' : 
                                                       mode === 'dark' ? '#f8fafc' : 
                                                       '#e2e8f0'
                                            }}>
                                                {feature.title}
                                            </Typography>
                                            
                                            <Typography
                                                variant="h6"
                                                sx={{ 
                                                    color: mode === 'light' ? '#64748b' : 
                                                           mode === 'dark' ? '#cbd5e1' : 
                                                           '#94a3b8',
                                                    mb: 2,
                                                    fontSize: { xs: '1rem', md: '1.1rem' }
                                                }}
                                            >
                                                {feature.description}
                                            </Typography>
                                            
                                            <Typography
                                                variant="body1"
                                                sx={{ 
                                                    color: mode === 'light' ? '#64748b' : 
                                                           mode === 'dark' ? '#cbd5e1' : 
                                                           '#94a3b8',
                                                    mb: 3,
                                                    flexGrow: 1,
                                                    lineHeight: 1.6
                                                }}
                                            >
                                                {feature.details}
                                            </Typography>
                                            
                                            <Chip
                                                label={feature.stats}
                                                size="medium"
                                                sx={{
                                                    bgcolor: alpha(feature.color, 0.15),
                                                    color: feature.color,
                                                    fontWeight: 700,
                                                    fontSize: '0.9rem',
                                                    px: 2,
                                                    py: 1
                                                }}
                                            />
                                        </Card>
                                    </Grid>
                                ))}
                            </Grid>
                        </Stack>
                    </Fade>
                </Container>
            </Box>

            {/* Enhanced CTA Section */}
            <Box
                sx={{
                    py: { xs: 10, md: 14 },
                    background: mode === 'light' 
                        ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)'
                        : mode === 'dark'
                        ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)'
                        : 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                    color: 'white',
                    textAlign: 'center',
                    position: 'relative',
                    overflow: 'hidden'
                }}
            >
                {/* Background Animation */}
                <Box
                    sx={{
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        background: 'radial-gradient(circle at 50% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 70%)',
                        animation: 'pulse 4s ease-in-out infinite'
                    }}
                />
                
                <Container maxWidth="md" sx={{ position: 'relative', zIndex: 1 }}>
                    <Fade in={mounted} timeout={2000}>
                        <Stack spacing={4} alignItems="center">
                            <RocketLaunch sx={{ fontSize: 64, opacity: 0.9, mb: 2 }} />
                            
                            <Typography variant="h2" component="h2" fontWeight="800" sx={{ 
                                fontSize: { xs: '2.5rem', md: '3rem' },
                                mb: 2
                            }}>
                                Ready to Start Your Journey?
                            </Typography>
                            
                            <Typography variant="h5" sx={{ 
                                opacity: 0.95, 
                                maxWidth: 600,
                                lineHeight: 1.6,
                                fontSize: { xs: '1.1rem', md: '1.2rem' }
                            }}>
                                Join hundreds of students already sharing their stories and shaping campus discourse.
                            </Typography>
                            
                            <Button
                                variant="contained"
                                size="large"
                                endIcon={<ArrowForward />}
                                component={Link}
                                href="/register"
                                sx={{
                                    px: 6,
                                    py: 3,
                                    fontSize: '1.3rem',
                                    fontWeight: 700,
                                    bgcolor: 'white',
                                    color: mode === 'light' ? '#6366f1' : 
                                           mode === 'dark' ? '#06b6d4' : 
                                           '#8b5cf6',
                                    '&:hover': {
                                        bgcolor: alpha('#ffffff', 0.9),
                                        transform: 'translateY(-4px) scale(1.05)',
                                        boxShadow: '0 12px 40px rgba(0, 0, 0, 0.2)'
                                    }
                                }}
                            >
                                Get Started Now
                            </Button>
                        </Stack>
                    </Fade>
                </Container>
            </Box>

            {/* Footer */}
            <Box
                sx={{
                    py: 6,
                    bgcolor: mode === 'light' ? '#1e293b' : 
                                   mode === 'dark' ? '#0a0e27' : 
                                   '#0a0e27',
                    color: 'white',
                }}
            >
                <Container maxWidth="xl" textAlign="center">
                    <Typography variant="h6" sx={{ opacity: 0.9, mb: 2 }}>
                        Built with ❤️ for campus communities everywhere
                    </Typography>
                    <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} justifyContent="center" alignItems="center">
                        <Typography variant="body2" sx={{ opacity: 0.8 }}>
                            Powered by Laravel v{laravelVersion}
                        </Typography>
                        <Typography variant="body2" sx={{ opacity: 0.8 }}>
                            •
                        </Typography>
                        <Typography variant="body2" sx={{ opacity: 0.8 }}>
                            PHP v{phpVersion}
                        </Typography>
                    </Stack>
                </Container>
            </Box>
        </React.Fragment>
    );
}