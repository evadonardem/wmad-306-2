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
    Toolbar,
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
import {
    RateReview,
    Publish,
    Visibility,
    Person,
    Logout,
    Assignment,
    Edit,
    Menu as MenuIcon,
    TrendingUp,
    Send,
    Create,
    Article,
    Refresh,
    Add,
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
    Share,
    Star,
    ThumbUp,
    EditNote,
    Description,
    Title,
    Subject
} from '@mui/icons-material';
import BackToDashboard from '@/Components/BackToDashboard';
import ThemeToggle from '@/Components/ThemeToggle';

const WriterDashboard = ({ drafts, submitted, needsRevision, published }) => {
    const { mode } = useThemeContext();
    const [anchorEl, setAnchorEl] = useState(null);
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [revisionDialog, setRevisionDialog] = useState(false);
    const [revisionComments, setRevisionComments] = useState('');
    const [selectedFilter, setSelectedFilter] = useState('dashboard');
    const [expandedStats, setExpandedStats] = useState(true);
    const [expandedArticles, setExpandedArticles] = useState(true);
    const [loading, setLoading] = useState(true);
    const [mounted, setMounted] = useState(false);
    const [tabValue, setTabValue] = useState(0);

    const { flash, auth } = usePage().props;

    useEffect(() => {
        setMounted(true);
        setTimeout(() => setLoading(false), 1000);
    }, []);

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
        const getStatusColor = (status) => {
            if (!status) return '#64748b';
            const statusName = typeof status === 'string' ? status : status?.name;
            switch(statusName) {
                case 'draft': return '#64748b';
                case 'submitted': return '#06b6d4';
                case 'needs_revision': return '#f59e0b';
                case 'published': return '#10b981';
                case 'rejected': return '#ef4444';
                default: return '#64748b';
            }
        };

        const getStatusIcon = (status) => {
            if (!status) return <Article />;
            const statusName = typeof status === 'string' ? status : status?.name;
            switch(statusName) {
                case 'draft': return <EditNote />;
                case 'submitted': return <Send />;
                case 'needs_revision': return <Edit />;
                case 'published': return <CheckCircle />;
                case 'rejected': return <Cancel />;
                default: return <Article />;
            }
        };

        const handleEditArticle = () => {
            if (article && article.id) {
                router.get(`/writer/articles/${article.id}/edit`);
            }
        };

        const handleViewArticle = () => {
            if (article && article.id) {
                router.get(`/writer/articles/${article.id}`);
            }
        };

        const handleSubmitArticle = () => {
            if (article && article.id) {
                router.post(`/writer/articles/${article.id}/submit`, {}, {
                    onSuccess: () => {
                        router.reload();
                    }
                });
            }
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
                                    color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
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
                                        {article.created_at ? `Created ${new Date(article.created_at).toLocaleDateString('en-US', { 
                                            month: 'short', 
                                            day: 'numeric', 
                                            year: 'numeric' 
                                        })}` : 'No date'}
                                    </Typography>
                                </Box>
                                {article.category && typeof article.category === 'object' && (article.category.name || article.category.label) && (
                                    <Chip 
                                        label={article.category.name || article.category.label || 'Uncategorized'}
                                        size="small"
                                        sx={{ 
                                            backgroundColor: mode === 'light' ? 'rgba(16, 185, 129, 0.1)' : 
                                                           mode === 'dark' ? 'rgba(16, 185, 129, 0.2)' : 
                                                           'rgba(139, 92, 246, 0.2)',
                                            color: mode === 'light' ? '#10b981' : 
                                                   mode === 'dark' ? '#10b981' : 
                                                   '#8b5cf6',
                                            fontWeight: 'bold'
                                        }}
                                    />
                                )}
                            </Box>
                        </Box>
                        {article.content && typeof article.content === 'string' && (
                            <Box sx={{ 
                                backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.8)' : 
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
                                    color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                                }}>
                                    {article.content.length > 150 ? `${article.content.substring(0, 150)}...` : article.content}
                                </Typography>
                            </Box>
                        )}
                    </CardContent>
                    <CardActions sx={{ gap: 1, px: 2, pb: 2 }}>
                        {type === 'draft' && (
                            <>
                                <Button 
                                    size="small" 
                                    variant="contained"
                                    startIcon={<Edit />}
                                    onClick={handleEditArticle}
                                    sx={{ 
                                        background: 'linear-gradient(135deg, #10b981 0%, #f59e0b 100%)',
                                        '&:hover': { background: 'linear-gradient(135deg, #059669 0%, #d97706 100%)' }
                                    }}
                                >
                                    Edit
                                </Button>
                                <Button 
                                    size="small" 
                                    variant="outlined"
                                    startIcon={<Send />}
                                    onClick={handleSubmitArticle}
                                    sx={{ 
                                        borderColor: '#06b6d4',
                                        color: '#06b6d4',
                                        '&:hover': { borderColor: '#0891b2', color: '#0891b2' }
                                    }}
                                >
                                    Submit
                                </Button>
                            </>
                        )}
                        {type === 'submitted' && (
                            <Button 
                                size="small" 
                                variant="outlined"
                                startIcon={<Visibility />}
                                onClick={handleViewArticle}
                                sx={{ 
                                    borderColor: '#06b6d4',
                                    color: '#06b6d4',
                                    '&:hover': { borderColor: '#0891b2', color: '#0891b2' }
                                }}
                            >
                                View
                            </Button>
                        )}
                        {type === 'needs_revision' && (
                            <Button 
                                size="small" 
                                variant="contained"
                                startIcon={<Edit />}
                                onClick={handleEditArticle}
                                sx={{ 
                                    background: 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
                                    '&:hover': { background: 'linear-gradient(135deg, #d97706 0%, #b45309 100%)' }
                                }}
                            >
                                Revise
                            </Button>
                        )}
                        {type === 'published' && (
                            <Button 
                                size="small" 
                                variant="outlined"
                                startIcon={<Visibility />}
                                onClick={handleViewArticle}
                                sx={{ 
                                    borderColor: '#10b981',
                                    color: '#10b981',
                                    '&:hover': { borderColor: '#059669', color: '#059669' }
                                }}
                            >
                                View
                            </Button>
                        )}
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
        <>
            <Head title="Writer Dashboard" />
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
                    background: mode === 'light' ? 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)' :
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
                            backgroundColor: mode === 'light' ? 'linear-gradient(135deg, #3b82f6 0%, #10b981 100%)' :
                                           mode === 'dark' ? 'linear-gradient(135deg, #10b981 0%, #f59e0b 100%)' :
                                           'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                            width: 48,
                            height: 48
                        }}>
                            <EditNote />
                        </Avatar>
                        <Box>
                            <Typography variant="h4" sx={{ 
                                color: mode === 'light' ? '#1e293b' : 
                                       mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                fontWeight: 800, 
                                letterSpacing: '-0.01em' 
                            }}>
                                Writer Dashboard
                            </Typography>
                            <Typography variant="body2" sx={{ 
                                color: mode === 'light' ? '#475569' : 
                                       mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                            }}>
                                Content Creation & Management
                            </Typography>
                        </Box>
                    </Box>

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <ThemeToggle />
                        <Tooltip title="Create New Article">
                            <Button
                                variant="contained"
                                startIcon={<Add />}
                                onClick={() => router.get('/writer/articles/create')}
                                sx={{ 
                                    background: mode === 'light' ? 'linear-gradient(135deg, #3b82f6 0%, #10b981 100%)' :
                                               mode === 'dark' ? 'linear-gradient(135deg, #10b981 0%, #f59e0b 100%)' :
                                               'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                    '&:hover': { 
                                        background: mode === 'light' ? 'linear-gradient(135deg, #2563eb 0%, #059669 100%)' :
                                                   mode === 'dark' ? 'linear-gradient(135deg, #059669 0%, #d97706 100%)' :
                                                   'linear-gradient(135deg, #7c3aed 0%, #db2777 100%)' 
                                    }
                                }}
                            >
                                New Article
                            </Button>
                        </Tooltip>
                        <Tooltip title="Drafts">
                            <Button
                                variant="outlined"
                                startIcon={<EditNote />}
                                onClick={() => setTabValue(0)}
                                sx={{ 
                                    borderColor: mode === 'light' ? '#64748b' : 
                                               mode === 'dark' ? '#64748b' : '#8b5cf6', 
                                    color: mode === 'light' ? '#64748b' : 
                                          mode === 'dark' ? '#64748b' : '#8b5cf6',
                                    '&:hover': { 
                                        borderColor: mode === 'light' ? '#475569' : 
                                                   mode === 'dark' ? '#475569' : '#7c3aed', 
                                        color: mode === 'light' ? '#475569' : 
                                              mode === 'dark' ? '#475569' : '#7c3aed' 
                                    }
                                }}
                            >
                                Drafts
                            </Button>
                        </Tooltip>
                        <Tooltip title="Menu">
                            <IconButton onClick={handleMenuClick} sx={{ 
                                color: mode === 'light' ? '#3b82f6' : 
                                       mode === 'dark' ? '#f8fafc' : '#8b5cf6' 
                            }}>
                                <MenuIcon />
                            </IconButton>
                        </Tooltip>
                        <Menu
                            anchorEl={anchorEl}
                            open={Boolean(anchorEl)}
                            onClose={handleMenuClose}
                            PaperProps={{
                                sx: {
                                    background: mode === 'light' ? '#ffffff' :
                                               mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' :
                                               'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                                    backdropFilter: 'blur(20px)',
                                    border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' :
                                               mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' :
                                               '1px solid rgba(139, 92, 246, 0.2)',
                                }
                            }}
                        >
                            <MenuItem onClick={handleLogout}>
                                <ListItemIcon><Logout sx={{ color: '#ef4444' }} /></ListItemIcon>
                                <Typography sx={{ 
                                    color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#f8fafc' : '#f8fafc' 
                                }}>Logout</Typography>
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
                                Create, edit, and manage your campus articles with our comprehensive writing tools.
                            </Typography>
                            <Box sx={{ display: 'flex', justifyContent: 'center', gap: 2 }}>
                                <Chip 
                                    icon={<AutoAwesome />}
                                    label="Writer Active"
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
                                        backgroundColor: alpha('#f59e0b', 0.2), 
                                        color: '#f59e0b',
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
                                Writing Statistics
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
                                        title="Drafts"
                                        value={drafts?.length || 0}
                                        icon={<EditNote />}
                                        color="#64748b"
                                        subtitle="Articles in progress"
                                        trend={drafts?.length > 0 ? `+${drafts?.length}` : '0'}
                                        delay={0}
                                    />
                                </Grid>
                                <Grid item xs={12} sm={6} md={3}>
                                    <StatCard
                                        title="Submitted"
                                        value={submitted?.length || 0}
                                        icon={<Send />}
                                        color="#06b6d4"
                                        subtitle="Under review"
                                        trend={submitted?.length > 0 ? `+${submitted?.length}` : '0'}
                                        delay={100}
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
                                        delay={200}
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
                                        color: '#10b981',
                                    }
                                },
                                '& .MuiTabs-indicator': {
                                    background: 'linear-gradient(90deg, #10b981 0%, #f59e0b 100%)',
                                    height: 3,
                                }
                            }}
                        >
                            <Tab label="Drafts" />
                            <Tab label="Submitted" />
                            <Tab label="Needs Revision" />
                            <Tab label="Published" />
                        </Tabs>
                    </Box>

                    {/* Article Lists */}
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
                        <Typography variant="h5" sx={{ 
                            color: mode === 'light' ? '#1e293b' : 
                                   mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                            fontWeight: 700 
                        }}>
                            {tabValue === 0 ? 'Drafts' : tabValue === 1 ? 'Submitted Articles' : tabValue === 2 ? 'Needs Revision' : 'Published Articles'}
                        </Typography>
                        <IconButton 
                            onClick={() => setExpandedArticles(!expandedArticles)}
                            sx={{ 
                                color: mode === 'light' ? '#64748b' : 
                                       mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                            }}
                        >
                            {expandedArticles ? <ExpandLess /> : <ExpandMore />}
                        </IconButton>
                    </Box>
                    <Collapse in={expandedArticles}>
                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                            {tabValue === 0 && drafts?.filter(article => article && article.id).map((article, index) => (
                                <ArticleCard key={article.id || `draft-${index}`} article={article} type="draft" delay={index * 100} />
                            ))}
                            {tabValue === 1 && submitted?.filter(article => article && article.id).map((article, index) => (
                                <ArticleCard key={article.id || `submitted-${index}`} article={article} type="submitted" delay={index * 100} />
                            ))}
                            {tabValue === 2 && needsRevision?.filter(article => article && article.id).map((article, index) => (
                                <ArticleCard key={article.id || `revision-${index}`} article={article} type="needs_revision" delay={index * 100} />
                            ))}
                            {tabValue === 3 && published?.filter(article => article && article.id).map((article, index) => (
                                <ArticleCard key={article.id || `published-${index}`} article={article} type="published" delay={index * 100} />
                            ))}
                            {((tabValue === 0 && (!drafts || drafts.length === 0)) ||
                              (tabValue === 1 && (!submitted || submitted.length === 0)) ||
                              (tabValue === 2 && (!needsRevision || needsRevision.length === 0)) ||
                              (tabValue === 3 && (!published || published.length === 0))) && (
                                <Fade in={mounted} timeout={2000}>
                                    <Paper sx={{ 
                                        background: mode === 'light' ? 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)' : 
                                                   mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' : 
                                                   'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                                        border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                                 mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                                 '1px solid rgba(139, 92, 246, 0.2)',
                                        p: 4,
                                        textAlign: 'center',
                                        borderRadius: 3
                                    }}>
                                        <EditNote sx={{ 
                                            fontSize: 48, 
                                            color: mode === 'light' ? '#64748b' : 
                                                   mode === 'dark' ? '#64748b' : '#8b5cf6', 
                                            mb: 2 
                                        }} />
                                        <Typography variant="h6" sx={{ 
                                            color: mode === 'light' ? '#475569' : 
                                                   mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                                        }}>
                                            No articles found
                                        </Typography>
                                        <Typography variant="body2" sx={{ 
                                            color: mode === 'light' ? '#64748b' : 
                                                   mode === 'dark' ? '#94a3b8' : '#94a3b8' 
                                        }}>
                                            {tabValue === 0 ? 'No drafts yet. Start creating your first article!' : 
                                             tabValue === 1 ? 'No articles submitted for review.' : 
                                             tabValue === 2 ? 'No articles need revision.' : 
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
                        background: 'linear-gradient(135deg, #10b981 0%, #f59e0b 100%)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #059669 0%, #d97706 100%)',
                        }
                    }}
                    onClick={() => router.get('/writer/articles/create')}
                >
                    <Add />
                </Fab>
            </Box>
        </>
    );
};

export default WriterDashboard;
