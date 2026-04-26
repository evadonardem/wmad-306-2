import { Head, Link } from '@inertiajs/react';
import { Inertia } from '@inertiajs/inertia';
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
    Box,
    Container,
    Button,
    Typography,
    Card,
    CardContent,
    CardHeader,
    Grid,
    Paper,
    AppBar,
    Toolbar,
    IconButton,
    Badge,
    Menu,
    MenuItem,
    Avatar,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Slide,
    Fade,
    Backdrop,
    Modal,
    List,
    ListItem,
    ListItemIcon,
    ListItemText,
    Divider,
    ListItemSecondaryAction,
    Tooltip,
    Chip,
    Fab,
    Zoom,
    useTheme,
    useMediaQuery
} from '@mui/material';
import {
    Edit as EditIcon,
    RateReview as ReviewIcon,
    Publish as PublishIcon,
    Comment as CommentIcon,
    CreateNewFolder as CreateIcon,
    Dashboard as DashboardIcon,
    CheckCircle as CheckIcon,
    Article as ArticleIcon,
    Group as GroupIcon,
    TrendingUp,
    School as SchoolIcon,
    AutoStories,
    Psychology,
    Lightbulb,
    Star,
    ThumbUp,
    ArrowBackIos,
    ArrowForwardIos,
    Close as CloseIcon,
    Delete as DeleteIcon,
    Send as SendIcon,
    Menu as MenuIcon,
    EmojiEmotions as EmojiIcon,
    Brush as BrushIcon,
    Cloud as CloudIcon,
    Rocket as RocketIcon,
    Pets as PetsIcon,
    Cake as CakeIcon,
    MusicNote as MusicIcon,
    Palette as PaletteIcon,
    SelfImprovement as YogaIcon,
    Whatshot as FireIcon,
    AcUnit as IceIcon,
    Waves as WavesIcon,
    Forest as ForestIcon,
    WbSunny as SunIcon,
    Nightlight as MoonIcon
} from '@mui/icons-material';

