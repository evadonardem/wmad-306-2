import React, { useState, useEffect } from 'react';
import { Inertia } from '@inertiajs/inertia';
import axios from 'axios';
import {
    Box,
    Container,
    Typography,
    Button,
    Card,
    CardContent,
    CardActions,
    Grid,
    Chip,
    AppBar,
    Toolbar,
    Drawer,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    Fade,
    Select,
    MenuItem,
    Menu,
    Avatar,
    IconButton,
    Divider,
    Badge,
    LinearProgress,
    Paper,
    Stack,
    alpha,
    Tooltip,
    Zoom,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    ListItemAvatar,
    TextField,
    InputAdornment,
    Fab,
    useTheme,
    useMediaQuery,
} from '@mui/material';
import {
    AccountCircle as AccountCircleIcon,
    Logout as LogoutIcon,
    SwapHoriz as SwapHorizIcon,
    Notifications as NotificationsIcon,
    NotificationsNone as NotificationsNoneIcon,
    Home as HomeIcon,
    Reviews as ReviewsIcon,
    PublishedWithChanges as PublishedWithChangesIcon,
    Visibility as VisibilityIcon,
    HourglassEmpty as HourglassEmptyIcon,
    Dashboard as DashboardIcon,
    EditNote as EditNoteIcon,
    AssignmentTurnedIn as AssignmentTurnedInIcon,
    RateReview as RateReviewIcon,
    Timeline as TimelineIcon,
    TrendingUp as TrendingUpIcon,
    Star as StarIcon,
    Warning as WarningIcon,
    AutoStories as AutoStoriesIcon,
    MenuBook as MenuBookIcon,
    Psychology as PsychologyIcon,
    EmojiEvents as EmojiEventsIcon,
    PlaylistAddCheck as PlaylistAddCheckIcon,
    Comment as CommentIcon,
    Edit as EditIcon,
    Delete as DeleteIcon,
    CheckCircle as CheckCircleIcon,
    Cancel as CancelIcon,
    Whatshot as FireIcon,
    EmojiEmotions as EmojiIcon,
    RocketLaunch as RocketLaunchIcon,
    Lightbulb as LightbulbIcon,
    School as SchoolIcon,
    Brush as BrushIcon,
    Forest as ForestIcon,
    WbSunny as SunIcon,
    Nightlight as MoonIcon,
    CalendarToday as CalendarTodayIcon,
    Schedule as ScheduleIcon,
    Search as SearchIcon,
    Close
} from '@mui/icons-material';

const STATUS_COLORS = {
    submitted: { 
        bg: '#F3E8FF', 
        text: '#7E3AF2', 
        border: '#E0D4FC',
        gradient: 'linear-gradient(135deg, #F3E8FF 0%, #E0D4FC 100%)',
        icon: <EditNoteIcon />,
        emoji: '📝'
    },
    needs_revision: { 
        bg: '#FFF3E0', 
        text: '#F97316', 
        border: '#FFE4B5',
        gradient: 'linear-gradient(135deg, #FFF3E0 0%, #FFE4B5 100%)',
        icon: <WarningIcon />,
        emoji: '🔄'
    },
    published: { 
        bg: '#E6F7E6', 
        text: '#10B981', 
        border: '#C3E6CB',
        gradient: 'linear-gradient(135deg, #E6F7E6 0%, #C3E6CB 100%)',
        icon: <CheckCircleIcon />,
        emoji: '🌟'
    },
    under_review: {
        bg: '#E0F2FE',
        text: '#3B82F6',
        border: '#B8E0FE',
        gradient: 'linear-gradient(135deg, #E0F2FE 0%, #B8E0FE 100%)',
        icon: <RateReviewIcon />,
        emoji: '🔍'
    }
};

const PRIORITY_COLORS = {
    high: { bg: '#FEF2F2', text: '#EF4444', border: '#FECACA', emoji: '🔥' },
    medium: { bg: '#FFFBEB', text: '#F59E0B', border: '#FDE68A', emoji: '⚡' },
    low: { bg: '#ECFDF5', text: '#10B981', border: '#A7F3D0', emoji: '💧' }
};

const DRAWER_WIDTH = 300;
const THEME = {
    primary: '#6366F1',      // Indigo
    primaryLight: '#818CF8',
    primaryDark: '#4F46E5',
    secondary: '#8B5CF6',    // Purple
    secondaryLight: '#A78BFA',
    secondaryDark: '#7C3AED',
    accent: '#FBBF24',       // Amber
    success: '#10B981',
    warning: '#F59E0B',
    error: '#EF4444',
    purple: '#9B6B9E',
    pink: '#FF8A80',
    surface: '#FFFFFF',
    background: '#F9FAFB',
    text: {
        primary: '#1F2937',
        secondary: '#6B7280',
        light: '#9CA3AF'
    },
    gradient: {
        primary: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)',
        secondary: 'linear-gradient(135deg, #8B5CF6 0%, #EC4899 100%)',
        success: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
        warning: 'linear-gradient(135deg, #F59E0B 0%, #D97706 100%)',
        sunset: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)'
    },
    shadows: {
        small: '2px 2px 0 rgba(0,0,0,0.1)',
        medium: '4px 4px 0 rgba(0,0,0,0.1)',
        large: '8px 8px 0 rgba(0,0,0,0.1)',
        hover: '12px 12px 0 rgba(0,0,0,0.1)'
    }
};

