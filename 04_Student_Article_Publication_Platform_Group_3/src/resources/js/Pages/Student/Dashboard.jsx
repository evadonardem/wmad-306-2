import React, { useState, useEffect } from 'react';
import {
    Box,
    Container,
    Typography,
    Button,
    TextField,
    Card,
    CardContent,
    CardActions,
    CardMedia,
    Grid,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    AppBar,
    Toolbar,
    Drawer,
    List,
    ListItem,
    ListItemIcon,
    ListItemText,
    ListItemAvatar,
    Paper,
    Divider,
    Chip,
    Avatar,
    Fade,
    Select,
    MenuItem,
    Menu,
    IconButton,
    InputAdornment,
    Badge,
    Stack,
    alpha,
    Tooltip,
    Zoom,
    LinearProgress,
    Rating,
    useTheme,
    useMediaQuery,
    Fab
} from '@mui/material';
import {
    AccountCircle as AccountCircleIcon,
    Logout as LogoutIcon,
    SwapHoriz as SwapHorizIcon,
    Home as HomeIcon,
    Send as SendIcon,
    Comment as CommentIcon,
    Person as PersonIcon,
    MenuBook as MenuBookIcon,
    Chat as ChatIcon,
    Dashboard as DashboardIcon,
    Search as SearchIcon,
    Bookmark as BookmarkIcon,
    BookmarkBorder as BookmarkBorderIcon,
    Share as ShareIcon,
    Visibility as VisibilityIcon,
    CalendarToday as CalendarTodayIcon,
    Schedule as ScheduleIcon,
    TrendingUp as TrendingUpIcon,
    EmojiEvents as EmojiEventsIcon,
    AutoStories as AutoStoriesIcon,
    Favorite as FavoriteIcon,
    FavoriteBorder as FavoriteBorderIcon,
    Edit as EditIcon,
    Delete as DeleteIcon,
    ArrowForward as ArrowForwardIcon,
    Close as CloseIcon,
    Whatshot as FireIcon,
    Waves as WavesIcon,
    Forest as ForestIcon,
    WbSunny as SunIcon,
    Nightlight as MoonIcon,
    EmojiEmotions as EmojiIcon,
    Cloud as CloudIcon,
    RocketLaunch as RocketLaunchIcon,
    Lightbulb as LightbulbIcon,
    School as SchoolIcon,
    Star as StarIcon
} from '@mui/icons-material';
import { Inertia } from '@inertiajs/inertia';

// Student Dashboard Theme - Fresh & Playful
const THEME = {
    primary: '#2A9D8F',      // Teal - calm and focused
    primaryLight: '#64B6AC',
    primaryDark: '#21867A',
    secondary: '#E76F51',    // Coral - energetic and engaging
    secondaryLight: '#F4A261',
    secondaryDark: '#E63946',
    accent: '#F4A261',        // Warm orange - highlights
    accentLight: '#FFE66D',
    success: '#2A9D8F',
    warning: '#E9C46A',
    info: '#61A5C2',
    purple: '#9B6B9E',        // Soft purple - magical
    pink: '#FF8A80',          // Soft pink - sweet
    green: '#6BAA6B',         // Forest green - nature
    blue: '#6B8CFF',          // Sky blue - calm
    background: {
        main: '#F8F9FA',
        paper: '#FFFFFF',
        gradient: 'linear-gradient(135deg, #F8F9FA 0%, #E9ECEF 100%)',
        playful: 'radial-gradient(circle at 10% 20%, #F4A26120 0%, transparent 20%), radial-gradient(circle at 90% 80%, #2A9D8F20 0%, transparent 20%)'
    },
    text: {
        primary: '#264653',
        secondary: '#5A6B7A',
        light: '#8D9AA9'
    },
    gradient: {
        primary: 'linear-gradient(135deg, #2A9D8F 0%, #21867A 100%)',
        secondary: 'linear-gradient(135deg, #E76F51 0%, #E63946 100%)',
        accent: 'linear-gradient(135deg, #F4A261 0%, #E9C46A 100%)',
        card: 'linear-gradient(135deg, rgba(42, 157, 143, 0.05) 0%, rgba(231, 111, 81, 0.05) 100%)',
        magical: 'linear-gradient(135deg, #9B6B9E 0%, #6B8CFF 100%)'
    },
    shadows: {
        small: '2px 2px 0 rgba(0,0,0,0.1)',
        medium: '4px 4px 0 rgba(0,0,0,0.1)',
        large: '8px 8px 0 rgba(0,0,0,0.1)',
        hover: '12px 12px 0 rgba(0,0,0,0.1)'
    }
};

const DRAWER_WIDTH = 280;

