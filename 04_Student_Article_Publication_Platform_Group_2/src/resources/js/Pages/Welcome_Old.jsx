import {
    Box,
    Container,
    AppBar,
    Toolbar,
    TextField,
    InputAdornment,
    Avatar,
    Badge,
    Button,
    Typography,
    Card,
    CardContent,
    Grid,
    Paper,
    Link,
    Divider,
    Stack,
    IconButton,
} from '@mui/material';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';
import SearchIcon from '@mui/icons-material/Search';
import NotificationsIcon from '@mui/icons-material/Notifications';
import CreateIcon from '@mui/icons-material/Create';
import ReviewsIcon from '@mui/icons-material/Reviews';
import EmojiEventsIcon from '@mui/icons-material/EmojiEvents';
import PsychologyIcon from '@mui/icons-material/Psychology';
import WorkIcon from '@mui/icons-material/Work';
import EmojiObjectsIcon from '@mui/icons-material/EmojiObjects';
import GroupsIcon from '@mui/icons-material/Groups';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import LinkedInIcon from '@mui/icons-material/LinkedIn';
import TwitterIcon from '@mui/icons-material/Twitter';
import FacebookIcon from '@mui/icons-material/Facebook';
import { Head, Link as InertiaLink } from '@inertiajs/react';

const LandingPage = () => {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const isTablet = useMediaQuery(theme.breakpoints.down('lg'));

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
                        {/* Logo */}
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <Typography
                                variant="h5"
                                sx={{
                                    fontWeight: 800,
                                    color: theme.palette.primary.main,
                                    letterSpacing: '-0.02em',
                                }}
                            >
                                SAPP
                            </Typography>
                        </Box>

                        {/* Navigation Links - Hidden on mobile */}
                        {!isMobile && (
                            <Box sx={{ display: 'flex', gap: 3 }}>
                                <Link
                                    href="#features"
                                    sx={{
                                        color: theme.palette.text.primary,
                                        textDecoration: 'none',
                                        fontSize: '0.95rem',
                                        fontWeight: 500,
                                        '&:hover': {
                                            color: theme.palette.brand.main,
                                        },
                                    }}
                                >
                                    Features
                                </Link>
                                <Link
                                    href="#benefits"
                                    sx={{
                                        color: theme.palette.text.primary,
                                        textDecoration: 'none',
                                        fontSize: '0.95rem',
                                        fontWeight: 500,
                                        '&:hover': {
                                            color: theme.palette.brand.main,
                                        },
                                    }}
                                >
                                    Benefits
                                </Link>
                                <Link
                                    href="#testimonials"
                                    sx={{
                                        color: theme.palette.text.primary,
                                        textDecoration: 'none',
                                        fontSize: '0.95rem',
                                        fontWeight: 500,
                                        '&:hover': {
                                            color: theme.palette.brand.main,
                                        },
                                    }}
                                >
                                    Testimonials
                                </Link>
                            </Box>
                        )}

                        {/* CTA Buttons */}
                        <Box sx={{ display: 'flex', gap: 2 }}>
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
                                    backgroundColor: theme.palette.brand.main,
                                    '&:hover': {
                                        backgroundColor: theme.palette.brand.dark,
                                    },
                                    fontWeight: 600,
                                }}
                            >
                                Sign Up
                            </Button>
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
                                        color: theme.palette.brand.main,
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
                                            color: theme.palette.brand.main,
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

                                <Stack
                                    direction={{ xs: 'column', sm: 'row' }}
                                    spacing={2}
                                    sx={{ mb: 4 }}
                                >
                                    <Button
                                        variant="contained"
                                        size="large"
                                        component={InertiaLink}
                                        href="/register"
                                        sx={{
                                            backgroundColor: theme.palette.brand.main,
                                            '&:hover': {
                                                backgroundColor: theme.palette.brand.dark,
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
                                        size="large"
                                        sx={{
                                            color: theme.palette.text.primary,
                                            '&:hover': {
                                                backgroundColor: 'transparent',
                                            },
                                        }}
                                    >
                                        Log In
                                    </Button>
                                </Stack>
                            </Box>
                        </Grid>
                    </Grid>
                </Container>
            </Box>

            {/* Write. Collaborate. Publish. Section */}
            <Box sx={{ py: { xs: 6, md: 10 } }}>
                <Container maxWidth="lg">
                    <Typography
                        variant="h4"
                        sx={{
                            fontWeight: 700,
                            textAlign: 'center',
                            color: theme.palette.text.primary,
                            mb: 6,
                        }}
                    >
                        Write. Collaborate. Publish.
                    </Typography>

                    <Grid container spacing={4}>
                        {/* Card 1: Focus & Write */}
                        <Grid item xs={12} md={4}>
                            <Card
                                elevation={2}
                                sx={{
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    borderRadius: 2,
                                }}
                            >
                                <CardContent sx={{ flexGrow: 1 }}>
                                    <Box
                                        sx={{
                                            display: 'flex',
                                            justifyContent: 'center',
                                            mb: 2,
                                        }}
                                    >
                                        <CreateIcon
                                            sx={{
                                                fontSize: 48,
                                                color: theme.palette.text.primary,
                                            }}
                                        />
                                    </Box>
                                    <Typography
                                        variant="h6"
                                        sx={{
                                            fontWeight: 700,
                                            textAlign: 'center',
                                            color: theme.palette.text.primary,
                                            mb: 2,
                                        }}
                                    >
                                        Focus & Write
                                    </Typography>
                                    <Typography
                                        variant="body2"
                                        sx={{
                                            textAlign: 'center',
                                            color: theme.palette.text.secondary,
                                            mb: 3,
                                            lineHeight: 1.6,
                                        }}
                                    >
                                        Streamlined drafting and writing interface. Set and track
                                        word goals with our built-in progress tracker.
                                    </Typography>

                                    {/* Word Goal Teaser */}
                                    <Box
                                        sx={{
                                            mb: 3,
                                            p: 2,
                                            backgroundColor: theme.palette.background.default,
                                            borderRadius: 1.5,
                                        }}
                                    >
                                        <Box
                                            sx={{
                                                display: 'flex',
                                                justifyContent: 'space-between',
                                                mb: 1,
                                            }}
                                        >
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    fontWeight: 600,
                                                    color: theme.palette.text.secondary,
                                                }}
                                            >
                                                Word Goal
                                            </Typography>
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    fontWeight: 600,
                                                    color: theme.palette.text.primary,
                                                }}
                                            >
                                                2,500 / 3,000
                                            </Typography>
                                        </Box>
                                        <Box
                                            sx={{
                                                width: '100%',
                                                height: 6,
                                                backgroundColor: theme.palette.divider,
                                                borderRadius: 3,
                                                overflow: 'hidden',
                                            }}
                                        >
                                            <Box
                                                sx={{
                                                    width: '83%',
                                                    height: '100%',
                                                    backgroundColor: theme.palette.info.main,
                                                    borderRadius: 3,
                                                }}
                                            />
                                        </Box>
                                    </Box>
                                </CardContent>
                                <Box sx={{ p: 2, pt: 0 }}>
                                    <Button
                                        variant="text"
                                        fullWidth
                                        sx={{
                                            color: theme.palette.text.primary,
                                        }}
                                    >
                                        Start a Draft
                                    </Button>
                                </Box>
                            </Card>
                        </Grid>

                        {/* Card 2: Refine & Review */}
                        <Grid item xs={12} md={4}>
                            <Card
                                elevation={2}
                                sx={{
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    borderRadius: 2,
                                }}
                            >
                                <CardContent sx={{ flexGrow: 1 }}>
                                    <Box
                                        sx={{
                                            display: 'flex',
                                            justifyContent: 'center',
                                            mb: 2,
                                        }}
                                    >
                                        <ReviewsIcon
                                            sx={{
                                                fontSize: 48,
                                                color: theme.palette.text.primary,
                                            }}
                                        />
                                    </Box>
                                    <Typography
                                        variant="h6"
                                        sx={{
                                            fontWeight: 700,
                                            textAlign: 'center',
                                            color: theme.palette.text.primary,
                                            mb: 2,
                                        }}
                                    >
                                        Refine & Review
                                    </Typography>
                                    <Typography
                                        variant="body2"
                                        sx={{
                                            textAlign: 'center',
                                            color: theme.palette.text.secondary,
                                            mb: 3,
                                            lineHeight: 1.6,
                                        }}
                                    >
                                        Collaborative feedback loop. Submit drafts with reviewer
                                        notes and manage revision requests.
                                    </Typography>

                                    {/* Reviewer Status Teaser */}
                                    <Box
                                        sx={{
                                            mb: 3,
                                            p: 2,
                                            backgroundColor: theme.palette.background.default,
                                            borderRadius: 1.5,
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
                                                    backgroundColor: '#FFA500',
                                                }}
                                            />
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    color: theme.palette.text.secondary,
                                                }}
                                            >
                                                Awaiting Reviewer Feedback
                                            </Typography>
                                        </Box>
                                    </Box>
                                </CardContent>
                                <Box sx={{ p: 2, pt: 0 }}>
                                    <Button
                                        variant="text"
                                        fullWidth
                                        sx={{
                                            color: theme.palette.text.primary,
                                        }}
                                    >
                                        Get Feedback
                                    </Button>
                                </Box>
                            </Card>
                        </Grid>

                        {/* Card 3: Share with the World */}
                        <Grid item xs={12} md={4}>
                            <Card
                                elevation={2}
                                sx={{
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    borderRadius: 2,
                                }}
                            >
                                <CardContent sx={{ flexGrow: 1 }}>
                                    <Box
                                        sx={{
                                            display: 'flex',
                                            justifyContent: 'center',
                                            mb: 2,
                                        }}
                                    >
                                        <EmojiEventsIcon
                                            sx={{
                                                fontSize: 48,
                                                color: theme.palette.text.primary,
                                            }}
                                        />
                                    </Box>
                                    <Typography
                                        variant="h6"
                                        sx={{
                                            fontWeight: 700,
                                            textAlign: 'center',
                                            color: theme.palette.text.primary,
                                            mb: 2,
                                        }}
                                    >
                                        Share with the World
                                    </Typography>
                                    <Typography
                                        variant="body2"
                                        sx={{
                                            textAlign: 'center',
                                            color: theme.palette.text.secondary,
                                            mb: 3,
                                            lineHeight: 1.6,
                                        }}
                                    >
                                        Track your progress from submission to publication. Manage
                                        drafts, submitted, and published articles.
                                    </Typography>

                                    {/* Status Counter Teaser */}
                                    <Box
                                        sx={{
                                            mb: 3,
                                            display: 'grid',
                                            gridTemplateColumns: '1fr 1fr',
                                            gap: 1,
                                        }}
                                    >
                                        <Box
                                            sx={{
                                                p: 1.5,
                                                backgroundColor: theme.palette.background.default,
                                                borderRadius: 1.5,
                                                textAlign: 'center',
                                            }}
                                        >
                                            <Typography
                                                variant="h6"
                                                sx={{
                                                    fontWeight: 700,
                                                    color: theme.palette.text.primary,
                                                }}
                                            >
                                                4
                                            </Typography>
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    color: theme.palette.text.secondary,
                                                }}
                                            >
                                                Drafts
                                            </Typography>
                                        </Box>
                                        <Box
                                            sx={{
                                                p: 1.5,
                                                backgroundColor: theme.palette.background.default,
                                                borderRadius: 1.5,
                                                textAlign: 'center',
                                            }}
                                        >
                                            <Typography
                                                variant="h6"
                                                sx={{
                                                    fontWeight: 700,
                                                    color: theme.palette.text.primary,
                                                }}
                                            >
                                                4
                                            </Typography>
                                            <Typography
                                                variant="caption"
                                                sx={{
                                                    color: theme.palette.text.secondary,
                                                }}
                                            >
                                                Published
                                            </Typography>
                                        </Box>
                                    </Box>
                                </CardContent>
                                <Box sx={{ p: 2, pt: 0 }}>
                                    <Button
                                        variant="text"
                                        fullWidth
                                        sx={{
                                            color: theme.palette.text.primary,
                                        }}
                                    >
                                        See the SAPP Impact
                                    </Button>
                                </Box>
                            </Card>
                        </Grid>
                    </Grid>
                </Container>
            </Box>

            {/* Why Publish with SAPP Section */}
            <Box
                sx={{
                    backgroundColor: theme.palette.background.default,
                    py: { xs: 6, md: 10 },
                }}
            >
                <Container maxWidth="lg">
                    <Typography
                        variant="h4"
                        sx={{
                            fontWeight: 700,
                            textAlign: 'center',
                            color: theme.palette.text.primary,
                            mb: 6,
                        }}
                    >
                        Why Publish with SAPP?
                    </Typography>

                    <Grid container spacing={4}>
                        {/* Icon 1: Psychology */}
                        <Grid item xs={12} sm={6} md={6}>
                            <Box
                                sx={{
                                    display: 'flex',
                                    gap: 3,
                                }}
                            >
                                <Box
                                    sx={{
                                        display: 'flex',
                                        alignItems: 'flex-start',
                                        justifyContent: 'center',
                                        width: 60,
                                        height: 60,
                                        minWidth: 60,
                                    }}
                                >
                                    <PsychologyIcon
                                        sx={{
                                            fontSize: 40,
                                            color: theme.palette.text.primary,
                                        }}
                                    />
                                </Box>
                                <Box>
                                    <Typography
                                        variant="h6"
                                        sx={{
                                            fontWeight: 700,
                                            color: theme.palette.text.primary,
                                            mb: 1,
                                        }}
                                    >
                                        Reach a Student Audience
                                    </Typography>
                                    <Typography
                                        variant="body2"
                                        sx={{
                                            color: theme.palette.text.secondary,
                                            lineHeight: 1.6,
                                        }}
                                    >
                                        Amplified visibility for your articles among a vibrant
                                        community of student writers and readers.
                                    </Typography>
                                </Box>
                            </Box>
                        </Grid>

                        {/* Icon 2: Briefcase */}
                        <Grid item xs={12} sm={6} md={6}>
                            <Box
                                sx={{
                                    display: 'flex',
                                    gap: 3,
                                }}
                            >
                                <Box
                                    sx={{
                                        display: 'flex',
                                        alignItems: 'flex-start',
                                        justifyContent: 'center',
                                        width: 60,
                                        height: 60,
                                        minWidth: 60,
                                    }}
                                >
                                    <WorkIcon
                                        sx={{
                                            fontSize: 40,
                                            color: theme.palette.text.primary,
                                        }}
                                    />
                                </Box>
                                <Box>
                                    <Typography
                                        variant="h6"
                                        sx={{
                                            fontWeight: 700,
                                            color: theme.palette.text.primary,
                                            mb: 1,
                                        }}
                                    >
                                        Boost Your Portfolio
                                    </Typography>
                                    <Typography
                                        variant="body2"
                                        sx={{
                                            color: theme.palette.text.secondary,
                                            lineHeight: 1.6,
                                        }}
                                    >
                                        Build a public profile of your published work to showcase
                                        to future employers and academic institutions.
                                    </Typography>
                                </Box>
                            </Box>
                        </Grid>

                        {/* Icon 3: Lightbulb */}
                        <Grid item xs={12} sm={6} md={6}>
                            <Box
                                sx={{
                                    display: 'flex',
                                    gap: 3,
                                }}
                            >
                                <Box
                                    sx={{
                                        display: 'flex',
                                        alignItems: 'flex-start',
                                        justifyContent: 'center',
                                        width: 60,
                                        height: 60,
                                        minWidth: 60,
                                    }}
                                >
                                    <EmojiObjectsIcon
                                        sx={{
                                            fontSize: 40,
                                            color: theme.palette.text.primary,
                                        }}
                                    />
                                </Box>
                                <Box>
                                    <Typography
                                        variant="h6"
                                        sx={{
                                            fontWeight: 700,
                                            color: theme.palette.text.primary,
                                            mb: 1,
                                        }}
                                    >
                                        Expert Feedback
                                    </Typography>
                                    <Typography
                                        variant="body2"
                                        sx={{
                                            color: theme.palette.text.secondary,
                                            lineHeight: 1.6,
                                        }}
                                    >
                                        Improve your writing with constructive guidance from
                                        experienced reviewers in the community.
                                    </Typography>
                                </Box>
                            </Box>
                        </Grid>

                        {/* Icon 4: Group */}
                        <Grid item xs={12} sm={6} md={6}>
                            <Box
                                sx={{
                                    display: 'flex',
                                    gap: 3,
                                }}
                            >
                                <Box
                                    sx={{
                                        display: 'flex',
                                        alignItems: 'flex-start',
                                        justifyContent: 'center',
                                        width: 60,
                                        height: 60,
                                        minWidth: 60,
                                    }}
                                >
                                    <GroupsIcon
                                        sx={{
                                            fontSize: 40,
                                            color: theme.palette.text.primary,
                                        }}
                                    />
                                </Box>
                                <Box>
                                    <Typography
                                        variant="h6"
                                        sx={{
                                            fontWeight: 700,
                                            color: theme.palette.text.primary,
                                            mb: 1,
                                        }}
                                    >
                                        Student Writer Community
                                    </Typography>
                                    <Typography
                                        variant="body2"
                                        sx={{
                                            color: theme.palette.text.secondary,
                                            lineHeight: 1.6,
                                        }}
                                    >
                                        Connect and learn from peers, share knowledge, and build
                                        lasting professional relationships.
                                    </Typography>
                                </Box>
                            </Box>
                        </Grid>
                    </Grid>
                </Container>
            </Box>

            {/* Testimonial Section */}
            <Box sx={{ py: { xs: 6, md: 10 } }}>
                <Container maxWidth="sm">
                    <Card
                        elevation={2}
                        sx={{
                            borderRadius: 2,
                            position: 'relative',
                        }}
                    >
                        <CardContent sx={{ textAlign: 'center', pt: 4, pb: 4 }}>
                            <Box sx={{ mb: 2 }}>
                                <Avatar
                                    sx={{
                                        width: 64,
                                        height: 64,
                                        backgroundColor: theme.palette.text.primary,
                                        fontSize: '1.5rem',
                                        fontWeight: 700,
                                        mx: 'auto',
                                    }}
                                >
                                    JW
                                </Avatar>
                            </Box>
                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 0.5,
                                }}
                            >
                                John Writer
                            </Typography>
                            <Typography
                                variant="caption"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    display: 'block',
                                    mb: 2,
                                }}
                            >
                                Senior, Journalism
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    fontStyle: 'italic',
                                    lineHeight: 1.8,
                                }}
                            >
                                "SAPP gave me the platform and feedback to finally get my
                                research published. A game-changer for student writers! The
                                collaborative review process is invaluable."
                            </Typography>
                        </CardContent>
                    </Card>
                </Container>
            </Box>

            {/* Final CTA Section */}
            <Box
                sx={{
                    backgroundColor: theme.palette.text.primary,
                    py: { xs: 6, md: 10 },
                }}
            >
                <Container maxWidth="sm">
                    <Box sx={{ textAlign: 'center' }}>
                        <Typography
                            variant="h3"
                            sx={{
                                fontWeight: 700,
                                color: '#FFFFFF',
                                mb: 4,
                                lineHeight: 1.2,
                            }}
                        >
                            Ready to make an impact?
                        </Typography>

                        <Button
                            variant="contained"
                            size="large"
                            sx={{
                                backgroundColor: theme.palette.brand.main,
                                '&:hover': {
                                    backgroundColor: theme.palette.brand.dark,
                                },
                                px: 5,
                                py: 2,
                                mb: 3,
                            }}
                            endIcon={<TrendingUpIcon />}
                        >
                            Join the SAPP Community Today
                        </Button>

                        <Box>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: 'rgba(255,255,255,0.7)',
                                }}
                            >
                                Already a member?{' '}
                                <Link
                                    href="#"
                                    sx={{
                                        color: '#FFFFFF',
                                        fontWeight: 600,
                                        textDecoration: 'none',
                                        '&:hover': {
                                            textDecoration: 'underline',
                                        },
                                    }}
                                >
                                    Log In
                                </Link>
                            </Typography>
                        </Box>
                    </Box>
                </Container>
            </Box>

            {/* Footer */}
            <Box
                sx={{
                    backgroundColor: '#FAFBFC',
                    borderTop: `1px solid ${theme.palette.divider}`,
                    py: { xs: 4, md: 6 },
                }}
            >
                <Container maxWidth="lg">
                    <Grid container spacing={4} sx={{ mb: 4 }}>
                        {/* Left - Logo & Description */}
                        <Grid item xs={12} md={4}>
                            <Typography
                                variant="h6"
                                sx={{
                                    fontWeight: 700,
                                    color: theme.palette.text.primary,
                                    mb: 2,
                                }}
                            >
                                SAPP
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    lineHeight: 1.6,
                                }}
                            >
                                The premier platform for student writers to publish, collaborate,
                                and share their voice.
                            </Typography>
                        </Grid>

                        {/* Center - Links */}
                        <Grid item xs={12} md={4}>
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
                            <Stack spacing={1}>
                                <Link
                                    href="#"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        textDecoration: 'none',
                                        fontSize: '0.875rem',
                                        '&:hover': {
                                            color: theme.palette.brand.main,
                                        },
                                    }}
                                >
                                    About SAPP
                                </Link>
                                <Link
                                    href="#"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        textDecoration: 'none',
                                        fontSize: '0.875rem',
                                        '&:hover': {
                                            color: theme.palette.brand.main,
                                        },
                                    }}
                                >
                                    How it Works
                                </Link>
                                <Link
                                    href="#"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                        textDecoration: 'none',
                                        fontSize: '0.875rem',
                                        '&:hover': {
                                            color: theme.palette.brand.main,
                                        },
                                    }}
                                >
                                    FAQ
                                </Link>
                            </Stack>
                        </Grid>

                        {/* Right - Social */}
                        <Grid item xs={12} md={4}>
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
                            <Box sx={{ display: 'flex', gap: 1 }}>
                                <IconButton size="small">
                                    <LinkedInIcon
                                        sx={{
                                            fontSize: 20,
                                            color: theme.palette.text.secondary,
                                        }}
                                    />
                                </IconButton>
                                <IconButton size="small">
                                    <TwitterIcon
                                        sx={{
                                            fontSize: 20,
                                            color: theme.palette.text.secondary,
                                        }}
                                    />
                                </IconButton>
                                <IconButton size="small">
                                    <FacebookIcon
                                        sx={{
                                            fontSize: 20,
                                            color: theme.palette.text.secondary,
                                        }}
                                    />
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
                        <Typography
                            variant="caption"
                            sx={{
                                color: theme.palette.text.secondary,
                            }}
                        >
                            © 2026 SAPP. All rights reserved.
                        </Typography>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <Typography
                                variant="caption"
                                sx={{
                                    color: theme.palette.text.secondary,
                                }}
                            >
                                Powered by
                            </Typography>
                            <Typography
                                variant="caption"
                                sx={{
                                    color: theme.palette.text.primary,
                                    fontWeight: 600,
                                }}
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
