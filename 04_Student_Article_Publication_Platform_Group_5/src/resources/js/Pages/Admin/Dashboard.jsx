import React, { useState, useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import { useThemeContext } from '@/Context/ThemeContext';
import {
    Typography,
    Box,
    Button,
    Paper,
    Avatar,
    IconButton,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    Grid,
    Card,
    CardContent,
    CardActions,
    Chip,
    ThemeProvider,
    createTheme,
    LinearProgress,
    Container,
    Fade,
    Slide,
    Zoom,
    Collapse,
    Fab,
    Tooltip,
    Badge,
    Skeleton,
    alpha
} from '@mui/material';
import {
    ArrowBack,
    People,
    Person,
    Edit,
    RateReview,
    Pending,
    CheckCircle,
    Cancel,
    Visibility,
    Settings,
    Logout,
    Menu as MenuIcon,
    TrendingUp,
    Assignment,
    Group,
    ExpandMore,
    ExpandLess,
    Notifications,
    Dashboard,
    Article,
    Star,
    Timeline,
    Assessment,
    Lightbulb,
    AutoAwesome,
    Speed,
    Analytics,
    Report,
    FilterList,
    Search
} from '@mui/icons-material';

const AdminDashboard = ({ stats, recentUsers, pendingRequests }) => {
    const { mode } = useThemeContext();
    const [anchorEl, setAnchorEl] = useState(null);
    const [expandedStats, setExpandedStats] = useState(true);
    const [expandedUsers, setExpandedUsers] = useState(true);
    const [expandedRequests, setExpandedRequests] = useState(true);
    const [loading, setLoading] = useState(true);
    const [mounted, setMounted] = useState(false);

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
            info: {
                main: '#06b6d4',
                light: '#22d3ee',
                dark: '#0891b2',
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

    const handleLogout = () => {
        router.post('/logout', {}, {
            onFinish: () => {
                handleMenuClose();
            }
        });
    };

    const handleMenuClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    const handleViewUsers = () => {
        router.get('/admin/users');
    };

    const handleViewRoleRequests = () => {
        router.get('/admin/role-requests');
    };

    const handleApproveRequest = (requestId) => {
        router.post(`/admin/role-requests/${requestId}/approve`, {}, {
            onSuccess: () => {
                router.reload();
            }
        });
    };

    const handleRejectRequest = (requestId) => {
        if (window.confirm('Are you sure you want to reject this role request?')) {
            router.post(`/admin/role-requests/${requestId}/reject`, {}, {
                onSuccess: () => {
                    router.reload();
                }
            });
        }
    };

    // Enhanced StatCard with animations
    const StatCard = ({ title, value, icon, color, subtitle, trend, delay = 0 }) => (
        <Zoom in={mounted} style={{ transitionDelay: `${delay}ms` }}>
            <Card sx={{ 
                background: `linear-gradient(135deg, ${alpha(color, 0.1)} 0%, ${alpha(color, 0.05)} 100%)`,
                border: `1px solid ${alpha(color, 0.2)}`,
                position: 'relative',
                overflow: 'hidden',
                '&:hover': { 
                    border: `2px solid ${color}`,
                    transform: 'translateY(-8px) scale(1.02)'
                },
                '&::before': {
                    content: '""',
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    right: 0,
                    height: '4px',
                    background: `linear-gradient(90deg, ${color}, ${alpha(color, 0.5)})`,
                }
            }}>
                <CardContent sx={{ p: 3 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                        <Avatar sx={{ 
                            backgroundColor: alpha(color, 0.2), 
                            color: color,
                            width: 56,
                            height: 56,
                            fontSize: '1.5rem'
                        }}>
                            {icon}
                        </Avatar>
                        {trend && (
                            <Chip 
                                label={trend} 
                                size="small" 
                                sx={{ 
                                    backgroundColor: trend.includes('+') ? alpha('#10b981', 0.2) : alpha('#ef4444', 0.2),
                                    color: trend.includes('+') ? '#10b981' : '#ef4444',
                                    fontWeight: 'bold'
                                }} 
                            />
                        )}
                    </Box>
                    <Typography variant="h3" sx={{ color: color, fontWeight: 'bold', mb: 1 }}>
                        {loading ? <Skeleton width={60} /> : value}
                    </Typography>
                    <Typography variant="h6" sx={{ color: '#f8fafc', mb: 1, fontWeight: 600 }}>
                        {title}
                    </Typography>
                    {subtitle && (
                        <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                            {subtitle}
                        </Typography>
                    )}
                </CardContent>
            </Card>
        </Zoom>
    );

    // Enhanced UserCard with animations
    const UserCard = ({ user, delay = 0 }) => (
        <Fade in={mounted} style={{ transitionDelay: `${delay}ms` }}>
            <Card sx={{ 
                background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                border: '1px solid rgba(148, 163, 184, 0.1)',
                position: 'relative',
                overflow: 'hidden',
                '&:hover': { 
                    transform: 'translateY(-4px)',
                    border: '1px solid rgba(99, 102, 241, 0.3)',
                }
            }}>
                <CardContent sx={{ pb: 2 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Avatar sx={{ 
                            backgroundColor: '#6366f1',
                            width: 48,
                            height: 48,
                            fontSize: '1.2rem'
                        }}>
                            {user.name.charAt(0).toUpperCase()}
                        </Avatar>
                        <Box sx={{ flex: 1 }}>
                            <Typography variant="h6" sx={{ color: '#f8fafc', fontWeight: 600 }}>
                                {user.name}
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                                {user.email}
                            </Typography>
                            <Typography variant="caption" sx={{ color: '#64748b' }}>
                                Joined {new Date(user.created_at).toLocaleDateString('en-US', { 
                                    month: 'short', 
                                    day: 'numeric', 
                                    year: 'numeric' 
                                })}
                            </Typography>
                        </Box>
                        <Chip 
                            label="New" 
                            size="small" 
                            sx={{ 
                                backgroundColor: alpha('#ec4899', 0.2), 
                                color: '#ec4899',
                                fontWeight: 'bold'
                            }} 
                        />
                    </Box>
                </CardContent>
            </Card>
        </Fade>
    );

    // Enhanced RequestCard with animations
    const RequestCard = ({ request, delay = 0 }) => (
        <Slide direction="up" in={mounted} style={{ transitionDelay: `${delay}ms` }}>
            <Card sx={{ 
                background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                border: '1px solid rgba(148, 163, 184, 0.1)',
                position: 'relative',
                overflow: 'hidden',
                '&:hover': { 
                    transform: 'translateY(-4px)',
                    border: '1px solid rgba(236, 72, 153, 0.3)',
                }
            }}>
                <CardContent>
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                            <Avatar sx={{ 
                                backgroundColor: alpha('#f59e0b', 0.2),
                                color: '#f59e0b',
                                width: 48,
                                height: 48
                            }}>
                                {request.user.name.charAt(0).toUpperCase()}
                            </Avatar>
                            <Box>
                                <Typography variant="h6" sx={{ color: '#f8fafc', fontWeight: 600 }}>
                                    {request.user.name}
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                                    {request.user.email}
                                </Typography>
                            </Box>
                        </Box>
                        <Chip 
                            label={request.requested_role} 
                            size="small" 
                            sx={{ 
                                backgroundColor: alpha('#06b6d4', 0.2), 
                                color: '#06b6d4',
                                fontWeight: 'bold',
                                textTransform: 'capitalize'
                            }} 
                        />
                    </Box>
                    {request.reason && (
                        <Box sx={{ 
                            backgroundColor: alpha('#f59e0b', 0.1),
                            border: '1px solid rgba(245, 158, 11, 0.2)',
                            borderRadius: 2,
                            p: 2,
                            mb: 2
                        }}>
                            <Typography variant="body2" sx={{ color: '#fbbf24', fontStyle: 'italic' }}>
                                "{request.reason}"
                            </Typography>
                        </Box>
                    )}
                    <Typography variant="caption" sx={{ color: '#64748b' }}>
                        Requested {new Date(request.created_at).toLocaleDateString('en-US', { 
                            month: 'short', 
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                        })}
                    </Typography>
                </CardContent>
                <CardActions sx={{ gap: 1, px: 2, pb: 2 }}>
                    <Button 
                        size="small" 
                        variant="contained" 
                        startIcon={<CheckCircle />}
                        onClick={() => handleApproveRequest(request.id)}
                        sx={{ 
                            background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                            '&:hover': { background: 'linear-gradient(135deg, #059669 0%, #047857 100%)' }
                        }}
                    >
                        Approve
                    </Button>
                    <Button 
                        size="small" 
                        variant="outlined" 
                        startIcon={<Cancel />}
                        onClick={() => handleRejectRequest(request.id)}
                        sx={{ 
                            borderColor: '#ef4444',
                            color: '#ef4444',
                            '&:hover': { borderColor: '#dc2626', color: '#dc2626' }
                        }}
                    >
                        Reject
                    </Button>
                </CardActions>
            </Card>
        </Slide>
    );

    return (
        <React.Fragment>
            <Head title="Admin Dashboard" />
            
            <Box sx={{ 
                minHeight: "100vh", 
                background: mode === 'light'
                    ? 'linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #bae6fd 100%)'
                    : mode === 'dark' 
                    ? 'linear-gradient(135deg, #0a0e27 0%, #1e293b 50%, #334155 100%)'
                    : 'radial-gradient(circle at 20% 50%, rgba(139, 92, 246, 0.15) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(236, 72, 153, 0.1) 0%, transparent 50%), linear-gradient(135deg, #0a0e27 0%, #1e293b 100%)',
                display: 'flex',
                flexDirection: 'column',
                position: 'relative',
                overflow: 'hidden'
            }}>
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

                {/* Header */}
                <Box sx={{ 
                    background: mode === 'light' ? 'linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(248, 250, 252, 0.9) 100%)' : 
                                   mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' : 
                                   'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                    backdropFilter: 'blur(20px)',
                    borderBottom: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                     mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                     '1px solid rgba(139, 92, 246, 0.2)',
                    p: 3,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    position: 'relative',
                    zIndex: 10
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                        <Avatar sx={{ 
                            backgroundColor: mode === 'light' ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)' : 
                                             mode === 'dark' ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)' : 
                                             'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                            width: 48,
                            height: 48
                        }}>
                            <Settings sx={{ color: '#fff' }} />
                        </Avatar>
                        <Box>
                            <Typography variant="h4" sx={{ color: mode === 'light' ? '#f8fafc' : 
                                                                           mode === 'dark' ? '#f8fafc' : 
                                                                           '#f8fafc', fontWeight: 800, letterSpacing: '-0.01em' }}>
                                Admin Dashboard
                            </Typography>
                            <Typography variant="body2" sx={{ color: mode === 'light' ? '#cbd5e1' : 
                                                                               mode === 'dark' ? '#cbd5e1' : 
                                                                               '#cbd5e1' }}>
                                Campus Article Management System
                            </Typography>
                        </Box>
                    </Box>

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Tooltip title="Manage Users">
                            <Button
                                variant="outlined"
                                startIcon={<People />}
                                onClick={handleViewUsers}
                                sx={{ 
                                    borderColor: '#6366f1', 
                                    color: '#6366f1',
                                    '&:hover': { borderColor: '#4f46e5', color: '#4f46e5' }
                                }}
                            >
                                Manage Users
                            </Button>
                        </Tooltip>
                        <Tooltip title="Role Requests">
                            <Badge badgeContent={stats.pending_requests} color="error">
                                <Button
                                    variant="outlined"
                                    startIcon={<Assignment />}
                                    onClick={handleViewRoleRequests}
                                    sx={{ 
                                        borderColor: '#ec4899', 
                                        color: '#ec4899',
                                        '&:hover': { borderColor: '#db2777', color: '#db2777' }
                                    }}
                                >
                                    Role Requests
                                </Button>
                            </Badge>
                        </Tooltip>
                        <Tooltip title="Menu">
                            <IconButton onClick={handleMenuClick} sx={{ color: '#f8fafc' }}>
                                <MenuIcon />
                            </IconButton>
                        </Tooltip>
                        <Menu
                            anchorEl={anchorEl}
                            open={Boolean(anchorEl)}
                            onClose={handleMenuClose}
                            PaperProps={{
                                sx: {
                                    background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                                    backdropFilter: 'blur(20px)',
                                    border: '1px solid rgba(148, 163, 184, 0.1)',
                                }
                            }}
                        >
                            <MenuItem onClick={handleLogout}>
                                <ListItemIcon><Logout sx={{ color: '#ef4444' }} /></ListItemIcon>
                                <Typography sx={{ color: '#f8fafc' }}>Logout</Typography>
                            </MenuItem>
                        </Menu>
                    </Box>
                </Box>

                {/* Main Content */}
                <Container maxWidth="xl" sx={{ flexGrow: 1, py: 4, position: 'relative', zIndex: 1 }}>
                    {/* Hero Section */}
                    <Fade in={mounted} timeout={1000}>
                        <Box sx={{ textAlign: 'center', mb: 6 }}>
                            <Typography variant="h1" sx={{ mb: 2 }}>
                                Welcome back, {auth.user.name}
                            </Typography>
                            <Typography variant="h6" sx={{ color: '#cbd5e1', mb: 4, maxWidth: 600, mx: 'auto' }}>
                                Monitor and manage your campus article platform with real-time insights and comprehensive user management tools.
                            </Typography>
                            <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2 }}>
                                <Chip 
                                    icon={<AutoAwesome />}
                                    label="System Active"
                                    sx={{ 
                                        backgroundColor: alpha('#10b981', 0.2), 
                                        color: '#10b981',
                                        fontWeight: 'bold'
                                    }} 
                                />
                                <Chip 
                                    icon={<Speed />}
                                    label="Real-time Data"
                                    sx={{ 
                                        backgroundColor: alpha('#06b6d4', 0.2), 
                                        color: '#06b6d4',
                                        fontWeight: 'bold'
                                    }} 
                                />
                            </Box>
                        </Box>
                    </Fade>

                    {/* Statistics Cards */}
                    <Box sx={{ mb: 6 }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
                            <Typography variant="h4" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                                Platform Statistics
                            </Typography>
                            <IconButton 
                                onClick={() => setExpandedStats(!expandedStats)}
                                sx={{ color: '#cbd5e1' }}
                            >
                                {expandedStats ? <ExpandLess /> : <ExpandMore />}
                            </IconButton>
                        </Box>
                        <Collapse in={expandedStats}>
                            <Grid container spacing={3}>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Total Users"
                                        value={stats.total_users}
                                        icon={<People />}
                                        color="#6366f1"
                                        subtitle="Active community members"
                                        trend="+12%"
                                        delay={0}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Students"
                                        value={stats.students}
                                        icon={<Person />}
                                        color="#06b6d4"
                                        subtitle="Content consumers"
                                        trend="+8%"
                                        delay={100}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Writers"
                                        value={stats.writers}
                                        icon={<Edit />}
                                        color="#10b981"
                                        subtitle="Content creators"
                                        trend="+15%"
                                        delay={200}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Editors"
                                        value={stats.editors}
                                        icon={<RateReview />}
                                        color="#f59e0b"
                                        subtitle="Content reviewers"
                                        trend="+5%"
                                        delay={300}
                                    />
                                </Grid>
                            </Grid>
                        </Collapse>
                    </Box>

                    {/* Pending Requests Alert */}
                    {stats.pending_requests > 0 && (
                        <Fade in={mounted} timeout={1500}>
                            <Paper sx={{ 
                                background: 'linear-gradient(135deg, rgba(245, 158, 11, 0.1) 0%, rgba(245, 158, 11, 0.05) 100%)', 
                                border: '1px solid rgba(245, 158, 11, 0.3)',
                                p: 3,
                                mb: 4,
                                borderRadius: 3,
                                backdropFilter: 'blur(20px)'
                            }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                    <Badge badgeContent={stats.pending_requests} color="error">
                                        <Pending sx={{ color: '#f59e0b', fontSize: 32 }} />
                                    </Badge>
                                    <Box sx={{ flex: 1 }}>
                                        <Typography variant="h6" sx={{ color: '#fbbf24', fontWeight: 600 }}>
                                            Action Required: Pending Role Requests
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#fcd34d' }}>
                                            You have {stats.pending_requests} pending role request{stats.pending_requests > 1 ? 's' : ''} to review
                                        </Typography>
                                    </Box>
                                    <Button 
                                        variant="contained"
                                        onClick={handleViewRoleRequests}
                                        sx={{ 
                                            background: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
                                            '&:hover': { background: 'linear-gradient(135deg, #d97706 0%, #b45309 100%)' }
                                        }}
                                    >
                                        Review Now
                                    </Button>
                                </Box>
                            </Paper>
                        </Fade>
                    )}

                    <Grid container spacing={4}>
                        {/* Recent Users */}
                        <Grid item xs={12} md={6}>
                            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
                                <Typography variant="h5" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                                    Recent Users
                                </Typography>
                                <IconButton 
                                    onClick={() => setExpandedUsers(!expandedUsers)}
                                    sx={{ color: '#cbd5e1' }}
                                >
                                    {expandedUsers ? <ExpandLess /> : <ExpandMore />}
                                </IconButton>
                            </Box>
                            <Collapse in={expandedUsers}>
                                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                                    {recentUsers.map((user, index) => (
                                        <UserCard key={user.id} user={user} delay={index * 100} />
                                    ))}
                                </Box>
                            </Collapse>
                        </Grid>

                        {/* Pending Role Requests */}
                        <Grid item xs={12} md={6}>
                            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
                                <Typography variant="h5" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                                    Pending Role Requests
                                </Typography>
                                <IconButton 
                                    onClick={() => setExpandedRequests(!expandedRequests)}
                                    sx={{ color: '#cbd5e1' }}
                                >
                                    {expandedRequests ? <ExpandLess /> : <ExpandMore />}
                                </IconButton>
                            </Box>
                            <Collapse in={expandedRequests}>
                                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                                    {pendingRequests.length > 0 ? (
                                        pendingRequests.map((request, index) => (
                                            <RequestCard key={request.id} request={request} delay={index * 100} />
                                        ))
                                    ) : (
                                        <Fade in={mounted} timeout={2000}>
                                            <Paper sx={{ 
                                                background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                                                border: '1px solid rgba(148, 163, 184, 0.1)',
                                                p: 4,
                                                textAlign: 'center',
                                                borderRadius: 3
                                            }}>
                                                <Assignment sx={{ fontSize: 48, color: '#64748b', mb: 2 }} />
                                                <Typography variant="h6" sx={{ color: '#cbd5e1' }}>
                                                    No pending role requests
                                                </Typography>
                                                <Typography variant="body2" sx={{ color: '#64748b' }}>
                                                    All caught up! Check back later for new requests.
                                                </Typography>
                                            </Paper>
                                        </Fade>
                                    )}
                                </Box>
                            </Collapse>
                        </Grid>
                    </Grid>
                </Container>

                {/* Floating Action Button */}
                <Fab
                    color="primary"
                    sx={{
                        position: 'fixed',
                        bottom: 24,
                        right: 24,
                        background: 'linear-gradient(135deg, #6366f1 0%, #ec4899 100%)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #4f46e5 0%, #db2777 100%)',
                        }
                    }}
                    onClick={handleViewUsers}
                >
                    <People />
                </Fab>

                {/* Global Styles for Animations */}
                <style jsx>{`
                    @keyframes float {
                        0%, 100% { transform: translateY(0px); }
                        50% { transform: translateY(-20px); }
                    }
                `}</style>
            </Box>
        </React.Fragment>
    );
};

export default AdminDashboard;
