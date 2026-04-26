import React, { useState, useEffect } from 'react';
import { Inertia } from '@inertiajs/inertia';
import axios from 'axios';
import {
    Box,
    Container,
    TextField,
    Button,
    Select,
    MenuItem,
    Typography,
    Card,
    CardContent,
    CardActions,
    Grid,
    Chip,
    AppBar,
    Toolbar,
    Paper,
    Drawer,
    List,
    ListItem,
    ListItemIcon,
    ListItemText,
    Divider,
    Fade,
    Alert,
    Menu,
    Avatar,
    IconButton,
    InputAdornment,
    Badge,
    LinearProgress,
    Stack,
    alpha,
    Tooltip,
    Zoom,
    Fab,
    useTheme,
    useMediaQuery
} from '@mui/material';
import {
    AccountCircle as AccountCircleIcon,
    Logout as LogoutIcon,
    SwapHoriz as SwapHorizIcon,
    Home as HomeIcon,
    Edit as EditIcon,
    Send as SendIcon,
    Visibility as VisibilityIcon,
    Search as SearchIcon,
    Add as AddIcon,
    Create as CreateIcon,
    Done as DoneIcon,
    MoreVert as MoreVertIcon,
    Dashboard as DashboardIcon,
    Notifications as NotificationsIcon,
    NotificationsNone as NotificationsNoneIcon,
    AutoStories as AutoStoriesIcon,
    Psychology as PsychologyIcon,
    Lightbulb as LightbulbIcon,
    RocketLaunch as RocketLaunchIcon,
    Save as SaveIcon,
    Publish as PublishIcon,
    Delete as DeleteIcon,
    Star as StarIcon,
    TrendingUp as TrendingUpIcon,
    Timeline as TimelineIcon,
    MenuBook as MenuBookIcon,
    FormatQuote as FormatQuoteIcon,
    Brush as BrushIcon,
    EmojiEvents as EmojiEventsIcon,
    Whatshot as FireIcon,
    Waves as WavesIcon,
    Forest as ForestIcon,
    WbSunny as SunIcon,
    Nightlight as MoonIcon,
    EmojiEmotions as EmojiIcon,
    Cloud as CloudIcon
} from '@mui/icons-material';
import JoditEditor from 'jodit-react';

// Enhanced Creative Theme with Playful Elements
const THEME = {
    primary: '#FF6B6B',        // Coral Red - energetic and creative
    primaryLight: '#FF8E8E',
    primaryDark: '#E84545',
    secondary: '#4ECDC4',      // Mint - calm and focused
    secondaryLight: '#6FD1C9',
    secondaryDark: '#3AA89F',
    accent: '#FFE66D',         // Warm Yellow - inspiration
    accentLight: '#FFF0A5',
    accentDark: '#F7D44A',
    success: '#95E1D3',        // Soft Green - achievement
    warning: '#FFA07A',        // Light Salmon - attention
    error: '#FF6B6B',          // Coral - errors
    purple: '#9B6B9E',         // Soft purple - magical
    orange: '#FF9F1C',         // Bright orange - adventurous
    pink: '#FF8A80',           // Soft pink - sweet
    green: '#6BAA6B',          // Forest green - nature
    blue: '#6B8CFF',           // Sky blue - calm
    background: {
        main: '#FAF9F8',       // Warm White
        paper: '#FFFFFF',
        gradient: 'linear-gradient(135deg, #FFF9F5 0%, #F8F3F0 100%)',
        playful: 'radial-gradient(circle at 10% 20%, #FFE66D20 0%, transparent 20%), radial-gradient(circle at 90% 80%, #FF6B6B20 0%, transparent 20%)'
    },
    text: {
        primary: '#2D4059',     // Deep Blue-Gray
        secondary: '#5C6B7E',
        light: '#8D9AA9',
        accent: '#FF6B6B'
    },
    gradient: {
        primary: 'linear-gradient(135deg, #FF6B6B 0%, #E84545 100%)',
        secondary: 'linear-gradient(135deg, #4ECDC4 0%, #3AA89F 100%)',
        accent: 'linear-gradient(135deg, #FFE66D 0%, #F7D44A 100%)',
        sunset: 'linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 100%)',
        magical: 'linear-gradient(135deg, #9B6B9E 0%, #6B8CFF 100%)'
    },
    shadows: {
        small: '2px 2px 0 rgba(0,0,0,0.1)',
        medium: '4px 4px 0 rgba(0,0,0,0.1)',
        large: '8px 8px 0 rgba(0,0,0,0.1)',
        hover: '12px 12px 0 rgba(0,0,0,0.1)'
    }
};

const STATUS_COLORS = {
    draft: { 
        bg: '#F8F3F0', 
        text: '#2D4059', 
        border: '#E8E0DA',
        gradient: 'linear-gradient(135deg, #F8F3F0 0%, #ECE5E0 100%)',
        icon: <CreateIcon />,
        emoji: '✏️'
    },
    submitted: { 
        bg: '#E6F7F5', 
        text: '#4ECDC4', 
        border: '#C1F0EB',
        gradient: 'linear-gradient(135deg, #E6F7F5 0%, #D1F0EC 100%)',
        icon: <SendIcon />,
        emoji: '🚀'
    },
    needs_revision: { 
        bg: '#FFF3E6', 
        text: '#FFA07A', 
        border: '#FFE4D4',
        gradient: 'linear-gradient(135deg, #FFF3E6 0%, #FFE8DC 100%)',
        icon: <BrushIcon />,
        emoji: '🎨'
    },
    published: { 
        bg: '#F0F6FA', 
        text: '#5C6B7E', 
        border: '#E1E8F0',
        gradient: 'linear-gradient(135deg, #F0F6FA 0%, #E5EAF0)',
        icon: <RocketLaunchIcon />,
        emoji: '🌟'
    },
};

const DRAWER_WIDTH = 300;