export default function Dashboard({ articles, comments, categories: serverCategories, auth }) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [activeNav, setActiveNav] = useState('dashboard');
    const [selectedCategory, setSelectedCategory] = useState('');
    const [categories] = useState(serverCategories && serverCategories.length > 0 ? serverCategories : []);
    const [commentText, setCommentText] = useState('');
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [openDialog, setOpenDialog] = useState(false);
    const [profileAnchor, setProfileAnchor] = useState(null);
    const [articleModalOpen, setArticleModalOpen] = useState(false);
    const [selectedArticleForModal, setSelectedArticleForModal] = useState(null);
    const [editingCommentId, setEditingCommentId] = useState(null);
    const [editCommentText, setEditCommentText] = useState('');
    const [searchQuery, setSearchQuery] = useState('');
    const [bookmarkedArticles, setBookmarkedArticles] = useState([]);
    const [likedArticles, setLikedArticles] = useState([]);
    const [floatingIcons, setFloatingIcons] = useState([]);
    const [readingStreak, setReadingStreak] = useState(0);
    const [dailyGoal, setDailyGoal] = useState(0);

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

    useEffect(() => {
        generateFloatingIcons();
        calculateReadingStreak();
    }, []);

    const generateFloatingIcons = () => {
        const icons = [
            <EmojiIcon />, <SchoolIcon />, <CloudIcon />, <RocketLaunchIcon />, 
            <LightbulbIcon />, <MenuBookIcon />, <AutoStoriesIcon />,
            <FireIcon />, <WavesIcon />, <ForestIcon />, <SunIcon />, <MoonIcon />
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

    const calculateReadingStreak = () => {
        // Simulate reading streak based on comments activity
        const streak = Math.floor(comments.length / 3) + 1;
        setReadingStreak(streak);
        
        // Calculate daily goal progress (simulated)
        const goal = Math.min(Math.floor(comments.length * 0.2), 10);
        setDailyGoal(goal);
    };

    const handleOpenDialog = (article) => {
        setSelectedArticle(article);
        setOpenDialog(true);
        setCommentText('');
    };

    const handleCloseDialog = () => {
        setOpenDialog(false);
        setSelectedArticle(null);
        setCommentText('');
    };

    const handleOpenArticleModal = (article) => {
        setSelectedArticleForModal(article);
        setArticleModalOpen(true);
    };

    const handleCloseArticleModal = () => {
        setArticleModalOpen(false);
        setSelectedArticleForModal(null);
        setEditingCommentId(null);
        setEditCommentText('');
    };

    const handleEditComment = (comment) => {
        setEditingCommentId(comment.id);
        setEditCommentText(comment.content);
    };

    const handleSaveEdit = () => {
        if (editingCommentId && editCommentText.trim()) {
            Inertia.put(
                route('comments.update', editingCommentId),
                { content: editCommentText },
                {
                    onSuccess: () => {
                        setEditingCommentId(null);
                        setEditCommentText('');
                    },
                }
            );
        }
    };

    const handleCancelEdit = () => {
        setEditingCommentId(null);
        setEditCommentText('');
    };

    const handleDeleteComment = (commentId) => {
        if (confirm('Are you sure you want to delete this comment?')) {
            Inertia.delete(route('comments.destroy', commentId));
        }
    };

    const postComment = () => {
        if (selectedArticle && commentText.trim()) {
            Inertia.post(
                route('student.articles.comment', selectedArticle.id),
                { content: commentText },
                {
                    onSuccess: () => {
                        handleCloseDialog();
                        setDailyGoal(prev => Math.min(prev + 1, 10));
                    },
                }
            );
        }
    };

    const toggleBookmark = (articleId) => {
        setBookmarkedArticles(prev =>
            prev.includes(articleId)
                ? prev.filter(id => id !== articleId)
                : [...prev, articleId]
        );
    };

    const toggleLike = (articleId) => {
        setLikedArticles(prev =>
            prev.includes(articleId)
                ? prev.filter(id => id !== articleId)
                : [...prev, articleId]
        );
    };

    const getReadTime = (content) => {
        const wordsPerMinute = 200;
        const wordCount = content?.replace(/<[^>]*>/g, '').split(/\s+/).length || 0;
        return Math.ceil(wordCount / wordsPerMinute);
    };

    const truncateText = (text, length = 120) => {
        if (!text) return '';
        const plainText = text.replace(/<[^>]*>/g, '');
        return plainText.length > length ? plainText.substring(0, length) + '...' : plainText;
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
                                    <AutoStoriesIcon sx={{ fontSize: 60, color: 'rgba(255,255,255,0.2)' }} />
                                </Box>
                                <Box sx={{
                                    position: 'absolute',
                                    bottom: 20,
                                    right: '15%',
                                    animation: 'float 8s infinite ease-in-out',
                                    animationDelay: '1s'
                                }}>
                                    <SchoolIcon sx={{ fontSize: 50, color: 'rgba(255,255,255,0.2)' }} />
                                </Box>

                                <Box sx={{ position: 'relative', zIndex: 1 }}>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                        <Chip
                                            icon={<EmojiIcon />}
                                            label="Welcome to Your Learning Adventure!"
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
                                        {readingStreak > 0 && (
                                            <Chip
                                                icon={<FireIcon />}
                                                label={`${readingStreak} Day Streak!`}
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
                                        Welcome back, {auth?.user?.name?.split(' ')[0] || 'Student'}! 
                                        <Box component="span" sx={{ display: 'inline-block', ml: 1, animation: 'wave 2s infinite' }}>
                                            👋
                                        </Box>
                                    </Typography>
                                    
                                    <Typography variant="body1" sx={{ opacity: 0.9, mb: 3, fontSize: '1.2rem' }}>
                                        Discover new knowledge and engage with our community
                                    </Typography>
                                    
                                    <Stack direction="row" spacing={2} flexWrap="wrap" sx={{ gap: 1 }}>
                                        <Chip
                                            icon={<AutoStoriesIcon />}
                                            label={`${articles.length} Articles Available`}
                                            sx={{ 
                                                bgcolor: 'rgba(255,255,255,0.2)', 
                                                color: 'white',
                                                border: '2px solid white',
                                                fontSize: '1rem',
                                                '&:hover': { bgcolor: 'rgba(255,255,255,0.3)' }
                                            }}
                                        />
                                        <Chip
                                            icon={<ChatIcon />}
                                            label={`${comments.length} Your Comments`}
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

                            {/* Daily Reading Goal */}
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
                                            Daily Reading Goal
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                            {dailyGoal}/10 comments today
                                        </Typography>
                                    </Box>
                                </Box>
                                <Box sx={{ minWidth: 200 }}>
                                    <LinearProgress
                                        variant="determinate"
                                        value={(dailyGoal / 10) * 100}
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
                                        {dailyGoal >= 10 ? '🎉 Goal achieved! Great job!' : `${10 - dailyGoal} more to go!`}
                                    </Typography>
                                </Box>
                            </Paper>

                            {/* Statistics Cards with Playful Design */}
                            <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <DashboardIcon sx={{ color: THEME.primary }} />
                                Reading Overview
                            </Typography>

                            <Grid container spacing={3} sx={{ mb: 4 }}>
                                {[
                                    { label: 'Total Articles', count: articles.length, icon: <MenuBookIcon />, color: THEME.primary, emoji: '📚', gradient: THEME.gradient.primary },
                                    { label: 'Your Comments', count: comments.length, icon: <ChatIcon />, color: THEME.secondary, emoji: '💬', gradient: THEME.gradient.secondary },
                                    { label: 'Categories', count: categories.length, icon: <EmojiEventsIcon />, color: THEME.accent, emoji: '🏆', gradient: THEME.gradient.accent },
                                    { label: 'Bookmarked', count: bookmarkedArticles.length, icon: <BookmarkIcon />, color: THEME.purple, emoji: '🔖', gradient: THEME.gradient.magical }
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
                                                    
                                                    <Typography variant="body1" sx={{ color: THEME.text.secondary, fontWeight: 600, mb: 2 }}>
                                                        {stat.label}
                                                    </Typography>
                                                    
                                                    <LinearProgress
                                                        variant="determinate"
                                                        value={index === 0 ? 75 : index === 1 ? (comments.length / 20) * 100 : index === 2 ? 60 : (bookmarkedArticles.length / articles.length) * 100}
                                                        sx={{
                                                            height: 6,
                                                            borderRadius: 3,
                                                            bgcolor: alpha(stat.color, 0.1),
                                                            '& .MuiLinearProgress-bar': {
                                                                background: stat.gradient,
                                                                borderRadius: 3
                                                            }
                                                        }}
                                                    />
                                                </CardContent>
                                            </Card>
                                        </Zoom>
                                    </Grid>
                                ))}
                            </Grid>

                            {/* Featured Articles Section */}
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                                <Typography variant="h5" sx={{ fontWeight: 700, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <StarIcon sx={{ color: THEME.accent }} />
                                    Featured Articles
                                </Typography>
                                <Button
                                    endIcon={<ArrowForwardIcon />}
                                    onClick={() => setActiveNav('articles')}
                                    sx={{ color: THEME.primary, fontWeight: 600 }}
                                >
                                    View All
                                </Button>
                            </Box>

                            <Grid container spacing={3} sx={{ mb: 4 }}>
                                {articles.slice(0, 3).map((article, index) => (
                                    <Grid item xs={12} md={4} key={article.id}>
                                        <Zoom in timeout={700 + index * 100}>
                                            <Card
                                                elevation={0}
                                                sx={{
                                                    height: '100%',
                                                    borderRadius: '20px',
                                                    background: THEME.background.card,
                                                    border: `3px solid ${alpha(THEME.primary, 0.2)}`,
                                                    boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.2)}`,
                                                    transition: 'all 0.3s ease',
                                                    '&:hover': {
                                                        transform: 'translateY(-8px) translateX(-4px)',
                                                        boxShadow: `8px 8px 0 ${alpha(THEME.primary, 0.2)}`,
                                                        borderColor: THEME.primary
                                                    }
                                                }}
                                            >
                                                <CardMedia
                                                    component="img"
                                                    height="160"
                                                    image={article.image_url || `https://source.unsplash.com/random/400x200?${index}`}
                                                    alt={article.title}
                                                    sx={{ objectFit: 'cover' }}
                                                />
                                                <CardContent sx={{ p: 3 }}>
                                                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                                                        <Chip
                                                            label={article.category.name}
                                                            size="small"
                                                            sx={{
                                                                bgcolor: alpha(THEME.primary, 0.1),
                                                                color: THEME.primary,
                                                                fontWeight: 600
                                                            }}
                                                        />
                                                        <Box sx={{ display: 'flex', gap: 0.5 }}>
                                                            <IconButton
                                                                size="small"
                                                                onClick={() => toggleBookmark(article.id)}
                                                                sx={{ 
                                                                    color: bookmarkedArticles.includes(article.id) ? THEME.secondary : THEME.text.light,
                                                                    '&:hover': { transform: 'scale(1.1)' }
                                                                }}
                                                            >
                                                                {bookmarkedArticles.includes(article.id) ? <BookmarkIcon fontSize="small" /> : <BookmarkBorderIcon fontSize="small" />}
                                                            </IconButton>
                                                            <IconButton
                                                                size="small"
                                                                onClick={() => toggleLike(article.id)}
                                                                sx={{ 
                                                                    color: likedArticles.includes(article.id) ? '#E76F51' : THEME.text.light,
                                                                    '&:hover': { transform: 'scale(1.1)' }
                                                                }}
                                                            >
                                                                {likedArticles.includes(article.id) ? <FavoriteIcon fontSize="small" /> : <FavoriteBorderIcon fontSize="small" />}
                                                            </IconButton>
                                                        </Box>
                                                    </Box>

                                                    <Typography variant="h6" sx={{ fontWeight: 700, mb: 1, color: THEME.text.primary }}>
                                                        {article.title}
                                                    </Typography>

                                                    <Typography variant="body2" sx={{ color: THEME.text.secondary, mb: 2, lineHeight: 1.6 }}>
                                                        {truncateText(article.content, 100)}
                                                    </Typography>

                                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                                        <Avatar
                                                            sx={{
                                                                width: 24,
                                                                height: 24,
                                                                bgcolor: alpha(THEME.secondary, 0.1),
                                                                fontSize: '0.75rem',
                                                                color: THEME.secondary
                                                            }}
                                                        >
                                                            {article.writer?.name?.charAt(0) || 'A'}
                                                        </Avatar>
                                                        <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                                            {article.writer?.name || 'Author'}
                                                        </Typography>
                                                        <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                            • {getReadTime(article.content)} min read
                                                        </Typography>
                                                    </Box>

                                                    <Button
                                                        fullWidth
                                                        variant="outlined"
                                                        endIcon={<ArrowForwardIcon />}
                                                        onClick={() => handleOpenArticleModal(article)}
                                                        sx={{
                                                            borderColor: alpha(THEME.primary, 0.3),
                                                            color: THEME.primary,
                                                            borderRadius: '20px',
                                                            borderWidth: 2,
                                                            '&:hover': {
                                                                borderColor: THEME.primary,
                                                                bgcolor: alpha(THEME.primary, 0.04),
                                                                transform: 'scale(1.02)'
                                                            }
                                                        }}
                                                    >
                                                        Read Article
                                                    </Button>
                                                </CardContent>
                                            </Card>
                                        </Zoom>
                                    </Grid>
                                ))}
                            </Grid>

                            {/* Recent Activity with Playful Design */}
                            {comments.length > 0 && (
                                <Box>
                                    <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                        <TrendingUpIcon sx={{ color: THEME.secondary }} />
                                        Recent Activity
                                    </Typography>
                                    <Paper
                                        elevation={0}
                                        sx={{
                                            borderRadius: '16px',
                                            p: 3,
                                            background: 'white',
                                            border: `3px solid ${alpha(THEME.secondary, 0.2)}`,
                                            boxShadow: `4px 4px 0 ${alpha(THEME.secondary, 0.2)}`
                                        }}
                                    >
                                        <Stack spacing={2}>
                                            {comments.slice(0, 5).map((comment, index) => (
                                                <Box
                                                    key={comment.id}
                                                    sx={{
                                                        display: 'flex',
                                                        alignItems: 'center',
                                                        gap: 2,
                                                        p: 2,
                                                        borderRadius: '12px',
                                                        bgcolor: alpha(THEME.primary, 0.02),
                                                        transition: 'all 0.2s ease',
                                                        animation: `slideIn 0.5s ease ${index * 0.1}s`,
                                                        '@keyframes slideIn': {
                                                            '0%': { opacity: 0, transform: 'translateX(-20px)' },
                                                            '100%': { opacity: 1, transform: 'translateX(0)' }
                                                        },
                                                        '&:hover': {
                                                            bgcolor: alpha(THEME.primary, 0.05),
                                                            transform: 'translateX(4px)'
                                                        }
                                                    }}
                                                >
                                                    <Avatar
                                                        sx={{
                                                            bgcolor: alpha(THEME.secondary, 0.1),
                                                            color: THEME.secondary,
                                                            border: `2px solid ${THEME.accent}`
                                                        }}
                                                    >
                                                        <ChatIcon fontSize="small" />
                                                    </Avatar>
                                                    <Box sx={{ flex: 1 }}>
                                                        <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                            Commented on "{comment.article?.title || 'Article'}"
                                                        </Typography>
                                                        <Typography variant="caption" sx={{ color: THEME.text.light, display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                            <CalendarTodayIcon sx={{ fontSize: 12 }} />
                                                            {new Date(comment.created_at).toLocaleDateString()} • {new Date(comment.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                                        </Typography>
                                                    </Box>
                                                    <Chip
                                                        size="small"
                                                        label="View"
                                                        onClick={() => handleOpenArticleModal(comment.article)}
                                                        sx={{
                                                            bgcolor: alpha(THEME.primary, 0.1),
                                                            color: THEME.primary,
                                                            cursor: 'pointer',
                                                            '&:hover': {
                                                                bgcolor: alpha(THEME.primary, 0.2),
                                                                transform: 'scale(1.05)'
                                                            }
                                                        }}
                                                    />
                                                </Box>
                                            ))}
                                        </Stack>
                                    </Paper>
                                </Box>
                            )}
                        </Box>
                    </Fade>
                );

            case 'articles':
                return (
                    <Fade in={activeNav === 'articles'} timeout={500}>
                        <Box>
                            <Box sx={{ mb: 4 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                    <Box
                                        sx={{
                                            width: 50,
                                            height: 50,
                                            borderRadius: '12px',
                                            background: THEME.gradient.primary,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center'
                                        }}
                                    >
                                        <MenuBookIcon sx={{ color: 'white' }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                            Published Articles
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                            Explore our collection of insightful articles
                                        </Typography>
                                    </Box>
                                </Box>
                            </Box>

                            {/* Search and Filter Bar with Playful Design */}
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 2,
                                    mb: 4,
                                    borderRadius: '30px',
                                    bgcolor: 'white',
                                    border: `3px solid ${alpha(THEME.primary, 0.2)}`,
                                    boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.2)}`,
                                    display: 'flex',
                                    gap: 2,
                                    alignItems: 'center',
                                    flexWrap: 'wrap'
                                }}
                            >
                                <TextField
                                    placeholder="Search articles... 🔍"
                                    value={searchQuery}
                                    onChange={(e) => setSearchQuery(e.target.value)}
                                    size="small"
                                    sx={{
                                        flex: 1,
                                        minWidth: 250,
                                        '& .MuiOutlinedInput-root': {
                                            borderRadius: '30px',
                                            bgcolor: alpha(THEME.background.main, 0.5),
                                            '&:hover fieldset': { borderColor: THEME.primary }
                                        }
                                    }}
                                    InputProps={{
                                        startAdornment: (
                                            <InputAdornment position="start">
                                                <SearchIcon sx={{ color: THEME.text.light }} />
                                            </InputAdornment>
                                        ),
                                    }}
                                />

                                <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                                    <Typography variant="body2" sx={{ color: THEME.text.secondary, fontWeight: 600 }}>
                                        📚 Category:
                                    </Typography>
                                    <Select
                                        value={selectedCategory}
                                        onChange={(e) => setSelectedCategory(e.target.value ? Number(e.target.value) : '')}
                                        displayEmpty
                                        size="small"
                                        sx={{
                                            minWidth: 150,
                                            borderRadius: '30px',
                                            '& .MuiOutlinedInput-notchedOutline': {
                                                borderColor: alpha(THEME.primary, 0.2),
                                                borderWidth: 2
                                            },
                                            '&:hover .MuiOutlinedInput-notchedOutline': {
                                                borderColor: THEME.primary
                                            }
                                        }}
                                    >
                                        <MenuItem value="">All Categories</MenuItem>
                                        {categories.map((c) => (
                                            <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>
                                        ))}
                                    </Select>
                                </Box>
                            </Paper>

                            {articles.length === 0 ? (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        p: 6,
                                        borderRadius: '24px',
                                        bgcolor: 'white',
                                        textAlign: 'center',
                                        border: `4px solid ${alpha(THEME.primary, 0.2)}`,
                                        boxShadow: THEME.shadows.medium
                                    }}
                                >
                                    <AutoStoriesIcon sx={{ fontSize: 80, color: THEME.text.light, mb: 2, animation: 'float 3s infinite' }} />
                                    <Typography variant="h5" sx={{ color: THEME.text.primary, mb: 1, fontWeight: 600 }}>
                                        No Articles Yet
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                        Check back soon for new content!
                                    </Typography>
                                </Paper>
                            ) : (
                                <Grid container spacing={3}>
                                    {articles
                                        .filter(a => !selectedCategory || a.category?.id === selectedCategory)
                                        .filter(a => 
                                            searchQuery === '' || 
                                            a.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                                            (a.writer?.name || '').toLowerCase().includes(searchQuery.toLowerCase())
                                        )
                                        .map((article, index) => (
                                            <Grid key={article.id} item xs={12}>
                                                <Zoom in timeout={300 + index * 100}>
                                                    <Card
                                                        elevation={0}
                                                        sx={{
                                                            borderRadius: '20px',
                                                            background: 'white',
                                                            border: `3px solid ${alpha(THEME.primary, 0.2)}`,
                                                            boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.2)}`,
                                                            transition: 'all 0.3s ease',
                                                            '&:hover': {
                                                                transform: 'translateX(8px) translateY(-4px)',
                                                                boxShadow: `8px 8px 0 ${alpha(THEME.primary, 0.2)}`,
                                                                borderColor: THEME.primary
                                                            }
                                                        }}
                                                    >
                                                        <CardContent sx={{ p: 3 }}>
                                                            <Grid container spacing={2}>
                                                                <Grid item xs={12} md={8}>
                                                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                                        <Avatar
                                                                            sx={{
                                                                                bgcolor: alpha(THEME.secondary, 0.1),
                                                                                color: THEME.secondary,
                                                                                border: `2px solid ${THEME.accent}`
                                                                            }}
                                                                        >
                                                                            {article.writer?.name?.charAt(0) || 'A'}
                                                                        </Avatar>
                                                                        <Box>
                                                                            <Typography variant="subtitle1" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                                                {article.writer?.name || 'Author'}
                                                                            </Typography>
                                                                            <Typography variant="caption" sx={{ color: THEME.text.light, display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                                                <SchoolIcon sx={{ fontSize: 12 }} />
                                                                                {article.writer?.email || 'writer@example.com'}
                                                                            </Typography>
                                                                        </Box>
                                                                    </Box>

                                                                    <Typography variant="h5" sx={{ fontWeight: 700, mb: 1, color: THEME.text.primary }}>
                                                                        {article.title}
                                                                    </Typography>

                                                                    <Typography variant="body2" sx={{ color: THEME.text.secondary, mb: 2, lineHeight: 1.6 }}>
                                                                        {truncateText(article.content, 200)}
                                                                    </Typography>

                                                                    <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                                                                        <Chip
                                                                            label={article.category?.name || 'Uncategorized'}
                                                                            size="small"
                                                                            sx={{
                                                                                bgcolor: alpha(THEME.primary, 0.1),
                                                                                color: THEME.primary,
                                                                                fontWeight: 600
                                                                            }}
                                                                        />
                                                                        <Chip
                                                                            icon={<CalendarTodayIcon />}
                                                                            label={new Date(article.created_at).toLocaleDateString()}
                                                                            size="small"
                                                                            sx={{ bgcolor: alpha(THEME.text.light, 0.1), color: THEME.text.secondary }}
                                                                        />
                                                                    </Box>
                                                                </Grid>

                                                                <Grid item xs={12} md={4}>
                                                                    <Box sx={{ 
                                                                        display: 'flex', 
                                                                        flexDirection: 'column', 
                                                                        gap: 1.5,
                                                                        height: '100%',
                                                                        justifyContent: 'center',
                                                                        alignItems: 'flex-end'
                                                                    }}>
                                                                        <Box sx={{ display: 'flex', gap: 1 }}>
                                                                            <Tooltip title={bookmarkedArticles.includes(article.id) ? "Remove Bookmark" : "Add Bookmark"}>
                                                                                <IconButton
                                                                                    size="small"
                                                                                    onClick={() => toggleBookmark(article.id)}
                                                                                    sx={{ 
                                                                                        color: bookmarkedArticles.includes(article.id) ? THEME.secondary : THEME.text.light,
                                                                                        '&:hover': { transform: 'scale(1.1)' }
                                                                                    }}
                                                                                >
                                                                                    {bookmarkedArticles.includes(article.id) ? <BookmarkIcon /> : <BookmarkBorderIcon />}
                                                                                </IconButton>
                                                                            </Tooltip>
                                                                            <Tooltip title={likedArticles.includes(article.id) ? "Unlike" : "Like"}>
                                                                                <IconButton
                                                                                    size="small"
                                                                                    onClick={() => toggleLike(article.id)}
                                                                                    sx={{ 
                                                                                        color: likedArticles.includes(article.id) ? '#E76F51' : THEME.text.light,
                                                                                        '&:hover': { transform: 'scale(1.1)' }
                                                                                    }}
                                                                                >
                                                                                    {likedArticles.includes(article.id) ? <FavoriteIcon /> : <FavoriteBorderIcon />}
                                                                                </IconButton>
                                                                            </Tooltip>
                                                                            <Tooltip title="Share">
                                                                                <IconButton
                                                                                    size="small"
                                                                                    sx={{ 
                                                                                        color: THEME.text.light,
                                                                                        '&:hover': { transform: 'scale(1.1)' }
                                                                                    }}
                                                                                >
                                                                                    <ShareIcon />
                                                                                </IconButton>
                                                                            </Tooltip>
                                                                        </Box>

                                                                        <Button
                                                                            fullWidth
                                                                            variant="contained"
                                                                            startIcon={<VisibilityIcon />}
                                                                            onClick={() => handleOpenArticleModal(article)}
                                                                            sx={{
                                                                                background: THEME.gradient.primary,
                                                                                color: 'white',
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
                                                                            Read Article 📖
                                                                        </Button>

                                                                        <Button
                                                                            fullWidth
                                                                            variant="outlined"
                                                                            startIcon={<CommentIcon />}
                                                                            onClick={() => handleOpenDialog(article)}
                                                                            sx={{
                                                                                borderColor: alpha(THEME.secondary, 0.3),
                                                                                color: THEME.secondary,
                                                                                textTransform: 'none',
                                                                                py: 1.5,
                                                                                borderRadius: '30px',
                                                                                borderWidth: 2,
                                                                                '&:hover': {
                                                                                    borderColor: THEME.secondary,
                                                                                    bgcolor: alpha(THEME.secondary, 0.04),
                                                                                    transform: 'scale(1.02)'
                                                                                }
                                                                            }}
                                                                        >
                                                                            Comment ({article.comments?.length || 0}) 💬
                                                                        </Button>
                                                                    </Box>
                                                                </Grid>
                                                            </Grid>
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

            case 'comments':
                return (
                    <Fade in={activeNav === 'comments'} timeout={500}>
                        <Box>
                            <Box sx={{ mb: 4 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                    <Box
                                        sx={{
                                            width: 50,
                                            height: 50,
                                            borderRadius: '12px',
                                            background: THEME.gradient.secondary,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center'
                                        }}
                                    >
                                        <ChatIcon sx={{ color: 'white' }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                            My Comments
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                            {comments.length} comment{comments.length !== 1 ? 's' : ''} you've shared with the community
                                        </Typography>
                                    </Box>
                                </Box>
                            </Box>

                            {comments.length === 0 ? (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        p: 6,
                                        borderRadius: '24px',
                                        bgcolor: 'white',
                                        textAlign: 'center',
                                        border: `4px solid ${alpha(THEME.secondary, 0.2)}`,
                                        boxShadow: THEME.shadows.medium
                                    }}
                                >
                                    <ChatIcon sx={{ fontSize: 80, color: THEME.text.light, mb: 2, animation: 'float 3s infinite' }} />
                                    <Typography variant="h5" sx={{ color: THEME.text.primary, mb: 1, fontWeight: 600 }}>
                                        No Comments Yet
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                        Start engaging with articles by leaving your thoughts!
                                    </Typography>
                                </Paper>
                            ) : (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        borderRadius: '16px',
                                        bgcolor: 'white',
                                        border: `3px solid ${alpha(THEME.secondary, 0.2)}`,
                                        boxShadow: `4px 4px 0 ${alpha(THEME.secondary, 0.2)}`,
                                        overflow: 'hidden'
                                    }}
                                >
                                    {comments.map((comment, index) => (
                                        <Box
                                            key={comment.id}
                                            sx={{
                                                p: 3,
                                                borderBottom: index !== comments.length - 1 ? `2px solid ${alpha(THEME.primary, 0.1)}` : 'none',
                                                transition: 'all 0.2s ease',
                                                '&:hover': {
                                                    bgcolor: alpha(THEME.primary, 0.02),
                                                    transform: 'translateX(4px)'
                                                }
                                            }}
                                        >
                                            <Grid container spacing={2}>
                                                <Grid item xs={12} md={8}>
                                                    <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2 }}>
                                                        <Avatar
                                                            sx={{
                                                                bgcolor: alpha(THEME.secondary, 0.1),
                                                                color: THEME.secondary,
                                                                border: `2px solid ${THEME.accent}`
                                                            }}
                                                        >
                                                            {auth?.user?.name?.charAt(0) || 'U'}
                                                        </Avatar>
                                                        <Box sx={{ flex: 1 }}>
                                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 1, flexWrap: 'wrap' }}>
                                                                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                                    {auth?.user?.name}
                                                                </Typography>
                                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                                    <CalendarTodayIcon sx={{ fontSize: 12, color: THEME.text.light }} />
                                                                    <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                                        {new Date(comment.created_at).toLocaleDateString()} • {new Date(comment.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                                                    </Typography>
                                                                </Box>
                                                            </Box>

                                                            {editingCommentId === comment.id ? (
                                                                <Box sx={{ mt: 1 }}>
                                                                    <TextField
                                                                        fullWidth
                                                                        multiline
                                                                        rows={3}
                                                                        value={editCommentText}
                                                                        onChange={(e) => setEditCommentText(e.target.value)}
                                                                        variant="outlined"
                                                                        size="small"
                                                                        sx={{
                                                                            mb: 1,
                                                                            '& .MuiOutlinedInput-root': {
                                                                                borderRadius: '12px',
                                                                                '&:hover fieldset': { borderColor: THEME.secondary },
                                                                                '&.Mui-focused fieldset': { borderColor: THEME.secondary }
                                                                            }
                                                                        }}
                                                                    />
                                                                    <Box sx={{ display: 'flex', gap: 1 }}>
                                                                        <Button
                                                                            size="small"
                                                                            variant="contained"
                                                                            onClick={handleSaveEdit}
                                                                            disabled={!editCommentText.trim()}
                                                                            sx={{
                                                                                background: THEME.gradient.primary,
                                                                                fontWeight: 600,
                                                                                borderRadius: '20px'
                                                                            }}
                                                                        >
                                                                            Save
                                                                        </Button>
                                                                        <Button
                                                                            size="small"
                                                                            variant="outlined"
                                                                            onClick={handleCancelEdit}
                                                                            sx={{ 
                                                                                fontWeight: 600,
                                                                                borderRadius: '20px'
                                                                            }}
                                                                        >
                                                                            Cancel
                                                                        </Button>
                                                                    </Box>
                                                                </Box>
                                                            ) : (
                                                                <Typography variant="body1" sx={{ color: THEME.text.primary, mb: 2, lineHeight: 1.6 }}>
                                                                    {comment.content}
                                                                </Typography>
                                                            )}

                                                            <Paper
                                                                sx={{
                                                                    p: 2,
                                                                    bgcolor: alpha(THEME.primary, 0.02),
                                                                    borderRadius: '12px',
                                                                    border: `2px solid ${alpha(THEME.primary, 0.1)}`
                                                                }}
                                                            >
                                                                <Typography variant="caption" sx={{ color: THEME.text.light, display: 'block', mb: 0.5, fontWeight: 600 }}>
                                                                    📌 On article:
                                                                </Typography>
                                                                <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.primary }}>
                                                                    {comment.article?.title || 'Article'}
                                                                </Typography>
                                                            </Paper>
                                                        </Box>
                                                    </Box>
                                                </Grid>

                                                <Grid item xs={12} md={4}>
                                                    <Box sx={{ display: 'flex', gap: 1, justifyContent: 'flex-end', flexWrap: 'wrap' }}>
                                                        <Button
                                                            size="small"
                                                            startIcon={<VisibilityIcon />}
                                                            onClick={() => handleOpenArticleModal(comment.article)}
                                                            sx={{
                                                                color: THEME.primary,
                                                                borderRadius: '20px',
                                                                '&:hover': {
                                                                    bgcolor: alpha(THEME.primary, 0.04),
                                                                    transform: 'scale(1.05)'
                                                                }
                                                            }}
                                                        >
                                                            View Article
                                                        </Button>
                                                        <Button
                                                            size="small"
                                                            startIcon={<EditIcon />}
                                                            onClick={() => handleEditComment(comment)}
                                                            sx={{
                                                                color: THEME.text.secondary,
                                                                borderRadius: '20px',
                                                                '&:hover': {
                                                                    bgcolor: alpha(THEME.primary, 0.04),
                                                                    transform: 'scale(1.05)'
                                                                }
                                                            }}
                                                        >
                                                            Edit
                                                        </Button>
                                                        <Button
                                                            size="small"
                                                            startIcon={<DeleteIcon />}
                                                            onClick={() => handleDeleteComment(comment.id)}
                                                            sx={{
                                                                color: THEME.secondaryDark,
                                                                borderRadius: '20px',
                                                                '&:hover': {
                                                                    bgcolor: alpha(THEME.secondaryDark, 0.04),
                                                                    transform: 'scale(1.05)'
                                                                }
                                                            }}
                                                        >
                                                            Delete
                                                        </Button>
                                                    </Box>
                                                </Grid>
                                            </Grid>
                                        </Box>
                                    ))}
                                </Paper>
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
            background: THEME.background.gradient,
            position: 'relative',
            '&::before': {
                content: '""',
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                background: THEME.background.playful,
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
                            <SchoolIcon sx={{ color: 'white', fontSize: 28 }} />
                        </Box>
                        <Box>
                            <Typography variant="h5" sx={{ fontWeight: 800, color: THEME.text.primary, letterSpacing: '-0.5px' }}>
                                Student Learning Portal
                            </Typography>
                            <Typography variant="caption" sx={{ color: THEME.text.secondary, display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                <EmojiIcon sx={{ fontSize: 14, color: THEME.accent }} />
                                Explore, Learn, Engage
                            </Typography>
                        </Box>
                    </Box>
                    
                    {/* Search Bar */}
                    <TextField
                        placeholder="Search articles... 🔍"
                        size="small"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        sx={{
                            width: 300,
                            mr: 2,
                            '& .MuiOutlinedInput-root': {
                                borderRadius: '30px',
                                bgcolor: alpha(THEME.primary, 0.05),
                                border: `2px solid ${alpha(THEME.primary, 0.2)}`,
                                '&:hover': {
                                    bgcolor: alpha(THEME.primary, 0.1),
                                    borderColor: THEME.primary
                                }
                            }
                        }}
                        InputProps={{
                            startAdornment: (
                                <InputAdornment position="start">
                                    <SearchIcon sx={{ color: THEME.text.light }} />
                                </InputAdornment>
                            ),
                        }}
                    />
                    
                    {/* Home Button */}
                    <Tooltip title="Home">
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
                    <Tooltip title="Profile">
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
                                {auth?.user?.name?.charAt(0) || 'S'}
                            </Avatar>
                        </IconButton>
                    </Tooltip>

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
                            <LogoutIcon sx={{ mr: 1.5, fontSize: 20, color: THEME.secondaryDark }} />
                            Sign Out
                        </MenuItem>
                        <Divider />
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
                        { id: 'dashboard', icon: <DashboardIcon />, label: 'Dashboard', emoji: '📊', badge: null },
                        { id: 'articles', icon: <MenuBookIcon />, label: 'Published Articles', emoji: '📚', badge: articles.length },
                        { id: 'comments', icon: <ChatIcon />, label: 'My Comments', emoji: '💬', badge: comments.length }
                    ].map((item) => (
                        <ListItem
                            key={item.id}
                            button
                            onClick={() => setActiveNav(item.id)}
                            sx={{
                                borderRadius: '16px',
                                mb: 1,
                                bgcolor: activeNav === item.id ? alpha(THEME.primary, 0.08) : 'transparent',
                                border: activeNav === item.id ? `2px solid ${THEME.primary}` : '2px solid transparent',
                                '&:hover': {
                                    bgcolor: activeNav === item.id ? alpha(THEME.primary, 0.12) : alpha(THEME.primary, 0.04),
                                    transform: 'translateX(4px)'
                                },
                                transition: 'all 0.2s ease'
                            }}
                        >
                            <ListItemIcon>
                                <Badge 
                                    badgeContent={item.badge} 
                                    color="primary"
                                    sx={{
                                        '& .MuiBadge-badge': {
                                            bgcolor: THEME.primary,
                                            color: 'white'
                                        }
                                    }}
                                >
                                    {React.cloneElement(item.icon, { 
                                        sx: { color: activeNav === item.id ? THEME.primary : THEME.text.light } 
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
                                primaryTypographyProps={{
                                    sx: { 
                                        fontWeight: activeNav === item.id ? 700 : 500,
                                        color: activeNav === item.id ? THEME.primary : THEME.text.primary
                                    }
                                }}
                            />
                        </ListItem>
                    ))}
                </List>

                <Divider sx={{ my: 2, borderWidth: 2, borderColor: alpha(THEME.primary, 0.1) }} />

                {/* Reading Tips */}
                <Box sx={{ p: 2 }}>
                    <Typography variant="subtitle2" sx={{ color: THEME.text.primary, mb: 2, fontWeight: 700, display: 'flex', alignItems: 'center', gap: 1 }}>
                        <LightbulbIcon sx={{ color: THEME.accent }} />
                        Reading Tips
                    </Typography>
                    <List dense>
                        {[
                            { tip: "Read actively", sub: "Take notes while reading", icon: <EmojiIcon /> },
                            { tip: "Engage with content", sub: "Leave thoughtful comments", icon: <ChatIcon /> },
                            { tip: "Bookmark favorites", sub: "Save articles to read later", icon: <BookmarkIcon /> }
                        ].map((item, index) => (
                            <ListItem key={index} sx={{ px: 0 }}>
                                <ListItemIcon sx={{ minWidth: 32 }}>
                                    <Box sx={{ color: THEME.accent, fontSize: '1.2rem' }}>
                                        {item.icon}
                                    </Box>
                                </ListItemIcon>
                                <ListItemText 
                                    primary={item.tip} 
                                    secondary={item.sub} 
                                    primaryTypographyProps={{ sx: { fontSize: '0.9rem', fontWeight: 600 } }}
                                    secondaryTypographyProps={{ sx: { fontSize: '0.7rem' } }} 
                                />
                            </ListItem>
                        ))}
                    </List>
                </Box>

                {/* Quick Stats with Playful Design */}
                <Box sx={{ mt: 'auto', p: 2 }}>
                    <Paper
                        elevation={0}
                        sx={{
                            p: 2,
                            borderRadius: '16px',
                            background: THEME.gradient.card,
                            border: `3px solid ${alpha(THEME.primary, 0.2)}`,
                            boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.2)}`,
                            transform: 'rotate(-1deg)',
                            '&:hover': {
                                transform: 'rotate(0deg) scale(1.02)'
                            },
                            transition: 'all 0.3s ease'
                        }}
                    >
                        <Typography variant="subtitle2" sx={{ fontWeight: 700, color: THEME.primary, mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                            <EmojiEventsIcon sx={{ fontSize: 18 }} />
                            Your Stats
                        </Typography>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                            <Typography variant="caption" sx={{ color: THEME.text.secondary }}>Articles Read</Typography>
                            <Typography variant="caption" sx={{ fontWeight: 600, color: THEME.primary }}>{Math.floor(articles.length * 0.3)}</Typography>
                        </Box>
                        <LinearProgress
                            variant="determinate"
                            value={30}
                            sx={{
                                height: 6,
                                borderRadius: 3,
                                bgcolor: alpha(THEME.primary, 0.1),
                                '& .MuiLinearProgress-bar': {
                                    background: THEME.gradient.primary,
                                    borderRadius: 3
                                }
                            }}
                        />
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 1 }}>
                            <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                🎯 Daily Goal: {dailyGoal}/10
                            </Typography>
                            {readingStreak > 0 && (
                                <Chip
                                    size="small"
                                    icon={<FireIcon sx={{ fontSize: 12 }} />}
                                    label={`${readingStreak} day streak!`}
                                    sx={{ 
                                        height: 20,
                                        bgcolor: alpha(THEME.secondary, 0.1),
                                        color: THEME.secondary,
                                        fontSize: '0.6rem'
                                    }}
                                />
                            )}
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
                    bgcolor: THEME.background.gradient,
                    position: 'relative',
                    zIndex: 2
                }}
            >
                <Container maxWidth="xl" sx={{ height: '100%' }}>
                    {renderMainContent()}
                </Container>
            </Box>

            {/* Comment Dialog */}
            <Dialog 
                open={openDialog} 
                onClose={handleCloseDialog} 
                maxWidth="md" 
                fullWidth
                PaperProps={{
                    sx: {
                        borderRadius: '24px',
                        overflow: 'hidden',
                        border: `4px solid ${THEME.secondary}`,
                        boxShadow: `8px 8px 0 ${alpha(THEME.secondary, 0.3)}`
                    }
                }}
            >
                <DialogTitle sx={{ 
                    fontWeight: 700, 
                    background: THEME.gradient.secondary, 
                    color: 'white',
                    py: 2,
                    borderBottom: `3px solid ${THEME.accent}`
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <CommentIcon />
                        <Typography variant="h6">Comments & Discussion 💬</Typography>
                    </Box>
                </DialogTitle>
                <DialogContent sx={{ pt: 3, pb: 2 }}>
                    <Typography variant="subtitle2" sx={{ mb: 2, color: THEME.text.primary, fontWeight: 600 }}>
                        Article: {selectedArticle?.title}
                    </Typography>

                    {/* Existing Comments Section */}
                    <Box sx={{ mb: 3, maxHeight: 300, overflowY: 'auto' }}>
                        {selectedArticle?.comments && selectedArticle.comments.length > 0 ? (
                            <>
                                <Typography variant="body2" sx={{ mb: 2, color: THEME.text.secondary, fontWeight: 600 }}>
                                    {selectedArticle.comments.length} Comment{selectedArticle.comments.length !== 1 ? 's' : ''}
                                </Typography>
                                <List sx={{ width: '100%' }}>
                                    {selectedArticle.comments.map((comment) => (
                                        <ListItem key={comment.id} alignItems="flex-start" sx={{ px: 0, mb: 2 }}>
                                            <ListItemAvatar>
                                                <Avatar sx={{ bgcolor: alpha(THEME.secondary, 0.1), color: THEME.secondary, border: `2px solid ${THEME.accent}` }}>
                                                    {comment.user?.name?.charAt(0) || 'A'}
                                                </Avatar>
                                            </ListItemAvatar>
                                            <ListItemText
                                                primary={
                                                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                            <Typography variant="subtitle2" sx={{ fontWeight: 600, color: '#111827' }}>
                                                                {comment.user?.name || 'Anonymous'}
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
                                                    </Box>
                                                }
                                                secondary={
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
                                                }
                                            />
                                        </ListItem>
                                    ))}
                                </List>
                            </>
                        ) : (
                            <Box sx={{ textAlign: 'center', py: 3, bgcolor: alpha(THEME.background.main, 0.5), borderRadius: 2 }}>
                                <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                    No comments yet. Be the first to share your thoughts! 📝
                                </Typography>
                            </Box>
                        )}
                    </Box>

                    {/* Add Comment Section */}
                    <Divider sx={{ my: 2 }} />
                    <Typography variant="subtitle2" sx={{ mb: 2, color: THEME.text.primary, fontWeight: 600 }}>
                        Share Your Thoughts ✍️
                    </Typography>
                    <TextField
                        fullWidth
                        multiline
                        rows={4}
                        placeholder="What are your thoughts on this article?"
                        value={commentText}
                        onChange={(e) => setCommentText(e.target.value)}
                        variant="outlined"
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                borderRadius: '16px',
                                bgcolor: alpha(THEME.background.main, 0.5),
                                '&:hover fieldset': { borderColor: THEME.secondary, borderWidth: 2 },
                                '&.Mui-focused fieldset': { borderColor: THEME.secondary, borderWidth: 2 }
                            }
                        }}
                    />
                </DialogContent>
                <DialogActions sx={{ p: 2, bgcolor: alpha(THEME.primary, 0.02), gap: 1 }}>
                    <Button 
                        onClick={handleCloseDialog}
                        sx={{ 
                            color: THEME.text.secondary,
                            borderRadius: '30px',
                            px: 3
                        }}
                    >
                        Cancel
                    </Button>
                    <Button
                        onClick={postComment}
                        disabled={!commentText.trim()}
                        variant="contained"
                        startIcon={<SendIcon />}
                        sx={{
                            background: THEME.gradient.secondary,
                            color: 'white',
                            fontWeight: 600,
                            borderRadius: '30px',
                            px: 4,
                            border: '2px solid white',
                            '&:hover': {
                                transform: 'scale(1.05)',
                                boxShadow: `0 8px 16px ${alpha(THEME.secondary, 0.3)}`
                            }
                        }}
                    >
                        Post Comment 🚀
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Article Modal */}
            <Dialog
                open={articleModalOpen}
                onClose={handleCloseArticleModal}
                maxWidth="md"
                fullWidth
                scroll="paper"
                PaperProps={{
                    sx: {
                        borderRadius: '24px',
                        overflow: 'hidden',
                        maxHeight: '90vh',
                        border: `4px solid ${THEME.primary}`,
                        boxShadow: `8px 8px 0 ${alpha(THEME.primary, 0.3)}`
                    }
                }}
            >
                {selectedArticleForModal && (
                    <>
                        <DialogTitle sx={{ 
                            p: 0,
                            background: THEME.gradient.primary,
                            color: 'white',
                            borderBottom: `3px solid ${THEME.accent}`
                        }}>
                            <Box sx={{ p: 3 }}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                                    <Chip
                                        label={selectedArticleForModal.category?.name || 'Uncategorized'}
                                        size="small"
                                        sx={{ 
                                            bgcolor: 'rgba(255,255,255,0.2)', 
                                            color: 'white',
                                            border: '2px solid white'
                                        }}
                                    />
                                    <IconButton onClick={handleCloseArticleModal} sx={{ color: 'white', '&:hover': { transform: 'scale(1.1)' } }}>
                                        <CloseIcon />
                                    </IconButton>
                                </Box>
                                <Typography variant="h5" sx={{ fontWeight: 700, mb: 2 }}>
                                    {selectedArticleForModal.title}
                                </Typography>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                    <Avatar sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white', border: '2px solid white' }}>
                                        {selectedArticleForModal.writer?.name?.charAt(0) || 'A'}
                                    </Avatar>
                                    <Box>
                                        <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                                            {selectedArticleForModal.writer?.name || 'Author'}
                                        </Typography>
                                        <Typography variant="caption" sx={{ opacity: 0.9, display: 'flex', alignItems: 'center', gap: 1 }}>
                                            <CalendarTodayIcon sx={{ fontSize: 12 }} />
                                            {new Date(selectedArticleForModal.created_at).toLocaleDateString()} • {getReadTime(selectedArticleForModal.content)} min read
                                        </Typography>
                                    </Box>
                                </Box>
                            </Box>
                        </DialogTitle>

                        <DialogContent sx={{ p: 3 }}>
                            {/* Article Content */}
                            <Paper
                                sx={{
                                    p: 3,
                                    mb: 4,
                                    borderRadius: '16px',
                                    bgcolor: alpha(THEME.background.main, 0.5),
                                    border: `3px solid ${alpha(THEME.primary, 0.1)}`,
                                    '& p': { lineHeight: 1.8, color: THEME.text.primary },
                                    '& h2': { fontSize: '1.5rem', fontWeight: 700, mt: 3, mb: 2 },
                                    '& img': { maxWidth: '100%', borderRadius: '12px', my: 2, border: `2px solid ${THEME.accent}` }
                                }}
                            >
                                <div dangerouslySetInnerHTML={{ __html: selectedArticleForModal.content }} />
                            </Paper>

                            {/* Comments Section */}
                            <Box sx={{ mt: 4 }}>
                                <Typography variant="h6" sx={{ mb: 3, fontWeight: 700, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <ChatIcon sx={{ color: THEME.secondary }} />
                                    Comments ({selectedArticleForModal.comments?.length || 0})
                                </Typography>

                                {selectedArticleForModal.comments && selectedArticleForModal.comments.length > 0 ? (
                                    <Stack spacing={2}>
                                        {selectedArticleForModal.comments.map((comment) => (
                                            <Paper
                                                key={comment.id}
                                                sx={{
                                                    p: 2,
                                                    borderRadius: '16px',
                                                    border: `3px solid ${alpha(THEME.secondary, 0.2)}`,
                                                    bgcolor: alpha(THEME.background.main, 0.5),
                                                    transition: 'all 0.2s ease',
                                                    '&:hover': {
                                                        transform: 'translateX(4px)',
                                                        borderColor: THEME.secondary
                                                    }
                                                }}
                                            >
                                                <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2 }}>
                                                    <Avatar
                                                        sx={{
                                                            width: 32,
                                                            height: 32,
                                                            bgcolor: alpha(THEME.secondary, 0.1),
                                                            color: THEME.secondary,
                                                            border: `2px solid ${THEME.accent}`
                                                        }}
                                                    >
                                                        {comment.user?.name?.charAt(0) || 'U'}
                                                    </Avatar>
                                                    <Box sx={{ flex: 1 }}>
                                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                                                            <Box>
                                                                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                                    {comment.user?.name || 'Anonymous'}
                                                                </Typography>
                                                                <Typography variant="caption" sx={{ color: THEME.text.light, display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                                    <CalendarTodayIcon sx={{ fontSize: 10 }} />
                                                                    {new Date(comment.created_at).toLocaleDateString()}
                                                                </Typography>
                                                            </Box>
                                                            {comment.user_id === auth?.user?.id && (
                                                                <Box sx={{ display: 'flex', gap: 0.5 }}>
                                                                    <IconButton
                                                                        size="small"
                                                                        onClick={() => handleEditComment(comment)}
                                                                        sx={{ color: THEME.text.secondary, '&:hover': { transform: 'scale(1.1)' } }}
                                                                    >
                                                                        <EditIcon fontSize="small" />
                                                                    </IconButton>
                                                                    <IconButton
                                                                        size="small"
                                                                        onClick={() => handleDeleteComment(comment.id)}
                                                                        sx={{ color: THEME.secondaryDark, '&:hover': { transform: 'scale(1.1)' } }}
                                                                    >
                                                                        <DeleteIcon fontSize="small" />
                                                                    </IconButton>
                                                                </Box>
                                                            )}
                                                        </Box>
                                                        {editingCommentId === comment.id ? (
                                                            <Box sx={{ mt: 1 }}>
                                                                <TextField
                                                                    fullWidth
                                                                    multiline
                                                                    rows={3}
                                                                    value={editCommentText}
                                                                    onChange={(e) => setEditCommentText(e.target.value)}
                                                                    variant="outlined"
                                                                    size="small"
                                                                    sx={{
                                                                        mb: 1,
                                                                        '& .MuiOutlinedInput-root': {
                                                                            borderRadius: '12px'
                                                                        }
                                                                    }}
                                                                />
                                                                <Box sx={{ display: 'flex', gap: 1 }}>
                                                                    <Button
                                                                        size="small"
                                                                        variant="contained"
                                                                        onClick={handleSaveEdit}
                                                                        disabled={!editCommentText.trim()}
                                                                        sx={{
                                                                            background: THEME.gradient.primary,
                                                                            fontWeight: 600,
                                                                            borderRadius: '20px'
                                                                        }}
                                                                    >
                                                                        Save
                                                                    </Button>
                                                                    <Button
                                                                        size="small"
                                                                        variant="outlined"
                                                                        onClick={handleCancelEdit}
                                                                        sx={{ 
                                                                            fontWeight: 600,
                                                                            borderRadius: '20px'
                                                                        }}
                                                                    >
                                                                        Cancel
                                                                    </Button>
                                                                </Box>
                                                            </Box>
                                                        ) : (
                                                            <Typography variant="body2" sx={{ color: THEME.text.secondary, lineHeight: 1.6 }}>
                                                                {comment.content}
                                                            </Typography>
                                                        )}
                                                    </Box>
                                                </Box>
                                            </Paper>
                                        ))}
                                    </Stack>
                                ) : (
                                    <Paper
                                        sx={{
                                            p: 4,
                                            textAlign: 'center',
                                            borderRadius: '16px',
                                            bgcolor: alpha(THEME.background.main, 0.5),
                                            border: `3px dashed ${alpha(THEME.secondary, 0.3)}`
                                        }}
                                    >
                                        <ChatIcon sx={{ fontSize: 48, color: THEME.text.light, mb: 2 }} />
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary, mb: 1, fontWeight: 600 }}>
                                            No comments yet
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: THEME.text.light }}>
                                            Be the first to share your thoughts! 💭
                                        </Typography>
                                    </Paper>
                                )}

                                {/* Add Comment Section */}
                                <Paper
                                    sx={{
                                        p: 3,
                                        mt: 3,
                                        borderRadius: '16px',
                                        border: `3px dashed ${alpha(THEME.secondary, 0.3)}`,
                                        bgcolor: alpha(THEME.secondary, 0.02)
                                    }}
                                >
                                    <Typography variant="subtitle1" sx={{ mb: 2, fontWeight: 600, color: THEME.secondary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                        <EmojiIcon sx={{ color: THEME.accent }} />
                                        Join the Discussion
                                    </Typography>
                                    <TextField
                                        fullWidth
                                        multiline
                                        rows={4}
                                        placeholder="Share your thoughts about this article... 💬"
                                        value={commentText}
                                        onChange={(e) => setCommentText(e.target.value)}
                                        variant="outlined"
                                        sx={{
                                            mb: 2,
                                            '& .MuiOutlinedInput-root': {
                                                borderRadius: '16px',
                                                '&:hover fieldset': { borderColor: THEME.secondary },
                                                '&.Mui-focused fieldset': { borderColor: THEME.secondary }
                                            }
                                        }}
                                    />
                                    <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1 }}>
                                        <Button
                                            variant="outlined"
                                            onClick={() => setCommentText('')}
                                            disabled={!commentText.trim()}
                                            sx={{ 
                                                color: THEME.text.secondary,
                                                borderRadius: '30px',
                                                borderWidth: 2
                                            }}
                                        >
                                            Clear
                                        </Button>
                                        <Button
                                            variant="contained"
                                            onClick={() => {
                                                if (commentText.trim()) {
                                                    Inertia.post(
                                                        route('student.articles.comment', selectedArticleForModal.id),
                                                        { content: commentText },
                                                        {
                                                            onSuccess: () => {
                                                                setCommentText('');
                                                                setDailyGoal(prev => Math.min(prev + 1, 10));
                                                            },
                                                        }
                                                    );
                                                }
                                            }}
                                            disabled={!commentText.trim()}
                                            startIcon={<SendIcon />}
                                            sx={{
                                                background: THEME.gradient.primary,
                                                color: 'white',
                                                fontWeight: 600,
                                                borderRadius: '30px',
                                                px: 4,
                                                border: '2px solid white',
                                                '&:hover': {
                                                    transform: 'scale(1.05)',
                                                    boxShadow: `0 8px 16px ${alpha(THEME.primary, 0.3)}`
                                                }
                                            }}
                                        >
                                            Post Comment 🚀
                                        </Button>
                                    </Box>
                                </Paper>
                            </Box>
                        </DialogContent>
                    </>
                )}
            </Dialog>

            {/* Floating Action Button for Quick Actions */}
            {activeNav !== 'articles' && (
                <Tooltip title="Browse Articles" arrow>
                    <Fab
                        color="primary"
                        sx={{
                            position: 'fixed',
                            bottom: 24,
                            right: 24,
                            background: THEME.gradient.primary,
                            width: 64,
                            height: 64,
                            border: '4px solid white',
                            boxShadow: `6px 6px 0 ${alpha(THEME.primary, 0.3)}`,
                            '&:hover': {
                                transform: 'scale(1.1) rotate(360deg)',
                                boxShadow: `8px 8px 0 ${alpha(THEME.primary, 0.3)}`
                            },
                            transition: 'all 0.5s ease'
                        }}
                        onClick={() => setActiveNav('articles')}
                    >
                        <MenuBookIcon sx={{ fontSize: 32 }} />
                    </Fab>
                </Tooltip>
            )}
        </Box>
    );
}