export default function Welcome({ auth, laravelVersion, phpVersion }) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [articles, setArticles] = useState([]);
    const [currentSlide, setCurrentSlide] = useState(0);
    const [loading, setLoading] = useState(true);
    const [touchStart, setTouchStart] = useState(null);
    const [touchEnd, setTouchEnd] = useState(null);
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [articleModalOpen, setArticleModalOpen] = useState(false);
    const [comments, setComments] = useState([]);
    const [newComment, setNewComment] = useState('');
    const [editingComment, setEditingComment] = useState(null);
    const [editCommentText, setEditCommentText] = useState('');
    const [postingComment, setPostingComment] = useState(false);
    const [mobileMenuAnchor, setMobileMenuAnchor] = useState(null);
    const [floatingIcons, setFloatingIcons] = useState([]);

    useEffect(() => {
        fetchLatestArticles();
        generateFloatingIcons();
    }, []);

    const generateFloatingIcons = () => {
        const icons = [
            <EmojiIcon />, <BrushIcon />, <CloudIcon />, <RocketIcon />, 
            <PetsIcon />, <CakeIcon />, <MusicIcon />, <PaletteIcon />,
            <YogaIcon />, <FireIcon />, <IceIcon />, <WavesIcon />,
            <ForestIcon />, <SunIcon />, <MoonIcon />
        ];
        const positions = [];
        for (let i = 0; i < 20; i++) {
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

    const fetchLatestArticles = async () => {
        try {
            const response = await axios.get('/api/latest-articles');
            setArticles(response.data);
        } catch (error) {
            console.error('Error fetching articles:', error);
        } finally {
            setLoading(false);
        }
    };

    const nextSlide = () => {
        setCurrentSlide((prev) => (prev + 1) % articles.length);
    };

    const prevSlide = () => {
        setCurrentSlide((prev) => (prev - 1 + articles.length) % articles.length);
    };

    const getVisibleArticles = () => {
        return articles.length > 0 ? [articles[currentSlide]] : [];
    };

    useEffect(() => {
        if (articles.length > 1) {
            const interval = setInterval(() => {
                nextSlide();
            }, 5000);
            return () => clearInterval(interval);
        }
    }, [currentSlide, articles.length]);

    const stripHtml = (html) => {
        if (!html) return '';
        const tmp = document.createElement('div');
        tmp.innerHTML = html;
        return tmp.textContent || tmp.innerText || '';
    };

    const handleTouchStart = (e) => {
        setTouchEnd(null);
        setTouchStart(e.targetTouches[0].clientX);
    };

    const handleTouchMove = (e) => {
        setTouchEnd(e.targetTouches[0].clientX);
    };

    const handleTouchEnd = () => {
        if (!touchStart || !touchEnd) return;
        const distance = touchStart - touchEnd;
        const isLeftSwipe = distance > 50;
        const isRightSwipe = distance < -50;

        if (isLeftSwipe) {
            nextSlide();
        }
        if (isRightSwipe) {
            prevSlide();
        }
    };

    const handleArticleClick = (article) => {
        setSelectedArticle(article);
        setArticleModalOpen(true);
        fetchComments(article.id);
    };

    const handleCloseArticleModal = () => {
        setArticleModalOpen(false);
        setSelectedArticle(null);
        setComments([]);
        setNewComment('');
        setEditingComment(null);
        setEditCommentText('');
    };

    const fetchComments = async (articleId) => {
        try {
            const response = await axios.get(`/api/articles/${articleId}/comments`);
            setComments(response.data);
        } catch (error) {
            console.error('Error fetching comments:', error);
        }
    };

    const handleAddComment = async () => {
        if (!newComment.trim() || !auth.user || postingComment) return;

        setPostingComment(true);
        
        try {
            const response = await axios.post(`/api/articles/${selectedArticle.id}/comments`, {
                content: newComment,
                user_id: auth.user.id
            });
            
            setComments([response.data, ...comments]);
            setNewComment('');
            
            setArticles(articles.map(article => 
                article.id === selectedArticle.id 
                    ? { ...article, comments_count: article.comments_count + 1 }
                    : article
            ));
            
            setSelectedArticle({
                ...selectedArticle,
                comments_count: selectedArticle.comments_count + 1
            });
            
        } catch (error) {
            console.error('Error adding comment:', error);
            alert('Failed to post comment. Please try again.');
        } finally {
            setPostingComment(false);
        }
    };

    const handleEditComment = (comment) => {
        setEditingComment(comment.id);
        setEditCommentText(comment.content);
    };

    const handleUpdateComment = async (commentId) => {
        try {
            const response = await axios.put(`/api/comments/${commentId}`, {
                content: editCommentText
            });
            setComments(comments.map(comment => 
                comment.id === commentId ? response.data : comment
            ));
            setEditingComment(null);
            setEditCommentText('');
        } catch (error) {
            console.error('Error updating comment:', error);
        }
    };

    const handleDeleteComment = async (commentId) => {
        if (!window.confirm('Are you sure you want to delete this comment?')) return;

        try {
            await axios.delete(`/api/comments/${commentId}`);
            
            setComments(comments.filter(comment => comment.id !== commentId));
            
            setArticles(articles.map(article => 
                article.id === selectedArticle.id 
                    ? { ...article, comments_count: Math.max(0, article.comments_count - 1) }
                    : article
            ));
            
            setSelectedArticle({
                ...selectedArticle,
                comments_count: Math.max(0, selectedArticle.comments_count - 1)
            });
            
        } catch (error) {
            console.error('Error deleting comment:', error);
            alert('Failed to delete comment. Please try again.');
        }
    };

    const handleCancelEdit = () => {
        setEditingComment(null);
        setEditCommentText('');
    };

    const handleMobileMenuOpen = (event) => {
        setMobileMenuAnchor(event.currentTarget);
    };

    const handleMobileMenuClose = () => {
        setMobileMenuAnchor(null);
    };

    // Cartoon color palette
    const colors = {
        primary: '#FF6B6B', // Coral red - friendly and energetic
        secondary: '#4ECDC4', // Turquoise - calm and playful
        accent: '#FFE66D', // Sunny yellow - cheerful
        background: '#FFF9E6', // Creamy white
        purple: '#9B6B9E', // Soft purple
        orange: '#FF9F1C', // Bright orange
        pink: '#FF8A80', // Soft pink
        green: '#6BAA6B', // Forest green
        blue: '#6B8CFF', // Sky blue
        text: '#4A4A4A', // Soft black
        cardBg: '#FFFFFF',
        shadow: 'rgba(0, 0, 0, 0.1)'
    };

    return (
        <>
            <Head title="Scribble Press - Where Imagination Comes to Life!" />

            {/* Floating Background Icons */}
            <Box sx={{
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                pointerEvents: 'none',
                zIndex: 0,
                overflow: 'hidden'
            }}>
                {floatingIcons.map((item, index) => (
                    <Box
                        key={index}
                        sx={{
                            position: 'absolute',
                            left: `${item.left}%`,
                            top: `${item.top}%`,
                            color: [colors.primary, colors.secondary, colors.accent, colors.purple][Math.floor(Math.random() * 4)],
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

            {/* Playful Navigation Bar */}
            <AppBar 
                position="sticky" 
                elevation={4}
                sx={{ 
                    background: `linear-gradient(135deg, ${colors.primary} 0%, ${colors.pink} 100%)`,
                    borderBottom: `4px solid ${colors.accent}`,
                    zIndex: 10
                }}
            >
                <Toolbar sx={{ display: 'flex', justifyContent: 'space-between', py: 1 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Box
                            sx={{
                                bgcolor: colors.accent,
                                borderRadius: '50%',
                                width: 50,
                                height: 50,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                transform: 'rotate(-5deg)',
                                boxShadow: '0 4px 0 rgba(0,0,0,0.1)',
                                animation: 'bounce 2s infinite',
                                '@keyframes bounce': {
                                    '0%, 100%': { transform: 'rotate(-5deg) translateY(0)' },
                                    '50%': { transform: 'rotate(-5deg) translateY(-5px)' }
                                }
                            }}
                        >
                            <AutoStories sx={{ fontSize: 30, color: colors.primary }} />
                        </Box>
                        <Box>
                            <Typography 
                                variant="h5" 
                                sx={{ 
                                    fontWeight: 'bold', 
                                    color: 'white',
                                    fontFamily: '"Comic Sans MS", "Chalkboard SE", cursive',
                                    textShadow: '3px 3px 0 rgba(0,0,0,0.1)',
                                    letterSpacing: '1px'
                                }}
                            >
                                Scribble Press
                            </Typography>
                            <Typography 
                                variant="caption" 
                                sx={{ 
                                    color: colors.accent,
                                    fontFamily: '"Comic Sans MS", cursive',
                                    fontWeight: 'bold'
                                }}
                            >
                                Where Articles Come Alive!
                            </Typography>
                        </Box>
                    </Box>

                    <Box sx={{ display: 'flex', gap: 2 }}>
                        {!auth.user ? (
                            <>
                                {isMobile ? (
                                    <IconButton
                                        onClick={handleMobileMenuOpen}
                                        sx={{ 
                                            bgcolor: colors.accent,
                                            '&:hover': { transform: 'scale(1.1)' },
                                            transition: 'all 0.3s ease'
                                        }}
                                    >
                                        <MenuIcon />
                                    </IconButton>
                                ) : (
                                    <>
                                        <Button
                                            component={Link}
                                            href={route('login')}
                                            variant="outlined"
                                            sx={{ 
                                                color: 'white', 
                                                borderColor: 'white',
                                                borderWidth: 3,
                                                borderRadius: 20,
                                                fontFamily: '"Comic Sans MS", cursive',
                                                fontWeight: 'bold',
                                                '&:hover': {
                                                    bgcolor: 'rgba(255,255,255,0.2)',
                                                    transform: 'scale(1.05)'
                                                }
                                            }}
                                        >
                                            Sign In
                                        </Button>
                                        <Button
                                            component={Link}
                                            href={route('register')}
                                            variant="contained"
                                            sx={{
                                                bgcolor: colors.accent,
                                                color: colors.primary,
                                                fontWeight: 'bold',
                                                borderRadius: 20,
                                                fontFamily: '"Comic Sans MS", cursive',
                                                border: '3px solid white',
                                                '&:hover': {
                                                    bgcolor: '#FFD93D',
                                                    transform: 'scale(1.05)'
                                                }
                                            }}
                                        >
                                            Join the Fun!
                                        </Button>
                                    </>
                                )}
                            </>
                        ) : (
                            <Button
                                component={Link}
                                href={route('dashboard')}
                                variant="contained"
                                sx={{
                                    bgcolor: colors.accent,
                                    color: colors.primary,
                                    fontWeight: 'bold',
                                    borderRadius: 20,
                                    fontFamily: '"Comic Sans MS", cursive',
                                    '&:hover': {
                                        bgcolor: '#FFD93D',
                                        transform: 'scale(1.05)'
                                    }
                                }}
                            >
                                My Scribble Room
                            </Button>
                        )}
                    </Box>
                </Toolbar>

                {/* Mobile Menu */}
                <Menu
                    anchorEl={mobileMenuAnchor}
                    open={Boolean(mobileMenuAnchor)}
                    onClose={handleMobileMenuClose}
                    PaperProps={{
                        sx: {
                            bgcolor: colors.primary,
                            borderRadius: 4,
                            border: `4px solid ${colors.accent}`,
                            mt: 2
                        }
                    }}
                >
                    <MenuItem onClick={handleMobileMenuClose}>
                        <Link href={route('login')} style={{ textDecoration: 'none', color: 'white', width: '100%' }}>
                            <Typography fontFamily='"Comic Sans MS", cursive'>Sign In</Typography>
                        </Link>
                    </MenuItem>
                    <MenuItem onClick={handleMobileMenuClose}>
                        <Link href={route('register')} style={{ textDecoration: 'none', color: 'white', width: '100%' }}>
                            <Typography fontFamily='"Comic Sans MS", cursive'>Join the Fun!</Typography>
                        </Link>
                    </MenuItem>
                </Menu>
            </AppBar>

            {/* Hero Section - Cartoon Style */}
            <Box
                sx={{
                    background: `linear-gradient(135deg, ${colors.blue} 0%, ${colors.secondary} 50%, ${colors.green} 100%)`,
                    position: 'relative',
                    overflow: 'hidden',
                    py: 8,
                    '&::before': {
                        content: '""',
                        position: 'absolute',
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        background: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 120' preserveAspectRatio='none'%3E%3Cpath d='M0,0V46.29c47.79,22.2,103.59,32.17,158,28,70.36-5.37,136.33-33.31,206.8-37.5C438.64,32.43,512.34,53.67,583,72.05c69.27,18,138.3,24.88,209.4,13.08,36.15-6,69.85-17.84,104.45-29.34C989.49,25,1113-14.29,1200,52.47V0Z' fill='${colors.background.replace('#', '%23')}' opacity='1'%3E%3C/path%3E%3C/svg%3E")`,
                        backgroundSize: 'cover',
                        backgroundRepeat: 'no-repeat'
                    }
                }}
            >
                {/* Animated Clouds */}
                <Box sx={{
                    position: 'absolute',
                    top: 20,
                    left: '5%',
                    animation: 'cloudMove 20s infinite linear',
                    '@keyframes cloudMove': {
                        '0%': { transform: 'translateX(-100px)' },
                        '100%': { transform: 'translateX(100vw)' }
                    }
                }}>
                    <CloudIcon sx={{ fontSize: 80, color: 'rgba(255,255,255,0.3)' }} />
                </Box>
                <Box sx={{
                    position: 'absolute',
                    top: 100,
                    right: '5%',
                    animation: 'cloudMoveReverse 25s infinite linear',
                    '@keyframes cloudMoveReverse': {
                        '0%': { transform: 'translateX(100px)' },
                        '100%': { transform: 'translateX(-100vw)' }
                    }
                }}>
                    <CloudIcon sx={{ fontSize: 60, color: 'rgba(255,255,255,0.3)' }} />
                </Box>

                <Container maxWidth="lg" sx={{ position: 'relative', zIndex: 2 }}>
                    <Grid container spacing={4} alignItems="center">
                        <Grid item xs={12} md={6}>
                            <Zoom in timeout={1000}>
                                <Box>
                                    <Chip
                                        icon={<EmojiIcon />}
                                        label="Welcome to Scribble Press!"
                                        sx={{
                                            bgcolor: colors.accent,
                                            color: colors.text,
                                            fontSize: '1rem',
                                            p: 2,
                                            mb: 3,
                                            borderRadius: 30,
                                            fontFamily: '"Comic Sans MS", cursive',
                                            fontWeight: 'bold',
                                            animation: 'wiggle 2s infinite',
                                            '@keyframes wiggle': {
                                                '0%, 100%': { transform: 'rotate(0deg)' },
                                                '25%': { transform: 'rotate(-5deg)' },
                                                '75%': { transform: 'rotate(5deg)' }
                                            }
                                        }}
                                    />
                                    
                                    <Typography
                                        variant="h1"
                                        sx={{
                                            fontFamily: '"Comic Sans MS", "Chalkboard SE", cursive',
                                            fontWeight: 'bold',
                                            fontSize: { xs: '3rem', md: '4.5rem' },
                                            color: 'white',
                                            textShadow: '6px 6px 0 rgba(0,0,0,0.2)',
                                            lineHeight: 1.1,
                                            mb: 3
                                        }}
                                    >
                                        Create Amazing
                                        <Box component="span" sx={{ color: colors.accent, display: 'block' }}>
                                            Artices Today!
                                        </Box>
                                    </Typography>

                                    <Typography
                                        variant="h5"
                                        sx={{
                                            color: 'white',
                                            mb: 4,
                                            fontFamily: '"Comic Sans MS", cursive',
                                            textShadow: '2px 2px 0 rgba(0,0,0,0.1)'
                                        }}
                                    >
                                        Join our magical world where article becomes an adventure! 
                                        Write, edit, and read your articles with friends.
                                    </Typography>

                                    {!auth.user && (
                                        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                                            <Button
                                                component={Link}
                                                href={route('register')}
                                                variant="contained"
                                                size="large"
                                                sx={{
                                                    bgcolor: colors.accent,
                                                    color: colors.primary,
                                                    fontSize: '1.3rem',
                                                    py: 2,
                                                    px: 4,
                                                    borderRadius: 40,
                                                    fontFamily: '"Comic Sans MS", cursive',
                                                    fontWeight: 'bold',
                                                    border: '4px solid white',
                                                    '&:hover': {
                                                        bgcolor: '#FFD93D',
                                                        transform: 'scale(1.1) rotate(-2deg)'
                                                    },
                                                    transition: 'all 0.3s ease'
                                                }}
                                            >
                                                Start Your Adventure
                                                <RocketIcon sx={{ ml: 1 }} />
                                            </Button>
                                            <Button
                                                component={Link}
                                                href={route('login')}
                                                variant="outlined"
                                                size="large"
                                                sx={{
                                                    color: 'white',
                                                    borderColor: 'white',
                                                    borderWidth: 4,
                                                    fontSize: '1.3rem',
                                                    py: 2,
                                                    px: 4,
                                                    borderRadius: 40,
                                                    fontFamily: '"Comic Sans MS", cursive',
                                                    fontWeight: 'bold',
                                                    '&:hover': {
                                                        bgcolor: 'rgba(255,255,255,0.2)',
                                                        transform: 'scale(1.1) rotate(2deg)'
                                                    }
                                                }}
                                            >
                                                I Already Have Magic
                                            </Button>
                                        </Box>
                                    )}
                                </Box>
                            </Zoom>
                        </Grid>

                        <Grid item xs={12} md={6}>
                            <Zoom in timeout={1500}>
                                <Box
                                    sx={{
                                        position: 'relative',
                                        display: 'flex',
                                        justifyContent: 'center',
                                        alignItems: 'center'
                                    }}
                                >
                                    {/* Playful character illustrations */}
                                    <Box sx={{ position: 'relative', width: 400, height: 400 }}>
                                        {[...Array(5)].map((_, i) => (
                                            <Box
                                                key={i}
                                                sx={{
                                                    position: 'absolute',
                                                    width: 60 + i * 20,
                                                    height: 60 + i * 20,
                                                    borderRadius: '50%',
                                                    background: `radial-gradient(circle at 30% 30%, ${[
                                                        colors.accent,
                                                        colors.primary,
                                                        colors.purple,
                                                        colors.green,
                                                        colors.orange
                                                    ][i]}, ${[
                                                        colors.primary,
                                                        colors.pink,
                                                        colors.blue,
                                                        colors.secondary,
                                                        colors.accent
                                                    ][i]})`,
                                                    left: '50%',
                                                    top: '50%',
                                                    transform: 'translate(-50%, -50%)',
                                                    animation: `bubble ${3 + i}s infinite ease-in-out`,
                                                    animationDelay: `${i * 0.2}s`,
                                                    '@keyframes bubble': {
                                                        '0%, 100%': { transform: 'translate(-50%, -50%) scale(1)' },
                                                        '50%': { transform: 'translate(-50%, -50%) scale(1.1)' }
                                                    },
                                                    '&::before': {
                                                        content: '""',
                                                        position: 'absolute',
                                                        width: '20%',
                                                        height: '20%',
                                                        borderRadius: '50%',
                                                        background: 'rgba(255,255,255,0.6)',
                                                        top: '15%',
                                                        left: '20%'
                                                    }
                                                }}
                                            />
                                        ))}
                                        <Box
                                            sx={{
                                                position: 'absolute',
                                                top: '20%',
                                                left: '30%',
                                                animation: 'float 3s infinite',
                                                '@keyframes float': {
                                                    '0%, 100%': { transform: 'translateY(0)' },
                                                    '50%': { transform: 'translateY(-20px)' }
                                                }
                                            }}
                                        >
                                            <BrushIcon sx={{ fontSize: 50, color: colors.accent }} />
                                        </Box>
                                        <Box
                                            sx={{
                                                position: 'absolute',
                                                bottom: '20%',
                                                right: '30%',
                                                animation: 'float 4s infinite',
                                                animationDelay: '1s'
                                            }}
                                        >
                                            <PaletteIcon sx={{ fontSize: 60, color: colors.orange }} />
                                        </Box>
                                    </Box>
                                </Box>
                            </Zoom>
                        </Grid>
                    </Grid>
                </Container>
            </Box>

            {/* Featured Stories Section */}
            <Box sx={{ bgcolor: colors.background, py: 8, position: 'relative', zIndex: 2 }}>
                <Container maxWidth="xl">
                    <Box sx={{ textAlign: 'center', mb: 6 }}>
                        <Typography
                            variant="overline"
                            sx={{
                                fontFamily: '"Comic Sans MS", cursive',
                                fontSize: '1.2rem',
                                color: colors.purple,
                                bgcolor: colors.accent,
                                p: 1,
                                px: 3,
                                borderRadius: 30,
                                display: 'inline-block',
                                mb: 2
                            }}
                        >
                            🌟 Featured Articles 🌟
                        </Typography>
                        <Typography
                            variant="h3"
                            sx={{
                                fontFamily: '"Comic Sans MS", cursive',
                                fontWeight: 'bold',
                                color: colors.primary,
                                textShadow: '3px 3px 0 rgba(255,107,107,0.3)'
                            }}
                        >
                            Check Out These Amazing Tales!
                        </Typography>
                    </Box>

                    {!loading && articles.length > 0 && (
                        <Box sx={{ position: 'relative' }}>
                            <IconButton
                                onClick={prevSlide}
                                sx={{
                                    position: 'absolute',
                                    left: { xs: -10, md: -30 },
                                    top: '50%',
                                    transform: 'translateY(-50%)',
                                    zIndex: 3,
                                    bgcolor: colors.primary,
                                    color: 'white',
                                    width: 60,
                                    height: 60,
                                    '&:hover': {
                                        bgcolor: colors.pink,
                                        transform: 'translateY(-50%) scale(1.1)'
                                    },
                                    boxShadow: '0 4px 0 rgba(0,0,0,0.1)'
                                }}
                            >
                                <ArrowBackIos />
                            </IconButton>

                            <IconButton
                                onClick={nextSlide}
                                sx={{
                                    position: 'absolute',
                                    right: { xs: -10, md: -30 },
                                    top: '50%',
                                    transform: 'translateY(-50%)',
                                    zIndex: 3,
                                    bgcolor: colors.primary,
                                    color: 'white',
                                    width: 60,
                                    height: 60,
                                    '&:hover': {
                                        bgcolor: colors.pink,
                                        transform: 'translateY(-50%) scale(1.1)'
                                    },
                                    boxShadow: '0 4px 0 rgba(0,0,0,0.1)'
                                }}
                            >
                                <ArrowForwardIos />
                            </IconButton>

                            <Box
                                sx={{ width: '100%', maxWidth: '900px', mx: 'auto' }}
                                onTouchStart={handleTouchStart}
                                onTouchMove={handleTouchMove}
                                onTouchEnd={handleTouchEnd}
                            >
                                {getVisibleArticles().map((article, index) => (
                                    <Slide in timeout={500} direction="left" key={article.id}>
                                        <Card
                                            onClick={() => handleArticleClick(article)}
                                            sx={{
                                                bgcolor: 'white',
                                                borderRadius: 8,
                                                border: `4px solid ${colors.secondary}`,
                                                boxShadow: `8px 8px 0 ${colors.primary}`,
                                                transition: 'all 0.3s ease',
                                                cursor: 'pointer',
                                                '&:hover': {
                                                    transform: 'translateY(-4px) translateX(-4px)',
                                                    boxShadow: `12px 12px 0 ${colors.primary}`
                                                }
                                            }}
                                        >
                                            <CardContent sx={{ p: 4 }}>
                                                <Box sx={{ display: 'flex', gap: 1, mb: 2, flexWrap: 'wrap' }}>
                                                    <Chip
                                                        icon={<Star />}
                                                        label="Featured Articles"
                                                        sx={{
                                                            bgcolor: colors.accent,
                                                            color: colors.text,
                                                            fontWeight: 'bold',
                                                            borderRadius: 20
                                                        }}
                                                    />
                                                    <Chip
                                                        icon={<EmojiIcon />}
                                                        label={article.category || 'Adventure'}
                                                        sx={{
                                                            bgcolor: colors.secondary,
                                                            color: 'white',
                                                            fontWeight: 'bold',
                                                            borderRadius: 20
                                                        }}
                                                    />
                                                </Box>

                                                <Typography
                                                    variant="h4"
                                                    sx={{
                                                        fontFamily: '"Comic Sans MS", cursive',
                                                        fontWeight: 'bold',
                                                        color: colors.primary,
                                                        mb: 3,
                                                        lineHeight: 1.3
                                                    }}
                                                >
                                                    {article.title}
                                                </Typography>

                                                <Typography
                                                    variant="body1"
                                                    sx={{
                                                        color: colors.text,
                                                        mb: 3,
                                                        fontSize: '1.1rem',
                                                        lineHeight: 1.8
                                                    }}
                                                >
                                                    {article.excerpt || stripHtml(article.content).substring(0, 200) + '...'}
                                                </Typography>

                                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                        <Avatar
                                                            sx={{
                                                                bgcolor: colors.purple,
                                                                border: `2px solid ${colors.accent}`
                                                            }}
                                                        >
                                                            {article.writer?.[0] || '?'}
                                                        </Avatar>
                                                        <Box>
                                                            <Typography variant="body2" sx={{ fontWeight: 'bold', color: colors.primary }}>
                                                                {article.writer || 'Storyteller'}
                                                            </Typography>
                                                            <Typography variant="caption" sx={{ color: colors.text }}>
                                                                Magic Maker
                                                            </Typography>
                                                        </Box>
                                                    </Box>
                                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                            <CommentIcon sx={{ color: colors.secondary }} />
                                                            <Typography variant="body2">{article.comments_count || 0}</Typography>
                                                        </Box>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                                            <ThumbUp sx={{ color: colors.primary }} />
                                                            <Typography variant="body2">42</Typography>
                                                        </Box>
                                                    </Box>
                                                </Box>
                                            </CardContent>
                                        </Card>
                                    </Slide>
                                ))}
                            </Box>

                            {/* Slide Indicators */}
                            <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4, gap: 2 }}>
                                {articles.map((_, index) => (
                                    <Box
                                        key={index}
                                        onClick={() => setCurrentSlide(index)}
                                        sx={{
                                            width: currentSlide === index ? 40 : 20,
                                            height: 20,
                                            borderRadius: 20,
                                            bgcolor: currentSlide === index ? colors.primary : colors.secondary,
                                            border: `2px solid ${colors.primary}`,
                                            cursor: 'pointer',
                                            transition: 'all 0.3s ease',
                                            '&:hover': {
                                                transform: 'scale(1.2)'
                                            }
                                        }}
                                    />
                                ))}
                            </Box>
                        </Box>
                    )}
                </Container>
            </Box>

            {/* Magical Features Section */}
            <Box sx={{ bgcolor: colors.primary, py: 8, position: 'relative', overflow: 'hidden' }}>
                <Container maxWidth="xl">
                    <Typography
                        variant="h3"
                        sx={{
                            fontFamily: '"Comic Sans MS", cursive',
                            fontWeight: 'bold',
                            color: 'white',
                            textAlign: 'center',
                            mb: 6,
                            textShadow: '4px 4px 0 rgba(0,0,0,0.2)'
                        }}
                    >
                        ✨ Magical Features Await You! ✨
                    </Typography>

                    <Grid container spacing={4}>
                        {[
                            { icon: <BrushIcon sx={{ fontSize: 60 }} />, title: 'Story Painter', color: colors.accent, desc: 'Paint your imagination with words' },
                            { icon: <RocketIcon sx={{ fontSize: 60 }} />, title: 'Adventure Builder', color: colors.orange, desc: 'Create epic adventures' },
                            { icon: <PetsIcon sx={{ fontSize: 60 }} />, title: 'Character Creator', color: colors.green, desc: 'Bring characters to life' },
                            { icon: <MusicIcon sx={{ fontSize: 60 }} />, title: 'Sound Explorer', color: colors.purple, desc: 'Add music to your articles' }
                        ].map((feature, index) => (
                            <Grid item xs={12} sm={6} md={3} key={index}>
                                <Zoom in timeout={1000 + index * 200}>
                                    <Card
                                        sx={{
                                            bgcolor: 'white',
                                            borderRadius: 8,
                                            border: `4px solid ${feature.color}`,
                                            boxShadow: `6px 6px 0 ${feature.color}`,
                                            transition: 'all 0.3s ease',
                                            '&:hover': {
                                                transform: 'translateY(-4px) translateX(-4px)',
                                                boxShadow: `10px 10px 0 ${feature.color}`
                                            }
                                        }}
                                    >
                                        <CardContent sx={{ textAlign: 'center', p: 4 }}>
                                            <Box
                                                sx={{
                                                    bgcolor: feature.color,
                                                    borderRadius: '50%',
                                                    width: 100,
                                                    height: 100,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    mx: 'auto',
                                                    mb: 3,
                                                    animation: 'spin 10s infinite linear',
                                                    '@keyframes spin': {
                                                        '0%': { transform: 'rotate(0deg)' },
                                                        '100%': { transform: 'rotate(360deg)' }
                                                    }
                                                }}
                                            >
                                                {feature.icon}
                                            </Box>
                                            <Typography
                                                variant="h5"
                                                sx={{
                                                    fontFamily: '"Comic Sans MS", cursive',
                                                    fontWeight: 'bold',
                                                    color: colors.text,
                                                    mb: 2
                                                }}
                                            >
                                                {feature.title}
                                            </Typography>
                                            <Typography variant="body2" sx={{ color: colors.text }}>
                                                {feature.desc}
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Zoom>
                            </Grid>
                        ))}
                    </Grid>
                </Container>
            </Box>

            {/* Fun Activities Section */}
            <Box sx={{ bgcolor: colors.secondary, py: 8 }}>
                <Container maxWidth="xl">
                    <Typography
                        variant="h3"
                        sx={{
                            fontFamily: '"Comic Sans MS", cursive',
                            fontWeight: 'bold',
                            color: 'white',
                            textAlign: 'center',
                            mb: 6,
                            textShadow: '4px 4px 0 rgba(0,0,0,0.2)'
                        }}
                    >
                        🎨 Fun Activities for Everyone! 🎨
                    </Typography>

                    <Grid container spacing={3}>
                        {[
                            { emoji: '🎭', title: 'Story Theater', bg: colors.pink },
                            { emoji: '🎪', title: 'Circus of Tales', bg: colors.orange },
                            { emoji: '🎨', title: 'Drawing Corner', bg: colors.green },
                            { emoji: '🎮', title: 'Game Zone', bg: colors.purple },
                            { emoji: '🎵', title: 'Music Room', bg: colors.blue },
                            { emoji: '📚', title: 'Reading Nook', bg: colors.accent }
                        ].map((activity, index) => (
                            <Grid item xs={12} sm={6} md={4} key={index}>
                                <Paper
                                    sx={{
                                        p: 3,
                                        bgcolor: activity.bg,
                                        borderRadius: 8,
                                        border: '4px solid white',
                                        textAlign: 'center',
                                        cursor: 'pointer',
                                        transition: 'all 0.3s ease',
                                        '&:hover': {
                                            transform: 'scale(1.05) rotate(1deg)'
                                        }
                                    }}
                                >
                                    <Typography variant="h1" sx={{ fontSize: '4rem', mb: 2 }}>
                                        {activity.emoji}
                                    </Typography>
                                    <Typography
                                        variant="h5"
                                        sx={{
                                            fontFamily: '"Comic Sans MS", cursive',
                                            fontWeight: 'bold',
                                            color: 'white'
                                        }}
                                    >
                                        {activity.title}
                                    </Typography>
                                </Paper>
                            </Grid>
                        ))}
                    </Grid>
                </Container>
            </Box>

            {/* Call to Action - Playful Banner */}
            <Box sx={{ bgcolor: colors.accent, py: 8, position: 'relative', overflow: 'hidden' }}>
                <Container maxWidth="md">
                    <Paper
                        elevation={0}
                        sx={{
                            p: 6,
                            bgcolor: 'white',
                            borderRadius: 8,
                            border: `6px solid ${colors.primary}`,
                            textAlign: 'center',
                            position: 'relative',
                            '&::before': {
                                content: '""',
                                position: 'absolute',
                                top: -20,
                                left: -20,
                                width: 60,
                                height: 60,
                                borderRadius: '50%',
                                bgcolor: colors.orange
                            },
                            '&::after': {
                                content: '""',
                                position: 'absolute',
                                bottom: -20,
                                right: -20,
                                width: 60,
                                height: 60,
                                borderRadius: '50%',
                                bgcolor: colors.green
                            }
                        }}
                    >
                        <Typography
                            variant="h3"
                            sx={{
                                fontFamily: '"Comic Sans MS", cursive',
                                fontWeight: 'bold',
                                color: colors.primary,
                                mb: 3
                            }}
                        >
                            Ready for an Adventure? 🚀
                        </Typography>
                        <Typography variant="h5" sx={{ color: colors.text, mb: 4 }}>
                            Join thousands of young article publishers creating magic every day!
                        </Typography>
                        <Button
                            component={Link}
                            href={route('register')}
                            variant="contained"
                            size="large"
                            sx={{
                                bgcolor: colors.primary,
                                color: 'white',
                                fontSize: '1.5rem',
                                py: 2,
                                px: 6,
                                borderRadius: 40,
                                fontFamily: '"Comic Sans MS", cursive',
                                fontWeight: 'bold',
                                border: '4px solid white',
                                '&:hover': {
                                    bgcolor: colors.pink,
                                    transform: 'scale(1.1) rotate(-2deg)'
                                }
                            }}
                        >
                            Let's Go! <RocketIcon sx={{ ml: 2 }} />
                        </Button>
                    </Paper>
                </Container>
            </Box>

            {/* Article Modal - Cartoon Style */}
            <Dialog
                open={articleModalOpen}
                onClose={handleCloseArticleModal}
                fullScreen
                TransitionComponent={Slide}
                TransitionProps={{ direction: 'up' }}
                PaperProps={{
                    sx: {
                        bgcolor: colors.background,
                        backgroundImage: `radial-gradient(circle at 10% 20%, ${colors.accent}20 0%, transparent 20%),
                                         radial-gradient(circle at 90% 80%, ${colors.primary}20 0%, transparent 20%)`
                    }
                }}
            >
                <DialogTitle sx={{ 
                    bgcolor: colors.primary, 
                    color: 'white',
                    borderBottom: `4px solid ${colors.accent}`,
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                }}>
                    <Typography variant="h4" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold' }}>
                        📖 {selectedArticle?.title}
                    </Typography>
                    <IconButton onClick={handleCloseArticleModal} sx={{ color: 'white', '&:hover': { transform: 'scale(1.2)' } }}>
                        <CloseIcon />
                    </IconButton>
                </DialogTitle>

                <DialogContent>
                    <Container maxWidth="md" sx={{ py: 4 }}>
                        {/* Storyteller Info */}
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 3, mb: 4, bgcolor: 'white', p: 3, borderRadius: 4, border: `3px solid ${colors.secondary}` }}>
                            <Avatar sx={{ width: 80, height: 80, bgcolor: colors.purple, border: `3px solid ${colors.accent}` }}>
                                {selectedArticle?.writer?.[0] || '?'}
                            </Avatar>
                            <Box>
                                <Typography variant="h5" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold', color: colors.primary }}>
                                    {selectedArticle?.writer || 'Mystery Storyteller'}
                                </Typography>
                                <Typography variant="body1" sx={{ color: colors.text }}>
                                    🌟 Master Writer • {selectedArticle?.updated_at}
                                </Typography>
                            </Box>
                        </Box>

                        {/* Story Content */}
                        <Paper sx={{ p: 4, bgcolor: 'white', borderRadius: 4, border: `3px solid ${colors.green}`, mb: 4 }}>
                            <Typography
                                variant="body1"
                                sx={{
                                    fontFamily: '"Comic Sans MS", cursive',
                                    color: colors.text,
                                    lineHeight: 2,
                                    fontSize: '1.2rem'
                                }}
                            >
                                {selectedArticle?.content}
                            </Typography>
                        </Paper>

                        {/* Comments Section - Playful */}
                        <Box sx={{ mt: 4 }}>
                            <Typography variant="h4" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold', color: colors.primary, mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
                                <CommentIcon sx={{ fontSize: 40 }} /> Reader Comments ({comments.length})
                            </Typography>

                            {auth.user ? (
                                <Paper sx={{ p: 3, mb: 4, bgcolor: 'white', borderRadius: 4, border: `3px solid ${colors.secondary}` }}>
                                    <TextField
                                        fullWidth
                                        multiline
                                        rows={3}
                                        placeholder="Share your thoughts about this article..."
                                        value={newComment}
                                        onChange={(e) => setNewComment(e.target.value)}
                                        sx={{
                                            '& .MuiOutlinedInput-root': {
                                                fontFamily: '"Comic Sans MS", cursive',
                                                '& fieldset': {
                                                    borderColor: colors.secondary,
                                                    borderWidth: 2
                                                }
                                            }
                                        }}
                                    />
                                    <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 2 }}>
                                        <Button
                                            variant="contained"
                                            onClick={handleAddComment}
                                            disabled={!newComment.trim() || postingComment}
                                            sx={{
                                                bgcolor: colors.primary,
                                                color: 'white',
                                                fontFamily: '"Comic Sans MS", cursive',
                                                fontWeight: 'bold',
                                                borderRadius: 30,
                                                px: 4,
                                                '&:hover': {
                                                    bgcolor: colors.pink,
                                                    transform: 'scale(1.05)'
                                                }
                                            }}
                                        >
                                            {postingComment ? 'Sending...' : 'Post Comment'} 🚀
                                        </Button>
                                    </Box>
                                </Paper>
                            ) : (
                                <Paper sx={{ p: 4, bgcolor: colors.accent, textAlign: 'center', mb: 4, borderRadius: 4 }}>
                                    <Typography variant="h6" sx={{ color: colors.primary, fontFamily: '"Comic Sans MS", cursive' }}>
                                        ✨ <Link href={route('login')} style={{ color: colors.primary, fontWeight: 'bold' }}>Sign in</Link> to join the conversation! ✨
                                    </Typography>
                                </Paper>
                            )}

                            {/* Comments List */}
                            <List>
                                {comments.map((comment) => (
                                    <Paper key={comment.id} sx={{ mb: 2, bgcolor: 'white', borderRadius: 4, border: `2px solid ${colors.secondary}`, overflow: 'hidden' }}>
                                        <ListItem alignItems="flex-start">
                                            <ListItemIcon>
                                                <Avatar sx={{ bgcolor: colors.purple, border: `2px solid ${colors.accent}` }}>
                                                    {comment.user?.name?.[0] || 'R'}
                                                </Avatar>
                                            </ListItemIcon>
                                            <ListItemText
                                                primary={
                                                    <Typography variant="subtitle1" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold', color: colors.primary }}>
                                                        {comment.user?.name || 'Reader'} 
                                                        <Typography component="span" variant="caption" sx={{ ml: 1, color: colors.text }}>
                                                            • just now
                                                        </Typography>
                                                    </Typography>
                                                }
                                                secondary={
                                                    editingComment === comment.id ? (
                                                        <Box sx={{ mt: 2 }}>
                                                            <TextField
                                                                fullWidth
                                                                multiline
                                                                size="small"
                                                                value={editCommentText}
                                                                onChange={(e) => setEditCommentText(e.target.value)}
                                                                sx={{ mb: 2 }}
                                                            />
                                                            <Box sx={{ display: 'flex', gap: 1 }}>
                                                                <Button
                                                                    size="small"
                                                                    variant="contained"
                                                                    onClick={() => handleUpdateComment(comment.id)}
                                                                    sx={{ bgcolor: colors.green }}
                                                                >
                                                                    Save
                                                                </Button>
                                                                <Button
                                                                    size="small"
                                                                    onClick={handleCancelEdit}
                                                                    sx={{ color: colors.primary }}
                                                                >
                                                                    Cancel
                                                                </Button>
                                                            </Box>
                                                        </Box>
                                                    ) : (
                                                        <Typography variant="body1" sx={{ color: colors.text, mt: 1, fontFamily: '"Comic Sans MS", cursive' }}>
                                                            {comment.content}
                                                        </Typography>
                                                    )
                                                }
                                            />
                                            {auth.user && auth.user.id === comment.user_id && (
                                                <ListItemSecondaryAction>
                                                    <IconButton
                                                        edge="end"
                                                        onClick={() => handleEditComment(comment)}
                                                        sx={{ color: colors.secondary, mr: 1 }}
                                                    >
                                                        <EditIcon />
                                                    </IconButton>
                                                    <IconButton
                                                        edge="end"
                                                        onClick={() => handleDeleteComment(comment.id)}
                                                        sx={{ color: colors.primary }}
                                                    >
                                                        <DeleteIcon />
                                                    </IconButton>
                                                </ListItemSecondaryAction>
                                            )}
                                        </ListItem>
                                    </Paper>
                                ))}
                            </List>
                        </Box>
                    </Container>
                </DialogContent>
            </Dialog>

            {/* Playful Footer */}
            <Box sx={{ bgcolor: colors.purple, color: 'white', py: 6, borderTop: `6px solid ${colors.accent}` }}>
                <Container maxWidth="xl">
                    <Grid container spacing={4}>
                        <Grid item xs={12} md={4}>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
                                <Box sx={{ bgcolor: colors.accent, borderRadius: '50%', p: 1 }}>
                                    <AutoStories sx={{ fontSize: 40, color: colors.purple }} />
                                </Box>
                                <Typography variant="h4" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold' }}>
                                    Scribble Press
                                </Typography>
                            </Box>
                            <Typography variant="body1" sx={{ mb: 3 }}>
                                Where every article is an adventure waiting to happen!
                            </Typography>
                            <Box sx={{ display: 'flex', gap: 2 }}>
                                {['📘', '📗', '📕', '📙'].map((emoji, index) => (
                                    <Typography key={index} variant="h4" sx={{ cursor: 'pointer', '&:hover': { transform: 'scale(1.2)' } }}>
                                        {emoji}
                                    </Typography>
                                ))}
                            </Box>
                        </Grid>

                        <Grid item xs={12} md={8}>
                            <Grid container spacing={4}>
                                {[
                                    { title: 'Explore', items: ['Stories', 'Authors', 'Illustrations', 'Activities'] },
                                    { title: 'Create', items: ['Write Story', 'Draw', 'Compose Music', 'Build World'] },
                                    { title: 'Connect', items: ['Friends', 'Groups', 'Events', 'Contests'] }
                                ].map((section) => (
                                    <Grid item xs={4} key={section.title}>
                                        <Typography variant="h6" sx={{ fontFamily: '"Comic Sans MS", cursive', fontWeight: 'bold', mb: 2, color: colors.accent }}>
                                            {section.title}
                                        </Typography>
                                        {section.items.map((item) => (
                                            <Typography
                                                key={item}
                                                variant="body2"
                                                sx={{
                                                    mb: 1,
                                                    cursor: 'pointer',
                                                    '&:hover': {
                                                        color: colors.accent,
                                                        transform: 'translateX(5px)'
                                                    },
                                                    transition: 'all 0.3s ease'
                                                }}
                                            >
                                                {item}
                                            </Typography>
                                        ))}
                                    </Grid>
                                ))}
                            </Grid>
                        </Grid>
                    </Grid>

                    <Divider sx={{ my: 4, borderColor: 'rgba(255,255,255,0.2)' }} />

                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap' }}>
                        <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.7)' }}>
                            © 2026 Article Publication Platform Group3
                        </Typography>
                        <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.7)' }}>
                            Made with ❤️ and lots of crayons by Group3
                        </Typography>
                    </Box>
                </Container>
            </Box>

            {/* Back to Top Button */}
            <Fab
                color="primary"
                sx={{
                    position: 'fixed',
                    bottom: 20,
                    right: 20,
                    bgcolor: colors.accent,
                    '&:hover': {
                        bgcolor: colors.orange,
                        transform: 'scale(1.1) rotate(360deg)'
                    },
                    transition: 'all 0.5s ease'
                }}
                onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            >
                <RocketIcon />
            </Fab>
        </>
    );
}