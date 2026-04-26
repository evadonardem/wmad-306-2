import { Head, Link } from '@inertiajs/react';
import { usePage } from '@inertiajs/react';
import {
    Box,
    Button,
    Container,
    Grid,
    Card,
    CardContent,
    Typography,
    AppBar,
    Toolbar,
} from '@mui/material';
import {
    Feather,
    CheckCircle2,
    BookOpen,
    Zap,
    Star,
    Sparkles,
    ArrowRight
} from 'lucide-react';

export default function Welcome() {
    const { auth } = usePage().props;

    return (
        <Box sx={{
            minHeight: '100vh',
            background: 'linear-gradient(135deg, #0F172A 0%, #1E293B 50%, #0F172A 100%)',
            position: 'relative',
            overflow: 'hidden',
            backgroundAttachment: 'fixed',
        }}>
            <Head title="Welcome" />

            <Box sx={{
                position: 'fixed',
                top: '-200px',
                right: '-200px',
                width: '600px',
                height: '600px',
                background: 'radial-gradient(circle, rgba(59, 130, 246, 0.1), transparent)',
                borderRadius: '50%',
                animation: 'float 15s ease-in-out infinite',
                pointerEvents: 'none',
                zIndex: 0,
            }} />
            <Box sx={{
                position: 'fixed',
                bottom: '-300px',
                left: '-200px',
                width: '700px',
                height: '700px',
                background: 'radial-gradient(circle, rgba(5, 150, 105, 0.08), transparent)',
                borderRadius: '50%',
                animation: 'float 20s ease-in-out infinite reverse',
                pointerEvents: 'none',
                zIndex: 0,
            }} />

            <AppBar position="sticky" sx={{
                background: 'rgba(15, 23, 42, 0.7)',
                backdropFilter: 'blur(20px)',
                border: '1px solid rgba(148, 163, 184, 0.1)',
                boxShadow: 'none',
                zIndex: 100,
            }}>
                <Toolbar sx={{ display: 'flex', justifyContent: 'space-between' }}>
                    <Box sx={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 2,
                        fontWeight: 900,
                        fontSize: '1.25rem',
                        background: 'linear-gradient(90deg, #3B82F6, #0EA5E9)',
                        WebkitBackgroundClip: 'text',
                        WebkitTextFillColor: 'transparent',
                        animation: 'electricPulse 2s ease infinite',
                    }}>
                        <Zap size={28} color="#3B82F6" />
                        Article Platform
                    </Box>
                    <Box sx={{ display: 'flex', gap: 2 }}>
                        {!auth.user ? (
                            <>
                                <Button href={route('login')} component={Link} sx={{ color: '#CBD5E1' }}>
                                    Sign In
                                </Button>
                                <Button
                                    href={route('register')}
                                    component={Link}
                                    variant="contained"
                                    sx={{
                                        background: 'linear-gradient(135deg, #3B82F6, #0EA5E9)',
                                        fontWeight: 700,
                                        '&:hover': {
                                            boxShadow: '0 0 20px rgba(59, 130, 246, 0.5)',
                                        }
                                    }}
                                >
                                    Get Started
                                </Button>
                            </>
                        ) : (
                            <Button href={route('logout')} component={Link} method="post" sx={{ color: '#CBD5E1' }}>
                                Logout
                            </Button>
                        )}
                    </Box>
                </Toolbar>
            </AppBar>

            <Container maxWidth="lg" sx={{ position: 'relative', zIndex: 1, py: 8 }}>
                <Box sx={{
                    textAlign: 'center',
                    mb: 8,
                    animation: 'slideInBounce 0.8s cubic-bezier(0.34, 1.56, 0.64, 1)',
                }}>
                    <Typography variant="h2" sx={{
                        fontWeight: 900,
                        mb: 2,
                        background: 'linear-gradient(90deg, #3B82F6, #0EA5E9, #059669, #F59E0B, #3B82F6)',
                        backgroundSize: '200% auto',
                        WebkitBackgroundClip: 'text',
                        WebkitTextFillColor: 'transparent',
                        animation: 'gradientShift 4s ease infinite',
                    }}>
                        WELCOME TO THE PLATFORM
                    </Typography>
                    <Typography variant="h5" sx={{
                        color: '#CBD5E1',
                        mb: 4,
                        fontWeight: 500,
                        animation: 'fadeInUp 0.8s ease 0.2s both',
                    }}>
                        Collaborate, create, and publish amazing content
                    </Typography>
                </Box>

                <Grid container spacing={3} sx={{ mb: 8 }}>
                    <Grid item xs={12} md={4}>
                        <Card sx={{
                            background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.95) 0%, rgba(15, 23, 42, 0.98) 100%)',
                            backdropFilter: 'blur(20px)',
                            border: '2px solid rgba(59, 130, 246, 0.3)',
                            borderRadius: '25px',
                            boxShadow: '0 0 30px rgba(59, 130, 246, 0.1), inset 0 0 15px rgba(59, 130, 246, 0.05)',
                            transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                            animation: 'slideInBounce 0.8s ease 0.1s both',
                            cursor: 'pointer',
                            height: '100%',
                            position: 'relative',
                            overflow: 'hidden',
                            '&:hover': {
                                border: '2px solid rgba(59, 130, 246, 0.6)',
                                boxShadow: '0 0 50px rgba(59, 130, 246, 0.2), inset 0 0 25px rgba(59, 130, 246, 0.1)',
                                transform: 'translateY(-8px)',
                            }
                        }}>
                            <CardContent sx={{ p: 3, textAlign: 'center' }}>
                                <Box sx={{
                                    width: '70px',
                                    height: '70px',
                                    background: 'linear-gradient(135deg, #3B82F6, #0EA5E9)',
                                    borderRadius: '18px',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mx: 'auto',
                                    mb: 2,
                                    boxShadow: '0 0 25px rgba(59, 130, 246, 0.5)',
                                    animation: 'neonGlow 2s ease-in-out infinite',
                                    transition: 'all 0.3s ease',
                                }}>
                                    <Feather size={35} color="white" />
                                </Box>
                                <Typography variant="h5" sx={{
                                    color: '#F1F5F9',
                                    fontWeight: 800,
                                    mb: 1,
                                    animation: 'electricPulse 2s ease infinite',
                                }}>
                                    WRITER
                                </Typography>
                                <Typography variant="body2" sx={{
                                    color: '#CBD5E1',
                                    mb: 3,
                                    animation: 'fadeInUp 0.8s ease 0.1s both',
                                }}>
                                    Create and submit your articles. Share your ideas with the world and get them reviewed by editors.
                                </Typography>
                                <Button
                                    fullWidth
                                    variant="contained"
                                    onClick={() => {
                                        if (!auth.user) window.location.href = route('register');
                                        else window.location.href = route('writer.dashboard');
                                    }}
                                    sx={{
                                        background: 'linear-gradient(135deg, #3B82F6, #0EA5E9)',
                                        fontWeight: 700,
                                        py: 1.5,
                                        '&:hover': {
                                            boxShadow: '0 0 25px rgba(59, 130, 246, 0.6)',
                                            transform: 'scale(1.05)',
                                        }
                                    }}
                                >
                                    {auth.user ? 'Go to Dashboard' : 'Get Started'}
                                </Button>
                            </CardContent>
                        </Card>
                    </Grid>

                    <Grid item xs={12} md={4}>
                        <Card sx={{
                            background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.95) 0%, rgba(15, 23, 42, 0.98) 100%)',
                            backdropFilter: 'blur(20px)',
                            border: '2px solid rgba(5, 150, 105, 0.3)',
                            borderRadius: '25px',
                            boxShadow: '0 0 30px rgba(5, 150, 105, 0.1), inset 0 0 15px rgba(5, 150, 105, 0.05)',
                            transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                            animation: 'slideInBounce 0.8s ease 0.2s both',
                            cursor: 'pointer',
                            height: '100%',
                            position: 'relative',
                            overflow: 'hidden',
                            '&:hover': {
                                border: '2px solid rgba(5, 150, 105, 0.6)',
                                boxShadow: '0 0 50px rgba(5, 150, 105, 0.2), inset 0 0 25px rgba(5, 150, 105, 0.1)',
                                transform: 'translateY(-8px)',
                            }
                        }}>
                            <CardContent sx={{ p: 3, textAlign: 'center' }}>
                                <Box sx={{
                                    width: '70px',
                                    height: '70px',
                                    background: 'linear-gradient(135deg, #059669, #10B981)',
                                    borderRadius: '18px',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mx: 'auto',
                                    mb: 2,
                                    boxShadow: '0 0 25px rgba(5, 150, 105, 0.5)',
                                    animation: 'neonGlowGreen 2s ease-in-out infinite',
                                    transition: 'all 0.3s ease',
                                }}>
                                    <CheckCircle2 size={35} color="white" />
                                </Box>
                                <Typography variant="h5" sx={{
                                    color: '#F1F5F9',
                                    fontWeight: 800,
                                    mb: 1,
                                    animation: 'electricPulse 2s ease infinite',
                                }}>
                                    EDITOR
                                </Typography>
                                <Typography variant="body2" sx={{
                                    color: '#CBD5E1',
                                    mb: 3,
                                    animation: 'fadeInUp 0.8s ease 0.2s both',
                                }}>
                                    Review and approve articles. Provide feedback to writers and manage the publication workflow.
                                </Typography>
                                <Button
                                    fullWidth
                                    variant="contained"
                                    onClick={() => {
                                        if (!auth.user) window.location.href = route('register');
                                        else window.location.href = route('editor.dashboard');
                                    }}
                                    sx={{
                                        background: 'linear-gradient(135deg, #059669, #10B981)',
                                        fontWeight: 700,
                                        py: 1.5,
                                        '&:hover': {
                                            boxShadow: '0 0 25px rgba(5, 150, 105, 0.6)',
                                            transform: 'scale(1.05)',
                                        }
                                    }}
                                >
                                    {auth.user ? 'Go to Dashboard' : 'Get Started'}
                                </Button>
                            </CardContent>
                        </Card>
                    </Grid>

                    <Grid item xs={12} md={4}>
                        <Card sx={{
                            background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.95) 0%, rgba(15, 23, 42, 0.98) 100%)',
                            backdropFilter: 'blur(20px)',
                            border: '2px solid rgba(14, 165, 233, 0.3)',
                            borderRadius: '25px',
                            boxShadow: '0 0 30px rgba(14, 165, 233, 0.1), inset 0 0 15px rgba(14, 165, 233, 0.05)',
                            transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                            animation: 'slideInBounce 0.8s ease 0.3s both',
                            cursor: 'pointer',
                            height: '100%',
                            position: 'relative',
                            overflow: 'hidden',
                            '&:hover': {
                                border: '2px solid rgba(14, 165, 233, 0.6)',
                                boxShadow: '0 0 50px rgba(14, 165, 233, 0.2), inset 0 0 25px rgba(14, 165, 233, 0.1)',
                                transform: 'translateY(-8px)',
                            }
                        }}>
                            <CardContent sx={{ p: 3, textAlign: 'center' }}>
                                <Box sx={{
                                    width: '70px',
                                    height: '70px',
                                    background: 'linear-gradient(135deg, #0EA5E9, #06B6D4)',
                                    borderRadius: '18px',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mx: 'auto',
                                    mb: 2,
                                    boxShadow: '0 0 25px rgba(14, 165, 233, 0.5)',
                                    animation: 'neonGlowCyan 2s ease-in-out infinite',
                                    transition: 'all 0.3s ease',
                                }}>
                                    <BookOpen size={35} color="white" />
                                </Box>
                                <Typography variant="h5" sx={{
                                    color: '#F1F5F9',
                                    fontWeight: 800,
                                    mb: 1,
                                    animation: 'electricPulse 2s ease infinite',
                                }}>
                                    STUDENT
                                </Typography>
                                <Typography variant="body2" sx={{
                                    color: '#CBD5E1',
                                    mb: 3,
                                    animation: 'fadeInUp 0.8s ease 0.3s both',
                                }}>
                                    Discover and read published articles. Comment on content and engage with the community.
                                </Typography>
                                <Button
                                    fullWidth
                                    variant="contained"
                                    onClick={() => {
                                        if (!auth.user) window.location.href = route('register');
                                        else window.location.href = route('student.dashboard');
                                    }}
                                    sx={{
                                        background: 'linear-gradient(135deg, #0EA5E9, #06B6D4)',
                                        fontWeight: 700,
                                        py: 1.5,
                                        '&:hover': {
                                            boxShadow: '0 0 25px rgba(14, 165, 233, 0.6)',
                                            transform: 'scale(1.05)',
                                        }
                                    }}
                                >
                                    {auth.user ? 'Go to Dashboard' : 'Get Started'}
                                </Button>
                            </CardContent>
                        </Card>
                    </Grid>
                </Grid>
            </Container>
        </Box>
    );
}
