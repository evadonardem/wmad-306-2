import React, { useState, useEffect } from 'react';
import { Head, Link, usePage } from '@inertiajs/react';
import {
    Typography,
    Box,
    Container,
    Card,
    CardContent,
    Avatar,
    Button,
    IconButton,
    Fade,
    Slide,
    Zoom,
    Collapse,
    Paper,
    Divider,
    Chip,
    LinearProgress,
    ThemeProvider,
    createTheme,
    alpha,
    Tooltip,
    Badge
} from '@mui/material';
import {
    ArrowBack,
    Person,
    Security,
    Delete,
    Edit,
    VerifiedUser,
    Email,
    Settings,
    AccountCircle,
    Lock,
    Warning,
    ExpandMore,
    ExpandLess,
    Timeline,
    Star,
    Lightbulb
} from '@mui/icons-material';
import DeleteUserForm from './Partials/DeleteUserForm';
import UpdatePasswordForm from './Partials/UpdatePasswordForm';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm';

export default function ProfileEdit({ mustVerifyEmail, status }) {
    const [expandedProfile, setExpandedProfile] = useState(true);
    const [expandedPassword, setExpandedPassword] = useState(true);
    const [expandedDelete, setExpandedDelete] = useState(false);
    const [mounted, setMounted] = useState(false);
    const [loading, setLoading] = useState(true);

    const { auth } = usePage().props;

    useEffect(() => {
        setMounted(true);
        setTimeout(() => setLoading(false), 1000);
    }, []);

    const theme = createTheme({
        palette: {
            mode: 'dark',
            background: {
                default: '#0a0e27',
                paper: '#151932',
            },
            primary: {
                main: '#6366f1',
                light: '#818cf8',
                dark: '#4f46e5',
            },
            secondary: {
                main: '#ec4899',
                light: '#f472b6',
                dark: '#db2777',
            },
            success: {
                main: '#10b981',
                light: '#34d399',
                dark: '#059669',
            },
            warning: {
                main: '#f59e0b',
                light: '#fbbf24',
                dark: '#d97706',
            },
            error: {
                main: '#ef4444',
                light: '#f87171',
                dark: '#dc2626',
            },
            text: {
                primary: '#f8fafc',
                secondary: '#cbd5e1',
                disabled: '#64748b',
            },
        },
        typography: {
            fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
            h1: {
                fontWeight: 800,
                fontSize: '3.5rem',
                lineHeight: 1.1,
                background: 'linear-gradient(135deg, #6366f1 0%, #ec4899 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundClip: 'text',
            },
            h2: {
                fontWeight: 700,
                fontSize: '2.5rem',
                lineHeight: 1.2,
            },
            h3: {
                fontWeight: 600,
                fontSize: '1.875rem',
            },
            h4: {
                fontWeight: 600,
                fontSize: '1.5rem',
            },
            body1: {
                fontSize: '1.125rem',
                lineHeight: 1.6,
            },
            body2: {
                fontSize: '0.875rem',
                lineHeight: 1.5,
            },
        },
        shape: {
            borderRadius: 16,
        },
        components: {
            MuiCard: {
                styleOverrides: {
                    root: {
                        background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                        backdropFilter: 'blur(20px)',
                        border: '1px solid rgba(148, 163, 184, 0.1)',
                        borderRadius: 20,
                        transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                        '&:hover': {
                            transform: 'translateY(-8px) scale(1.02)',
                            boxShadow: '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 30px rgba(99, 102, 241, 0.1)',
                            border: '1px solid rgba(99, 102, 241, 0.2)',
                        },
                    },
                },
            },
            MuiButton: {
                styleOverrides: {
                    root: {
                        textTransform: 'none',
                        fontWeight: 600,
                        fontSize: '0.875rem',
                        borderRadius: 12,
                        padding: '12px 24px',
                        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                    },
                    contained: {
                        background: 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)',
                        boxShadow: '0 4px 14px 0 rgba(99, 102, 241, 0.39)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)',
                            transform: 'translateY(-2px)',
                            boxShadow: '0 6px 20px 0 rgba(99, 102, 241, 0.5)',
                        },
                    },
                    outlined: {
                        borderWidth: 2,
                        '&:hover': {
                            borderWidth: 2,
                            transform: 'translateY(-2px)',
                        },
                    },
                },
            },
        },
    });

    // Determine dashboard route based on user role
    const getDashboardRoute = () => {
        switch(auth?.user?.role) {
            case 'admin':
                return '/admin/dashboard';
            case 'writer':
                return '/writer/dashboard';
            case 'editor':
                return '/editor/dashboard';
            case 'student':
                return '/student/dashboard';
            default:
                return '/dashboard';
        }
    };

    const getRoleColor = (role) => {
        switch(role) {
            case 'admin': return '#ef4444';
            case 'writer': return '#10b981';
            case 'editor': return '#f59e0b';
            case 'student': return '#06b6d4';
            default: return '#64748b';
        }
    };

    const getRoleIcon = (role) => {
        switch(role) {
            case 'admin': return <Settings />;
            case 'writer': return <Edit />;
            case 'editor': return <Security />;
            case 'student': return <Person />;
            default: return <AccountCircle />;
        }
    };

    return (
        <ThemeProvider theme={theme}>
            <Head title="Profile Settings" />
            
            <Box sx={{ 
                minHeight: "100vh", 
                backgroundColor: "#0a0e27",
                display: 'flex',
                flexDirection: 'column',
                background: 'radial-gradient(circle at 20% 50%, rgba(99, 102, 241, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(236, 72, 153, 0.05) 0%, transparent 50%), #0a0e27',
                position: 'relative',
                overflow: 'hidden'
            }}>
                {/* Animated Background Elements */}
                <Box
                    sx={{
                        position: 'absolute',
                        top: '10%',
                        left: '10%',
                        width: 300,
                        height: 300,
                        background: 'radial-gradient(circle, rgba(99, 102, 241, 0.1) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 6s ease-in-out infinite',
                    }}
                />
                <Box
                    sx={{
                        position: 'absolute',
                        bottom: '10%',
                        right: '10%',
                        width: 200,
                        height: 200,
                        background: 'radial-gradient(circle, rgba(236, 72, 153, 0.1) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 8s ease-in-out infinite reverse',
                    }}
                />

                {/* Header */}
                <Box sx={{ 
                    background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                    backdropFilter: 'blur(20px)',
                    borderBottom: '1px solid rgba(148, 163, 184, 0.1)',
                    p: 3,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    position: 'relative',
                    zIndex: 10
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                        <Avatar sx={{ 
                            backgroundColor: 'linear-gradient(135deg, #6366f1 0%, #ec4899 100%)',
                            width: 48,
                            height: 48
                        }}>
                            <AccountCircle />
                        </Avatar>
                        <Box>
                            <Typography variant="h4" sx={{ color: '#f8fafc', fontWeight: 800, letterSpacing: '-0.01em' }}>
                                Profile Settings
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                                Manage your account settings and preferences
                            </Typography>
                        </Box>
                    </Box>

                    <Tooltip title="Go Back to Dashboard">
                        <Button
                            variant="outlined"
                            startIcon={<ArrowBack />}
                            component={Link}
                            href={getDashboardRoute()}
                            sx={{ 
                                borderColor: '#6366f1', 
                                color: '#6366f1',
                                '&:hover': { borderColor: '#4f46e5', color: '#4f46e5' }
                            }}
                        >
                            Back to Dashboard
                        </Button>
                    </Tooltip>
                </Box>

                {/* Main Content */}
                <Container maxWidth="lg" sx={{ flexGrow: 1, py: 4, position: 'relative', zIndex: 1 }}>
                    {/* Profile Overview */}
                    <Fade in={mounted} timeout={1000}>
                        <Card sx={{ mb: 4 }}>
                            <CardContent sx={{ p: 4 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 3, mb: 3 }}>
                                    <Avatar sx={{ 
                                        backgroundColor: alpha(getRoleColor(auth?.user?.role), 0.2),
                                        color: getRoleColor(auth?.user?.role),
                                        width: 80,
                                        height: 80,
                                        fontSize: '2rem'
                                    }}>
                                        {getRoleIcon(auth?.user?.role)}
                                    </Avatar>
                                    <Box sx={{ flex: 1 }}>
                                        <Typography variant="h3" sx={{ color: '#f8fafc', fontWeight: 700, mb: 1 }}>
                                            {auth?.user?.name}
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: '#cbd5e1', mb: 2 }}>
                                            {auth?.user?.email}
                                        </Typography>
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                            <Chip 
                                                label={auth?.user?.role || 'user'}
                                                sx={{ 
                                                    backgroundColor: alpha(getRoleColor(auth?.user?.role), 0.2),
                                                    color: getRoleColor(auth?.user?.role),
                                                    fontWeight: 'bold',
                                                    textTransform: 'capitalize'
                                                }}
                                            />
                                            {mustVerifyEmail && (
                                                <Chip 
                                                    icon={<Email />}
                                                    label="Email verification required"
                                                    color="warning"
                                                    variant="outlined"
                                                />
                                            )}
                                        </Box>
                                    </Box>
                                    <Box sx={{ textAlign: 'center' }}>
                                        <Typography variant="h4" sx={{ color: getRoleColor(auth?.user?.role), fontWeight: 'bold' }}>
                                            {auth?.user?.name?.charAt(0)?.toUpperCase() || 'U'}
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                                            Profile
                                        </Typography>
                                    </Box>
                                </Box>
                                {status && (
                                    <Box sx={{ 
                                        backgroundColor: alpha('#10b981', 0.1),
                                        border: '1px solid rgba(16, 185, 129, 0.2)',
                                        borderRadius: 2,
                                        p: 2,
                                        mt: 2
                                    }}>
                                        <Typography variant="body2" sx={{ color: '#10b981' }}>
                                            {status}
                                        </Typography>
                                    </Box>
                                )}
                            </CardContent>
                        </Card>
                    </Fade>

                    {/* Profile Information Section */}
                    <Fade in={mounted} timeout={1200}>
                        <Card sx={{ mb: 4 }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', p: 3, pb: 0 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                    <Avatar sx={{ 
                                        backgroundColor: alpha('#6366f1', 0.2),
                                        color: '#6366f1'
                                    }}>
                                        <Edit />
                                    </Avatar>
                                    <Typography variant="h5" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                                        Profile Information
                                    </Typography>
                                </Box>
                                <IconButton 
                                    onClick={() => setExpandedProfile(!expandedProfile)}
                                    sx={{ color: '#cbd5e1' }}
                                >
                                    {expandedProfile ? <ExpandLess /> : <ExpandMore />}
                                </IconButton>
                            </Box>
                            <Collapse in={expandedProfile}>
                                <CardContent sx={{ p: 3 }}>
                                    <UpdateProfileInformationForm
                                        mustVerifyEmail={mustVerifyEmail}
                                        status={status}
                                    />
                                </CardContent>
                            </Collapse>
                        </Card>
                    </Fade>

                    {/* Password Section */}
                    <Fade in={mounted} timeout={1400}>
                        <Card sx={{ mb: 4 }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', p: 3, pb: 0 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                    <Avatar sx={{ 
                                        backgroundColor: alpha('#f59e0b', 0.2),
                                        color: '#f59e0b'
                                    }}>
                                        <Lock />
                                    </Avatar>
                                    <Typography variant="h5" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                                        Password Settings
                                    </Typography>
                                </Box>
                                <IconButton 
                                    onClick={() => setExpandedPassword(!expandedPassword)}
                                    sx={{ color: '#cbd5e1' }}
                                >
                                    {expandedPassword ? <ExpandLess /> : <ExpandMore />}
                                </IconButton>
                            </Box>
                            <Collapse in={expandedPassword}>
                                <CardContent sx={{ p: 3 }}>
                                    <UpdatePasswordForm />
                                </CardContent>
                            </Collapse>
                        </Card>
                    </Fade>

                    {/* Delete Account Section */}
                    <Fade in={mounted} timeout={1600}>
                        <Card>
                            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', p: 3, pb: 0 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                    <Avatar sx={{ 
                                        backgroundColor: alpha('#ef4444', 0.2),
                                        color: '#ef4444'
                                    }}>
                                        <Warning />
                                    </Avatar>
                                    <Typography variant="h5" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                                        Danger Zone
                                    </Typography>
                                </Box>
                                <IconButton 
                                    onClick={() => setExpandedDelete(!expandedDelete)}
                                    sx={{ color: '#cbd5e1' }}
                                >
                                    {expandedDelete ? <ExpandLess /> : <ExpandMore />}
                                </IconButton>
                            </Box>
                            <Collapse in={expandedDelete}>
                                <CardContent sx={{ p: 3 }}>
                                    <Box sx={{ 
                                        backgroundColor: alpha('#ef4444', 0.1),
                                        border: '1px solid rgba(239, 68, 68, 0.2)',
                                        borderRadius: 2,
                                        p: 2,
                                        mb: 3
                                    }}>
                                        <Typography variant="body2" sx={{ color: '#ef4444', fontWeight: 600 }}>
                                            ⚠️ Warning: This action cannot be undone. All your data will be permanently deleted.
                                        </Typography>
                                    </Box>
                                    <DeleteUserForm />
                                </CardContent>
                            </Collapse>
                        </Card>
                    </Fade>
                </Container>

                {/* Global Styles for Animations */}
                <style jsx>{`
                    @keyframes float {
                        0%, 100% { transform: translateY(0px); }
                        50% { transform: translateY(-20px); }
                    }
                `}</style>
            </Box>
        </ThemeProvider>
    );
}