export default function Dashboard({ articles, categories, auth, notifications }) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [activeNav, setActiveNav] = useState('dashboard');
    const [form, setForm] = useState({ title: '', content: '', category_id: '' });
    const [profileAnchor, setProfileAnchor] = useState(null);
    const [categorySearch, setCategorySearch] = useState('');
    const [publishedSearchQuery, setPublishedSearchQuery] = useState('');
    const [submittedSearchQuery, setSubmittedSearchQuery] = useState('');
    const [notificationAnchor, setNotificationAnchor] = useState(null);
    const [readNotifications, setReadNotifications] = useState(new Set());
    const [writingProgress, setWritingProgress] = useState(0);
    const [inspirationQuote, setInspirationQuote] = useState('');
    const [floatingIcons, setFloatingIcons] = useState([]);
    const [showConfetti, setShowConfetti] = useState(false);

    // Inspirational quotes for writers
    const quotes = [
        { text: "The art of writing is the art of discovering what you believe.", author: "Gustave Flaubert" },
        { text: "Start writing, no matter what. The water does not flow until the faucet is turned on.", author: "Louis L'Amour" },
        { text: "You can always edit a bad page. You can't edit a blank page.", author: "Jodi Picoult" },
        { text: "The scariest moment is always just before you start.", author: "Stephen King" },
        { text: "Fill your paper with the breathings of your heart.", author: "William Wordsworth" },
        { text: "Write what should not be forgotten.", author: "Isabel Allende" },
        { text: "The first draft is just you telling yourself the story.", author: "Terry Pratchett" }
    ];

    useEffect(() => {
        // Set random inspirational quote
        const randomQuote = quotes[Math.floor(Math.random() * quotes.length)];
        setInspirationQuote(`${randomQuote.text} — ${randomQuote.author}`);
        
        // Generate floating background icons
        generateFloatingIcons();
    }, []);

    useEffect(() => {
        // Calculate writing progress based on content length
        if (form.content) {
            const wordCount = form.content.split(/\s+/).length;
            const progress = Math.min((wordCount / 500) * 100, 100);
            setWritingProgress(progress);
            
            // Show confetti when reaching milestones
            if (progress >= 25 && progress < 30) {
                setShowConfetti(true);
                setTimeout(() => setShowConfetti(false), 2000);
            } else if (progress >= 50 && progress < 55) {
                setShowConfetti(true);
                setTimeout(() => setShowConfetti(false), 2000);
            } else if (progress >= 75 && progress < 80) {
                setShowConfetti(true);
                setTimeout(() => setShowConfetti(false), 2000);
            } else if (progress >= 100) {
                setShowConfetti(true);
                setTimeout(() => setShowConfetti(false), 3000);
            }
        } else {
            setWritingProgress(0);
        }
    }, [form.content]);

    // Filter articles based on search queries
    const filteredPublished = articles.filter(article => article.status === 'published').filter(article => {
        if (!publishedSearchQuery.trim()) return true;
        
        const query = publishedSearchQuery.toLowerCase();
        return (
            article.title.toLowerCase().includes(query) ||
            (article.content && article.content.toLowerCase().includes(query)) ||
            (article.category && article.category.name.toLowerCase().includes(query))
        );
    });

    const filteredSubmitted = articles.filter(article => article.status === 'submitted').filter(article => {
        if (!submittedSearchQuery.trim()) return true;
        
        const query = submittedSearchQuery.toLowerCase();
        return (
            article.title.toLowerCase().includes(query) ||
            (article.content && article.content.toLowerCase().includes(query)) ||
            (article.category && article.category.name.toLowerCase().includes(query))
        );
    });

    const generateFloatingIcons = () => {
        const icons = [
            <EmojiIcon />, <BrushIcon />, <CloudIcon />, <RocketLaunchIcon />, 
            <CreateIcon />, <LightbulbIcon />, <PsychologyIcon />, <AutoStoriesIcon />,
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

    const handleSubmit = (e) => {
        e.preventDefault();
        Inertia.post(route('writer.articles.store'), form);
    };

    const handleSubmitArticle = (articleId) => {
        if (window.confirm('Ready to share your story with the world? 🚀')) {
            Inertia.post(route('writer.articles.submit', articleId));
        }
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
    }, [notifications]);

    const draftArticles = articles.filter(a => a.status.name === 'draft');
    const submittedArticles = articles.filter(a => a.status.name === 'submitted');
    const revisedArticles = articles.filter(a => a.status.name === 'needs_revision');
    const publishedArticles = articles.filter(a => a.status.name === 'published');

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

    // Filter draft articles by search (title or category)
    const filteredDraftArticles = draftArticles.filter(article => 
        categorySearch === '' || 
        article.category.name.toLowerCase().includes(categorySearch.toLowerCase()) ||
        article.title.toLowerCase().includes(categorySearch.toLowerCase())
    );

    const getWordCount = (content) => {
        return content ? content.split(/\s+/).length : 0;
    };

    const getReadTime = (content) => {
        const wordsPerMinute = 200;
        const wordCount = getWordCount(content);
        const readTime = Math.ceil(wordCount / wordsPerMinute);
        return `${readTime} min read`;
    };

    // Confetti effect component
    const Confetti = () => (
        <Box sx={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            pointerEvents: 'none',
            zIndex: 9999,
            overflow: 'hidden'
        }}>
            {[...Array(50)].map((_, i) => (
                <Box
                    key={i}
                    sx={{
                        position: 'absolute',
                        left: `${Math.random() * 100}%`,
                        top: '-10%',
                        width: 10,
                        height: 10,
                        background: [THEME.primary, THEME.secondary, THEME.accent, THEME.purple, THEME.orange][Math.floor(Math.random() * 5)],
                        borderRadius: Math.random() > 0.5 ? '50%' : '0%',
                        transform: `rotate(${Math.random() * 360}deg)`,
                        animation: `confetti ${3 + Math.random() * 4}s ease-in forwards`,
                        animationDelay: `${Math.random() * 2}s`,
                        '@keyframes confetti': {
                            '0%': {
                                transform: `translateY(0) rotate(0deg)`,
                                opacity: 1
                            },
                            '100%': {
                                transform: `translateY(100vh) rotate(${720 + Math.random() * 360}deg)`,
                                opacity: 0
                            }
                        }
                    }}
                />
            ))}
        </Box>
    );

    const renderMainContent = () => {
        switch (activeNav) {
            case 'dashboard':
                return (
                    <Fade in={activeNav === 'dashboard'} timeout={500}>
                        <Box>
                            {/* Welcome Header with Quote and Floating Elements */}
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 4,
                                    mb: 4,
                                    borderRadius: '24px',
                                    background: THEME.gradient.sunset,
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
                                    <BrushIcon sx={{ fontSize: 50, color: 'rgba(255,255,255,0.2)' }} />
                                </Box>

                                <Box sx={{ position: 'relative', zIndex: 1 }}>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                        <Chip
                                            icon={<EmojiIcon />}
                                            label="Welcome to Your Creative Studio!"
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
                                    </Box>
                                    
                                    <Typography variant="h4" sx={{ 
                                        fontWeight: 800, 
                                        mb: 2, 
                                        fontFamily: '"Playfair Display", serif',
                                        textShadow: '3px 3px 0 rgba(0,0,0,0.2)'
                                    }}>
                                        Welcome back, {auth?.user?.name?.split(' ')[0] || 'Writer'}! 
                                        <Box component="span" sx={{ display: 'inline-block', ml: 1, animation: 'wave 2s infinite' }}>
                                            👋
                                        </Box>
                                    </Typography>
                                    
                                    <Typography variant="body1" sx={{ opacity: 0.9, mb: 3, fontStyle: 'italic', fontSize: '1.2rem' }}>
                                        "{inspirationQuote}"
                                    </Typography>
                                    
                                    <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                                        <Chip
                                            icon={<EmojiEventsIcon />}
                                            label={`${publishedArticles.length} Articles Published`}
                                            sx={{ 
                                                bgcolor: 'rgba(255,255,255,0.2)', 
                                                color: 'white',
                                                border: '2px solid white',
                                                fontSize: '1rem',
                                                '&:hover': { bgcolor: 'rgba(255,255,255,0.3)' }
                                            }}
                                        />
                                        <Chip
                                            icon={<TrendingUpIcon />}
                                            label={`${draftArticles.length} Works in Progress`}
                                            sx={{ 
                                                bgcolor: 'rgba(255,255,255,0.2)', 
                                                color: 'white',
                                                border: '2px solid white',
                                                fontSize: '1rem',
                                                '&:hover': { bgcolor: 'rgba(255,255,255,0.3)' }
                                            }}
                                        />
                                    </Box>
                                </Box>
                            </Paper>

                            {/* Quick Stats with Playful Cards */}
                            <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, color: THEME.text.primary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <AutoStoriesIcon sx={{ color: THEME.primary }} />
                                Your Writing Studio
                            </Typography>
                            
                            <Grid container spacing={3} sx={{ mb: 4 }}>
                                {[
                                    { label: 'Drafts', count: draftArticles.length, icon: <CreateIcon />, color: THEME.primary, emoji: '✏️', gradient: THEME.gradient.primary },
                                    { label: 'Submitted', count: submittedArticles.length, icon: <SendIcon />, color: THEME.secondary, emoji: '🚀', gradient: THEME.gradient.secondary },
                                    { label: 'Need Revision', count: revisedArticles.length, icon: <BrushIcon />, color: THEME.warning, emoji: '🎨', gradient: THEME.gradient.accent },
                                    { label: 'Published', count: publishedArticles.length, icon: <RocketLaunchIcon />, color: THEME.success, emoji: '🌟', gradient: THEME.gradient.magical }
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
                                                        value={(stat.count / (articles.length || 1)) * 100}
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

                            {/* Writing Tips & Inspiration with Playful Design */}
                            <Grid container spacing={3}>
                                <Grid item xs={12} md={6}>
                                    <Card
                                        elevation={0}
                                        sx={{
                                            borderRadius: '20px',
                                            background: 'white',
                                            border: `3px solid ${THEME.accent}`,
                                            boxShadow: `6px 6px 0 ${alpha(THEME.accent, 0.3)}`,
                                            p: 3,
                                            transition: 'all 0.3s ease',
                                            '&:hover': {
                                                transform: 'translateY(-4px) translateX(-4px)',
                                                boxShadow: `10px 10px 0 ${alpha(THEME.accent, 0.3)}`
                                            }
                                        }}
                                    >
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                            <Box
                                                sx={{
                                                    width: 50,
                                                    height: 50,
                                                    borderRadius: '50%',
                                                    background: THEME.gradient.accent,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    animation: 'pulse 2s infinite',
                                                    '@keyframes pulse': {
                                                        '0%': { transform: 'scale(1)' },
                                                        '50%': { transform: 'scale(1.1)' }
                                                    }
                                                }}
                                            >
                                                <LightbulbIcon sx={{ color: 'white' }} />
                                            </Box>
                                            <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.text.primary }}>
                                                Today's Writing Prompt
                                            </Typography>
                                        </Box>
                                        
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary, mb: 3, fontStyle: 'italic', fontSize: '1.1rem', pl: 2, borderLeft: `4px solid ${THEME.accent}` }}>
                                            "Write about a moment that changed your perspective on creativity."
                                        </Typography>
                                        
                                        <Button
                                            variant="contained"
                                            startIcon={<CreateIcon />}
                                            onClick={() => setActiveNav('create')}
                                            sx={{
                                                background: THEME.gradient.accent,
                                                color: THEME.text.primary,
                                                fontWeight: 600,
                                                borderRadius: '30px',
                                                py: 1,
                                                px: 3,
                                                border: '2px solid white',
                                                '&:hover': {
                                                    transform: 'scale(1.05) rotate(-2deg)',
                                                    boxShadow: `0 8px 16px ${alpha(THEME.accent, 0.3)}`
                                                }
                                            }}
                                        >
                                            Start Writing ✨
                                        </Button>
                                    </Card>
                                </Grid>

                                <Grid item xs={12} md={6}>
                                    <Card
                                        elevation={0}
                                        sx={{
                                            borderRadius: '20px',
                                            background: 'white',
                                            border: `3px solid ${THEME.secondary}`,
                                            boxShadow: `6px 6px 0 ${alpha(THEME.secondary, 0.3)}`,
                                            p: 3,
                                            transition: 'all 0.3s ease',
                                            '&:hover': {
                                                transform: 'translateY(-4px) translateX(-4px)',
                                                boxShadow: `10px 10px 0 ${alpha(THEME.secondary, 0.3)}`
                                            }
                                        }}
                                    >
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                            <Box
                                                sx={{
                                                    width: 50,
                                                    height: 50,
                                                    borderRadius: '50%',
                                                    background: THEME.gradient.secondary,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center'
                                                }}
                                            >
                                                <TimelineIcon sx={{ color: 'white' }} />
                                            </Box>
                                            <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.text.primary }}>
                                                Your Writing Journey
                                            </Typography>
                                        </Box>
                                        
                                        <Stack spacing={2}>
                                            <Box>
                                                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                                                    <Typography variant="body2" sx={{ color: THEME.text.secondary }}>Articles Written</Typography>
                                                    <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.secondary }}>{articles.length} / 20</Typography>
                                                </Box>
                                                <LinearProgress
                                                    variant="determinate"
                                                    value={(articles.length / 20) * 100}
                                                    sx={{
                                                        height: 8,
                                                        borderRadius: 4,
                                                        bgcolor: alpha(THEME.secondary, 0.1),
                                                        '& .MuiLinearProgress-bar': {
                                                            background: THEME.gradient.secondary,
                                                            borderRadius: 4
                                                        }
                                                    }}
                                                />
                                            </Box>
                                            <Box>
                                                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                                                    <Typography variant="body2" sx={{ color: THEME.text.secondary }}>Publication Rate</Typography>
                                                    <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.success }}>
                                                        {articles.length ? Math.round((publishedArticles.length / articles.length) * 100) : 0}%
                                                    </Typography>
                                                </Box>
                                                <LinearProgress
                                                    variant="determinate"
                                                    value={articles.length ? (publishedArticles.length / articles.length) * 100 : 0}
                                                    sx={{
                                                        height: 8,
                                                        borderRadius: 4,
                                                        bgcolor: alpha(THEME.success, 0.1),
                                                        '& .MuiLinearProgress-bar': {
                                                            background: THEME.gradient.primary,
                                                            borderRadius: 4
                                                        }
                                                    }}
                                                />
                                            </Box>
                                        </Stack>
                                        
                                        {/* Achievement Badge */}
                                        {publishedArticles.length >= 5 && (
                                            <Box sx={{ mt: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
                                                <StarIcon sx={{ color: THEME.accent }} />
                                                <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                                    Prolific Writer Badge ✨
                                                </Typography>
                                            </Box>
                                        )}
                                    </Card>
                                </Grid>
                            </Grid>
                        </Box>
                    </Fade>
                );

            case 'create':
                return (
                    <Fade in={activeNav === 'create'} timeout={500}>
                        <Box>
                            {showConfetti && <Confetti />}
                            
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 4,
                                    borderRadius: '24px',
                                    background: 'white',
                                    border: `4px solid ${THEME.primary}`,
                                    boxShadow: THEME.shadows.large,
                                    position: 'relative',
                                    overflow: 'hidden',
                                    '&::before': {
                                        content: '""',
                                        position: 'absolute',
                                        top: 0,
                                        right: 0,
                                        width: 150,
                                        height: 150,
                                        background: `radial-gradient(circle, ${alpha(THEME.accent, 0.2)} 0%, transparent 70%)`,
                                        borderRadius: '50%'
                                    }
                                }}
                            >
                                <Box sx={{ mb: 4 }}>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                        <Box
                                            sx={{
                                                width: 60,
                                                height: 60,
                                                borderRadius: '16px',
                                                background: THEME.gradient.primary,
                                                display: 'flex',
                                                alignItems: 'center',
                                                justifyContent: 'center',
                                                transform: 'rotate(-5deg)',
                                                animation: 'bounce 2s infinite'
                                            }}
                                        >
                                            <CreateIcon sx={{ color: 'white', fontSize: 30 }} />
                                        </Box>
                                        <Box>
                                            <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                                Create New Story
                                            </Typography>
                                            <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                                Let your creativity flow. Start writing your next masterpiece.
                                            </Typography>
                                        </Box>
                                    </Box>
                                    
                                    {/* Writing Progress with Milestone Celebrations */}
                                    {writingProgress > 0 && (
                                        <Box sx={{ mb: 4 }}>
                                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                                                <Typography variant="body2" sx={{ color: THEME.text.secondary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    <BrushIcon sx={{ fontSize: 16, color: THEME.primary }} />
                                                    Writing Progress
                                                </Typography>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.primary }}>
                                                        {Math.round(writingProgress)}%
                                                    </Typography>
                                                    {writingProgress >= 100 && (
                                                        <Chip
                                                            size="small"
                                                            icon={<EmojiEventsIcon />}
                                                            label="Complete!"
                                                            sx={{ bgcolor: THEME.success, color: 'white' }}
                                                        />
                                                    )}
                                                </Box>
                                            </Box>
                                            <LinearProgress
                                                variant="determinate"
                                                value={writingProgress}
                                                sx={{
                                                    height: 10,
                                                    borderRadius: 5,
                                                    bgcolor: alpha(THEME.primary, 0.1),
                                                    '& .MuiLinearProgress-bar': {
                                                        background: `linear-gradient(90deg, ${THEME.primary} 0%, ${THEME.accent} 100%)`,
                                                        borderRadius: 5,
                                                        transition: 'transform 0.5s ease'
                                                    }
                                                }}
                                            />
                                            <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 1 }}>
                                                <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                    💡 Keep going! You're doing great!
                                                </Typography>
                                                <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                    {getWordCount(form.content)} words
                                                </Typography>
                                            </Box>
                                        </Box>
                                    )}
                                </Box>

                                <Box component="form" onSubmit={handleSubmit}>
                                    <TextField
                                        label="Article Title"
                                        fullWidth
                                        placeholder="Enter a compelling title that captures attention..."
                                        value={form.title}
                                        onChange={(e) => setForm({ ...form, title: e.target.value })}
                                        sx={{
                                            mb: 3,
                                            '& .MuiOutlinedInput-root': {
                                                borderRadius: '16px',
                                                backgroundColor: alpha(THEME.background.main, 0.5),
                                                '&:hover fieldset': { borderColor: THEME.primary, borderWidth: 2 },
                                                '&.Mui-focused fieldset': { borderColor: THEME.primary, borderWidth: 2 },
                                            },
                                        }}
                                        required
                                        variant="outlined"
                                        InputProps={{
                                            startAdornment: (
                                                <InputAdornment position="start">
                                                    <EditIcon sx={{ color: THEME.primary }} />
                                                </InputAdornment>
                                            ),
                                        }}
                                    />

                                    <Select
                                        fullWidth
                                        value={form.category_id}
                                        onChange={(e) => setForm({ ...form, category_id: e.target.value ? Number(e.target.value) : '' })}
                                        displayEmpty
                                        renderValue={(selected) => {
                                            if (!selected) {
                                                return <Typography sx={{ color: THEME.text.light }}>📚 Choose a category for your story</Typography>;
                                            }
                                            const category = categories.find(cat => cat.id === selected);
                                            return category ? category.name : '';
                                        }}
                                        sx={{
                                            mb: 4,
                                            borderRadius: '16px',
                                            backgroundColor: alpha(THEME.background.main, 0.5),
                                            '& .MuiOutlinedInput-root': {
                                                '&:hover fieldset': { borderColor: THEME.primary, borderWidth: 2 },
                                                '&.Mui-focused fieldset': { borderColor: THEME.primary, borderWidth: 2 },
                                            },
                                        }}
                                    >
                                        <MenuItem value="">
                                            <Typography sx={{ color: THEME.text.light }}>Select a category</Typography>
                                        </MenuItem>
                                        {categories.map((cat) => (
                                            <MenuItem key={cat.id} value={cat.id}>{cat.name}</MenuItem>
                                        ))}
                                    </Select>

                                    <Typography sx={{ mb: 2, fontWeight: 700, color: THEME.text.primary, fontSize: '1rem', display: 'flex', alignItems: 'center', gap: 1 }}>
                                        <AutoStoriesIcon sx={{ color: THEME.primary }} />
                                        Your Story
                                    </Typography>
                                    
                                    <Paper
                                        sx={{
                                            mb: 4,
                                            border: `3px solid ${alpha(THEME.primary, 0.2)}`,
                                            borderRadius: '16px',
                                            overflow: 'hidden',
                                            backgroundColor: alpha(THEME.background.main, 0.5),
                                        }}
                                    >
                                        <JoditEditor
                                            value={form.content}
                                            onBlur={(newContent) => setForm({ ...form, content: newContent })}
                                            config={{
                                                buttons: ['bold', 'italic', 'underline', '|', 'ul', 'ol', '|', 'font', 'fontsize', '|', 'image', 'table', 'link', '|', 'align', '|', 'undo', 'redo'],
                                                theme: 'dark',
                                                showCharsCounter: true,
                                                showWordsCounter: true,
                                                showXPathInStatusbar: false,
                                                uploader: {
                                                    url: route('writer.upload.image'),
                                                    format: 'json',
                                                    method: 'POST',
                                                    headers: {
                                                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
                                                    },
                                                    prepareData: function (formdata) {
                                                        return formdata;
                                                    },
                                                    isSuccess: function (resp) {
                                                        return resp.uploaded === 1;
                                                    },
                                                    getMessage: function (resp) {
                                                        return resp.msg || 'Upload failed';
                                                    },
                                                    process: function (resp) {
                                                        return {
                                                            files: [resp.url],
                                                            path: resp.url,
                                                            baseurl: '',
                                                            newfilename: resp.fileName
                                                        };
                                                    },
                                                    error: function (e) {
                                                        console.error('Image upload error:', e);
                                                        alert('Image upload failed. Please try again.');
                                                    }
                                                },
                                                image: {
                                                    openOnDblClick: true,
                                                    editSrc: true,
                                                    useImageEditor: false,
                                                    editButtons: ['imageRemove']
                                                }
                                            }}
                                        />
                                    </Paper>

                                    <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end', flexWrap: 'wrap' }}>
                                        <Button
                                            type="submit"
                                            variant="contained"
                                            size="large"
                                            startIcon={<SaveIcon />}
                                            sx={{
                                                background: THEME.gradient.secondary,
                                                color: 'white',
                                                fontWeight: 600,
                                                textTransform: 'none',
                                                borderRadius: '30px',
                                                py: 1.5,
                                                px: 4,
                                                border: '2px solid white',
                                                '&:hover': {
                                                    transform: 'scale(1.05) translateY(-2px)',
                                                    boxShadow: `0 8px 16px ${alpha(THEME.secondary, 0.3)}`
                                                }
                                            }}
                                        >
                                            Save as Draft 📝
                                        </Button>
                                        <Button
                                            type="button"
                                            variant="contained"
                                            size="large"
                                            startIcon={<RocketLaunchIcon />}
                                            onClick={(e) => {
                                                Inertia.post(route('writer.articles.store'), { ...form, submit: true });
                                            }}
                                            sx={{
                                                background: THEME.gradient.primary,
                                                color: 'white',
                                                fontWeight: 600,
                                                textTransform: 'none',
                                                borderRadius: '30px',
                                                py: 1.5,
                                                px: 4,
                                                border: '2px solid white',
                                                '&:hover': {
                                                    transform: 'scale(1.05) translateY(-2px)',
                                                    boxShadow: `0 8px 16px ${alpha(THEME.primary, 0.3)}`
                                                }
                                            }}
                                        >
                                            Submit for Review 🚀
                                        </Button>
                                    </Box>
                                </Box>
                            </Paper>
                        </Box>
                    </Fade>
                );

            case 'drafts':
                return (
                    <Fade in={activeNav === 'drafts'} timeout={500}>
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
                                        <CreateIcon sx={{ color: 'white' }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                            My Drafts
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                            You have {draftArticles.length} work{draftArticles.length !== 1 ? 's' : ''} in progress
                                        </Typography>
                                    </Box>
                                </Box>
                                
                                <TextField
                                    fullWidth
                                    placeholder="Search your drafts by title or category... 🔍"
                                    value={categorySearch}
                                    onChange={(e) => setCategorySearch(e.target.value)}
                                    InputProps={{
                                        startAdornment: (
                                            <InputAdornment position="start">
                                                <SearchIcon sx={{ color: THEME.text.light }} />
                                            </InputAdornment>
                                        ),
                                    }}
                                    sx={{
                                        mb: 3,
                                        '& .MuiOutlinedInput-root': {
                                            borderRadius: '30px',
                                            backgroundColor: 'white',
                                            border: `2px solid ${alpha(THEME.primary, 0.2)}`,
                                            '&:hover fieldset': { borderColor: THEME.primary },
                                            '&.Mui-focused fieldset': { borderColor: THEME.primary },
                                        },
                                    }}
                                    variant="outlined"
                                />
                            </Box>

                            {filteredDraftArticles.length === 0 ? (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        p: 6,
                                        borderRadius: '24px',
                                        background: 'white',
                                        textAlign: 'center',
                                        border: `4px solid ${alpha(THEME.primary, 0.2)}`,
                                        boxShadow: THEME.shadows.medium
                                    }}
                                >
                                    <CreateIcon sx={{ fontSize: 80, color: THEME.text.light, mb: 2, animation: 'float 3s infinite' }} />
                                    <Typography variant="h5" sx={{ color: THEME.text.primary, mb: 1, fontWeight: 600 }}>
                                        {categorySearch ? 'No drafts found' : 'Start Your First Draft'}
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: THEME.text.secondary, mb: 4 }}>
                                        {categorySearch ? 'Try a different search term' : 'Begin writing your first article'}
                                    </Typography>
                                    {!categorySearch && (
                                        <Button
                                            variant="contained"
                                            size="large"
                                            startIcon={<AddIcon />}
                                            onClick={() => setActiveNav('create')}
                                            sx={{
                                                background: THEME.gradient.primary,
                                                color: 'white',
                                                borderRadius: '30px',
                                                px: 4,
                                                py: 1.5,
                                                border: '2px solid white',
                                                '&:hover': {
                                                    transform: 'scale(1.05)',
                                                    boxShadow: `0 8px 16px ${alpha(THEME.primary, 0.3)}`
                                                }
                                            }}
                                        >
                                            Create New Article 🚀
                                        </Button>
                                    )}
                                </Paper>
                            ) : (
                                <Grid container spacing={3}>
                                    {filteredDraftArticles.map((article, index) => (
                                        <Grid key={article.id} item xs={12} md={6} lg={4}>
                                            <Zoom in timeout={300 + index * 100}>
                                                <Card
                                                    elevation={0}
                                                    sx={{
                                                        height: '100%',
                                                        display: 'flex',
                                                        flexDirection: 'column',
                                                        borderRadius: '20px',
                                                        background: STATUS_COLORS.draft.gradient,
                                                        border: `3px solid ${THEME.primary}`,
                                                        boxShadow: `6px 6px 0 ${alpha(THEME.primary, 0.2)}`,
                                                        transition: 'all 0.3s ease',
                                                        position: 'relative',
                                                        overflow: 'visible',
                                                        '&:hover': {
                                                            transform: 'translateY(-8px) translateX(-4px)',
                                                            boxShadow: `10px 10px 0 ${alpha(THEME.primary, 0.2)}`,
                                                            borderColor: THEME.primaryDark
                                                        }
                                                    }}
                                                >
                                                    {/* Decorative corner */}
                                                    <Box sx={{
                                                        position: 'absolute',
                                                        top: -10,
                                                        right: -10,
                                                        width: 40,
                                                        height: 40,
                                                        borderRadius: '50%',
                                                        background: THEME.accent,
                                                        opacity: 0.3,
                                                        zIndex: 0
                                                    }} />
                                                    
                                                    <CardContent sx={{ flexGrow: 1, p: 3, position: 'relative', zIndex: 1 }}>
                                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                                                            <Chip
                                                                icon={<CreateIcon />}
                                                                label="Draft ✏️"
                                                                size="small"
                                                                sx={{
                                                                    bgcolor: THEME.primary,
                                                                    color: 'white',
                                                                    fontWeight: 600,
                                                                    borderRadius: '16px'
                                                                }}
                                                            />
                                                            <Typography variant="caption" sx={{ color: THEME.text.light, bgcolor: 'rgba(255,255,255,0.7)', px: 1, py: 0.5, borderRadius: '12px' }}>
                                                                {getReadTime(article.content)}
                                                            </Typography>
                                                        </Box>

                                                        <Typography variant="h6" sx={{ fontWeight: 700, mb: 2, color: THEME.text.primary }}>
                                                            {article.title}
                                                        </Typography>

                                                        <Chip
                                                            label={article.category.name}
                                                            size="small"
                                                            sx={{
                                                                mb: 2,
                                                                bgcolor: alpha(THEME.secondary, 0.2),
                                                                color: THEME.secondaryDark,
                                                                fontWeight: 600
                                                            }}
                                                        />

                                                        <Box sx={{ mt: 2 }}>
                                                            <Typography variant="caption" sx={{ color: THEME.text.light, display: 'block', mb: 0.5 }}>
                                                                Last edited
                                                            </Typography>
                                                            <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                                                {new Date(article.updated_at).toLocaleDateString()} at {new Date(article.updated_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                                            </Typography>
                                                        </Box>

                                                        {/* Writing Progress for this draft */}
                                                        {article.content && (
                                                            <Box sx={{ mt: 2 }}>
                                                                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                                                                    <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                                        Progress
                                                                    </Typography>
                                                                    <Typography variant="caption" sx={{ color: THEME.primary, fontWeight: 600 }}>
                                                                        {Math.min(Math.round((getWordCount(article.content) / 500) * 100), 100)}%
                                                                    </Typography>
                                                                </Box>
                                                                <LinearProgress
                                                                    variant="determinate"
                                                                    value={Math.min((getWordCount(article.content) / 500) * 100, 100)}
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
                                                            </Box>
                                                        )}
                                                    </CardContent>

                                                    <CardActions sx={{ p: 3, pt: 0, gap: 1 }}>
                                                        <Tooltip title="Continue Writing">
                                                            <Button
                                                                fullWidth
                                                                size="small"
                                                                variant="outlined"
                                                                startIcon={<EditIcon />}
                                                                onClick={() => window.location.href = route('writer.articles.show', article.id)}
                                                                sx={{
                                                                    borderColor: alpha(THEME.primary, 0.3),
                                                                    color: THEME.text.primary,
                                                                    borderRadius: '20px',
                                                                    borderWidth: 2,
                                                                    '&:hover': {
                                                                        borderColor: THEME.primary,
                                                                        bgcolor: alpha(THEME.primary, 0.04),
                                                                        transform: 'scale(1.02)'
                                                                    }
                                                                }}
                                                            >
                                                                Edit
                                                            </Button>
                                                        </Tooltip>
                                                        <Tooltip title="Submit for Review">
                                                            <Button
                                                                fullWidth
                                                                size="small"
                                                                variant="contained"
                                                                startIcon={<SendIcon />}
                                                                onClick={() => handleSubmitArticle(article.id)}
                                                                sx={{
                                                                    background: THEME.gradient.secondary,
                                                                    color: 'white',
                                                                    borderRadius: '20px',
                                                                    border: '2px solid white',
                                                                    '&:hover': {
                                                                        transform: 'scale(1.02)',
                                                                        boxShadow: `0 4px 12px ${alpha(THEME.secondary, 0.3)}`
                                                                    }
                                                                }}
                                                            >
                                                                Submit
                                                            </Button>
                                                        </Tooltip>
                                                    </CardActions>
                                                </Card>
                                            </Zoom>
                                        </Grid>
                                    ))}
                                </Grid>
                            )}
                        </Box>
                    </Fade>
                );

            case 'submitted':
                return (
                    <Fade in={activeNav === 'submitted'} timeout={500}>
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
                                        <SendIcon sx={{ color: 'white' }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                            Submitted Articles
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                            {submittedArticles.length} under review, {revisedArticles.length} awaiting your revisions
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
                                    border: `3px solid ${alpha(THEME.secondary, 0.2)}`,
                                    boxShadow: `4px 4px 0 ${alpha(THEME.secondary, 0.2)}`
                                }}
                            >
                                <TextField
                                    fullWidth
                                    placeholder="Search submitted articles... 🔍"
                                    size="medium"
                                    value={submittedSearchQuery}
                                    onChange={(e) => setSubmittedSearchQuery(e.target.value)}
                                    sx={{
                                        '& .MuiOutlinedInput-root': {
                                            borderRadius: '30px',
                                            bgcolor: alpha(THEME.secondary, 0.05),
                                            border: `2px solid ${alpha(THEME.secondary, 0.2)}`,
                                            '&:hover': {
                                                bgcolor: alpha(THEME.secondary, 0.1),
                                                borderColor: THEME.secondary
                                            },
                                            '&.Mui-focused': {
                                                bgcolor: 'white',
                                                borderColor: THEME.secondary,
                                                borderWidth: 2
                                            }
                                        }
                                    }}
                                    InputProps={{
                                        startAdornment: (
                                            <InputAdornment position="start">
                                                <SearchIcon sx={{ color: THEME.secondary, fontSize: 24 }} />
                                            </InputAdornment>
                                        ),
                                    }}
                                />
                            </Paper>

                            {filteredSubmitted.length === 0 && revisedArticles.length === 0 ? (
                                <Paper
                                    elevation={0}
                                    sx={{
                                        p: 6,
                                        borderRadius: '24px',
                                        background: 'white',
                                        textAlign: 'center',
                                        border: `4px solid ${alpha(THEME.secondary, 0.2)}`,
                                        boxShadow: THEME.shadows.medium
                                    }}
                                >
                                    <SearchIcon sx={{ fontSize: 80, color: THEME.text.light, mb: 2, animation: 'float 3s infinite' }} />
                                    <Typography variant="h5" sx={{ color: THEME.text.primary, mb: 1, fontWeight: 600 }}>
                                        {submittedSearchQuery.trim() ? 'No Submitted Articles Found' : 'No Submitted Articles'}
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                        {submittedSearchQuery.trim() 
                                            ? `No articles match "${submittedSearchQuery}". Try different keywords.`
                                            : 'When you submit articles for review, they\'ll appear here'
                                        }
                                    </Typography>
                                </Paper>
                            ) : (
                                <Grid container spacing={3}>
                                    {/* Articles Under Review */}
                                    {filteredSubmitted.map((article, index) => (
                                        <Grid key={article.id} item xs={12}>
                                            <Zoom in timeout={300 + index * 100}>
                                                <Card
                                                    elevation={0}
                                                    sx={{
                                                        borderRadius: '16px',
                                                        background: 'white',
                                                        border: `3px solid ${THEME.secondary}`,
                                                        boxShadow: `4px 4px 0 ${alpha(THEME.secondary, 0.2)}`,
                                                        transition: 'all 0.3s ease',
                                                        '&:hover': {
                                                            transform: 'translateX(4px) translateY(-2px)',
                                                            boxShadow: `8px 8px 0 ${alpha(THEME.secondary, 0.2)}`,
                                                            borderColor: THEME.secondaryDark
                                                        }
                                                    }}
                                                >
                                                    <CardContent sx={{ p: 3 }}>
                                                        <Grid container spacing={2} alignItems="center">
                                                            <Grid item xs={12} md={8}>
                                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2, flexWrap: 'wrap' }}>
                                                                    <Chip
                                                                        icon={<SendIcon />}
                                                                        label="Under Review 🚀"
                                                                        size="small"
                                                                        sx={{
                                                                            bgcolor: THEME.secondary,
                                                                            color: 'white',
                                                                            fontWeight: 600
                                                                        }}
                                                                    />
                                                                    <Chip
                                                                        label={article.category.name}
                                                                        size="small"
                                                                        sx={{ bgcolor: alpha(THEME.primary, 0.1), color: THEME.primary }}
                                                                    />
                                                                </Box>
                                                                
                                                                <Typography variant="h5" sx={{ fontWeight: 700, mb: 1, color: THEME.text.primary }}>
                                                                    {article.title}
                                                                </Typography>
                                                                
                                                                <Typography variant="body2" sx={{ color: THEME.text.secondary, display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                    <CloudIcon sx={{ fontSize: 16 }} />
                                                                    Submitted on {new Date(article.created_at).toLocaleDateString()}
                                                                </Typography>
                                                            </Grid>
                                                            
                                                            <Grid item xs={12} md={4}>
                                                                <Box sx={{ display: 'flex', gap: 1, justifyContent: { xs: 'flex-start', md: 'flex-end' } }}>
                                                                    <Tooltip title="View Article">
                                                                        <Button
                                                                            variant="outlined"
                                                                            startIcon={<VisibilityIcon />}
                                                                            onClick={() => window.location.href = route('writer.articles.show', article.id)}
                                                                            sx={{
                                                                                borderColor: alpha(THEME.secondary, 0.3),
                                                                                color: THEME.text.primary,
                                                                                borderRadius: '20px',
                                                                                borderWidth: 2,
                                                                                '&:hover': {
                                                                                    borderColor: THEME.secondary,
                                                                                    bgcolor: alpha(THEME.secondary, 0.04)
                                                                                }
                                                                            }}
                                                                        >
                                                                            View
                                                                        </Button>
                                                                    </Tooltip>
                                                                </Box>
                                                            </Grid>
                                                        </Grid>
                                                    </CardContent>
                                                </Card>
                                            </Zoom>
                                        </Grid>
                                    ))}

                                    {/* Articles Needing Revision */}
                                    {revisedArticles.map((article, index) => (
                                        <Grid key={article.id} item xs={12}>
                                            <Zoom in timeout={300 + index * 100}>
                                                <Card
                                                    elevation={0}
                                                    sx={{
                                                        borderRadius: '16px',
                                                        background: 'white',
                                                        border: `3px solid ${THEME.warning}`,
                                                        boxShadow: `4px 4px 0 ${alpha(THEME.warning, 0.2)}`,
                                                        transition: 'all 0.3s ease',
                                                        '&:hover': {
                                                            transform: 'translateX(4px) translateY(-2px)',
                                                            boxShadow: `8px 8px 0 ${alpha(THEME.warning, 0.2)}`,
                                                            borderColor: THEME.orange
                                                        }
                                                    }}
                                                >
                                                    <CardContent sx={{ p: 3 }}>
                                                        <Grid container spacing={2} alignItems="center">
                                                            <Grid item xs={12} md={8}>
                                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2, flexWrap: 'wrap' }}>
                                                                    <Chip
                                                                        icon={<BrushIcon />}
                                                                        label="Needs Revision 🎨"
                                                                        size="small"
                                                                        sx={{
                                                                            bgcolor: THEME.warning,
                                                                            color: 'white',
                                                                            fontWeight: 600
                                                                        }}
                                                                    />
                                                                    <Chip
                                                                        label={article.category.name}
                                                                        size="small"
                                                                        sx={{ bgcolor: alpha(THEME.primary, 0.1), color: THEME.primary }}
                                                                    />
                                                                </Box>
                                                                
                                                                <Typography variant="h5" sx={{ fontWeight: 700, mb: 1, color: THEME.text.primary }}>
                                                                    {article.title}
                                                                </Typography>
                                                                
                                                                {article.latest_feedback && (
                                                                    <Paper
                                                                        sx={{
                                                                            p: 2,
                                                                            mt: 2,
                                                                            bgcolor: alpha(THEME.warning, 0.05),
                                                                            borderRadius: '12px',
                                                                            border: `2px solid ${alpha(THEME.warning, 0.2)}`
                                                                        }}
                                                                    >
                                                                        <Typography variant="caption" sx={{ color: THEME.warning, fontWeight: 600, display: 'block', mb: 0.5 }}>
                                                                            Editor's Feedback:
                                                                        </Typography>
                                                                        <Typography variant="body2" sx={{ color: THEME.text.secondary, fontStyle: 'italic' }}>
                                                                            "{article.latest_feedback.comments}"
                                                                        </Typography>
                                                                    </Paper>
                                                                )}
                                                            </Grid>
                                                            
                                                            <Grid item xs={12} md={4}>
                                                                <Box sx={{ display: 'flex', gap: 1, justifyContent: { xs: 'flex-start', md: 'flex-end' } }}>
                                                                    <Tooltip title="Revise Article">
                                                                        <Button
                                                                            variant="contained"
                                                                            startIcon={<EditIcon />}
                                                                            onClick={() => window.location.href = route('writer.articles.revise.page', article.id)}
                                                                            sx={{
                                                                                background: THEME.gradient.accent,
                                                                                color: THEME.text.primary,
                                                                                borderRadius: '20px',
                                                                                border: '2px solid white',
                                                                                '&:hover': {
                                                                                    transform: 'scale(1.05)',
                                                                                    boxShadow: `0 4px 12px ${alpha(THEME.warning, 0.3)}`
                                                                                }
                                                                            }}
                                                                        >
                                                                            Revise Now
                                                                        </Button>
                                                                    </Tooltip>
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
                                            background: THEME.gradient.magical,
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center'
                                        }}
                                    >
                                        <RocketLaunchIcon sx={{ color: 'white' }} />
                                    </Box>
                                    <Box>
                                        <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary }}>
                                            Published Articles
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                            {publishedArticles.length} article{publishedArticles.length !== 1 ? 's' : ''} published and available for readers
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
                                    value={publishedSearchQuery}
                                    onChange={(e) => setPublishedSearchQuery(e.target.value)}
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
                                        background: 'white',
                                        textAlign: 'center',
                                        border: `4px solid ${alpha(THEME.success, 0.2)}`,
                                        boxShadow: THEME.shadows.medium
                                    }}
                                >
                                    <SearchIcon sx={{ fontSize: 80, color: THEME.text.light, mb: 2, animation: 'float 3s infinite' }} />
                                    <Typography variant="h5" sx={{ color: THEME.text.primary, mb: 1, fontWeight: 600 }}>
                                        {publishedSearchQuery.trim() ? 'No Published Articles Found' : 'No Published Articles Yet'}
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: THEME.text.secondary }}>
                                        {publishedSearchQuery.trim() 
                                            ? `No articles match "${publishedSearchQuery}". Try different keywords.`
                                            : 'Keep writing! Your published works will appear here'
                                        }
                                    </Typography>
                                </Paper>
                            ) : (
                                <Grid container spacing={3}>
                                    {filteredPublished.map((article, index) => (
                                        <Grid key={article.id} item xs={12} md={6}>
                                            <Zoom in timeout={300 + index * 100}>
                                                <Card
                                                    elevation={0}
                                                    sx={{
                                                        height: '100%',
                                                        borderRadius: '20px',
                                                        background: 'white',
                                                        border: `3px solid ${THEME.success}`,
                                                        boxShadow: `6px 6px 0 ${alpha(THEME.success, 0.2)}`,
                                                        transition: 'all 0.3s ease',
                                                        position: 'relative',
                                                        overflow: 'hidden',
                                                        '&:hover': {
                                                            transform: 'translateY(-8px) translateX(-4px)',
                                                            boxShadow: `10px 10px 0 ${alpha(THEME.success, 0.2)}`,
                                                            borderColor: THEME.green
                                                        },
                                                        '&::before': {
                                                            content: '""',
                                                            position: 'absolute',
                                                            top: -20,
                                                            right: -20,
                                                            width: 80,
                                                            height: 80,
                                                            borderRadius: '50%',
                                                            background: alpha(THEME.accent, 0.1),
                                                            zIndex: 0
                                                        }
                                                    }}
                                                >
                                                    <CardContent sx={{ p: 3, position: 'relative', zIndex: 1 }}>
                                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                                                            <Chip
                                                                icon={<RocketLaunchIcon />}
                                                                label="Published 🌟"
                                                                size="small"
                                                                sx={{
                                                                    bgcolor: THEME.success,
                                                                    color: 'white',
                                                                    fontWeight: 600
                                                                }}
                                                            />
                                                            <Box sx={{ display: 'flex', gap: 1 }}>
                                                                <Tooltip title="Views">
                                                                    <Chip
                                                                        icon={<VisibilityIcon />}
                                                                        label={article.views || 0}
                                                                        size="small"
                                                                        sx={{ bgcolor: alpha(THEME.primary, 0.1), color: THEME.primary }}
                                                                    />
                                                                </Tooltip>
                                                            </Box>
                                                        </Box>

                                                        <Typography variant="h5" sx={{ fontWeight: 700, mb: 2, color: THEME.text.primary }}>
                                                            {article.title}
                                                        </Typography>

                                                        <Chip
                                                            label={article.category.name}
                                                            size="small"
                                                            sx={{
                                                                mb: 2,
                                                                bgcolor: alpha(THEME.secondary, 0.1),
                                                                color: THEME.secondary,
                                                                fontWeight: 600
                                                            }}
                                                        />

                                                        <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                            <Typography variant="caption" sx={{ color: THEME.text.light, display: 'flex', alignItems: 'center', gap: 1 }}>
                                                                <SunIcon sx={{ fontSize: 14 }} />
                                                                Published on {new Date(article.updated_at).toLocaleDateString()}
                                                            </Typography>
                                                            <Button
                                                                size="small"
                                                                endIcon={<VisibilityIcon />}
                                                                onClick={() => window.location.href = route('writer.articles.show', article.id)}
                                                                sx={{
                                                                    color: THEME.primary,
                                                                    fontWeight: 600,
                                                                    borderRadius: '20px',
                                                                    '&:hover': {
                                                                        bgcolor: alpha(THEME.primary, 0.1)
                                                                    }
                                                                }}
                                                            >
                                                                Read
                                                            </Button>
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
                            <AutoStoriesIcon sx={{ color: 'white', fontSize: 28 }} />
                        </Box>
                        <Box>
                            <Typography variant="h5" sx={{ fontWeight: 800, color: THEME.text.primary, letterSpacing: '-0.5px' }}>
                                Creative Writing Studio
                            </Typography>
                            <Typography variant="caption" sx={{ color: THEME.text.secondary, display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                <EmojiIcon sx={{ fontSize: 14, color: THEME.accent }} />
                                Where words come to life
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
                                sx={{
                                    '& .MuiBadge-badge': {
                                        bgcolor: THEME.primary,
                                        color: 'white',
                                        fontWeight: 'bold'
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
                                {auth?.user?.name?.charAt(0) || 'W'}
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
                            <LogoutIcon sx={{ mr: 1.5, fontSize: 20, color: THEME.error }} />
                            Sign Out
                        </MenuItem>
                        <Divider />
                    </Menu>
                    
                    {/* Notification Dropdown */}
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
                                Notifications from Editors
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
                                        px: 2,
                                        flexDirection: 'column', 
                                        alignItems: 'flex-start',
                                        cursor: 'pointer',
                                        borderBottom: `2px solid ${alpha(THEME.primary, 0.05)}`,
                                        bgcolor: readNotifications.has(notification.id) ? 'transparent' : alpha(THEME.primary, 0.02),
                                        '&:hover': { bgcolor: alpha(THEME.primary, 0.04) }
                                    }}
                                    onClick={() => {
                                        markNotificationAsRead(notification.id);
                                        setNotificationAnchor(null);
                                        if (notification.data.type === 'revision_requested') {
                                            window.location.href = route('writer.articles.revise.page', notification.data.article_id);
                                        } else if (notification.data.type === 'article_published') {
                                            window.location.href = route('writer.articles.show', notification.data.article_id);
                                        }
                                    }}
                                >
                                    <Typography 
                                        variant="body2" 
                                        sx={{ 
                                            fontWeight: readNotifications.has(notification.id) ? 400 : 700,
                                            color: THEME.text.primary,
                                            mb: 0.5,
                                            display: 'flex',
                                            alignItems: 'center',
                                            gap: 1
                                        }}
                                    >
                                        {notification.data.type === 'revision_requested' ? '🎨 ' : 
                                         notification.data.type === 'article_published' ? '🌟 ' : '📬 '}
                                        {notification.data.message}
                                    </Typography>
                                    
                                    {notification.data.type === 'revision_requested' && notification.data.comments && (
                                        <Paper
                                            sx={{
                                                p: 1.5,
                                                mt: 1,
                                                width: '100%',
                                                bgcolor: alpha(THEME.warning, 0.05),
                                                borderRadius: '12px',
                                                border: `2px solid ${alpha(THEME.warning, 0.2)}`
                                            }}
                                        >
                                            <Typography variant="caption" sx={{ fontWeight: 600, color: THEME.warning, display: 'block', mb: 0.5 }}>
                                                Editor's Comments:
                                            </Typography>
                                            <Typography variant="body2" sx={{ color: THEME.text.secondary, fontStyle: 'italic' }}>
                                                "{notification.data.comments}"
                                            </Typography>
                                            <Typography variant="caption" sx={{ color: THEME.warning, display: 'block', mt: 0.5 }}>
                                                — {notification.data.editor_name}
                                            </Typography>
                                        </Paper>
                                    )}
                                    
                                    {notification.data.type === 'article_published' && (
                                        <Paper
                                            sx={{
                                                p: 1.5,
                                                mt: 1,
                                                width: '100%',
                                                bgcolor: alpha(THEME.success, 0.05),
                                                borderRadius: '12px',
                                                border: `2px solid ${alpha(THEME.success, 0.2)}`
                                            }}
                                        >
                                            <Typography variant="body2" sx={{ color: THEME.success, display: 'flex', alignItems: 'center', gap: 1 }}>
                                                <EmojiEventsIcon sx={{ fontSize: 16 }} />
                                                Your article is now live and available for readers!
                                            </Typography>
                                        </Paper>
                                    )}
                                    
                                    <Typography variant="caption" sx={{ color: THEME.text.light, display: 'block', mt: 1 }}>
                                        {new Date(notification.created_at).toLocaleDateString()} at {new Date(notification.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                    </Typography>
                                </MenuItem>
                            ))
                        ) : (
                            <MenuItem disabled sx={{ py: 3 }}>
                                <Typography variant="body2" sx={{ color: THEME.text.light, textAlign: 'center', width: '100%' }}>
                                    No notifications from editors 📭
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
                        { id: 'dashboard', icon: <DashboardIcon />, label: 'Dashboard', emoji: '📊' },
                        { id: 'create', icon: <AddIcon />, label: 'Create Article', emoji: '✍️' },
                        { id: 'drafts', icon: <CreateIcon />, label: 'My Drafts', badge: draftArticles.length, emoji: '📝' },
                        { id: 'submitted', icon: <SendIcon />, label: 'Submitted', badge: submittedArticles.length + revisedArticles.length, warning: revisedArticles.length > 0, emoji: '🚀' },
                        { id: 'published', icon: <RocketLaunchIcon />, label: 'Published', badge: publishedArticles.length, emoji: '🌟' }
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
                                    color={item.warning ? 'warning' : 'primary'}
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
                                secondary={item.badge !== undefined ? `${item.badge} items` : undefined}
                                secondaryTypographyProps={{
                                    sx: { color: THEME.text.light }
                                }}
                            />
                        </ListItem>
                    ))}
                </List>

                <Divider sx={{ my: 2, borderWidth: 2, borderColor: alpha(THEME.primary, 0.1) }} />

                {/* Writing Tips */}
                <Box sx={{ p: 2 }}>
                    <Typography variant="subtitle2" sx={{ color: THEME.text.primary, mb: 2, fontWeight: 700, display: 'flex', alignItems: 'center', gap: 1 }}>
                        <LightbulbIcon sx={{ color: THEME.accent }} />
                        Writing Tips
                    </Typography>
                    <List dense>
                        {[
                            { tip: "Write without editing", sub: "Let your ideas flow first", icon: <EmojiIcon /> },
                            { tip: "Set daily word goals", sub: "500 words a day adds up", icon: <TrendingUpIcon /> },
                            { tip: "Read aloud", sub: "Hear how your writing sounds", icon: <MenuBookIcon /> }
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

                {/* Quick Quote */}
                <Box sx={{ mt: 'auto', p: 2 }}>
                    <Paper
                        elevation={0}
                        sx={{
                            p: 2,
                            borderRadius: '16px',
                            background: THEME.gradient.accent,
                            border: `3px solid ${THEME.primary}`,
                            boxShadow: `4px 4px 0 ${alpha(THEME.primary, 0.2)}`,
                            transform: 'rotate(-1deg)',
                            '&:hover': {
                                transform: 'rotate(0deg) scale(1.02)'
                            },
                            transition: 'all 0.3s ease'
                        }}
                    >
                        <FormatQuoteIcon sx={{ fontSize: 24, color: THEME.primary, opacity: 0.5, mb: 1 }} />
                        <Typography variant="caption" sx={{ display: 'block', fontStyle: 'italic', color: THEME.text.primary, fontWeight: 600 }}>
                            "The first draft is just you telling yourself the story."
                        </Typography>
                        <Typography variant="caption" sx={{ display: 'block', mt: 1, color: THEME.text.primary, opacity: 0.7 }}>
                            — Terry Pratchett
                        </Typography>
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

            {/* Floating Action Button for Quick Create */}
            {activeNav !== 'create' && (
                <Tooltip title="Quick Create" arrow>
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
                        onClick={() => setActiveNav('create')}
                    >
                        <AddIcon sx={{ fontSize: 32 }} />
                    </Fab>
                </Tooltip>
            )}
        </Box>
    );
}