export default function Dashboard({ pending, published, categories: serverCategories, auth, notifications }) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [activeNav, setActiveNav] = useState('dashboard');
    const [selectedCategory, setSelectedCategory] = useState('');
    const [profileAnchor, setProfileAnchor] = useState(null);
    const [notificationAnchor, setNotificationAnchor] = useState(null);
    const [readNotifications, setReadNotifications] = useState(new Set());
    const [revisionPopover, setRevisionPopover] = useState({
        open: false,
        articleId: null,
        anchorEl: null,
        comments: ''
    });
    const [articleModal, setArticleModal] = useState({
        open: false,
        article: null
    });
    const [editingComment, setEditingComment] = useState(null);
    const [editContent, setEditContent] = useState('');
    const [categories] = useState(serverCategories && serverCategories.length > 0 ? serverCategories : []);
    const [stats, setStats] = useState({
        pendingToday: 0,
        avgReviewTime: '2.5h',
        completionRate: '85%',
        qualityScore: '4.8'
    });
    const [floatingIcons, setFloatingIcons] = useState([]);
    const [editorialStreak, setEditorialStreak] = useState(0);
    const [dailyGoal, setDailyGoal] = useState(0);
    const [searchQuery, setSearchQuery] = useState('');

    // Helper function to calculate article priority
    const getPriority = (article) => {
        // Simple priority calculation based on time
        const submittedDate = new Date(article.created_at);
        const now = new Date();
        const hoursDiff = (now - submittedDate) / (1000 * 60 * 60);
        
        if (hoursDiff > 48) return 'high';
        if (hoursDiff > 24) return 'medium';
        return 'low';
    };

    // Helper function to format date with time
    const formatDateTime = (dateString) => {
        const date = new Date(dateString);
        const now = new Date();
        const diffMs = now - date;
        const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
        const diffDays = Math.floor(diffHours / 24);
        
        // Show relative time for recent items
        if (diffHours < 1) {
            return 'Just now';
        } else if (diffHours < 24) {
            return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
        } else if (diffDays < 7) {
            return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
        } else {
            // Show full date and time for older items
            return date.toLocaleString('en-US', {
                month: 'short',
                day: 'numeric',
                year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined,
                hour: '2-digit',
                minute: '2-digit'
            });
        }
    };

    // Filter published articles based on search query
    const filteredPublished = published.filter(article => {
        if (!searchQuery.trim()) return true;
        
        const query = searchQuery.toLowerCase();
        return (
            article.title.toLowerCase().includes(query) ||
            article.writer.name.toLowerCase().includes(query) ||
            article.category.name.toLowerCase().includes(query) ||
            (article.content && article.content.toLowerCase().includes(query))
        );
    }).sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at));

    // Filter and sort pending articles by priority and submission date
    const filteredPending = pending.filter(article => {
        if (!selectedCategory || article.category_id === selectedCategory) {
            return true;
        }
        return false;
    }).sort((a, b) => {
        // First sort by priority (high first)
        const priorityOrder = { high: 0, medium: 1, low: 2 };
        const aPriority = priorityOrder[getPriority(a)] || 3;
        const bPriority = priorityOrder[getPriority(b)] || 3;
        
        if (aPriority !== bPriority) {
            return aPriority - bPriority;
        }
        
        // Then sort by submission date (newest first)
        return new Date(b.created_at) - new Date(a.created_at);
    });

    useEffect(() => {
        generateFloatingIcons();
        calculateEditorialStreak();
    }, []);

    const generateFloatingIcons = () => {
        const icons = [
            <RateReviewIcon />, <PsychologyIcon />, <EditNoteIcon />, <RocketLaunchIcon />, 
            <AutoStoriesIcon />, <MenuBookIcon />, <AssignmentTurnedInIcon />,
            <FireIcon />, <BrushIcon />, <ForestIcon />, <SunIcon />, <MoonIcon />
        ];
        const positions = [];
        for (let i = 0; i < 15; i++) {
            positions.push({
                icon: icons[Math.floor(Math.random() * icons.length)],
                left: Math.random() * 100,
                top: Math.random() * 100,
                delay: Math.random() * 5,
                duration: 10 + Math.random() * 20,
                size: 20 + Math.random() * 30
            });
        }
        setFloatingIcons(positions);
    };

    const calculateEditorialStreak = () => {
        // Simulate editorial streak based on published articles
        const streak = Math.floor(published.length / 2) + 1;
        setEditorialStreak(streak);
        
        // Calculate daily goal progress (simulated)
        const goal = Math.min(published.length % 5, 5);
        setDailyGoal(goal);
    };

    // Calculate unread notifications count
    const unreadCount = notifications?.filter(n => !readNotifications.has(n.id)).length || 0;

    // Initialize read notifications from actual read status
    useEffect(() => {
        if (notifications) {
            const readIds = new Set();
            notifications.forEach(notification => {
                if (notification.read_at) {
                    readIds.add(notification.id);
                }
            });
            setReadNotifications(readIds);
        }

        // Simulate stats calculation
        setStats({
            pendingToday: pending.filter(p => {
                const today = new Date();
                const submittedDate = new Date(p.created_at);
                return submittedDate.toDateString() === today.toDateString();
            }).length,
            avgReviewTime: '2.5h',
            completionRate: published.length > 0 ? Math.round((published.length / (pending.length + published.length)) * 100) + '%' : '0%',
            qualityScore: (4.5 + Math.random() * 0.5).toFixed(1)
        });
    }, [notifications, pending, published]);

    const handleReview = (articleId) => {
        Inertia.get(route('editor.articles.review', articleId));
    };

    const markNotificationAsRead = async (notificationId) => {
        try {
            await axios.post(route('notifications.mark-read'), {
                notification_id: notificationId
            });
            setReadNotifications(prev => new Set(prev).add(notificationId));
        } catch (error) {
            console.error('Error marking notification as read:', error);
        }
    };

    const markAllNotificationsAsRead = async () => {
        try {
            await axios.post(route('notifications.mark-all-read'));
            if (notifications) {
                const allIds = notifications.map(n => n.id);
                setReadNotifications(new Set(allIds));
            }
        } catch (error) {
            console.error('Error marking all notifications as read:', error);
        }
    };

    const handleArticleModalOpen = (article) => {
        setArticleModal({
            open: true,
            article: article
        });
    };

    const handleArticleModalClose = () => {
        setArticleModal({
            open: false,
            article: null
        });
    };

    const handleEditComment = (comment) => {
        setEditingComment(comment.id);
        setEditContent(comment.content || comment.comment);
    };

    const handleSaveEdit = async (commentId) => {
        try {
            // Make API call to update comment
            const response = await axios.put(route('comments.update', commentId), {
                content: editContent
            });
            
            // Update the article modal to reflect the edit immediately
            if (articleModal.article) {
                const updatedComments = articleModal.article.comments.map(c => 
                    c.id === commentId ? { 
                        ...c, 
                        content: editContent, 
                        comment: editContent,
                        updated_at: new Date().toISOString()
                    } : c
                );
                
                setArticleModal(prev => ({
                    ...prev,
                    article: {
                        ...prev.article,
                        comments: updatedComments
                    }
                }));
            }
            
            // Exit edit mode
            setEditingComment(null);
            setEditContent('');
            
            console.log('Comment updated successfully:', response.data);
            
        } catch (error) {
            console.error('Error updating comment:', error);
            alert('Failed to update comment. Please try again.');
        }
    };

    const handleCancelEdit = () => {
        setEditingComment(null);
        setEditContent('');
    };

    const handleDeleteComment = async (commentId) => {
        if (window.confirm('Are you sure you want to delete this comment? 🗑️')) {
            try {
                await axios.delete(route('comments.delete', commentId));
                
                // Update the article modal to reflect the deletion
                if (articleModal.article) {
                    const updatedComments = articleModal.article.comments.filter(c => c.id !== commentId);
                    setArticleModal({
                        ...articleModal,
                        article: {
                            ...articleModal.article,
                            comments: updatedComments,
                            comments_count: updatedComments.length
                        }
                    });
                }
                
                console.log('Comment deleted successfully');
            } catch (error) {
                console.error('Error deleting comment:', error);
                alert('Failed to delete comment. Please try again.');
            }
        }
    };

    
    const renderMainContent = () => {
        switch (activeNav) {
            case 'dashboard':
                return (
                    <Fade in={activeNav === 'dashboard'} timeout={500}>
                        <Box>
                            {/* Welcome Header with Playful Elements */}
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 4,
                                    mb: 4,
                                    borderRadius: '24px',
                                    background: THEME.gradient.primary,
                                    color: 'white',
                                    position: 'relative',
                                    overflow: 'hidden',
                                    border: `4px solid ${THEME.accent}`,
                                    boxShadow: THEME.shadows.large,
                                    transform: 'rotate(-0.5deg)',
                                    '&:hover': {
                                        transform: 'rotate(0deg) scale(1.01)',
                                        boxShadow: THEME.shadows.hover
                                    },
                                    transition: 'all 0.3s ease'
                                }}
                            >
                                {/* Floating background elements */}
                                <Box sx={{
                                    position: 'absolute',
                                    top: 20,
                                    left: '10%',
                                    animation: 'float 6s infinite ease-in-out',
                                    '@keyframes float': {
                                        '0%, 100%': { transform: 'translateY(0px) rotate(0deg)' },
                                        '50%': { transform: 'translateY(-20px) rotate(5deg)' }
                                    }
                                }}>
                                    <RateReviewIcon sx={{ fontSize: 60, color: 'rgba(255,255,255,0.2)' }} />
                                </Box>
                                <Box sx={{
                                    position: 'absolute',
                                    bottom: 20,
                                    right: '15%',
                                    animation: 'float 8s infinite ease-in-out',
                                    animationDelay: '1s'
                                }}>
                                    <EditNoteIcon sx={{ fontSize: 50, color: 'rgba(255,255,255,0.2)' }} />
                                </Box>

                                <Box sx={{ position: 'relative', zIndex: 1 }}>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                        <Chip
                                            icon={<EmojiIcon />}
                                            label="Welcome to Your Editorial Dashboard!"
                                            sx={{
                                                bgcolor: THEME.accent,
                                                color: THEME.text.primary,
                                                fontWeight: 'bold',
                                                fontSize: '1rem',
                                                p: 2,
                                                borderRadius: '30px',
                                                animation: 'wiggle 3s infinite',
                                                '@keyframes wiggle': {
                                                    '0%, 100%': { transform: 'rotate(0deg)' },
                                                    '25%': { transform: 'rotate(-2deg)' },
                                                    '75%': { transform: 'rotate(2deg)' }
                                                }
                                            }}
                                        />
                                        {editorialStreak > 0 && (
                                            <Chip
                                                icon={<FireIcon />}
                                                label={`${editorialStreak} Week Streak!`}
                                                sx={{
                                                    bgcolor: THEME.secondary,
                                                    color: 'white',
                                                    fontWeight: 'bold',
                                                    animation: 'pulse 2s infinite',
                                                    '@keyframes pulse': {
                                                        '0%': { transform: 'scale(1)' },
                                                        '50%': { transform: 'scale(1.05)' }
                                                    }
                                                }}
                                            />
                                        )}
                                    </Box>
                                    
                                    <Typography variant="h4" sx={{ 
                                        fontWeight: 800, 
                                        mb: 1,
                                        textShadow: '3px 3px 0 rgba(0,0,0,0.2)'
                                    }}>
                                        Welcome back, {auth?.user?.name?.split(' ')[0] || 'Editor'}! 
                                        <Box component="span" sx={{ display: 'inline-block', ml: 1, animation: 'wave 2s infinite' }}>
                                            👋
                                        </Box>
                                    </Typography>
                                    
                                    <Typography variant="body1" sx={{ opacity: 0.9, mb: 3, fontSize: '1.2rem' }}>
                                        Here's your editorial overview for today
                                    </Typography>
                                    
                                    <Stack direction="row" spacing={2} flexWrap="wrap" sx={{ gap: 1 }}>
                                        <Chip
                                            icon={<HourglassEmptyIcon />}
                                            label={`${pending.length} Pending Reviews`}
                                            sx={{ 
                                                bgcolor: 'rgba(255,255,255,0.2)', 
                                                color: 'white',
                                                border: '2px solid white',
                                                fontSize: '1rem',
                                                '&:hover': { bgcolor: 'rgba(255,255,255,0.3)' }
                                            }}
                                        />
                                        <Chip
                                            icon={<PublishedWithChangesIcon />}
                                            label={`${published.length} Published`}
                                            sx={{ 
                                                bgcolor: 'rgba(255,255,255,0.2)', 
                                                color: 'white',
                                                border: '2px solid white',
                                                fontSize: '1rem',
                                                '&:hover': { bgcolor: 'rgba(255,255,255,0.3)' }
                                            }}
                                        />
                                    </Stack>
                                </Box>
                            </Paper>

                            {/* Daily Editorial Goal */}
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 3,
                                    mb: 4,
                                    borderRadius: '16px',
                                    background: 'white',
                                    border: `3px solid ${THEME.secondary}`,
                                    boxShadow: `4px 4px 0 ${alpha(THEME.secondary, 0.3)}`,
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'space-between',
                                    flexWrap: 'wrap',
                                    gap: 2
                                }}
                            >
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                    <Box
                                        sx={{
                                            width: 50,
                                            height: 50,
                                            borderRadius: '12px',
                                            background: THEME.gradient.secondary,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            animation: 'bounce 2s infinite'
                                        }}
                                    >
                                        <EmojiEventsIcon sx={{ color: 'white', fontSize: 30 }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.text.primary }}>
                                            Daily Review Goal
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                            {dailyGoal}/5 reviews completed today
                                        </Typography>
                                    </Box>
                                </Box>
                                <Box sx={{ minWidth: 200 }}>
                                    <LinearProgress
                                        variant="determinate"
                                        value={(dailyGoal / 5) * 100}
                                        sx={{
                                            height: 10,
                                            borderRadius: 5,
                                            bgcolor: alpha(THEME.secondary, 0.1),
                                            '& .MuiLinearProgress-bar': {
                                                background: THEME.gradient.secondary,
                                                borderRadius: 5
                                            }
                                        }}
                                    />
                                    <Typography variant="caption" sx={{ color: THEME.text.light, mt: 0.5, display: 'block' }}>
                                        {dailyGoal >= 5 ? '🎉 Goal achieved! Great job!' : `${5 - dailyGoal} more to go!`}
                                    </Typography>
                                </Box>
                            </Paper>

                            {/* Stats Grid with Playful Design */}
                            <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <DashboardIcon sx={{ color: THEME.primary }} />
                                Editorial Overview
                            </Typography>

                            <Grid container spacing={3} sx={{ mb: 4 }}>
                                {[
                                    { label: 'Pending Reviews', count: pending.length, sub: `${stats.pendingToday} today`, icon: <HourglassEmptyIcon />, color: THEME.primary, emoji: '⏳', gradient: THEME.gradient.primary },
                                    { label: 'Published', count: published.length, sub: `${Math.floor(published.length * 0.2)} this month`, icon: <PublishedWithChangesIcon />, color: THEME.success, emoji: '🌟', gradient: THEME.gradient.success },
                                    { label: 'Completion Rate', count: stats.completionRate, sub: 'overall', icon: <AssignmentTurnedInIcon />, color: THEME.secondary, emoji: '📊', gradient: THEME.gradient.secondary },
                                    { label: 'Quality Score', count: stats.qualityScore, sub: 'out of 5.0', icon: <StarIcon />, color: THEME.accent, emoji: '⭐', gradient: THEME.gradient.warning }
                                ].map((stat, index) => (
                                    <Grid item xs={12} sm={6} md={3} key={stat.label}>
                                        <Zoom in timeout={300 + index * 100}>
                                            <Card
                                                elevation={0}
                                                sx={{
                                                    borderRadius: '20px',
                                                    background: 'white',
                                                    border: `3px solid ${stat.color}`,
                                                    boxShadow: `6px 6px 0 ${alpha(stat.color, 0.3)}`,
                                                    transition: 'all 0.3s ease',
                                                    position: 'relative',
                                                    overflow: 'visible',
                                                    '&:hover': {
                                                        transform: 'translateY(-8px) translateX(-4px)',
                                                        boxShadow: `10px 10px 0 ${alpha(stat.color, 0.3)}`
                                                    },
                                                    '&::before': {
                                                        content: '""',
                                                        position: 'absolute',
                                                        top: -10,
                                                        right: -10,
                                                        width: 40,
                                                        height: 40,
                                                        borderRadius: '50%',
                                                        background: stat.color,
                                                        opacity: 0.2,
                                                        zIndex: 0
                                                    }
                                                }}
                                            >
                                                <CardContent>
                                                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                                                        <Box
                                                            sx={{
                                                                width: 60,
                                                                height: 60,
                                                                borderRadius: '16px',
                                                                background: stat.gradient,
                                                                display: 'flex',
                                                                alignItems: 'center',
                                                                justifyContent: 'center',
                                                                color: 'white',
                                                                transform: 'rotate(-5deg)',
                                                                boxShadow: `4px 4px 0 ${alpha(stat.color, 0.3)}`,
                                                                animation: `bounce${index} 3s infinite`,
                                                                [`@keyframes bounce${index}`]: {
                                                                    '0%, 100%': { transform: 'rotate(-5deg) translateY(0)' },
                                                                    '50%': { transform: 'rotate(-5deg) translateY(-5px)' }
                                                                }
                                                            }}
                                                        >
                                                            {stat.icon}
                                                        </Box>
                                                        <Typography variant="h2" sx={{ fontSize: '3rem', opacity: 0.2 }}>
                                                            {stat.emoji}
                                                        </Typography>
                                                    </Box>
                                                    
                                                    <Typography variant="h3" sx={{ fontWeight: 800, color: THEME.text.primary, mb: 0.5 }}>
                                                        {stat.count}
                                                    </Typography>
                                                    
                                                    <Typography variant="body1" sx={{ color: THEME.text.secondary, fontWeight: 600 }}>
                                                        {stat.label}
                                                    </Typography>
                                                    
                                                    <Typography variant="caption" sx={{ color: stat.color, mt: 1, display: 'block' }}>
                                                        {stat.sub}
                                                    </Typography>
                                                </CardContent>
                                            </Card>
                                        </Zoom>
                                    </Grid>
                                ))}
                            </Grid>

                            {/* Quick Actions with Playful Design */}
                            <Grid container spacing={3}>
                                <Grid item xs={12} md={6}>
                                    <Zoom in timeout={700}>
                                        <Paper
                                            elevation={0}
                                            sx={{
                                                p: 3,
                                                borderRadius: '20px',
                                                background: THEME.gradient.primary,
                                                color: 'white',
                                                position: 'relative',
                                                overflow: 'hidden',
                                                border: `3px solid ${THEME.accent}`,
                                                boxShadow: `6px 6px 0 ${alpha(THEME.primary, 0.3)}`,
                                                '&:hover': {
                                                    transform: 'translateY(-4px)',
                                                    boxShadow: `8px 8px 0 ${alpha(THEME.primary, 0.3)}`
                                                },
                                                transition: 'all 0.3s ease'
                                            }}
                                        >
                                            <Box sx={{ position: 'relative', zIndex: 1 }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                    <Box
                                                        sx={{
                                                            width: 40,
                                                            height: 40,
                                                            borderRadius: '50%',
                                                            background: 'rgba(255,255,255,0.2)',
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            justifyContent: 'center',
                                                            animation: 'pulse 2s infinite'
                                                        }}
                                                    >
                                                        <FireIcon />
                                                    </Box>
                                                    <Typography variant="h6" sx={{ fontWeight: 700 }}>
                                                        Priority Queue 🔥
                                                    </Typography>
                                                </Box>
                                                <Typography variant="body2" sx={{ opacity: 0.9, mb: 3 }}>
                                                    {pending.filter(a => getPriority(a) === 'high').length} articles waiting over 48 hours
                                                </Typography>
                                                <Button
                                                    variant="contained"
                                                    startIcon={<RateReviewIcon />}
                                                    onClick={() => setActiveNav('pending')}
                                                    sx={{
                                                        bgcolor: '#ffffff',
                                                        color: THEME.primary,
                                                        borderRadius: '30px',
                                                        border: '2px solid white',
                                                        '&:hover': {
                                                            bgcolor: alpha('#ffffff', 0.9),
                                                            transform: 'scale(1.05)'
                                                        }
                                                    }}
                                                >
                                                    Review Now ⚡
                                                </Button>
                                            </Box>
                                            <Box
                                                sx={{
                                                    position: 'absolute',
                                                    top: -20,
                                                    right: -20,
                                                    width: 120,
                                                    height: 120,
                                                    borderRadius: '50%',
                                                    background: 'rgba(255,255,255,0.1)',
                                                    zIndex: 0
                                                }}
                                            />
                                        </Paper>
                                    </Zoom>
                                </Grid>
                                
                                <Grid item xs={12} md={6}>
                                    <Zoom in timeout={800}>
                                        <Paper
                                            elevation={0}
                                            sx={{
                                                p: 3,
                                                borderRadius: '20px',
                                                background: THEME.gradient.secondary,
                                                color: 'white',
                                                position: 'relative',
                                                overflow: 'hidden',
                                                border: `3px solid ${THEME.accent}`,
                                                boxShadow: `6px 6px 0 ${alpha(THEME.secondary, 0.3)}`,
                                                '&:hover': {
                                                    transform: 'translateY(-4px)',
                                                    boxShadow: `8px 8px 0 ${alpha(THEME.secondary, 0.3)}`
                                                },
                                                transition: 'all 0.3s ease'
                                            }}
                                        >
                                            <Box sx={{ position: 'relative', zIndex: 1 }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                    <Box
                                                        sx={{
                                                            width: 40,
                                                            height: 40,
                                                            borderRadius: '50%',
                                                            background: 'rgba(255,255,255,0.2)',
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            justifyContent: 'center'
                                                        }}
                                                    >
                                                        <EmojiEventsIcon />
                                                    </Box>
                                                    <Typography variant="h6" sx={{ fontWeight: 700 }}>
                                                        Achievement Unlocked 🏆
                                                    </Typography>
                                                </Box>
                                                <Typography variant="body2" sx={{ opacity: 0.9, mb: 3 }}>
                                                    You've reviewed {published.length} articles this month!
                                                </Typography>
                                                <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                                                    <StarIcon sx={{ color: THEME.accent }} />
                                                    <Typography variant="h5" sx={{ fontWeight: 800 }}>
                                                        Top Editor
                                                    </Typography>
                                                    <StarIcon sx={{ color: THEME.accent }} />
                                                </Box>
                                            </Box>
                                            <Box
                                                sx={{
                                                    position: 'absolute',
                                                    bottom: -20,
                                                    right: -20,
                                                    width: 120,
                                                    height: 120,
                                                    borderRadius: '50%',
                                                    background: 'rgba(255,255,255,0.1)',
                                                    zIndex: 0
                                                }}
                                            />
                                        </Paper>
                                    </Zoom>
                                </Grid>
                            </Grid>
                        </Box>
                    </Fade>
                );

            case 'pending':
                return (
                    <Fade in={activeNav === 'pending'} timeout={500}>
                        <Box>
                            <Box sx={{ mb: 4 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                    <Box
                                        sx={{
                                            width: 50,
                                            height: 50,
                                            borderRadius: '12px',
                                            background: THEME.gradient.warning,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center'
                                        }}
                                    >
                                        <HourglassEmptyIcon sx={{ color: 'white' }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                            Review Queue
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                            {pending.length} article{pending.length !== 1 ? 's' : ''} awaiting your editorial review
                                        </Typography>
                                    </Box>
                                </Box>
                            </Box>

                            {categories.length > 0 && (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        p: 2,
                                        mb: 3,
                                        borderRadius: '30px',
                                        bgcolor: 'white',
                                        border: `3px solid ${alpha(THEME.warning, 0.2)}`,
                                        boxShadow: `4px 4px 0 ${alpha(THEME.warning, 0.2)}`,
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: 2,
                                        flexWrap: 'wrap'
                                    }}
                                >
                                    <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                        <MenuBookIcon sx={{ color: THEME.warning }} />
                                        Filter by Category:
                                    </Typography>
                                    <Select
                                        value={selectedCategory}
                                        onChange={(e) => setSelectedCategory(e.target.value ? Number(e.target.value) : '')}
                                        displayEmpty
                                        size="small"
                                        sx={{
                                            minWidth: 200,
                                            borderRadius: '30px',
                                            '& .MuiOutlinedInput-notchedOutline': {
                                                borderColor: alpha(THEME.warning, 0.3),
                                                borderWidth: 2
                                            },
                                            '&:hover .MuiOutlinedInput-notchedOutline': {
                                                borderColor: THEME.warning
                                            }
                                        }}
                                    >
                                        <MenuItem value="">All Categories</MenuItem>
                                        {categories.map((c) => (
                                            <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>
                                        ))}
                                    </Select>
                                </Paper>
                            )}

                            {pending.length === 0 ? (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        p: 6,
                                        borderRadius: '24px',
                                        bgcolor: 'white',
                                        textAlign: 'center',
                                        border: `4px solid ${alpha(THEME.success, 0.2)}`,
                                        boxShadow: THEME.shadows.medium
                                    }}
                                >
                                    <CheckCircleIcon sx={{ fontSize: 80, color: THEME.success, mb: 2, animation: 'float 3s infinite' }} />
                                    <Typography variant="h5" sx={{ color: THEME.text.primary, mb: 1, fontWeight: 600 }}>
                                        All Caught Up! 🎉
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                        No pending articles in your queue. Take a well-deserved break!
                                    </Typography>
                                </Paper>
                            ) : (
                                <Grid container spacing={3}>
                                    {pending
                                        .filter(a => !selectedCategory || a.category?.id === selectedCategory)
                                        .sort((a, b) => new Date(a.created_at) - new Date(b.created_at))
                                        .map((article, index) => {
                                            const priority = getPriority(article);
                                            return (
                                                <Grid key={article.id} item xs={12}>
                                                    <Zoom in timeout={300 + index * 100}>
                                                        <Card
                                                            elevation={0}
                                                            sx={{
                                                                borderRadius: '20px',
                                                                border: `3px solid ${alpha(PRIORITY_COLORS[priority].text, 0.3)}`,
                                                                boxShadow: `6px 6px 0 ${alpha(PRIORITY_COLORS[priority].text, 0.2)}`,
                                                                transition: 'all 0.3s ease',
                                                                position: 'relative',
                                                                overflow: 'visible',
                                                                '&:hover': {
                                                                    transform: 'translateX(8px) translateY(-4px)',
                                                                    boxShadow: `10px 10px 0 ${alpha(PRIORITY_COLORS[priority].text, 0.2)}`,
                                                                    borderColor: PRIORITY_COLORS[priority].text
                                                                }
                                                            }}
                                                        >
                                                            <CardContent sx={{ p: 3 }}>
                                                                <Grid container spacing={2}>
                                                                    <Grid item xs={12} md={8}>
                                                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2, flexWrap: 'wrap' }}>
                                                                            <Chip
                                                                                icon={STATUS_COLORS.submitted.icon}
                                                                                label={`Pending Review ${STATUS_COLORS.submitted.emoji}`}
                                                                                size="small"
                                                                                sx={{
                                                                                    bgcolor: STATUS_COLORS.submitted.bg,
                                                                                    color: STATUS_COLORS.submitted.text,
                                                                                    fontWeight: 600,
                                                                                    border: `2px solid ${STATUS_COLORS.submitted.border}`
                                                                                }}
                                                                            />
                                                                            <Chip
                                                                                icon={priority === 'high' ? <FireIcon /> : priority === 'medium' ? <WarningIcon /> : <HourglassEmptyIcon />}
                                                                                label={`Priority: ${priority} ${PRIORITY_COLORS[priority].emoji}`}
                                                                                size="small"
                                                                                sx={{
                                                                                    bgcolor: PRIORITY_COLORS[priority].bg,
                                                                                    color: PRIORITY_COLORS[priority].text,
                                                                                    fontWeight: 600,
                                                                                    border: `2px solid ${PRIORITY_COLORS[priority].border}`
                                                                                }}
                                                                            />
                                                                        </Box>
                                                                        
                                                                        <Typography variant="h5" sx={{ fontWeight: 700, mb: 2, color: THEME.text.primary }}>
                                                                            {article.title}
                                                                        </Typography>
                                                                        
                                                                        <Stack direction="row" spacing={3} sx={{ mb: 2, flexWrap: 'wrap' }}>
                                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                                <Avatar
                                                                                    sx={{
                                                                                        width: 24,
                                                                                        height: 24,
                                                                                        bgcolor: alpha(THEME.primary, 0.1),
                                                                                        color: THEME.primary,
                                                                                        fontSize: '0.75rem'
                                                                                    }}
                                                                                >
                                                                                    {article.writer.name.charAt(0)}
                                                                                </Avatar>
                                                                                <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                                                                    {article.writer.name}
                                                                                </Typography>
                                                                            </Box>
                                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                                <MenuBookIcon sx={{ fontSize: 16, color: THEME.text.light }} />
                                                                                <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                                                                    {article.category.name}
                                                                                </Typography>
                                                                            </Box>
                                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                                <CalendarTodayIcon sx={{ fontSize: 16, color: THEME.text.light }} />
                                                                                <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                                                                    {formatDateTime(article.created_at)}
                                                                                </Typography>
                                                                            </Box>
                                                                        </Stack>
                                                                    </Grid>
                                                                    
                                                                    <Grid item xs={12} md={4}>
                                                                        <Box sx={{ 
                                                                            display: 'flex', 
                                                                            flexDirection: 'column', 
                                                                            gap: 1.5,
                                                                            height: '100%',
                                                                            justifyContent: 'center'
                                                                        }}>
                                                                            <Button
                                                                                fullWidth
                                                                                variant="contained"
                                                                                startIcon={<RateReviewIcon />}
                                                                                onClick={() => handleReview(article.id)}
                                                                                sx={{
                                                                                    background: THEME.gradient.primary,
                                                                                    color: 'white',
                                                                                    fontWeight: 600,
                                                                                    textTransform: 'none',
                                                                                    py: 1.5,
                                                                                    borderRadius: '30px',
                                                                                    border: '2px solid white',
                                                                                    '&:hover': {
                                                                                        transform: 'scale(1.02)',
                                                                                        boxShadow: `0 8px 16px ${alpha(THEME.primary, 0.3)}`
                                                                                    }
                                                                                }}
                                                                            >
                                                                                Begin Review 🔍
                                                                            </Button>
                                                                            <Button
                                                                                fullWidth
                                                                                variant="outlined"
                                                                                startIcon={<WarningIcon />}
                                                                                onClick={() => handleReview(article.id)}
                                                                                sx={{
                                                                                    borderColor: alpha(THEME.warning, 0.5),
                                                                                    color: THEME.warning,
                                                                                    textTransform: 'none',
                                                                                    py: 1.5,
                                                                                    borderRadius: '30px',
                                                                                    borderWidth: 2,
                                                                                    '&:hover': {
                                                                                        borderColor: THEME.warning,
                                                                                        bgcolor: alpha(THEME.warning, 0.04),
                                                                                        transform: 'scale(1.02)'
                                                                                    }
                                                                                }}
                                                                            >
                                                                                Request Revision 🔄
                                                                            </Button>
                                                                        </Box>
                                                                    </Grid>
                                                                </Grid>
                                                            </CardContent>
                                                        </Card>
                                                    </Zoom>
                                                </Grid>
                                            );
                                        })}
                                </Grid>
                            )}
                        </Box>
                    </Fade>
                );

            case 'published':
                return (
                    <Fade in={activeNav === 'published'} timeout={500}>
                        <Box>
                            <Box sx={{ mb: 4 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                    <Box
                                        sx={{
                                            width: 50,
                                            height: 50,
                                            borderRadius: '12px',
                                            background: THEME.gradient.success,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center'
                                        }}
                                    >
                                        <PublishedWithChangesIcon sx={{ color: 'white' }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                            Published Works
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                            {published.length} article{published.length !== 1 ? 's' : ''} successfully published
                                        </Typography>
                                    </Box>
                                </Box>
                            </Box>

                            {/* Search Bar */}
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 2,
                                    mb: 4,
                                    borderRadius: '20px',
                                    bgcolor: 'white',
                                    border: `3px solid ${alpha(THEME.success, 0.2)}`,
                                    boxShadow: `4px 4px 0 ${alpha(THEME.success, 0.2)}`
                                }}
                            >
                                <TextField
                                    fullWidth
                                    placeholder="Search published articles... 🔍"
                                    size="medium"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    sx={{
                                        '& .MuiOutlinedInput-root': {
                                            borderRadius: '30px',
                                            bgcolor: alpha(THEME.success, 0.05),
                                            border: `2px solid ${alpha(THEME.success, 0.2)}`,
                                            '&:hover': {
                                                bgcolor: alpha(THEME.success, 0.1),
                                                borderColor: THEME.success
                                            },
                                            '&.Mui-focused': {
                                                bgcolor: 'white',
                                                borderColor: THEME.success,
                                                borderWidth: 2
                                            }
                                        }
                                    }}
                                    InputProps={{
                                        startAdornment: (
                                            <InputAdornment position="start">
                                                <SearchIcon sx={{ color: THEME.success, fontSize: 24 }} />
                                            </InputAdornment>
                                        ),
                                    }}
                                />
                            </Paper>

                            {filteredPublished.length === 0 ? (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        p: 6,
                                        borderRadius: '24px',
                                        bgcolor: 'white',
                                        textAlign: 'center',
                                        border: `4px solid ${alpha(THEME.success, 0.2)}`,
                                        boxShadow: THEME.shadows.medium
                                    }}
                                >
                                    <SearchIcon sx={{ fontSize: 80, color: THEME.text.light, mb: 2, animation: 'float 3s infinite' }} />
                                    <Typography variant="h5" sx={{ color: THEME.text.primary, mb: 1, fontWeight: 600 }}>
                                        {searchQuery.trim() ? 'No Articles Found' : 'No Published Articles Yet'}
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                        {searchQuery.trim() 
                                            ? `No articles match "${searchQuery}". Try different keywords.`
                                            : 'Articles you approve will appear here'
                                        }
                                    </Typography>
                                </Paper>
                            ) : (
                                <Grid container spacing={3}>
                                    {filteredPublished.map((article, index) => (
                                        <Grid key={article.id} item xs={12} sm={6} lg={4}>
                                            <Zoom in timeout={300 + index * 100}>
                                                <Card
                                                    elevation={0}
                                                    onClick={() => handleArticleModalOpen(article)}
                                                    sx={{
                                                        height: '100%',
                                                        borderRadius: '20px',
                                                        border: `3px solid ${alpha(THEME.success, 0.3)}`,
                                                        boxShadow: `4px 4px 0 ${alpha(THEME.success, 0.2)}`,
                                                        transition: 'all 0.3s ease',
                                                        cursor: 'pointer',
                                                        position: 'relative',
                                                        overflow: 'visible',
                                                        '&:hover': {
                                                            transform: 'translateY(-8px) translateX(-4px)',
                                                            boxShadow: `8px 8px 0 ${alpha(THEME.success, 0.2)}`,
                                                            borderColor: THEME.success
                                                        },
                                                        '&::before': {
                                                            content: '""',
                                                            position: 'absolute',
                                                            top: -10,
                                                            left: -10,
                                                            width: 30,
                                                            height: 30,
                                                            borderRadius: '50%',
                                                            background: THEME.accent,
                                                            opacity: 0.2,
                                                            zIndex: 0
                                                        }
                                                    }}
                                                >
                                                    <CardContent sx={{ p: 3, position: 'relative', zIndex: 1 }}>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                                            <Avatar
                                                                sx={{
                                                                    width: 32,
                                                                    height: 32,
                                                                    bgcolor: alpha(THEME.success, 0.1),
                                                                    color: THEME.success,
                                                                    border: `2px solid ${THEME.accent}`
                                                                }}
                                                            >
                                                                {article.writer.name.charAt(0)}
                                                            </Avatar>
                                                            <Box>
                                                                <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                                    {article.writer.name}
                                                                </Typography>
                                                                <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                                    Author
                                                                </Typography>
                                                            </Box>
                                                        </Box>

                                                        <Typography variant="h6" sx={{ fontWeight: 700, mb: 2, color: THEME.text.primary }}>
                                                            {article.title}
                                                        </Typography>

                                                        <Chip
                                                            icon={<CheckCircleIcon />}
                                                            label={`Published 🌟`}
                                                            size="small"
                                                            sx={{
                                                                mb: 2,
                                                                bgcolor: STATUS_COLORS.published.bg,
                                                                color: STATUS_COLORS.published.text,
                                                                fontWeight: 600,
                                                                border: `2px solid ${STATUS_COLORS.published.border}`
                                                            }}
                                                        />

                                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                <CalendarTodayIcon sx={{ fontSize: 14, color: THEME.text.light }} />
                                                                <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                                                    {formatDateTime(article.updated_at)}
                                                                </Typography>
                                                            </Box>
                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                                <Tooltip title={`Click to read ${article.comments_count || 0} comment${(article.comments_count || 0) !== 1 ? 's' : ''}`} arrow>
                                                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, cursor: 'pointer', '&:hover': { transform: 'scale(1.05)' }, transition: 'transform 0.2s' }}>
                                                                        <CommentIcon sx={{ fontSize: 16, color: THEME.text.light }} />
                                                                        <Typography variant="body2" sx={{ color: THEME.text.primary, fontWeight: 600 }}>
                                                                            {article.comments_count || 0}
                                                                        </Typography>
                                                                    </Box>
                                                                </Tooltip>
                                                            </Box>
                                                        </Box>
                                                    </CardContent>
                                                </Card>
                                            </Zoom>
                                        </Grid>
                                    ))}
                                </Grid>
                            )}
                        </Box>
                    </Fade>
                );

            default:
                return null;
        }
    };

    return (
        <Box sx={{ 
            display: 'flex', 
            minHeight: '100vh', 
            bgcolor: THEME.background,
            position: 'relative',
            '&::before': {
                content: '""',
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                background: 'radial-gradient(circle at 10% 20%, #FBBF2420 0%, transparent 20%), radial-gradient(circle at 90% 80%, #6366F120 0%, transparent 20%)',
                pointerEvents: 'none',
                zIndex: 0
            }
        }}>
            {/* Floating Background Icons */}
            <Box sx={{
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                pointerEvents: 'none',
                zIndex: 1,
                overflow: 'hidden'
            }}>
                {floatingIcons.map((item, index) => (
                    <Box
                        key={index}
                        sx={{
                            position: 'absolute',
                            left: `${item.left}%`,
                            top: `${item.top}%`,
                            color: [THEME.primary, THEME.secondary, THEME.accent, THEME.purple][Math.floor(Math.random() * 4)],
                            opacity: 0.1,
                            fontSize: item.size,
                            animation: `float ${item.duration}s infinite ease-in-out`,
                            animationDelay: `${item.delay}s`,
                            '@keyframes float': {
                                '0%': { transform: 'translateY(0px) rotate(0deg)' },
                                '50%': { transform: 'translateY(-20px) rotate(10deg)' },
                                '100%': { transform: 'translateY(0px) rotate(0deg)' }
                            }
                        }}
                    >
                        {item.icon}
                    </Box>
                ))}
            </Box>

            {/* Header */}
            <AppBar
                position="fixed"
                elevation={0}
                sx={{
                    background: 'rgba(255, 255, 255, 0.9)',
                    backdropFilter: 'blur(20px)',
                    borderBottom: `3px solid ${THEME.primary}`,
                    zIndex: 1201,
                    height: 80,
                    boxShadow: THEME.shadows.small
                }}
            >
                <Toolbar sx={{ minHeight: 80 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flexGrow: 1 }}>
                        <Box
                            sx={{
                                width: 50,
                                height: 50,
                                borderRadius: '12px',
                                background: THEME.gradient.primary,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.3)}`,
                                transform: 'rotate(-5deg)',
                                animation: 'bounce 2s infinite',
                                '@keyframes bounce': {
                                    '0%, 100%': { transform: 'rotate(-5deg) translateY(0)' },
                                    '50%': { transform: 'rotate(-5deg) translateY(-5px)' }
                                }
                            }}
                        >
                            <RateReviewIcon sx={{ color: 'white', fontSize: 28 }} />
                        </Box>
                        <Box>
                            <Typography variant="h5" sx={{ fontWeight: 800, color: THEME.text.primary, letterSpacing: '-0.5px' }}>
                                Editorial Review Panel
                            </Typography>
                            <Typography variant="caption" sx={{ color: THEME.text.secondary, display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                <EmojiIcon sx={{ fontSize: 14, color: THEME.accent }} />
                                Shaping stories, one review at a time
                            </Typography>
                        </Box>
                    </Box>
                    
                    {/* Notification Bell */}
                    <Tooltip title="Notifications">
                        <IconButton
                            onClick={(e) => setNotificationAnchor(e.currentTarget)}
                            sx={{ 
                                mr: 2,
                                width: 48,
                                height: 48,
                                bgcolor: alpha(THEME.primary, 0.05),
                                border: `2px solid ${alpha(THEME.primary, 0.2)}`,
                                '&:hover': {
                                    bgcolor: alpha(THEME.primary, 0.1),
                                    transform: 'scale(1.1)'
                                }
                            }}
                        >
                            <Badge 
                                badgeContent={unreadCount} 
                                color="error"
                                sx={{
                                    '& .MuiBadge-badge': {
                                        bgcolor: THEME.error,
                                        color: 'white',
                                        fontWeight: 'bold',
                                        animation: unreadCount > 0 ? 'pulse 2s infinite' : 'none'
                                    }
                                }}
                            >
                                {unreadCount > 0 ? (
                                    <NotificationsIcon sx={{ color: THEME.primary }} />
                                ) : (
                                    <NotificationsNoneIcon sx={{ color: THEME.text.secondary }} />
                                )}
                            </Badge>
                        </IconButton>
                    </Tooltip>
                    
                    {/* Home Button */}
                    <Tooltip title="Go to Home">
                        <IconButton
                            onClick={() => Inertia.visit('/')}
                            sx={{ 
                                mr: 2,
                                width: 48,
                                height: 48,
                                bgcolor: alpha(THEME.primary, 0.05),
                                border: `2px solid ${alpha(THEME.primary, 0.2)}`,
                                '&:hover': {
                                    bgcolor: alpha(THEME.primary, 0.1),
                                    transform: 'scale(1.1)'
                                }
                            }}
                        >
                            <HomeIcon sx={{ color: THEME.primary }} />
                        </IconButton>
                    </Tooltip>
                    
                    {/* Profile Button */}
                    <IconButton
                        onClick={(e) => setProfileAnchor(e.currentTarget)}
                        sx={{ 
                            width: 48,
                            height: 48,
                            background: THEME.gradient.primary,
                            border: '3px solid white',
                            boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.3)}`,
                            '&:hover': {
                                transform: 'scale(1.1)',
                                boxShadow: `6px 6px 0 ${alpha(THEME.primary, 0.3)}`
                            }
                        }}
                    >
                        <Avatar sx={{ 
                            width: 40, 
                            height: 40,
                            bgcolor: 'white',
                            color: THEME.primary,
                            fontWeight: 'bold',
                            fontSize: '1.2rem'
                        }}>
                            {auth?.user?.name?.charAt(0) || 'E'}
                        </Avatar>
                    </IconButton>

                    {/* Profile Menu */}
                    <Menu
                        anchorEl={profileAnchor}
                        open={Boolean(profileAnchor)}
                        onClose={() => setProfileAnchor(null)}
                        PaperProps={{
                            sx: {
                                minWidth: 250,
                                borderRadius: '16px',
                                boxShadow: THEME.shadows.large,
                                border: `3px solid ${THEME.primary}`,
                                mt: 1
                            }
                        }}
                    >
                        <Box sx={{ px: 2, py: 1.5, bgcolor: alpha(THEME.primary, 0.05) }}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 700, color: THEME.text.primary }}>
                                {auth?.user?.name}
                            </Typography>
                            <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                {auth?.user?.email}
                            </Typography>
                        </Box>
                        <Divider />
                        <MenuItem onClick={() => {
                            setProfileAnchor(null);
                            Inertia.get(route('profile.edit'));
                        }}>
                            <AccountCircleIcon sx={{ mr: 1.5, fontSize: 20, color: THEME.primary }} />
                            Profile Settings
                        </MenuItem>
                        <MenuItem onClick={() => {
                            setProfileAnchor(null);
                            Inertia.post('/logout');
                        }}>
                            <LogoutIcon sx={{ mr: 1.5, fontSize: 20, color: THEME.error }} />
                            Sign Out
                        </MenuItem>
                        <Divider />
                    </Menu>
                    
                    {/* Notification Menu */}
                    <Menu
                        anchorEl={notificationAnchor}
                        open={Boolean(notificationAnchor)}
                        onClose={() => setNotificationAnchor(null)}
                        PaperProps={{
                            sx: {
                                maxHeight: 400,
                                width: 350,
                                mt: 1,
                                borderRadius: '16px',
                                boxShadow: THEME.shadows.large,
                                border: `3px solid ${THEME.primary}`,
                                overflow: 'hidden'
                            }
                        }}
                    >
                        <Box sx={{ p: 2, bgcolor: alpha(THEME.primary, 0.05), borderBottom: `2px solid ${alpha(THEME.primary, 0.1)}` }}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 700, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <NotificationsIcon sx={{ color: THEME.primary, fontSize: 20 }} />
                                Notifications
                            </Typography>
                        </Box>
                        
                        {notifications?.length > 0 && (
                            <MenuItem
                                onClick={async () => {
                                    await markAllNotificationsAsRead();
                                    setNotificationAnchor(null);
                                }}
                                sx={{ 
                                    py: 1.5,
                                    bgcolor: alpha(THEME.primary, 0.02),
                                    borderBottom: `2px solid ${alpha(THEME.primary, 0.1)}`,
                                    '&:hover': { bgcolor: alpha(THEME.primary, 0.04) }
                                }}
                            >
                                <Typography variant="body2" sx={{ color: THEME.primary, fontWeight: 600, textAlign: 'center', width: '100%' }}>
                                    Mark All as Read 📖
                                </Typography>
                            </MenuItem>
                        )}
                        
                        {notifications?.length > 0 ? (
                            notifications.map((notification) => (
                                <MenuItem 
                                    key={notification.id} 
                                    sx={{ 
                                        py: 2, 
                                        flexDirection: 'column', 
                                        alignItems: 'flex-start',
                                        cursor: 'pointer',
                                        borderBottom: `2px solid ${alpha(THEME.primary, 0.05)}`,
                                        '&:hover': { bgcolor: alpha(THEME.primary, 0.04) }
                                    }}
                                    onClick={() => {
                                        // Mark notification as read
                                        markNotificationAsRead(notification.id);
                                        
                                        // Close notification menu
                                        setNotificationAnchor(null);
                                        
                                        // Redirect based on notification type
                                        if (notification.data.type === 'revision_requested') {
                                            // Redirect to revise page for articles needing revision
                                            window.location.href = route('writer.articles.revise.page', notification.data.article_id);
                                        } else if (notification.data.type === 'article_published') {
                                            // Redirect to view page for published articles
                                            window.location.href = route('writer.articles.show', notification.data.article_id);
                                        }
                                    }}
                                >
                                    <Box sx={{ width: '100%' }}>
                                        <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 0.5, display: 'flex', alignItems: 'center', gap: 1 }}>
                                            {notification.data.type === 'revision_requested' ? '🔄 ' : 
                                             notification.data.type === 'article_published' ? '🌟 ' : '📬 '}
                                            {notification.data?.title || 'Notification'}
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#6b7280', fontSize: '0.875rem' }}>
                                            {notification.data?.message || notification.content}
                                        </Typography>
                                    </Box>
                                </MenuItem>
                            ))
                        ) : (
                            <MenuItem disabled sx={{ py: 3 }}>
                                <Typography variant="body2" sx={{ color: THEME.text.light, textAlign: 'center', width: '100%' }}>
                                    No notifications yet 📭
                                </Typography>
                            </MenuItem>
                        )}
                    </Menu>
                </Toolbar>
            </AppBar>

            {/* Sidebar */}
            <Drawer
                variant="permanent"
                sx={{
                    width: DRAWER_WIDTH,
                    flexShrink: 0,
                    '& .MuiDrawer-paper': {
                        width: DRAWER_WIDTH,
                        boxSizing: 'border-box',
                        bgcolor: 'white',
                        borderRight: `3px solid ${THEME.primary}`,
                        mt: '80px',
                        p: 2,
                        boxShadow: `4px 0 0 ${alpha(THEME.primary, 0.1)}`
                    }
                }}
            >
                <List>
                    {[
                        { id: 'dashboard', icon: <DashboardIcon />, label: 'Dashboard', emoji: '📊', badge: null, color: THEME.primary },
                        { id: 'pending', icon: <HourglassEmptyIcon />, label: 'Review Queue', emoji: '⏳', badge: pending.length, color: THEME.warning },
                        { id: 'published', icon: <PublishedWithChangesIcon />, label: 'Published', emoji: '🌟', badge: published.length, color: THEME.success }
                    ].map((item) => (
                        <ListItem key={item.id} disablePadding>
                            <ListItemButton
                                onClick={() => setActiveNav(item.id)}
                                sx={{
                                    borderRadius: '16px',
                                    mb: 1,
                                    bgcolor: activeNav === item.id ? alpha(item.color, 0.08) : 'transparent',
                                    border: activeNav === item.id ? `2px solid ${item.color}` : '2px solid transparent',
                                    '&:hover': {
                                        bgcolor: activeNav === item.id ? alpha(item.color, 0.12) : alpha(item.color, 0.04),
                                        transform: 'translateX(4px)'
                                    },
                                    transition: 'all 0.2s ease'
                                }}
                            >
                                <ListItemIcon>
                                    <Badge 
                                        badgeContent={item.badge} 
                                        color={item.id === 'pending' ? 'warning' : 'primary'}
                                        sx={{
                                            '& .MuiBadge-badge': {
                                                bgcolor: item.color,
                                                color: 'white',
                                                fontWeight: 'bold'
                                            }
                                        }}
                                    >
                                        {React.cloneElement(item.icon, { 
                                            sx: { color: activeNav === item.id ? item.color : THEME.text.light } 
                                        })}
                                    </Badge>
                                </ListItemIcon>
                                <ListItemText 
                                    primary={
                                        <Typography sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                            {item.label}
                                            <span style={{ fontSize: '1.2rem' }}>{item.emoji}</span>
                                        </Typography>
                                    }
                                    secondary={item.badge ? `${item.badge} waiting` : null}
                                    primaryTypographyProps={{
                                        sx: { 
                                            fontWeight: activeNav === item.id ? 700 : 500,
                                            color: activeNav === item.id ? item.color : THEME.text.primary
                                        }
                                    }}
                                    secondaryTypographyProps={{
                                        sx: { color: item.color }
                                    }}
                                />
                            </ListItemButton>
                        </ListItem>
                    ))}
                </List>

                <Divider sx={{ my: 2, borderWidth: 2, borderColor: alpha(THEME.primary, 0.1) }} />

                <Box sx={{ p: 2 }}>
                    <Typography variant="subtitle2" sx={{ color: THEME.text.primary, mb: 2, fontWeight: 700, display: 'flex', alignItems: 'center', gap: 1 }}>
                        <PsychologyIcon sx={{ color: THEME.secondary }} />
                        Editorial Guidelines
                    </Typography>
                    <List dense>
                        {[
                            { text: "Check for plagiarism", icon: <CheckCircleIcon sx={{ fontSize: 16, color: THEME.success }} /> },
                            { text: "Verify facts and sources", icon: <CheckCircleIcon sx={{ fontSize: 16, color: THEME.success }} /> },
                            { text: "Check grammar & style", icon: <CheckCircleIcon sx={{ fontSize: 16, color: THEME.success }} /> }
                        ].map((item, index) => (
                            <ListItem key={index} sx={{ px: 0 }}>
                                <ListItemIcon sx={{ minWidth: 32 }}>
                                    {item.icon}
                                </ListItemIcon>
                                <ListItemText 
                                    primary={item.text} 
                                    secondaryTypographyProps={{ sx: { fontSize: '0.75rem' } }} 
                                />
                            </ListItem>
                        ))}
                    </List>
                </Box>

                <Box sx={{ mt: 'auto', p: 2 }}>
                    <Paper
                        elevation={0}
                        sx={{
                            p: 2,
                            borderRadius: '16px',
                            background: THEME.gradient.primary,
                            color: 'white',
                            border: `3px solid ${THEME.accent}`,
                            boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.3)}`,
                            transform: 'rotate(-1deg)',
                            '&:hover': {
                                transform: 'rotate(0deg) scale(1.02)'
                            },
                            transition: 'all 0.3s ease',
                            position: 'relative',
                            overflow: 'hidden'
                        }}
                    >
                        <Box
                            sx={{
                                position: 'absolute',
                                top: -10,
                                right: -10,
                                width: 60,
                                height: 60,
                                borderRadius: '50%',
                                background: 'rgba(255,255,255,0.1)',
                                zIndex: 0
                            }}
                        />
                        <Box sx={{ position: 'relative', zIndex: 1 }}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 700, mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <LightbulbIcon sx={{ fontSize: 20 }} />
                                Quick Tip
                            </Typography>
                            <Typography variant="caption" sx={{ opacity: 0.9, display: 'block', mb: 1 }}>
                                High-priority articles are highlighted in orange. Try to review them within 24 hours.
                            </Typography>
                            <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
                                <PsychologyIcon sx={{ fontSize: 32, opacity: 0.3 }} />
                            </Box>
                        </Box>
                    </Paper>
                </Box>
            </Drawer>

            {/* Main Content */}
            <Box
                component="main"
                sx={{
                    flexGrow: 1,
                    mt: '80px',
                    p: 4,
                    minHeight: 'calc(100vh - 80px)',
                    bgcolor: THEME.background,
                    position: 'relative',
                    zIndex: 2
                }}
            >
                <Container maxWidth="xl" sx={{ height: '100%' }}>
                    {renderMainContent()}
                </Container>
            </Box>

            {/* Article Content Modal */}
            <Dialog
                open={articleModal.open}
                onClose={handleArticleModalClose}
                maxWidth="lg"
                fullWidth
                PaperProps={{
                    sx: {
                        borderRadius: '24px',
                        border: `4px solid ${THEME.success}`,
                        boxShadow: `8px 8px 0 ${alpha(THEME.success, 0.3)}`,
                        maxHeight: '90vh',
                        overflow: 'hidden'
                    }
                }}
            >
                {articleModal.article && (
                    <>
                        <DialogTitle
                            sx={{
                                pb: 1,
                                background: THEME.gradient.success,
                                color: 'white',
                                borderRadius: '20px 20px 0 0',
                                borderBottom: `3px solid ${THEME.accent}`
                            }}
                        >
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <Box>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                                        <Chip
                                            icon={<CheckCircleIcon />}
                                            label="Published 🌟"
                                            size="small"
                                            sx={{
                                                bgcolor: 'rgba(255,255,255,0.2)',
                                                color: 'white',
                                                border: '2px solid white',
                                                fontWeight: 600
                                            }}
                                        />
                                    </Box>
                                    <Typography variant="h5" sx={{ fontWeight: 700, mb: 1 }}>
                                        {articleModal.article.title}
                                    </Typography>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flexWrap: 'wrap' }}>
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                            <Avatar sx={{ width: 24, height: 24, bgcolor: 'rgba(255,255,255,0.2)' }}>
                                                {articleModal.article.writer.name.charAt(0)}
                                            </Avatar>
                                            <Typography variant="body2" sx={{ opacity: 0.9 }}>
                                                By {articleModal.article.writer.name}
                                            </Typography>
                                        </Box>
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                            <CalendarTodayIcon sx={{ fontSize: 16, opacity: 0.8 }} />
                                            <Typography variant="body2" sx={{ opacity: 0.8 }}>
                                                Published {formatDateTime(articleModal.article.updated_at)}
                                            </Typography>
                                        </Box>
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                            <ScheduleIcon sx={{ fontSize: 16, opacity: 0.8 }} />
                                            <Typography variant="body2" sx={{ opacity: 0.8 }}>
                                                Submitted {formatDateTime(articleModal.article.created_at)}
                                            </Typography>
                                        </Box>
                                    </Box>
                                </Box>
                                <IconButton onClick={handleArticleModalClose} sx={{ color: 'white', '&:hover': { transform: 'scale(1.1)' } }}>
                                    <Close />
                                </IconButton>
                            </Box>
                        </DialogTitle>

                        <DialogContent sx={{ p: 0 }}>
                            <Box sx={{ p: 4, pb: 2 }}>
                                <Typography
                                    variant="body1"
                                    sx={{
                                        lineHeight: 1.8,
                                        color: '#374151',
                                        fontSize: '1.1rem'
                                    }}
                                    dangerouslySetInnerHTML={{ __html: articleModal.article.content }}
                                />
                            </Box>

                            <Divider />

                            <Box sx={{ p: 4 }}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                                    <Typography variant="h6" sx={{ fontWeight: 700, color: '#111827', display: 'flex', alignItems: 'center', gap: 1 }}>
                                        <CommentIcon sx={{ color: THEME.primary }} />
                                        Comments ({articleModal.article.comments_count || 0})
                                    </Typography>
                                    <Typography variant="caption" sx={{ color: '#6b7280', fontStyle: 'italic' }}>
                                        Click on any comment to see the exact time it was posted
                                    </Typography>
                                </Box>

                                {articleModal.article.comments && articleModal.article.comments.length > 0 ? (
                                    <List sx={{ width: '100%' }}>
                                        {articleModal.article.comments.map((comment) => (
                                            <ListItem key={comment.id} alignItems="flex-start" sx={{ px: 0 }}>
                                                <ListItemAvatar>
                                                    <Avatar sx={{ bgcolor: alpha(THEME.primary, 0.1), color: THEME.primary, border: `2px solid ${THEME.accent}` }}>
                                                        {comment.user?.name?.charAt(0) || 'C'}
                                                    </Avatar>
                                                </ListItemAvatar>
                                                <ListItemText
                                                    primary={
                                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: '#111827' }}>
                                                                    {comment.user?.name || 'Anonymous Commentator'}
                                                                </Typography>
                                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                                    <ScheduleIcon sx={{ fontSize: 12, color: '#6b7280' }} />
                                                                    <Typography variant="caption" sx={{ color: '#6b7280', fontWeight: 500 }}>
                                                                        {formatDateTime(comment.created_at)}
                                                                    </Typography>
                                                                    {comment.updated_at && comment.updated_at !== comment.created_at && (
                                                                        <Typography variant="caption" sx={{ color: '#059669', fontWeight: 500, ml: 1 }}>
                                                                            • edited {formatDateTime(comment.updated_at)}
                                                                        </Typography>
                                                                    )}
                                                                </Box>
                                                            </Box>
                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                {editingComment === comment.id ? (
                                                                    <>
                                                                        <IconButton
                                                                            size="small"
                                                                            sx={{ 
                                                                                color: THEME.success,
                                                                                '&:hover': { transform: 'scale(1.1)' }
                                                                            }}
                                                                            onClick={() => handleSaveEdit(comment.id)}
                                                                        >
                                                                            <CheckCircleIcon fontSize="small" />
                                                                        </IconButton>
                                                                        <IconButton
                                                                            size="small"
                                                                            sx={{ 
                                                                                color: THEME.error,
                                                                                '&:hover': { transform: 'scale(1.1)' }
                                                                            }}
                                                                            onClick={handleCancelEdit}
                                                                        >
                                                                            <CancelIcon fontSize="small" />
                                                                        </IconButton>
                                                                    </>
                                                                ) : (
                                                                    <>
                                                                        <IconButton
                                                                            size="small"
                                                                            sx={{ 
                                                                                color: THEME.primary,
                                                                                '&:hover': { transform: 'scale(1.1)' }
                                                                            }}
                                                                            onClick={() => handleEditComment(comment)}
                                                                        >
                                                                            <EditIcon fontSize="small" />
                                                                        </IconButton>
                                                                        <IconButton
                                                                            size="small"
                                                                            sx={{ 
                                                                                color: THEME.error,
                                                                                '&:hover': { transform: 'scale(1.1)' }
                                                                            }}
                                                                            onClick={() => handleDeleteComment(comment.id)}
                                                                        >
                                                                            <DeleteIcon fontSize="small" />
                                                                        </IconButton>
                                                                    </>
                                                                )}
                                                            </Box>
                                                        </Box>
                                                    }
                                                    secondary={
                                                        editingComment === comment.id ? (
                                                            <TextField
                                                                fullWidth
                                                                multiline
                                                                rows={3}
                                                                value={editContent}
                                                                onChange={(e) => setEditContent(e.target.value)}
                                                                onKeyDown={(e) => {
                                                                    if (e.key === 'Enter' && e.ctrlKey) {
                                                                        e.preventDefault();
                                                                        handleSaveEdit(comment.id);
                                                                    }
                                                                    if (e.key === 'Escape') {
                                                                        e.preventDefault();
                                                                        handleCancelEdit();
                                                                    }
                                                                }}
                                                                sx={{
                                                                    mt: 1,
                                                                    '& .MuiOutlinedInput-root': {
                                                                        borderRadius: 2,
                                                                        bgcolor: 'rgba(99, 102, 241, 0.02)',
                                                                        '&:hover fieldset': { borderColor: THEME.primary },
                                                                        '&.Mui-focused fieldset': { borderColor: THEME.primary }
                                                                    }
                                                                }}
                                                                autoFocus
                                                                placeholder="Edit your comment..."
                                                                helperText="Ctrl+Enter to save, Esc to cancel"
                                                            />
                                                        ) : (
                                                            <Typography
                                                                variant="body2"
                                                                sx={{
                                                                    color: '#374151',
                                                                    mt: 1,
                                                                    lineHeight: 1.6,
                                                                    fontSize: '0.95rem'
                                                                }}
                                                            >
                                                                {comment.content || comment.comment}
                                                            </Typography>
                                                        )
                                                    }
                                                />
                                            </ListItem>
                                        ))}
                                    </List>
                                ) : (
                                    <Box sx={{ textAlign: 'center', py: 4 }}>
                                        <Typography variant="body2" sx={{ color: '#6b7280' }}>
                                            No comments yet. This article hasn't received any feedback from readers. 📝
                                        </Typography>
                                    </Box>
                                )}
                            </Box>
                        </DialogContent>

                        <DialogActions sx={{ p: 3, pt: 0 }}>
                            <Button
                                onClick={handleArticleModalClose}
                                variant="outlined"
                                sx={{
                                    borderRadius: '30px',
                                    px: 4,
                                    textTransform: 'none',
                                    borderColor: alpha(THEME.primary, 0.3),
                                    color: THEME.primary,
                                    '&:hover': {
                                        borderColor: THEME.primary,
                                        bgcolor: alpha(THEME.primary, 0.04),
                                        transform: 'scale(1.05)'
                                    }
                                }}
                            >
                                Close
                            </Button>
                        </DialogActions>
                    </>
                )}
            </Dialog>

            {/* Floating Action Button for Quick Access */}
            {activeNav !== 'pending' && pending.length > 0 && (
                <Tooltip title="Quick Review" arrow>
                    <Fab
                        color="primary"
                        sx={{
                            position: 'fixed',
                            bottom: 24,
                            right: 24,
                            background: THEME.gradient.warning,
                            width: 64,
                            height: 64,
                            border: '4px solid white',
                            boxShadow: `6px 6px 0 ${alpha(THEME.warning, 0.3)}`,
                            '&:hover': {
                                transform: 'scale(1.1) rotate(360deg)',
                                boxShadow: `8px 8px 0 ${alpha(THEME.warning, 0.3)}`
                            },
                            transition: 'all 0.5s ease'
                        }}
                        onClick={() => setActiveNav('pending')}
                    >
                        <RateReviewIcon sx={{ fontSize: 32 }} />
                        <Badge
                            badgeContent={pending.length}
                            color="error"
                            sx={{
                                position: 'absolute',
                                top: -5,
                                right: -5,
                                '& .MuiBadge-badge': {
                                    bgcolor: THEME.error,
                                    color: 'white',
                                    fontWeight: 'bold',
                                    animation: 'pulse 2s infinite'
                                }
                            }}
                        />
                    </Fab>
                </Tooltip>
            )}
        </Box>
    );
}