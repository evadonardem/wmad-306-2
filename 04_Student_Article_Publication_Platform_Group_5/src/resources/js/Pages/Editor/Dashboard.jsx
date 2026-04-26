import React, { useState, useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import { useThemeContext } from '@/Context/ThemeContext';
import {
    Typography,
    Box,
    Button,
    Card,
    CardContent,
    CardActions,
    Avatar,
    IconButton,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    Chip,
    Grid,
    Paper,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    TextField,
    List,
    ListItem,
    ListItemText,
    ListItemIcon as MuiListItemIcon,
    Badge,
    Container,
    Fade,
    Slide,
    Zoom,
    Collapse,
    Fab,
    Tooltip,
    Skeleton,
    LinearProgress,
    alpha,
    Tabs,
    Tab
} from '@mui/material';
import BackToDashboard from '@/Components/BackToDashboard';
import ThemeToggle from '@/Components/ThemeToggle';
import {
    RateReview,
    Publish,
    Visibility,
    Person,
    Logout,
    ArrowBack,
    Assignment,
    Edit,
    Menu as MenuIcon,
    TrendingUp,
    Send,
    Create,
    Article,
    Refresh,
    Assessment,
    ExpandMore,
    ExpandLess,
    Timeline,
    Analytics,
    Report,
    CheckCircle,
    Cancel,
    Speed,
    AutoAwesome,
    Lightbulb,
    Grade,
    Schedule,
    Bookmark,
    Share
} from '@mui/icons-material';

const EditorDashboard = ({ pending, needsRevision, published }) => {
    const { mode } = useThemeContext();
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [anchorEl, setAnchorEl] = useState(null);
    const [revisionDialog, setRevisionDialog] = useState(false);
    const [revisionComments, setRevisionComments] = useState('');
    const [selectedFilter, setSelectedFilter] = useState('dashboard');
    const [expandedStats, setExpandedStats] = useState(true);
    const [expandedArticles, setExpandedArticles] = useState(true);
    const [loading, setLoading] = useState(true);
    const [mounted, setMounted] = useState(false);
    const [tabValue, setTabValue] = useState(0);

    const { auth } = usePage().props;

    useEffect(() => {
        setMounted(true);
        setTimeout(() => setLoading(false), 1000);
    }, []);

    // Enhanced Article Card Component
    const ArticleCard = ({ article, type, delay = 0 }) => {
        const getStatusColor = (status) => {
            const statusName = typeof status === 'string' ? status : (status && typeof status === 'object' ? (status.name || status.label || 'unknown') : 'unknown');
            switch(statusName) {
                case 'pending': return '#06b6d4';
                case 'needs_revision': return '#f59e0b';
                case 'published': return '#10b981';
                case 'rejected': return '#ef4444';
                default: return '#64748b';
            }
        };

        const getStatusIcon = (status) => {
            const statusName = typeof status === 'string' ? status : (status && typeof status === 'object' ? (status.name || status.label || 'unknown') : 'unknown');
            switch(statusName) {
                case 'pending': return <Schedule />;
                case 'needs_revision': return <Edit />;
                case 'published': return <CheckCircle />;
                case 'rejected': return <Cancel />;
                default: return <Article />;
            }
        };

        return (
            <Fade in={mounted} style={{ transitionDelay: `${delay}ms` }}>
                <Card sx={{ 
                    background: mode === 'light' ? 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)' : 
                               mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' : 
                               'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                    border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                             mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                             '1px solid rgba(139, 92, 246, 0.2)',
                    position: 'relative',
                    overflow: 'hidden',
                    '&:hover': { 
                        transform: 'translateY(-4px)',
                        border: `1px solid ${alpha(getStatusColor(article.status), 0.3)}`,
                    }
                }}>
                    <CardContent sx={{ pb: 2 }}>
                        <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2 }}>
                            <Avatar sx={{ 
                                backgroundColor: alpha(getStatusColor(article.status), 0.2),
                                color: getStatusColor(article.status),
                                width: 48,
                                height: 48
                            }}>
                                {getStatusIcon(article.status)}
                            </Avatar>
                            <Box sx={{ flex: 1 }}>
                                <Typography variant="h6" sx={{ 
                                    color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                    fontWeight: 600, mb: 1 
                                }}>
                                    {article.title || 'Untitled Article'}
                                </Typography>
                                <Typography variant="body2" sx={{ 
                                    color: mode === 'light' ? '#475569' : 
                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1', mb: 2 
                                }}>
                                    {article.excerpt || 'No excerpt available'}
                                </Typography>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                    <Chip 
                                        label={typeof article.status === 'string' ? article.status : (article.status && typeof article.status === 'object' ? (article.status.name || article.status.label || 'unknown') : 'unknown')}
                                        size="small"
                                        sx={{ 
                                            backgroundColor: alpha(getStatusColor(article.status), 0.2),
                                            color: getStatusColor(article.status),
                                            fontWeight: 'bold',
                                            textTransform: 'capitalize'
                                        }}
                                    />
                                    <Typography variant="caption" sx={{ 
                                        color: mode === 'light' ? '#64748b' : 
                                               mode === 'dark' ? '#94a3b8' : '#94a3b8' 
                                    }}>
                                        By {article.writer?.name || 'Unknown Writer'}
                                    </Typography>
                                </Box>
                                <Typography variant="caption" sx={{ 
                                    color: mode === 'light' ? '#64748b' : 
                                           mode === 'dark' ? '#94a3b8' : '#94a3b8' 
                                }}>
                                    {article.created_at ? `Created ${new Date(article.created_at).toLocaleDateString('en-US', { 
                                        month: 'short', 
                                        day: 'numeric', 
                                        year: 'numeric' 
                                    })}` : 'No date available'}
                                </Typography>
                            </Box>
                        </Box>
                        {article.content && (
                            <Box sx={{ 
                                backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.5)' : 
                                               mode === 'dark' ? 'rgba(248, 250, 252, 0.05)' : 
                                               'rgba(248, 250, 252, 0.05)',
                                border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                         mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                         '1px solid rgba(139, 92, 246, 0.2)',
                                borderRadius: 2,
                                p: 2,
                                maxHeight: 100,
                                overflow: 'hidden'
                            }}>
                                <Typography variant="body2" sx={{ 
                                    color: mode === 'light' ? '#475569' : 
                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                                }}>
                                    {article.content.substring(0, 150)}...
                                </Typography>
                            </Box>
                        )}
                    </CardContent>
                    <CardActions sx={{ gap: 1, px: 2, pb: 2 }}>
                        {type === 'pending' && (
                            <Button 
                                size="small" 
                                variant="contained"
                                startIcon={<RateReview />}
                                onClick={() => handleReviewArticle(article)}
                                sx={{ 
                                    background: mode === 'light' ? 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' : 
                                               mode === 'dark' ? 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' : 
                                               'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)',
                                    '&:hover': { 
                                        background: mode === 'light' ? 'linear-gradient(135deg, #d97706 0%, #b45309 100%)' : 
                                                   mode === 'dark' ? 'linear-gradient(135deg, #d97706 0%, #b45309 100%)' : 
                                                   'linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%)' 
                                    }
                                }}
                            >
                                Review
                            </Button>
                        )}
                        {type === 'needs_revision' && (
                            <Button 
                                size="small" 
                                variant="contained"
                                startIcon={<Edit />}
                                onClick={() => handleRevisionDialog(article)}
                                sx={{ 
                                    background: mode === 'light' ? 'linear-gradient(135deg, #06b6d4 0%, #0891b2 100%)' : 
                                               mode === 'dark' ? 'linear-gradient(135deg, #06b6d4 0%, #0891b2 100%)' : 
                                               'linear-gradient(135deg, #ec4899 0%, #db2777 100%)',
                                    '&:hover': { 
                                        background: mode === 'light' ? 'linear-gradient(135deg, #0891b2 0%, #0e7490 100%)' : 
                                                   mode === 'dark' ? 'linear-gradient(135deg, #0891b2 0%, #0e7490 100%)' : 
                                                   'linear-gradient(135deg, #db2777 0%, #be185d 100%)' 
                                    }
                                }}
                            >
                                Request Revision
                            </Button>
                        )}
                        {type === 'published' && (
                            <Button 
                                size="small" 
                                variant="outlined"
                                startIcon={<Visibility />}
                                onClick={() => handleViewArticle(article)}
                                sx={{ 
                                    borderColor: mode === 'light' ? '#10b981' : 
                                               mode === 'dark' ? '#10b981' : 
                                               '#10b981',
                                    color: mode === 'light' ? '#10b981' : 
                                           mode === 'dark' ? '#10b981' : 
                                           '#10b981',
                                    '&:hover': { 
                                        borderColor: mode === 'light' ? '#059669' : 
                                                   mode === 'dark' ? '#059669' : 
                                                   '#059669', 
                                        color: mode === 'light' ? '#059669' : 
                                               mode === 'dark' ? '#059669' : 
                                               '#059669' 
                                    }
                                }}
                            >
                                View
                            </Button>
                        )}
                        <Button 
                            size="small" 
                            variant="outlined"
                            startIcon={<Share />}
                            onClick={() => handleShareArticle(article)}
                            sx={{ 
                                borderColor: mode === 'light' ? '#64748b' : 
                                           mode === 'dark' ? '#94a3b8' : 
                                           '#94a3b8',
                                color: mode === 'light' ? '#64748b' : 
                                       mode === 'dark' ? '#94a3b8' : 
                                       '#94a3b8'
                            }}
                        >
                            Share
                        </Button>
                    </CardActions>
                </Card>
            </Fade>
        );
    };
    // Enhanced StatCard Component
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

    // Event Handlers
    const handleReviewArticle = (article) => {
        router.get(`/editor/articles/${article.id}/review`);
    };

    const handleRevisionDialog = (article) => {
        setSelectedArticle(article);
        setRevisionDialog(true);
    };

    const handleViewArticle = (article) => {
        router.get(`/articles/${article.id}/view`);
    };

    const handleShareArticle = (article) => {
        if (navigator.share) {
            navigator.share({
                title: article.title,
                text: article.excerpt,
                url: window.location.origin + `/articles/${article.id}`
            });
        } else {
            navigator.clipboard.writeText(window.location.origin + `/articles/${article.id}`);
        }
    };

    const handleMenuClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    const handleLogout = () => {
        router.post('/logout', {}, {
            onFinish: () => {
                handleMenuClose();
            }
        });
    };

    const handleTabChange = (event, newValue) => {
        setTabValue(newValue);
    };

    return (
        <React.Fragment>
            <Head title="Editor Dashboard" />
            
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
                            backgroundColor: 'linear-gradient(135deg, #f59e0b 0%, #06b6d4 100%)',
                            width: 48,
                            height: 48
                        }}>
                            <RateReview />
                        </Avatar>
                        <Box>
                            <Typography variant="h4" sx={{ color: '#f8fafc', fontWeight: 800, letterSpacing: '-0.01em' }}>
                                Editor Dashboard
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                                Article Review & Publishing System
                            </Typography>
                        </Box>
                    </Box>

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <ThemeToggle />
                        <Tooltip title="Pending Review">
                            <Badge badgeContent={pending?.length || 0} color="error">
                                <Button
                                    variant="outlined"
                                    startIcon={<Schedule />}
                                    onClick={() => setTabValue(0)}
                                    sx={{ 
                                        borderColor: '#06b6d4', 
                                        color: '#06b6d4',
                                        '&:hover': { borderColor: '#0891b2', color: '#0891b2' }
                                    }}
                                >
                                    Pending
                                </Button>
                            </Badge>
                        </Tooltip>
                        <Tooltip title="Needs Revision">
                            <Badge badgeContent={needsRevision?.length || 0} color="warning">
                                <Button
                                    variant="outlined"
                                    startIcon={<Edit />}
                                    onClick={() => setTabValue(1)}
                                    sx={{ 
                                        borderColor: '#f59e0b', 
                                        color: '#f59e0b',
                                        '&:hover': { borderColor: '#d97706', color: '#d97706' }
                                    }}
                                >
                                    Revision
                                </Button>
                            </Badge>
                        </Tooltip>
                        <Tooltip title="Published">
                            <Badge badgeContent={published?.length || 0} color="success">
                                <Button
                                    variant="outlined"
                                    startIcon={<CheckCircle />}
                                    onClick={() => setTabValue(2)}
                                    sx={{ 
                                        borderColor: '#10b981', 
                                        color: '#10b981',
                                        '&:hover': { borderColor: '#059669', color: '#059669' }
                                    }}
                                >
                                    Published
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
                                Review, edit, and manage campus content with our comprehensive editorial tools.
                            </Typography>
                            <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2 }}>
                                <Chip 
                                    icon={<AutoAwesome />}
                                    label="Editor Active"
                                    sx={{ 
                                        backgroundColor: alpha('#10b981', 0.2), 
                                        color: '#10b981',
                                        fontWeight: 'bold'
                                    }} 
                                />
                                <Chip 
                                    icon={<Speed />}
                                    label="Real-time Updates"
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
                                Editorial Statistics
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
                                        title="Pending Review"
                                        value={pending?.length || 0}
                                        icon={<Schedule />}
                                        color="#06b6d4"
                                        subtitle="Awaiting your review"
                                        trend={pending?.length > 0 ? `+${pending?.length}` : '0'}
                                        delay={0}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Needs Revision"
                                        value={needsRevision?.length || 0}
                                        icon={<Edit />}
                                        color="#f59e0b"
                                        subtitle="Requires changes"
                                        trend={needsRevision?.length > 0 ? `+${needsRevision?.length}` : '0'}
                                        delay={100}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Published"
                                        value={published?.length || 0}
                                        icon={<CheckCircle />}
                                        color="#10b981"
                                        subtitle="Live articles"
                                        trend={published?.length > 0 ? `+${published?.length}` : '0'}
                                        delay={200}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Total Processed"
                                        value={(pending?.length || 0) + (needsRevision?.length || 0) + (published?.length || 0)}
                                        icon={<Assessment />}
                                        color="#6366f1"
                                        subtitle="All articles handled"
                                        trend="+100%"
                                        delay={300}
                                    />
                                </Grid>
                            </Grid>
                        </Collapse>
                    </Box>

                    {/* Tabs for Article Categories */}
                    <Box sx={{ mb: 4 }}>
                        <Tabs 
                            value={tabValue} 
                            onChange={handleTabChange}
                            sx={{
                                '& .MuiTab-root': {
                                    color: '#cbd5e1',
                                    fontWeight: 600,
                                    textTransform: 'none',
                                    fontSize: '1rem',
                                    '&.Mui-selected': {
                                        color: '#f59e0b',
                                    }
                                },
                                '& .MuiTabs-indicator': {
                                    background: 'linear-gradient(90deg, #f59e0b 0%, #06b6d4 100%)',
                                    height: 3,
                                }
                            }}
                        >
                            <Tab label="Pending Review" />
                            <Tab label="Needs Revision" />
                            <Tab label="Published" />
                        </Tabs>
                    </Box>

                    {/* Article Lists */}
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
                        <Typography variant="h5" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                            {tabValue === 0 ? 'Pending Review' : tabValue === 1 ? 'Needs Revision' : 'Published Articles'}
                        </Typography>
                        <IconButton 
                            onClick={() => setExpandedArticles(!expandedArticles)}
                            sx={{ color: '#cbd5e1' }}
                        >
                            {expandedArticles ? <ExpandLess /> : <ExpandMore />}
                        </IconButton>
                    </Box>
                    <Collapse in={expandedArticles}>
                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                            {tabValue === 0 && pending?.map((article, index) => (
                                <ArticleCard key={article.id} article={article} type="pending" delay={index * 100} />
                            ))}
                            {tabValue === 1 && needsRevision?.map((article, index) => (
                                <ArticleCard key={article.id} article={article} type="needs_revision" delay={index * 100} />
                            ))}
                            {tabValue === 2 && published?.map((article, index) => (
                                <ArticleCard key={article.id} article={article} type="published" delay={index * 100} />
                            ))}
                            {((tabValue === 0 && (!pending || pending.length === 0)) ||
                              (tabValue === 1 && (!needsRevision || needsRevision.length === 0)) ||
                              (tabValue === 2 && (!published || published.length === 0))) && (
                                <Fade in={mounted} timeout={2000}>
                                    <Paper sx={{ 
                                        background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                                        border: '1px solid rgba(148, 163, 184, 0.1)',
                                        p: 4,
                                        textAlign: 'center',
                                        borderRadius: 3
                                    }}>
                                        <Article sx={{ fontSize: 48, color: '#64748b', mb: 2 }} />
                                        <Typography variant="h6" sx={{ color: '#cbd5e1' }}>
                                            No articles found
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#64748b' }}>
                                            {tabValue === 0 ? 'No articles pending review.' : 
                                             tabValue === 1 ? 'No articles need revision.' : 
                                             'No published articles yet.'}
                                        </Typography>
                                    </Paper>
                                </Fade>
                            )}
                        </Box>
                    </Collapse>
                </Container>

                {/* Floating Action Button */}
                <Fab
                    color="primary"
                    sx={{
                        position: 'fixed',
                        bottom: 24,
                        right: 24,
                        background: 'linear-gradient(135deg, #f59e0b 0%, #06b6d4 100%)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #d97706 0%, #0891b2 100%)',
                        }
                    }}
                    onClick={() => setTabValue(0)}
                >
                    <RateReview />
                </Fab>

                {/* Revision Dialog */}
                <Dialog open={revisionDialog} onClose={() => setRevisionDialog(false)} maxWidth="md" fullWidth>
                    <DialogTitle sx={{ color: '#f8fafc', backgroundColor: '#151932' }}>
                        Request Revision
                    </DialogTitle>
                    <DialogContent sx={{ backgroundColor: '#151932' }}>
                        <TextField
                            fullWidth
                            multiline
                            rows={4}
                            label="Revision Comments"
                            value={revisionComments}
                            onChange={(e) => setRevisionComments(e.target.value)}
                            sx={{ mt: 2 }}
                        />
                    </DialogContent>
                    <DialogActions sx={{ backgroundColor: '#151932' }}>
                        <Button onClick={() => setRevisionDialog(false)}>Cancel</Button>
                        <Button 
                            variant="contained" 
                            onClick={() => {
                                if (selectedArticle && revisionComments) {
                                    router.post(`/editor/articles/${selectedArticle.id}/revision`, 
                                        { comments: revisionComments },
                                        { onSuccess: () => {
                                            setRevisionDialog(false);
                                            setRevisionComments('');
                                            setSelectedArticle(null);
                                        }}
                                    );
                                }
                            }}
                        >
                            Send Revision Request
                        </Button>
                    </DialogActions>
                </Dialog>

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

export default EditorDashboard;
