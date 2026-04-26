import React, { useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Box,
    Typography,
    Button,
    Card,
    CardContent,
    Avatar,
    Grid,
    Paper,
    Container
} from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import {
    Edit,
    Visibility,
    RateReview,
    Person,
    TrendingUp,
    Article,
    AdminPanelSettings
} from '@mui/icons-material';
 
export default function Dashboard() {
    const { auth } = usePage().props;
 
    const getRoleDashboard = () => {
        switch(auth?.user?.role) {
            case 'admin':
                return '/admin/admin';
            case 'writer':
                return '/writer/dashboard';
            case 'editor':
                return '/editor/dashboard';
            case 'student':
                return '/student/dashboard';
            default:
                '/dashboard';
        }
    };
 
    // Automatic redirect based on user role
    useEffect(() => {
        if (auth?.user?.role) {
            const dashboardPath = getRoleDashboard();
            router.visit(dashboardPath);
        }
    }, [auth?.user?.role]);
 
    // Professional Theme with enhanced styling
    const theme = createTheme({
        palette: {
            mode: "dark",
            background: { 
                default: "#0f0f23",
                paper: "#1a1a2e"
            },
            primary: { 
                main: "#667eea",
                light: "#764ba2",
                dark: "#4c51bf"
            },
            secondary: { 
                main: "#f093fb",
                light: "#f5576c",
                dark: "#e53e3e"
            },
            success: { 
                main: "#48bb78",
                light: "#68d391",
                dark: "#38a169"
            },
            warning: { 
                main: "#ed8936",
                light: "#f6ad55",
                dark: "#dd6b20"
            },
            error: { 
                main: "#f56565",
                light: "#fc8181",
                dark: "#e53e3e"
            },
            text: { 
                primary: "#f7fafc",
                secondary: "#cbd5e0",
                disabled: "#718096"
            },
            divider: "#2d3748"
        },
        typography: { 
            fontFamily: '"Inter", "SF Pro Display", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            h1: {
                fontWeight: 800,
                fontSize: '3.5rem',
                lineHeight: 1.2,
                letterSpacing: '-0.02em'
            },
            h2: {
                fontWeight: 700,
                fontSize: '2.5rem',
                lineHeight: 1.3,
                letterSpacing: '-0.01em'
            },
            h3: {
                fontWeight: 600,
                fontSize: '2rem',
                lineHeight: 1.4
            },
            h4: { 
                fontWeight: 600,
                fontSize: '1.5rem',
                lineHeight: 1.4
            },
            h5: { 
                fontWeight: 600,
                fontSize: '1.25rem',
                lineHeight: 1.5
            },
            h6: { 
                fontWeight: 600,
                fontSize: '1.125rem',
                lineHeight: 1.5
            },
            body1: {
                fontSize: '1.125rem',
                lineHeight: 1.6,
                fontWeight: 400
            },
            body2: {
                fontSize: '1rem',
                lineHeight: 1.5,
                fontWeight: 400
            }
        },
        shape: {
            borderRadius: 12
        },
        spacing: 8,
        components: {
            MuiPaper: {
                styleOverrides: {
                    root: {
                        backgroundImage: 'none',
                        backgroundColor: '#1a1a2e',
                        border: '1px solid rgba(255, 255, 255, 0.1)',
                        transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                        backdropFilter: 'blur(10px)',
                        '&:hover': {
                            transform: 'translateY(-4px)',
                            boxShadow: '0 20px 40px rgba(0, 0, 0, 0.3), 0 0 20px rgba(102, 126, 234, 0.1)',
                            borderColor: 'rgba(102, 126, 234, 0.3)'
                        }
                    }
                }
            },
            MuiButton: {
                styleOverrides: {
                    root: {
                        textTransform: 'none',
                        fontWeight: 600,
                        fontSize: '1rem',
                        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                        borderRadius: 12,
                        padding: '12px 32px',
                        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
                        '&:hover': {
                            transform: 'translateY(-2px)',
                            boxShadow: '0 8px 12px rgba(0, 0, 0, 0.2)'
                        },
                        '&:active': {
                            transform: 'translateY(0)'
                        }
                    },
                    contained: {
                        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%)'
                        }
                    },
                    outlined: {
                        borderWidth: 2,
                        '&:hover': {
                            borderWidth: 2
                        }
                    }
                }
            },
            MuiCard: {
                styleOverrides: {
                    root: {
                        backgroundColor: '#1a1a2e',
                        border: '1px solid rgba(255, 255, 255, 0.1)',
                        transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                        backdropFilter: 'blur(10px)',
                        '&:hover': {
                            transform: 'translateY(-6px)',
                            boxShadow: '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 30px rgba(102, 126, 234, 0.15)',
                            borderColor: 'rgba(102, 126, 234, 0.4)'
                        }
                    }
                }
            }
        }
    });
 
    const handleNavigate = (path) => {
        router.visit(path);
    };
 
    return (
        <ThemeProvider theme={theme}>
            <Head title="Dashboard" />
 
            <Box sx={{ 
                minHeight: "100vh", 
                backgroundColor: "#0f0f23",
                display: 'flex',
                flexDirection: 'column',
                background: 'radial-gradient(circle at 20% 50%, rgba(102, 126, 234, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(118, 75, 162, 0.1) 0%, transparent 50%), #0f0f23'
            }}>
                {/* Hero Section */}
                <Box sx={{
                    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%)',
                    py: 12,
                    px: 3,
                    position: 'relative',
                    overflow: 'hidden',
                    '&::before': {
                        content: '""',
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        background: 'url("data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%23ffffff" fill-opacity="0.08"%3E%3Ccircle cx="30" cy="30" r="4"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
                        opacity: 0.4
                    },
                    '&::after': {
                        content: '""',
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        background: 'radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.1) 0%, transparent 50%), radial-gradient(circle at 70% 80%, rgba(255, 255, 255, 0.05) 0%, transparent 50%)',
                        opacity: 0.6
                    }
                }}>
                    <Container maxWidth="lg">
                        <Box sx={{ position: 'relative', zIndex: 1, textAlign: 'center' }}>
                            <Typography 
                                variant="h1" 
                                sx={{ 
                                    color: '#ffffff', 
                                    fontWeight: 800,
                                    mb: 3,
                                    fontSize: { xs: '2.5rem', md: '3.5rem' },
                                    textShadow: '0 2px 4px rgba(0,0,0,0.1)'
                                }}
                            >
                                Welcome back, {auth?.user?.name || 'User'}!
                            </Typography>
                            <Typography 
                                variant="h4" 
                                sx={{ 
                                    color: 'rgba(255,255,255,0.9)', 
                                    mb: 6,
                                    maxWidth: '800px',
                                    mx: 'auto',
                                    lineHeight: 1.6
                                }}
                            >
                                You're logged in! Navigate to your role-specific dashboard to get started with your work.
                            </Typography>
                            <Button
                                variant="contained"
                                onClick={() => handleNavigate(getRoleDashboard())}
                                sx={{
                                    bgcolor: 'rgba(255, 255, 255, 0.95)',
                                    color: '#667eea',
                                    px: 8,
                                    py: 3,
                                    fontWeight: 700,
                                    fontSize: '1.125rem',
                                    borderRadius: 12,
                                    boxShadow: '0 8px 24px rgba(0, 0, 0, 0.2)',
                                    '&:hover': {
                                        bgcolor: '#ffffff',
                                        transform: 'translateY(-4px)',
                                        boxShadow: '0 12px 32px rgba(0, 0, 0, 0.3)'
                                    }
                                }}
                            >
                                Go to {auth?.user?.role || 'Your'} Dashboard
                            </Button>
                        </Box>
                    </Container>
                </Box>
 
                {/* Quick Access Cards */}
                <Container maxWidth="lg" sx={{ py: 8 }}>
                    <Typography 
                        variant="h3" 
                        sx={{ 
                            color: '#f7fafc', 
                            mb: 6, 
                            textAlign: 'center',
                            fontWeight: 700,
                            letterSpacing: '-0.01em'
                        }}
                    >
                        Quick Access
                    </Typography>
 
                    <Grid container spacing={4}>
                        {/* Admin Card - Only show for admin users */}
                        {auth?.user?.role === 'admin' && (
                            <Grid item xs={12} md={4}>
                                <Card 
                                    onClick={() => handleNavigate('/admin/admin')}
                                    sx={{ 
                                        cursor: 'pointer',
                                        height: '100%',
                                        display: 'flex',
                                        flexDirection: 'column'
                                    }}
                                >
                                    <CardContent sx={{ flexGrow: 1, textAlign: 'center', py: 6 }}>
                                        <Avatar sx={{ 
                                            bgcolor: '#f56565', 
                                            mx: 'auto', 
                                            mb: 3,
                                            width: 80,
                                            height: 80,
                                            fontSize: '2rem'
                                        }}>
                                            <AdminPanelSettings fontSize="large" />
                                        </Avatar>
                                        <Typography variant="h5" sx={{ color: '#f7fafc', mb: 2, fontWeight: 600 }}>
                                            Admin Dashboard
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#cbd5e0', mb: 3 }}>
                                            Manage users and system settings
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#f56565', fontWeight: 600 }}>
                                            Click to access →
                                        </Typography>
                                    </CardContent>
                                </Card>
                            </Grid>
                        )}
 
                        <Grid item xs={12} md={4}>
                            <Card 
                                onClick={() => handleNavigate('/writer/dashboard')}
                                sx={{ 
                                    cursor: 'pointer',
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column'
                                }}
                            >
                                <CardContent sx={{ flexGrow: 1, textAlign: 'center', py: 6 }}>
                                    <Avatar sx={{ 
                                        bgcolor: '#667eea', 
                                        mx: 'auto', 
                                        mb: 3,
                                        width: 80,
                                        height: 80,
                                        fontSize: '2rem'
                                    }}>
                                        <Edit fontSize="large" />
                                    </Avatar>
                                    <Typography variant="h5" sx={{ color: '#f7fafc', mb: 2, fontWeight: 600 }}>
                                        Writer Dashboard
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#cbd5e0', mb: 3 }}>
                                        Create, edit, and manage your articles
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#667eea', fontWeight: 600 }}>
                                        Click to access →
                                    </Typography>
                                </CardContent>
                            </Card>
                        </Grid>
 
                        <Grid item xs={12} md={4}>
                            <Card 
                                onClick={() => handleNavigate('/editor/dashboard')}
                                sx={{ 
                                    cursor: 'pointer',
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column'
                                }}
                            >
                                <CardContent sx={{ flexGrow: 1, textAlign: 'center', py: 6 }}>
                                    <Avatar sx={{ 
                                        bgcolor: '#ef4444', 
                                        mx: 'auto', 
                                        mb: 3,
                                        width: 80,
                                        height: 80,
                                        fontSize: '2rem'
                                    }}>
                                        <RateReview fontSize="large" />
                                    </Avatar>
                                    <Typography variant="h5" sx={{ color: '#f7fafc', mb: 2, fontWeight: 600 }}>
                                        Editor Dashboard
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#cbd5e0', mb: 3 }}>
                                        Review and publish submitted articles
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#ef4444', fontWeight: 600 }}>
                                        Click to access →
                                    </Typography>
                                </CardContent>
                            </Card>
                        </Grid>
 
                        <Grid item xs={12} md={4}>
                            <Card 
                                onClick={() => handleNavigate('/student/dashboard')}
                                sx={{ 
                                    cursor: 'pointer',
                                    height: '100%',
                                    display: 'flex',
                                    flexDirection: 'column'
                                }}
                            >
                                <CardContent sx={{ flexGrow: 1, textAlign: 'center', py: 6 }}>
                                    <Avatar sx={{ 
                                        bgcolor: '#10b981', 
                                        mx: 'auto', 
                                        mb: 3,
                                        width: 80,
                                        height: 80,
                                        fontSize: '2rem'
                                    }}>
                                        <Visibility fontSize="large" />
                                    </Avatar>
                                    <Typography variant="h5" sx={{ color: '#f7fafc', mb: 2, fontWeight: 600 }}>
                                        Student Dashboard
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#cbd5e0', mb: 3 }}>
                                        Read articles and engage with content
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#10b981', fontWeight: 600 }}>
                                        Click to access →
                                    </Typography>
                                </CardContent>
                            </Card>
                        </Grid>
                    </Grid>
                </Container>
            </Box>
        </ThemeProvider>
    );
}