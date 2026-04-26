import {
    Box,
    Container,
    AppBar,
    Toolbar,
    Button,
    Typography,
    Card,
    Grid,
    Link,
    Divider,
    Stack,
    IconButton,
    Avatar,
} from '@mui/material';
import { useEffect, useState } from 'react';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import CreateIcon from '@mui/icons-material/Create';
import ReviewsIcon from '@mui/icons-material/Reviews';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import PsychologyIcon from '@mui/icons-material/Psychology';
import WorkIcon from '@mui/icons-material/Work';
import EmojiObjectsIcon from '@mui/icons-material/EmojiObjects';
import GroupsIcon from '@mui/icons-material/Groups';
import LinkedInIcon from '@mui/icons-material/LinkedIn';
import TwitterIcon from '@mui/icons-material/Twitter';
import FacebookIcon from '@mui/icons-material/Facebook';
import { Article as ArticleIcon } from '@mui/icons-material';
import { Head, Link as InertiaLink, usePage } from '@inertiajs/react';

const LandingPage = () => {
    const theme = useTheme();
    const { auth } = usePage().props;
    const user = auth?.user;
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [activeSection, setActiveSection] = useState('');
    const [stats, setStats] = useState({
        students: 0,
        articles: 0,
        satisfaction: 0,
    });

    useEffect(() => {
        const durationMs = 1400;
        const targets = {
            students: 10,
            articles: 5,
            satisfaction: 98,
        };

        let animationFrameId;
        const startTime = performance.now();

        const animate = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / durationMs, 1);
            const easedProgress = 1 - Math.pow(1 - progress, 3);

            setStats({
                students: Math.round(targets.students * easedProgress),
                articles: Math.round(targets.articles * easedProgress),
                satisfaction: Math.round(targets.satisfaction * easedProgress),
            });

            if (progress < 1) {
                animationFrameId = requestAnimationFrame(animate);
            }
        };

        animationFrameId = requestAnimationFrame(animate);

        return () => cancelAnimationFrame(animationFrameId);
    }, []);

    // Track active section based on scroll position
    useEffect(() => {
        const handleScroll = () => {
            const sections = ['features', 'benefits', 'testimonials'];
            const scrollPosition = window.scrollY + 100; // Offset for better detection

            for (const sectionId of sections) {
                const element = document.getElementById(sectionId);
                if (element) {
                    const { offsetTop, offsetHeight } = element;
                    if (scrollPosition >= offsetTop && scrollPosition < offsetTop + offsetHeight) {
                        setActiveSection(sectionId);
                        break;
                    }
                }
            }
        };

        window.addEventListener('scroll', handleScroll);
        handleScroll(); // Check initial position

        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    return (
        <>
            <Head title="Welcome to SAPP - Share Your Voice" />

            {/* ==================== NAVIGATION BAR ==================== */}
            <AppBar
                position="sticky"
                elevation={0}
                sx={{
                    backgroundColor: '#FFFFFF',
                    borderBottom: `1px solid ${theme.palette.divider}`,
                }}
            >
                <Container maxWidth="lg">
                    <Toolbar sx={{ justifyContent: 'space-between', px: 0 }}>
                        <Box
                            component="a"
                            href="/"
                            sx={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: 1,
                                textDecoration: 'none',
                            }}
                        >
                            <Box
                                sx={{
                                    width: 40,
                                    height: 40,
                                    borderRadius: '10px',
                                    background: 'linear-gradient(135deg, #1B2A4A 0%, #2A7B9B 100%)',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                }}
                            >
                                <ArticleIcon sx={{ color: '#fff', fontSize: 20 }} />
                            </Box>
                            <Typography
                                variant="h5"
                                sx={{
                                    fontWeight: 800,
                                    color: theme.palette.primary.main,
                                    letterSpacing: '-0.02em',
                                }}
                            >
                                UniVox
                            </Typography>
                        </Box>

                        {!isMobile && (
                            <Box sx={{ display: 'flex', gap: 3 }}>
                                <Link
                                    href="#features"
                                    sx={{
                                        color: activeSection === 'features' ? theme.palette.primary.main : theme.palette.text.primary,
                                        textDecoration: 'none',
                                        fontSize: '0.95rem',
                                        fontWeight: activeSection === 'features' ? 600 : 500,
                                        position: 'relative',
                                        padding: '8px 12px',
                                        borderRadius: '6px',
                                        transition: 'all 0.3s ease',
                                        backgroundColor: activeSection === 'features' ? `${theme.palette.primary.main}08` : 'transparent',
                                        '&::after': {
                                            content: '""',
                                            position: 'absolute',
                                            bottom: '4px',
                                            left: '12px',
                                            right: '12px',
                                            height: '2px',
                                            backgroundColor: theme.palette.primary.main,
                                            transform: activeSection === 'features' ? 'scaleX(1)' : 'scaleX(0)',
                                            transition: 'transform 0.3s ease',
                                        },
                                        '&:hover': {
                                            color: theme.palette.primary.main,
                                            backgroundColor: `${theme.palette.primary.main}08`,
                                            transform: 'translateY(-2px)',
                                            '&::after': {
                                                transform: 'scaleX(1)',
                                            },
                                        },
                                        '&:active': {
                                            transform: 'translateY(0)',
                                            backgroundColor: `${theme.palette.primary.main}15`,
                                        },
                                    }}
                                >
                                    Features
                                </Link>
                                <Link
                                    href="#benefits"
                                    sx={{
                                        color: activeSection === 'benefits' ? theme.palette.primary.main : theme.palette.text.primary,
                                        textDecoration: 'none',
                                        fontSize: '0.95rem',
                                        fontWeight: activeSection === 'benefits' ? 600 : 500,
                                        position: 'relative',
                                        padding: '8px 12px',
                                        borderRadius: '6px',
                                        transition: 'all 0.3s ease',
                                        backgroundColor: activeSection === 'benefits' ? `${theme.palette.primary.main}08` : 'transparent',
                                        '&::after': {
                                            content: '""',
                                            position: 'absolute',
                                            bottom: '4px',
                                            left: '12px',
                                            right: '12px',
                                            height: '2px',
                                            backgroundColor: theme.palette.primary.main,
                                            transform: activeSection === 'benefits' ? 'scaleX(1)' : 'scaleX(0)',
                                            transition: 'transform 0.3s ease',
                                        },
                                        '&:hover': {
                                            color: theme.palette.primary.main,
                                            backgroundColor: `${theme.palette.primary.main}08`,
                                            transform: 'translateY(-2px)',
                                            '&::after': {
                                                transform: 'scaleX(1)',
                                            },
                                        },
                                        '&:active': {
                                            transform: 'translateY(0)',
                                            backgroundColor: `${theme.palette.primary.main}15`,
                                        },
                                    }}
                                >
                                    Benefits
                                </Link>
                                <Link
                                    href="#testimonials"
                                    sx={{
                                        color: activeSection === 'testimonials' ? theme.palette.primary.main : theme.palette.text.primary,
                                        textDecoration: 'none',
                                        fontSize: '0.95rem',
                                        fontWeight: activeSection === 'testimonials' ? 600 : 500,
                                        position: 'relative',
                                        padding: '8px 12px',
                                        borderRadius: '6px',
                                        transition: 'all 0.3s ease',
                                        backgroundColor: activeSection === 'testimonials' ? `${theme.palette.primary.main}08` : 'transparent',
                                        '&::after': {
                                            content: '""',
                                            position: 'absolute',
                                            bottom: '4px',
                                            left: '12px',
                                            right: '12px',
                                            height: '2px',
                                            backgroundColor: theme.palette.primary.main,
                                            transform: activeSection === 'testimonials' ? 'scaleX(1)' : 'scaleX(0)',
                                            transition: 'transform 0.3s ease',
                                        },
                                        '&:hover': {
                                            color: theme.palette.primary.main,
                                            backgroundColor: `${theme.palette.primary.main}08`,
                                            transform: 'translateY(-2px)',
                                            '&::after': {
                                                transform: 'scaleX(1)',
                                            },
                                        },
                                        '&:active': {
                                            transform: 'translateY(0)',
                                            backgroundColor: `${theme.palette.primary.main}15`,
                                        },
                                    }}
                                >
                                    Testimonials
                                </Link>
                                <InertiaLink
                                    href="/articles"
                                    style={{ textDecoration: 'none' }}
                                >
                                    <Box
                                        sx={{
                                            color: theme.palette.text.primary,
                                            fontSize: '0.95rem',
                                            fontWeight: 500,
                                            position: 'relative',
                                            padding: '8px 12px',
                                            borderRadius: '6px',
                                            transition: 'all 0.3s ease',
                                            '&:hover': {
                                                color: theme.palette.primary.main,
                                                backgroundColor: `${theme.palette.primary.main}08`,
                                                transform: 'translateY(-2px)',
                                            },
                                        }}
                                    >
                                        Articles
                                    </Box>
                                </InertiaLink>
                            </Box>
                        )}

                        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                            {user ? (
                                <>
                                    <Avatar
                                        sx={{
                                            width: 36,
                                            height: 36,
                                            bgcolor: theme.palette.primary.main,
                                            fontSize: '0.95rem',
                                            fontWeight: 700,
                                        }}
                                    >
                                        {user.name?.charAt(0)?.toUpperCase() || 'U'}
                                    </Avatar>
                                    <Button
                                        variant="contained"
                                        component={InertiaLink}
                                        href="/dashboard"
                                        sx={{
                                            backgroundColor: theme.palette.primary.main,
                                            '&:hover': {
                                                backgroundColor: theme.palette.primary.dark,
                                            },
                                            fontWeight: 600,
                                        }}
                                    >
                                        Dashboard
                                    </Button>
                                </>
                            ) : (
                                <>
                                    <Button
                                        variant="text"
                                        component={InertiaLink}
                                        href="/login"
                                        sx={{
                                            color: theme.palette.text.primary,
                                            fontWeight: 600,
                                        }}
                                    >
                                        Log In
                                    </Button>
                                    <Button
                                        variant="contained"
                                        component={InertiaLink}
                                        href="/register"
                                        sx={{
                                            backgroundColor: theme.palette.primary.main,
                                            '&:hover': {
                                                backgroundColor: theme.palette.primary.dark,
                                            },
                                            fontWeight: 600,
                                        }}
                                    >
                                        Sign Up
                                    </Button>
                                </>
                            )}
                        </Box>
                    </Toolbar>
                </Container>
            </AppBar>

            {/* ==================== HERO SECTION ==================== */}
            <Box
                sx={{
                    backgroundColor: theme.palette.background.default,
                    pt: { xs: 6, md: 10 },
                    pb: { xs: 6, md: 12 },
                    position: 'relative',
                    overflow: 'hidden',
                }}
            >
                <Container maxWidth="lg">
                    <Grid container spacing={{ xs: 4, md: 6 }} alignItems="center">
                        {/* Left Content */}
                        <Grid item xs={12} md={6}>
                            <Box>
                                <Typography
                                    variant="overline"
                                    sx={{
                                        color: theme.palette.primary.main,
                                        fontWeight: 700,
                                        fontSize: '0.875rem',
                                        letterSpacing: '0.1em',
                                        mb: 2,
                                        display: 'block',
                                    }}
                                >
                                    STUDENT ARTICLE PUBLICATION PLATFORM
                                </Typography>

                                <Typography
                                    variant="h1"
                                    sx={{
                                        fontWeight: 800,
                                        color: theme.palette.text.primary,
                                        fontSize: { xs: '2.5rem', md: '3.5rem' },
                                        lineHeight: 1.1,
                                        mb: 3,
                                    }}
                                >
                                    Share Your Voice{' '}
                                    <Box
                                        component="span"
                                        sx={{
                                            color: theme.palette.primary.main,
                                        }}
                                    >
                                        Publish Your Stories
                                    </Box>
                                </Typography>

                                <Typography
                                    variant="h6"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        fontWeight: 400,
                                        mb: 4,
                                        lineHeight: 1.7,
                                    }}
                                >
                                    Join thousands of students sharing their research, ideas, and perspectives. 
                                    Write, collaborate, and get published on the premier platform for student voices.
                                </Typography>

                                <Box
                                    sx={{
                                        display: 'flex',
                                        alignItems: { xs: 'flex-start', lg: 'center' },
                                        justifyContent: 'space-between',
                                        flexDirection: { xs: 'column', lg: 'row' },
                                        gap: 3,
                                        mb: 1,
                                    }}
                                >
                                    <Stack
                                        direction={{ xs: 'column', sm: 'row' }}
                                        spacing={2}
                                        sx={{ width: { xs: '100%', lg: 'auto' } }}
                                    >
                                        <Button
                                            variant="contained"
                                            size="large"
                                            component={InertiaLink}
                                            href="/register"
                                            sx={{
                                                backgroundColor: theme.palette.primary.main,
                                                '&:hover': {
                                                    backgroundColor: theme.palette.primary.dark,
                                                },
                                                px: 5,
                                                py: 1.8,
                                                fontSize: '1rem',
                                                fontWeight: 700,
                                            }}
                                            startIcon={<CreateIcon />}
                                        >
                                            Start Writing Today
                                        </Button>
                                        <Button
                                            variant="outlined"
                                            size="large"
                                            component={InertiaLink}
                                            href="/register"
                                            sx={{
                                                borderColor: theme.palette.text.primary,
                                                color: theme.palette.text.primary,
                                                '&:hover': {
                                                    borderColor: theme.palette.primary.main,
                                                    backgroundColor: 'rgba(37, 82, 115, 0.04)',
                                                },
                                                px: 5,
                                                py: 1.8,
                                                fontSize: '1rem',
                                                fontWeight: 600,
                                            }}
                                        >
                                            Learn More
                                        </Button>
                                        <Button
                                            variant="outlined"
                                            size="large"
                                            component={InertiaLink}
                                            href="/articles"
                                            sx={{
                                                borderWidth: 2,
                                                fontWeight: 700,
                                                '&:hover': { borderWidth: 2 },
                                            }}
                                        >
                                            Browse Articles
                                        </Button>
                                    </Stack>

                                    <Box
                                        sx={{
                                            display: 'flex',
                                            alignItems: 'center',
                                            gap: { xs: 3, sm: 4 },
                                            width: { xs: '100%', lg: 'auto' },
                                            justifyContent: { xs: 'flex-start', lg: 'flex-end' },
                                        }}
                                    >
                                        <Box>
                                            <Typography
                                                variant="h4"
                                                sx={{
                                                    fontWeight: 800,
                                                    color: theme.palette.primary.main,
                                                }}
                                            >
                                                {stats.students}K+
                                            </Typography>
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    color: theme.palette.text.secondary,
                                                    fontWeight: 500,
                                                }}
                                            >
                                                Students
                                            </Typography>
                                        </Box>
                                        <Box>
                                            <Typography
                                                variant="h4"
                                                sx={{
                                                    fontWeight: 800,
                                                    color: theme.palette.primary.main,
                                                }}
                                            >
                                                {stats.articles}K+
                                            </Typography>
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    color: theme.palette.text.secondary,
                                                    fontWeight: 500,
                                                }}
                                            >
                                                Articles
                                            </Typography>
                                        </Box>
                                        <Box>
                                            <Typography
                                                variant="h4"
                                                sx={{
                                                    fontWeight: 800,
                                                    color: theme.palette.primary.main,
                                                }}
                                            >
                                                {stats.satisfaction}%
                                            </Typography>
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    color: theme.palette.text.secondary,
                                                    fontWeight: 500,
                                                }}
                                            >
                                                Satisfaction
                                            </Typography>
                                        </Box>
                                    </Box>
                                </Box>
                            </Box>
                        </Grid>

                        {/* Right Image */}
                        <Grid item xs={12} md={6}>
                            <Box
                                sx={{
                                    position: 'relative',
                                    height: '100%',
                                    minHeight: { xs: 300, md: 500 },
                                    borderRadius: 3,
                                    overflow: 'hidden',
                                    boxShadow: '0 20px 60px rgba(0,0,0,0.15)',
                                }}
                            >
                                <Box
                                    component="img"
                                    src="/images/school.png"
                                    alt="Students collaborating"
                                    sx={{
                                        width: '100%',
                                        height: '100%',
                                        objectFit: 'cover',
                                    }}
                                />
                                {/* Overlay Gradient */}
                                <Box
                                    sx={{
                                        position: 'absolute',
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        background: `linear-gradient(135deg, ${theme.palette.primary.main}15 0%, transparent 100%)`,
                                    }}
                                />
                            </Box>
                        </Grid>
                    </Grid>
                </Container>

                {/* Background Decoration */}
                <Box
                    sx={{
                        position: 'absolute',
                        top: '10%',
                        right: '-5%',
                        width: 400,
                        height: 400,
                        borderRadius: '50%',
                        background: `radial-gradient(circle, ${theme.palette.primary.main}10 0%, transparent 70%)`,
                        pointerEvents: 'none',
                        display: { xs: 'none', md: 'block' },
                    }}
                />
            </Box>

            {/* ==================== FEATURES SECTION ==================== */}
            <Box
                id="features"
                sx={{
                    py: { xs: 6, md: 10 },
                    backgroundColor: '#FFFFFF',
                }}
            >
                <Container maxWidth="lg">
                    {/* Section Header */}
                    <Box sx={{ textAlign: 'center', mb: 8 }}>
                        <Typography
                            variant="overline"
                            sx={{
                                color: theme.palette.primary.main,
                                fontWeight: 700,
                                fontSize: '0.875rem',
                                letterSpacing: '0.1em',
                                mb: 2,
                                display: 'block',
                            }}
                        >
                            POWERFUL FEATURES
                        </Typography>
                        <Typography
                            variant="h3"
                            sx={{
                                fontWeight: 800,
                                color: theme.palette.text.primary,
                                mb: 2,
                            }}
                        >
                            Everything You Need to Publish
                        </Typography>
                        <Typography
                            variant="h6"
                            sx={{
                                color: theme.palette.text.secondary,
                                fontWeight: 400,
                                maxWidth: 600,
                                mx: 'auto',
                            }}
                        >
                            From drafting to publishing, we've got you covered with intuitive tools designed for student writers.
                        </Typography>
                    </Box>

                    <Box
                        sx={{
                            display: 'grid',
                            gridTemplateColumns: {
                                xs: '1fr',
                                md: 'repeat(3, minmax(0, 1fr))',
                            },
                            gap: 4,
                        }}
                    >
                        {/* Feature 1: Write */}
                        <Box sx={{ display: 'flex' }}>
                            <Card
                                elevation={0}
                                sx={{
                                    width: '100%',
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    p: 3,
                                    border: `2px solid ${theme.palette.divider}`,
                                    borderRadius: 3,
                                    transition: 'all 0.3s ease',
                                    cursor: 'pointer',
                                    '& .feature-icon': {
                                        transition: 'transform 0.25s ease, background-color 0.25s ease',
                                    },
                                    '& .feature-preview': {
                                        transition: 'background-color 0.25s ease',
                                    },
                                    '&:hover': {
                                        borderColor: theme.palette.primary.main,
                                        boxShadow: `0 12px 28px rgba(37, 82, 115, 0.16)`,
                                        transform: 'translateY(-6px)',
                                        '& .feature-icon': {
                                            transform: 'scale(1.06)',
                                            backgroundColor: `${theme.palette.primary.main}22`,
                                        },
                                        '& .feature-preview': {
                                            backgroundColor: '#EEF3F8',
                                        },
                                    },
                                }}
                            >
                                <Box
                                    className="feature-icon"
                                    sx={{
                                        width: 64,
                                        height: 64,
                                        borderRadius: 2,
                                        backgroundColor: `${theme.palette.primary.main}15`,
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        mb: 3,
                                    }}
                                >
                                    <CreateIcon
                                        sx={{
                                            fontSize: 32,
                                            color: theme.palette.primary.main,
                                        }}
                                    />
                                </Box>

                                <Typography
                                    variant="h5"
                                    sx={{
                                        fontWeight: 700,
                                        color: theme.palette.text.primary,
                                        mb: 2,
                                    }}
                                >
                                    Focus & Write
                                </Typography>

                                <Typography
                                    variant="body2"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        lineHeight: 1.7,
                                        mb: 3,
                                        flexGrow: 1,
                                    }}
                                >
                                    Distraction-free editor with word count tracking, auto-save, 
                                    and formatting tools to help you craft compelling articles.
                                </Typography>

                                {/* Progress Preview */}
                                <Box
                                    className="feature-preview"
                                    sx={{
                                        mt: 'auto',
                                        p: 2,
                                        backgroundColor: theme.palette.background.default,
                                        borderRadius: 2,
                                    }}
                                >
                                    <Box
                                        sx={{
                                            display: 'flex',
                                            justifyContent: 'space-between',
                                            mb: 1,
                                        }}
                                    >
                                        <Typography variant="caption" sx={{ fontWeight: 600 }}>
                                            Word Goal
                                        </Typography>
                                        <Typography
                                            variant="caption"
                                            sx={{ color: theme.palette.info.main, fontWeight: 600 }}
                                        >
                                            850 / 1200
                                        </Typography>
                                    </Box>
                                    <Box
                                        sx={{
                                            height: 8,
                                            backgroundColor: theme.palette.divider,
                                            borderRadius: 4,
                                            overflow: 'hidden',
                                        }}
                                    >
                                        <Box
                                            sx={{
                                                width: '71%',
                                                height: '100%',
                                                backgroundColor: theme.palette.info.main,
                                            }}
                                        />
                                    </Box>
                                </Box>
                            </Card>
                        </Box>

                        {/* Feature 2: Collaborate */}
                        <Box sx={{ display: 'flex' }}>
                            <Card
                                elevation={0}
                                sx={{
                                    width: '100%',
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    p: 3,
                                    border: `2px solid ${theme.palette.divider}`,
                                    borderRadius: 3,
                                    transition: 'all 0.3s ease',
                                    cursor: 'pointer',
                                    '& .feature-icon': {
                                        transition: 'transform 0.25s ease, background-color 0.25s ease',
                                    },
                                    '& .feature-preview': {
                                        transition: 'background-color 0.25s ease',
                                    },
                                    '&:hover': {
                                        borderColor: theme.palette.primary.main,
                                        boxShadow: `0 12px 28px rgba(37, 82, 115, 0.16)`,
                                        transform: 'translateY(-6px)',
                                        '& .feature-icon': {
                                            transform: 'scale(1.06)',
                                            backgroundColor: `${theme.palette.primary.main}22`,
                                        },
                                        '& .feature-preview': {
                                            backgroundColor: '#EEF3F8',
                                        },
                                    },
                                }}
                            >
                                <Box
                                    className="feature-icon"
                                    sx={{
                                        width: 64,
                                        height: 64,
                                        borderRadius: 2,
                                        backgroundColor: `${theme.palette.primary.main}15`,
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        mb: 3,
                                    }}
                                >
                                    <ReviewsIcon
                                        sx={{
                                            fontSize: 32,
                                            color: theme.palette.primary.main,
                                        }}
                                    />
                                </Box>

                                <Typography
                                    variant="h5"
                                    sx={{
                                        fontWeight: 700,
                                        color: theme.palette.text.primary,
                                        mb: 2,
                                    }}
                                >
                                    Refine & Review
                                </Typography>

                                <Typography
                                    variant="body2"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        lineHeight: 1.7,
                                        mb: 3,
                                        flexGrow: 1,
                                    }}
                                >
                                    Get feedback from peer reviewers, track revisions, and perfect 
                                    your work before publication.
                                </Typography>

                                {/* Status Preview */}
                                <Box
                                    className="feature-preview"
                                    sx={{
                                        mt: 'auto',
                                        p: 2,
                                        backgroundColor: theme.palette.background.default,
                                        borderRadius: 2,
                                    }}
                                >
                                    <Box
                                        sx={{
                                            display: 'flex',
                                            alignItems: 'center',
                                            gap: 1,
                                        }}
                                    >
                                        <Box
                                            sx={{
                                                width: 8,
                                                height: 8,
                                                borderRadius: '50%',
                                                backgroundColor: '#FFB74D',
                                            }}
                                        />
                                        <Typography variant="caption" sx={{ fontWeight: 600 }}>
                                            In Review
                                        </Typography>
                                    </Box>
                                    <Typography
                                        variant="caption"
                                        sx={{
                                            display: 'block',
                                            mt: 1,
                                            color: theme.palette.text.secondary,
                                        }}
                                    >
                                        2 reviewers assigned
                                    </Typography>
                                </Box>
                            </Card>
                        </Box>

                        {/* Feature 3: Publish */}
                        <Box sx={{ display: 'flex' }}>
                            <Card
                                elevation={0}
                                sx={{
                                    width: '100%',
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    p: 3,
                                    border: `2px solid ${theme.palette.divider}`,
                                    borderRadius: 3,
                                    transition: 'all 0.3s ease',
                                    cursor: 'pointer',
                                    '& .feature-icon': {
                                        transition: 'transform 0.25s ease, background-color 0.25s ease',
                                    },
                                    '& .feature-preview': {
                                        transition: 'background-color 0.25s ease',
                                    },
                                    '&:hover': {
                                        borderColor: theme.palette.primary.main,
                                        boxShadow: `0 12px 28px rgba(37, 82, 115, 0.16)`,
                                        transform: 'translateY(-6px)',
                                        '& .feature-icon': {
                                            transform: 'scale(1.06)',
                                            backgroundColor: `${theme.palette.primary.main}22`,
                                        },
                                        '& .feature-preview': {
                                            backgroundColor: '#EEF3F8',
                                        },
                                    },
                                }}
                            >
                                <Box
                                    className="feature-icon"
                                    sx={{
                                        width: 64,
                                        height: 64,
                                        borderRadius: 2,
                                        backgroundColor: `${theme.palette.primary.main}15`,
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        mb: 3,
                                    }}
                                >
                                    <EmojiEventsIcon
                                        sx={{
                                            fontSize: 32,
                                            color: theme.palette.primary.main,
                                        }}
                                    />
                                </Box>

                                <Typography
                                    variant="h5"
                                    sx={{
                                        fontWeight: 700,
                                        color: theme.palette.text.primary,
                                        mb: 2,
                                    }}
                                >
                                    Share with the World
                                </Typography>

                                <Typography
                                    variant="body2"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        lineHeight: 1.7,
                                        mb: 3,
                                        flexGrow: 1,
                                    }}
                                >
                                    Publish your articles to a global audience and build your academic 
                                    portfolio with metrics and analytics.
                                </Typography>

                                {/* Stats Preview */}
                                <Box
                                    className="feature-preview"
                                    sx={{
                                        mt: 'auto',
                                        p: 2,
                                        backgroundColor: theme.palette.background.default,
                                        borderRadius: 2,
                                    }}
                                >
                                    <Typography
                                        variant="caption"
                                        sx={{
                                            fontWeight: 600,
                                            display: 'block',
                                            mb: 1,
                                        }}
                                    >
                                        Your Published Articles
                                    </Typography>
                                    <Typography
                                        variant="h4"
                                        sx={{
                                            fontWeight: 700,
                                            color: theme.palette.primary.main,
                                        }}
                                    >
                                        13
                                    </Typography>
                                </Box>
                            </Card>
                        </Box>
                    </Box>
                </Container>
            </Box>

            {/* ==================== BENEFITS SECTION ==================== */}
            <Box
                id="benefits"
                sx={{
                    py: { xs: 6, md: 10 },
                    backgroundImage: `linear-gradient(rgba(245, 247, 249, 0.5), rgba(245, 247, 249, 0.5)), url('/images/benefitsBG.png')`,
                    backgroundSize: 'cover',
                    backgroundPosition: 'center',
                    backgroundRepeat: 'no-repeat',
                }}
            >
                <Container maxWidth="lg">
                    {/* Section Header */}
                    <Box sx={{ textAlign: 'center', mb: 8 }}>
                        <Typography
                            variant="overline"
                            sx={{
                                color: theme.palette.primary.main,
                                fontWeight: 700,
                                fontSize: '0.875rem',
                                letterSpacing: '0.1em',
                                mb: 2,
                                display: 'block',
                            }}
                        >
                            WHY CHOOSE SAPP
                        </Typography>
                        <Typography
                            variant="h3"
                            sx={{
                                fontWeight: 800,
                                color: theme.palette.text.primary,
                                mb: 2,
                            }}
                        >
                            Built for Student Success
                        </Typography>
                    </Box>

                    <Box
                        sx={{
                            display: 'grid',
                            gridTemplateColumns: {
                                xs: '1fr',
                                sm: 'repeat(2, minmax(0, 1fr))',
                                lg: 'repeat(4, minmax(0, 1fr))',
                            },
                            gap: 4,
                        }}
                    >
                        <Card
                            elevation={0}
                            sx={{
                                height: '100%',
                                p: 4,
                                textAlign: 'center',
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                backgroundColor: '#FFFFFF',
                                cursor: 'pointer',
                                transition: 'all 0.25s ease',
                                '& .benefit-icon': {
                                    transition: 'all 0.25s ease',
                                },
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 12px 26px rgba(37, 82, 115, 0.14)',
                                    transform: 'translateY(-4px)',
                                    '& .benefit-icon': {
                                        backgroundColor: `${theme.palette.primary.main}18`,
                                        transform: 'scale(1.06)',
                                    },
                                },
                            }}
                        >
                            <Box
                                className="benefit-icon"
                                sx={{
                                    width: 80,
                                    height: 80,
                                    borderRadius: '50%',
                                    backgroundColor: theme.palette.background.default,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mx: 'auto',
                                    mb: 3,
                                }}
                            >
                                <PsychologyIcon
                                    sx={{
                                        fontSize: 40,
                                        color: theme.palette.primary.main,
                                    }}
                                />
                            </Box>
                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 1.5,
                                }}
                            >
                                Develop Critical Thinking
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    lineHeight: 1.7,
                                }}
                            >
                                Sharpen your analytical and research skills through structured writing and peer review.
                            </Typography>
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                height: '100%',
                                p: 4,
                                textAlign: 'center',
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                backgroundColor: '#FFFFFF',
                                cursor: 'pointer',
                                transition: 'all 0.25s ease',
                                '& .benefit-icon': {
                                    transition: 'all 0.25s ease',
                                },
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 12px 26px rgba(37, 82, 115, 0.14)',
                                    transform: 'translateY(-4px)',
                                    '& .benefit-icon': {
                                        backgroundColor: `${theme.palette.primary.main}18`,
                                        transform: 'scale(1.06)',
                                    },
                                },
                            }}
                        >
                            <Box
                                className="benefit-icon"
                                sx={{
                                    width: 80,
                                    height: 80,
                                    borderRadius: '50%',
                                    backgroundColor: theme.palette.background.default,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mx: 'auto',
                                    mb: 3,
                                }}
                            >
                                <WorkIcon
                                    sx={{
                                        fontSize: 40,
                                        color: theme.palette.primary.main,
                                    }}
                                />
                            </Box>
                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 1.5,
                                }}
                            >
                                Build Your Portfolio
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    lineHeight: 1.7,
                                }}
                            >
                                Create a professional portfolio of published work to showcase to universities and employers.
                            </Typography>
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                height: '100%',
                                p: 4,
                                textAlign: 'center',
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                backgroundColor: '#FFFFFF',
                                cursor: 'pointer',
                                transition: 'all 0.25s ease',
                                '& .benefit-icon': {
                                    transition: 'all 0.25s ease',
                                },
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 12px 26px rgba(37, 82, 115, 0.14)',
                                    transform: 'translateY(-4px)',
                                    '& .benefit-icon': {
                                        backgroundColor: `${theme.palette.primary.main}18`,
                                        transform: 'scale(1.06)',
                                    },
                                },
                            }}
                        >
                            <Box
                                className="benefit-icon"
                                sx={{
                                    width: 80,
                                    height: 80,
                                    borderRadius: '50%',
                                    backgroundColor: theme.palette.background.default,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mx: 'auto',
                                    mb: 3,
                                }}
                            >
                                <EmojiObjectsIcon
                                    sx={{
                                        fontSize: 40,
                                        color: theme.palette.primary.main,
                                    }}
                                />
                            </Box>
                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 1.5,
                                }}
                            >
                                Express Your Ideas
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    lineHeight: 1.7,
                                }}
                            >
                                Share unique perspectives and contribute to meaningful academic discussions worldwide.
                            </Typography>
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                height: '100%',
                                p: 4,
                                textAlign: 'center',
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                backgroundColor: '#FFFFFF',
                                cursor: 'pointer',
                                transition: 'all 0.25s ease',
                                '& .benefit-icon': {
                                    transition: 'all 0.25s ease',
                                },
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 12px 26px rgba(37, 82, 115, 0.14)',
                                    transform: 'translateY(-4px)',
                                    '& .benefit-icon': {
                                        backgroundColor: `${theme.palette.primary.main}18`,
                                        transform: 'scale(1.06)',
                                    },
                                },
                            }}
                        >
                            <Box
                                className="benefit-icon"
                                sx={{
                                    width: 80,
                                    height: 80,
                                    borderRadius: '50%',
                                    backgroundColor: theme.palette.background.default,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mx: 'auto',
                                    mb: 3,
                                }}
                            >
                                <GroupsIcon
                                    sx={{
                                        fontSize: 40,
                                        color: theme.palette.primary.main,
                                    }}
                                />
                            </Box>
                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 1.5,
                                }}
                            >
                                Join a Community
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    lineHeight: 1.7,
                                }}
                            >
                                Connect with fellow student writers and scholars from around the globe.
                            </Typography>
                        </Card>
                    </Box>
                </Container>
            </Box>

            {/* ==================== TESTIMONIAL SECTION ==================== */}
            <Box
                id="testimonials"
                sx={{
                    py: { xs: 6, md: 10 },
                    backgroundColor: '#FFFFFF',
                }}
            >
                <Container maxWidth="lg">
                    {/* Section Header */}
                    <Box sx={{ textAlign: 'center', mb: 8 }}>
                        <Typography
                            variant="overline"
                            sx={{
                                color: theme.palette.primary.main,
                                fontWeight: 700,
                                fontSize: '0.875rem',
                                letterSpacing: '0.1em',
                                mb: 2,
                                display: 'block',
                            }}
                        >
                            TESTIMONIALS
                        </Typography>
                        <Typography
                            variant="h3"
                            sx={{
                                fontWeight: 800,
                                color: theme.palette.text.primary,
                                mb: 2,
                            }}
                        >
                            What Students Say
                        </Typography>
                        <Typography
                            variant="body1"
                            sx={{
                                color: theme.palette.text.secondary,
                                maxWidth: '600px',
                                mx: 'auto',
                            }}
                        >
                            Hear from students who have elevated their academic writing journey with SAPP
                        </Typography>
                    </Box>

                    {/* Testimonials Grid */}
                    <Box
                        sx={{
                            display: 'grid',
                            gridTemplateColumns: {
                                xs: '1fr',
                                md: 'repeat(2, minmax(0, 1fr))',
                            },
                            gap: 4,
                        }}
                    >
                        <Card
                            elevation={0}
                            sx={{
                                p: { xs: 4, md: 5 },
                                textAlign: 'center',
                                backgroundColor: theme.palette.background.default,
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                transition: 'all 0.3s ease',
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 8px 24px rgba(37, 82, 115, 0.12)',
                                    transform: 'translateY(-4px)',
                                },
                            }}
                        >
                            <Avatar
                                sx={{
                                    width: 80,
                                    height: 80,
                                    mx: 'auto',
                                    mb: 3,
                                    fontSize: '2rem',
                                    backgroundColor: theme.palette.primary.main,
                                }}
                            >
                                JW
                            </Avatar>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 600,
                                    color: theme.palette.text.primary,
                                    mb: 3,
                                    fontStyle: 'italic',
                                    lineHeight: 1.6,
                                }}
                            >
                                "SAPP transformed how I approach academic writing. The platform made it easy to 
                                collaborate with peers and get my research published. It's been invaluable for my portfolio!"
                            </Typography>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                }}
                            >
                                John Writer
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                }}
                            >
                                Computer Science Student, Harvard University
                            </Typography>
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                p: { xs: 4, md: 5 },
                                textAlign: 'center',
                                backgroundColor: theme.palette.background.default,
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                transition: 'all 0.3s ease',
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 8px 24px rgba(37, 82, 115, 0.12)',
                                    transform: 'translateY(-4px)',
                                },
                            }}
                        >
                            <Avatar
                                sx={{
                                    width: 80,
                                    height: 80,
                                    mx: 'auto',
                                    mb: 3,
                                    fontSize: '2rem',
                                    backgroundColor: theme.palette.secondary.main,
                                }}
                            >
                                SM
                            </Avatar>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 600,
                                    color: theme.palette.text.primary,
                                    mb: 3,
                                    fontStyle: 'italic',
                                    lineHeight: 1.6,
                                }}
                            >
                                "Publishing my first article on SAPP gave me the confidence to pursue more research opportunities. 
                                The peer review process helped me refine my writing skills tremendously!"
                            </Typography>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                }}
                            >
                                Sarah Martinez
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                }}
                            >
                                Biology Major, Stanford University
                            </Typography>
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                p: { xs: 4, md: 5 },
                                textAlign: 'center',
                                backgroundColor: theme.palette.background.default,
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                transition: 'all 0.3s ease',
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 8px 24px rgba(37, 82, 115, 0.12)',
                                    transform: 'translateY(-4px)',
                                },
                            }}
                        >
                            <Avatar
                                sx={{
                                    width: 80,
                                    height: 80,
                                    mx: 'auto',
                                    mb: 3,
                                    fontSize: '2rem',
                                    backgroundColor: '#e91e63',
                                }}
                            >
                                AP
                            </Avatar>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 600,
                                    color: theme.palette.text.primary,
                                    mb: 3,
                                    fontStyle: 'italic',
                                    lineHeight: 1.6,
                                }}
                            >
                                "The collaborative features are outstanding! I connected with students from different universities 
                                and we co-authored several papers. SAPP is more than a platform; it's a community."
                            </Typography>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                }}
                            >
                                Alex Patel
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                }}
                            >
                                Economics Student, MIT
                            </Typography>
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                p: { xs: 4, md: 5 },
                                textAlign: 'center',
                                backgroundColor: theme.palette.background.default,
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: 3,
                                transition: 'all 0.3s ease',
                                '&:hover': {
                                    borderColor: theme.palette.primary.main,
                                    boxShadow: '0 8px 24px rgba(37, 82, 115, 0.12)',
                                    transform: 'translateY(-4px)',
                                },
                            }}
                        >
                            <Avatar
                                sx={{
                                    width: 80,
                                    height: 80,
                                    mx: 'auto',
                                    mb: 3,
                                    fontSize: '2rem',
                                    backgroundColor: '#ff9800',
                                }}
                            >
                                EL
                            </Avatar>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 600,
                                    color: theme.palette.text.primary,
                                    mb: 3,
                                    fontStyle: 'italic',
                                    lineHeight: 1.6,
                                }}
                            >
                                "As an international student, SAPP helped me improve my academic English writing. 
                                The feedback from editors and peers has been invaluable for my growth."
                            </Typography>

                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                }}
                            >
                                Emily Liu
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                }}
                            >
                                English Literature, Oxford University
                            </Typography>
                        </Card>
                    </Box>
                </Container>
            </Box>

            {/* ==================== FINAL CTA SECTION ==================== */}
            <Box
                sx={{
                    py: { xs: 8, md: 12 },
                    backgroundColor: theme.palette.text.primary,
                    position: 'relative',
                    overflow: 'hidden',
                }}
            >
                <Container maxWidth="md">
                    <Box sx={{ textAlign: 'center', position: 'relative', zIndex: 1 }}>
                        <Typography
                            variant="h2"
                            sx={{
                                fontWeight: 800,
                                color: '#FFFFFF',
                                mb: 3,
                                fontSize: { xs: '2rem', md: '3rem' },
                            }}
                        >
                            Ready to Share Your Voice?
                        </Typography>

                        <Typography
                            variant="h6"
                            sx={{
                                color: 'rgba(255,255,255,0.8)',
                                mb: 5,
                                lineHeight: 1.7,
                            }}
                        >
                            Join thousands of students already publishing their work on SAPP. 
                            Start writing today—it's completely free!
                        </Typography>

                        <Button
                            variant="contained"
                            size="large"
                            component={InertiaLink}
                            href="/register"
                            sx={{
                                backgroundColor: theme.palette.primary.main,
                                '&:hover': {
                                    backgroundColor: theme.palette.primary.dark,
                                },
                                px: 6,
                                py: 2,
                                fontSize: '1.125rem',
                                fontWeight: 700,
                            }}
                            startIcon={<CreateIcon />}
                        >
                            Join the SAPP Community Today
                        </Button>
                    </Box>

                    {/* Background Decoration */}
                    <Box
                        sx={{
                            position: 'absolute',
                            bottom: '-20%',
                            left: '-10%',
                            width: 400,
                            height: 400,
                            borderRadius: '50%',
                            background: `radial-gradient(circle, ${theme.palette.primary.main}30 0%, transparent 70%)`,
                            pointerEvents: 'none',
                        }}
                    />
                    <Box
                        sx={{
                            position: 'absolute',
                            top: '-20%',
                            right: '-10%',
                            width: 300,
                            height: 300,
                            borderRadius: '50%',
                            background: `radial-gradient(circle, ${theme.palette.primary.main}20 0%, transparent 70%)`,
                            pointerEvents: 'none',
                        }}
                    />
                </Container>
            </Box>

            {/* ==================== FOOTER ==================== */}
            <Box
                sx={{
                    py: 6,
                    backgroundColor: '#FAFBFC',
                    borderTop: `1px solid ${theme.palette.divider}`,
                }}
            >
                <Container maxWidth="lg">
                    <Grid container spacing={4} sx={{ mb: 4 }}>
                        {/* Logo Column */}
                        <Grid item xs={12} md={4}>
                            <Box
                                component="a"
                                href="/"
                                sx={{
                                    display: 'block',
                                    textDecoration: 'none',
                                }}
                            >
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                    <Box
                                        sx={{
                                            width: 40,
                                            height: 40,
                                            borderRadius: '10px',
                                            background: 'linear-gradient(135deg, #1B2A4A 0%, #2A7B9B 100%)',
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                        }}
                                    >
                                        <ArticleIcon sx={{ color: '#fff', fontSize: 20 }} />
                                    </Box>
                                    <Typography
                                        variant="h5"
                                        sx={{
                                            fontWeight: 800,
                                            color: theme.palette.primary.main,
                                        }}
                                    >
                                        UniVox
                                    </Typography>
                                </Box>
                                <Typography
                                    variant="body2"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        lineHeight: 1.7,
                                    }}
                                >
                                    Empowering students to share their voice and publish their stories with the world.
                                </Typography>
                            </Box>
                        </Grid>

                        {/* Quick Links */}
                        <Grid item xs={12} sm={6} md={4}>
                            <Typography
                                variant="subtitle2"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 2,
                                }}
                            >
                                Quick Links
                            </Typography>
                            <Stack spacing={1.5}>
                                <Link
                                    href="#features"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        textDecoration: 'none',
                                        fontSize: '0.875rem',
                                        '&:hover': { color: theme.palette.primary.main },
                                    }}
                                >
                                    Features
                                </Link>
                                <Link
                                    href="#benefits"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        textDecoration: 'none',
                                        fontSize: '0.875rem',
                                        '&:hover': { color: theme.palette.primary.main },
                                    }}
                                >
                                    Benefits
                                </Link>
                                <Link
                                    href="#"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        textDecoration: 'none',
                                        fontSize: '0.875rem',
                                        '&:hover': { color: theme.palette.primary.main },
                                    }}
                                >
                                    About Us
                                </Link>
                            </Stack>
                        </Grid>

                        {/* Social Links */}
                        <Grid item xs={12} sm={6} md={4}>
                            <Typography
                                variant="subtitle2"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 2,
                                }}
                            >
                                Follow Us
                            </Typography>
                            <Box sx={{ display: 'flex', gap: 1.5 }}>
                                <IconButton
                                    size="small"
                                    sx={{
                                        backgroundColor: theme.palette.divider,
                                        '&:hover': {
                                            backgroundColor: theme.palette.primary.main,
                                            '& svg': { color: '#FFFFFF' },
                                        },
                                    }}
                                >
                                    <LinkedInIcon sx={{ fontSize: 20 }} />
                                </IconButton>
                                <IconButton
                                    size="small"
                                    sx={{
                                        backgroundColor: theme.palette.divider,
                                        '&:hover': {
                                            backgroundColor: theme.palette.primary.main,
                                            '& svg': { color: '#FFFFFF' },
                                        },
                                    }}
                                >
                                    <TwitterIcon sx={{ fontSize: 20 }} />
                                </IconButton>
                                <IconButton
                                    size="small"
                                    sx={{
                                        backgroundColor: theme.palette.divider,
                                        '&:hover': {
                                            backgroundColor: theme.palette.primary.main,
                                            '& svg': { color: '#FFFFFF' },
                                        },
                                    }}
                                >
                                    <FacebookIcon sx={{ fontSize: 20 }} />
                                </IconButton>
                            </Box>
                        </Grid>
                    </Grid>

                    <Divider sx={{ my: 3 }} />

                    {/* Bottom Footer */}
                    <Box
                        sx={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            flexWrap: 'wrap',
                            gap: 2,
                        }}
                    >
                        <Typography variant="caption" sx={{ color: theme.palette.text.secondary }}>
                            © 2026 SAPP. All rights reserved.
                        </Typography>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <Typography variant="caption" sx={{ color: theme.palette.text.secondary }}>
                                Powered by
                            </Typography>
                            <Typography
                                variant="caption"
                                sx={{ color: theme.palette.text.primary, fontWeight: 600 }}
                            >
                                Laravel
                            </Typography>
                        </Box>
                    </Box>
                </Container>
            </Box>
        </>
    );
};

export default LandingPage;
