import React, { useState, useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import { useThemeContext } from '@/Context/ThemeContext';
import {
    Typography,
    Box,
    Paper,
    Button,
    Card,
    CardContent,
    CardActions,
    Avatar,
    Chip,
    IconButton,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    Grid,
    List,
    ListItem,
    ListItemText,
    Toolbar,
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
import { ThemeProvider, createTheme } from '@mui/material/styles';
import {
    Person,
    Logout,
    Menu as MenuIcon,
    Edit,
    Visibility,
    RateReview,
    Article,
    Comment,
    TrendingUp,
    Favorite,
    FavoriteBorder,
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
    Share,
    School,
    Book,
    Star,
    ThumbUp
} from '@mui/icons-material';

const StudentDashboard = ({ publishedArticles, myComments, stats, favorites }) => {
    const { mode } = useThemeContext();
    const [anchorEl, setAnchorEl] = useState(null);
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

    const theme = createTheme({
        palette: {
            mode: 'dark',
            background: {
                default: '#0a0e27',
                paper: '#151932',
            },
            primary: {
                main: '#06b6d4',
                light: '#22d3ee',
                dark: '#0891b2',
            },
            secondary: {
                main: '#10b981',
                light: '#34d399',
                dark: '#059669',
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
                main: '#6366f1',
                light: '#818cf8',
                dark: '#4f46e5',
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
                background: 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)',
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
                            boxShadow: '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 30px rgba(6, 182, 212, 0.1)',
                            border: '1px solid rgba(6, 182, 212, 0.2)',
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
                        background: 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)',
                        boxShadow: '0 4px 14px 0 rgba(6, 182, 212, 0.39)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #0891b2 0%, #059669 100%)',
                            transform: 'translateY(-2px)',
                            boxShadow: '0 6px 20px 0 rgba(6, 182, 212, 0.5)',
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

    // Enhanced Article Card Component
    const ArticleCard = ({ article, type, delay = 0 }) => {
        const handleViewArticle = () => {
            router.get(`/student/articles/${article.id}`);
        };

        const handleToggleFavorite = () => {
            router.post(`/student/articles/${article.id}/favorite`, {}, {
                onSuccess: () => {
                    router.reload();
                }
            });
        };

        return (
            <Fade in={mounted} style={{ transitionDelay: `${delay}ms` }}>
                <Card sx={{ 
                    background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                    border: '1px solid rgba(148, 163, 184, 0.1)',
                    position: 'relative',
                    overflow: 'hidden',
                    '&:hover': { 
                        transform: 'translateY(-4px)',
                        border: '1px solid rgba(6, 182, 212, 0.3)',
                    }
                }}>
                    <CardContent sx={{ pb: 2 }}>
                        <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2 }}>
                            <Avatar sx={{ 
                                backgroundColor: alpha('#06b6d4', 0.2),
                                color: '#06b6d4',
                                width: 48,
                                height: 48
                            }}>
                                <Article />
                            </Avatar>
                            <Box sx={{ flex: 1 }}>
                                <Typography variant="h6" sx={{ color: '#f8fafc', fontWeight: 600, mb: 1 }}>
                                    {article.title || 'Untitled Article'}
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#cbd5e1', mb: 2 }}>
                                    {article.excerpt || 'No excerpt available'}
                                </Typography>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                    <Typography variant="caption" sx={{ color: '#64748b' }}>
                                        By {article.writer?.name || 'Unknown Writer'}
                                    </Typography>
                                    <Typography variant="caption" sx={{ color: '#64748b' }}>
                                        •
                                    </Typography>
                                    <Typography variant="caption" sx={{ color: '#64748b' }}>
                                        {article.created_at ? new Date(article.created_at).toLocaleDateString('en-US', { 
                                            month: 'short', 
                                            day: 'numeric', 
                                            year: 'numeric' 
                                        }) : 'No date'}
                                    </Typography>
                                </Box>
                                {article.category && typeof article.category === 'object' && (article.category.name || article.category.label) && (
                                    <Chip 
                                        label={article.category.name || article.category.label || 'Uncategorized'}
                                        size="small"
                                        sx={{ 
                                            backgroundColor: alpha('#10b981', 0.2),
                                            color: '#10b981',
                                            fontWeight: 'bold'
                                        }}
                                    />
                                )}
                            </Box>
                            <IconButton 
                                onClick={handleToggleFavorite}
                                sx={{ color: favorites?.some(fav => fav.article_id === article.id) ? '#ef4444' : '#64748b' }}
                            >
                                {favorites?.some(fav => fav.article_id === article.id) ? <Favorite /> : <FavoriteBorder />}
                            </IconButton>
                        </Box>
                        {article.content && (
                            <Box sx={{ 
                                backgroundColor: alpha('#f8fafc', 0.05),
                                border: '1px solid rgba(148, 163, 184, 0.1)',
                                borderRadius: 2,
                                p: 2,
                                maxHeight: 100,
                                overflow: 'hidden'
                            }}>
                                <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                                    {article.content.substring(0, 150)}...
                                </Typography>
                            </Box>
                        )}
                    </CardContent>
                    <CardActions sx={{ gap: 1, px: 2, pb: 2 }}>
                        <Button 
                            size="small" 
                            variant="contained"
                            startIcon={<Visibility />}
                            onClick={handleViewArticle}
                            sx={{ 
                                background: 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)',
                                '&:hover': { background: 'linear-gradient(135deg, #0891b2 0%, #059669 100%)' }
                            }}
                        >
                            Read More
                        </Button>
                        <Button 
                            size="small" 
                            variant="outlined"
                            startIcon={<Share />}
                            onClick={() => {
                                if (navigator.share) {
                                    navigator.share({
                                        title: article.title,
                                        text: article.excerpt,
                                        url: window.location.origin + `/student/articles/${article.id}`
                                    });
                                } else {
                                    navigator.clipboard.writeText(window.location.origin + `/student/articles/${article.id}`);
                                }
                            }}
                        >
                            Share
                        </Button>
                    </CardActions>
                </Card>
            </Fade>
        );
    };

    // Event Handlers
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
            <Head title="Student Dashboard" />
            
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
                            backgroundColor: 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)',
                            width: 48,
                            height: 48
                        }}>
                            <School />
                        </Avatar>
                        <Box>
                            <Typography variant="h4" sx={{ color: '#f8fafc', fontWeight: 800, letterSpacing: '-0.01em' }}>
                                Student Dashboard
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#cbd5e1' }}>
                                Campus Article Reader
                            </Typography>
                        </Box>
                    </Box>

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Tooltip title="Published Articles">
                            <Button
                                variant="outlined"
                                startIcon={<Book />}
                                onClick={() => setTabValue(0)}
                                sx={{ 
                                    borderColor: '#06b6d4', 
                                    color: '#06b6d4',
                                    '&:hover': { borderColor: '#0891b2', color: '#0891b2' }
                                }}
                            >
                                Articles
                            </Button>
                        </Tooltip>
                        <Tooltip title="My Comments">
                            <Button
                                variant="outlined"
                                startIcon={<Comment />}
                                onClick={() => setTabValue(1)}
                                sx={{ 
                                    borderColor: '#10b981', 
                                    color: '#10b981',
                                    '&:hover': { borderColor: '#059669', color: '#059669' }
                                }}
                            >
                                Comments
                            </Button>
                        </Tooltip>
                        <Tooltip title="Favorites">
                            <Button
                                variant="outlined"
                                startIcon={<Favorite />}
                                onClick={() => setTabValue(2)}
                                sx={{ 
                                    borderColor: '#ef4444', 
                                    color: '#ef4444',
                                    '&:hover': { borderColor: '#dc2626', color: '#dc2626' }
                                }}
                            >
                                Favorites
                            </Button>
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
                                Discover and engage with campus articles from our talented writers and editors.
                            </Typography>
                            <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2 }}>
                                <Chip 
                                    icon={<AutoAwesome />}
                                    label="Student Active"
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
                                Reading Statistics
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
                                        title="Articles Read"
                                        value={stats?.articles_read || 0}
                                        icon={<Book />}
                                        color="#06b6d4"
                                        subtitle="Campus articles explored"
                                        trend={stats?.articles_read > 0 ? `+${stats?.articles_read}` : '0'}
                                        delay={0}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Comments Made"
                                        value={stats?.comments_made || 0}
                                        icon={<Comment />}
                                        color="#10b981"
                                        subtitle="Engagement with content"
                                        trend={stats?.comments_made > 0 ? `+${stats?.comments_made}` : '0'}
                                        delay={100}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Favorites"
                                        value={favorites?.length || 0}
                                        icon={<Favorite />}
                                        color="#ef4444"
                                        subtitle="Saved articles"
                                        trend={favorites?.length > 0 ? `+${favorites?.length}` : '0'}
                                        delay={200}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Reading Time"
                                        value={`${stats?.reading_time || 0}h`}
                                        icon={<Schedule />}
                                        color="#f59e0b"
                                        subtitle="Total reading duration"
                                        trend={stats?.reading_time > 0 ? `+${stats?.reading_time}h` : '0h'}
                                        delay={300}
                                    />
                                </Grid>
                            </Grid>
                        </Collapse>
                    </Box>

                    {/* Tabs for Content Categories */}
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
                                        color: '#06b6d4',
                                    }
                                },
                                '& .MuiTabs-indicator': {
                                    background: 'linear-gradient(90deg, #06b6d4 0%, #10b981 100%)',
                                    height: 3,
                                }
                            }}
                        >
                            <Tab label="Published Articles" />
                            <Tab label="My Comments" />
                            <Tab label="Favorites" />
                        </Tabs>
                    </Box>

                    {/* Content Lists */}
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
                        <Typography variant="h5" sx={{ color: '#f8fafc', fontWeight: 700 }}>
                            {tabValue === 0 ? 'Published Articles' : tabValue === 1 ? 'My Comments' : 'My Favorites'}
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
                            {tabValue === 0 && publishedArticles?.map((article, index) => (
                                <ArticleCard key={article.id} article={article} type="published" delay={index * 100} />
                            ))}
                            {tabValue === 1 && myComments?.map((comment, index) => (
                                <Fade in={mounted} style={{ transitionDelay: `${index * 100}ms` }} key={comment.id}>
                                    <Card sx={{ 
                                        background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                                        border: '1px solid rgba(148, 163, 184, 0.1)',
                                        '&:hover': { 
                                            transform: 'translateY(-4px)',
                                            border: '1px solid rgba(16, 185, 129, 0.3)',
                                        }
                                    }}>
                                        <CardContent>
                                            <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2 }}>
                                                <Avatar sx={{ 
                                                    backgroundColor: alpha('#10b981', 0.2),
                                                    color: '#10b981',
                                                    width: 48,
                                                    height: 48
                                                }}>
                                                    <Comment />
                                                </Avatar>
                                                <Box sx={{ flex: 1 }}>
                                                    <Typography variant="h6" sx={{ color: '#f8fafc', fontWeight: 600, mb: 1 }}>
                                                        {comment.article?.title || 'Unknown Article'}
                                                    </Typography>
                                                    <Typography variant="body2" sx={{ color: '#cbd5e1', mb: 2 }}>
                                                        "{comment.content}"
                                                    </Typography>
                                                    <Typography variant="caption" sx={{ color: '#64748b' }}>
                                                        {comment.created_at ? `Commented ${new Date(comment.created_at).toLocaleDateString('en-US', { 
                                                            month: 'short', 
                                                            day: 'numeric', 
                                                            year: 'numeric' 
                                                        })}` : 'No date'}
                                                    </Typography>
                                                </Box>
                                            </Box>
                                        </CardContent>
                                    </Card>
                                </Fade>
                            ))}
                            {tabValue === 2 && favorites?.map((favorite, index) => (
                                <ArticleCard key={favorite.id} article={favorite.article} type="favorite" delay={index * 100} />
                            ))}
                            {((tabValue === 0 && (!publishedArticles || publishedArticles.length === 0)) ||
                              (tabValue === 1 && (!myComments || myComments.length === 0)) ||
                              (tabValue === 2 && (!favorites || favorites.length === 0))) && (
                                <Fade in={mounted} timeout={2000}>
                                    <Paper sx={{ 
                                        background: 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                                        border: '1px solid rgba(148, 163, 184, 0.1)',
                                        p: 4,
                                        textAlign: 'center',
                                        borderRadius: 3
                                    }}>
                                        <Book sx={{ fontSize: 48, color: '#64748b', mb: 2 }} />
                                        <Typography variant="h6" sx={{ color: '#cbd5e1' }}>
                                            No content found
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#64748b' }}>
                                            {tabValue === 0 ? 'No published articles available.' : 
                                             tabValue === 1 ? 'No comments made yet.' : 
                                             'No favorite articles saved yet.'}
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
                        background: 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #0891b2 0%, #059669 100%)',
                        }
                    }}
                    onClick={() => setTabValue(0)}
                >
                    <Book />
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

export default StudentDashboard;
