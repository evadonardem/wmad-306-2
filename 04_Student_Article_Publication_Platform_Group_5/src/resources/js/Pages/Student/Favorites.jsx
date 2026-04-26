import React from 'react';
import { Head, router, usePage } from '@inertiajs/react';
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
    CircularProgress
} from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import {
    ArrowBack,
    Person,
    Logout,
    Menu as MenuIcon,
    Edit,
    Visibility,
    RateReview,
    Comment,
    Star,
    StarBorder
} from '@mui/icons-material';

const StudentFavorites = ({ favorites }) => {
    const [anchorEl, setAnchorEl] = React.useState(null);

    const { auth } = usePage().props;

    // Theme from Login.jsx - same as Dashboard
    const theme = createTheme({
        palette: {
            mode: "dark",
            background: { default: "#0b1220", paper: "#0f172a" },
            primary: { main: "#60a5fa" },
            secondary: { main: "#22d3ee" },
            text: { primary: "#ffffff" }
        },
        typography: { fontFamily: '"Times New Roman", Times, serif' }
    });

    const handleMenuOpen = (event) => {
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

    const handleToggleFavorite = (articleId) => {
        router.post(`/student/articles/${articleId}/favorite`, {}, {
            preserveScroll: true
        });
    };

    const isFavorite = (articleId) => {
        return favorites?.some(fav => fav.article_id === articleId) || false;
    };

    return (
        <ThemeProvider theme={theme}>
            <Head title="My Favorites" />
            
            <Box sx={{ 
                minHeight: "100vh", 
                backgroundColor: "#0b1220",
                display: 'flex',
                flexDirection: 'column'
            }}>
                {/* Header - Same as Dashboard */}
                <Box sx={{ 
                    backgroundColor: '#0f172a', 
                    borderBottom: '1px solid #334155',
                    p: 2,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between'
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <IconButton 
                            onClick={() => router.get('/student/dashboard')}
                            sx={{ color: '#ffffff' }}
                        >
                            <ArrowBack />
                        </IconButton>
                        <Typography variant="h4" sx={{ color: '#ffffff', fontWeight: 'bold' }}>
                            My Favorites
                        </Typography>
                    </Box>
                    
                    <IconButton color="inherit" onClick={handleMenuOpen} sx={{ color: '#ffffff' }}>
                        <MenuIcon />
                    </IconButton>
                </Box>

                {/* Menu - Same as Dashboard */}
                <Menu
                    anchorEl={anchorEl}
                    open={Boolean(anchorEl)}
                    onClose={handleMenuClose}
                    PaperProps={{
                        sx: {
                            backgroundColor: '#1e293b',
                            color: '#ffffff',
                            border: '1px solid #334155'
                        }
                    }}
                >
                    <MenuItem onClick={handleMenuClose}>
                        <ListItemIcon>
                            <Person sx={{ color: '#60a5fa' }} />
                        </ListItemIcon>
                        Profile
                    </MenuItem>
                    
                    <Divider sx={{ backgroundColor: '#334155' }} />
                    <MenuItem onClick={() => { router.get('/writer/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Edit sx={{ color: '#f59e0b' }} />
                        </ListItemIcon>
                        Switch to Writer
                    </MenuItem>
                    <MenuItem onClick={() => { router.get('/editor/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <RateReview sx={{ color: '#ef4444' }} />
                        </ListItemIcon>
                        Switch to Editor
                    </MenuItem>
                    <MenuItem onClick={() => { router.get('/student/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Visibility sx={{ color: '#10b981' }} />
                        </ListItemIcon>
                        Switch to Student
                    </MenuItem>
                    
                    <Divider sx={{ backgroundColor: '#334155' }} />
                    <MenuItem onClick={handleLogout}>
                        <ListItemIcon>
                            <Logout sx={{ color: '#f59e0b' }} />
                        </ListItemIcon>
                        Logout
                    </MenuItem>
                </Menu>

                {/* Main Content */}
                <Box sx={{ flexGrow: 1, p: 3 }}>
                    <Typography variant="h5" sx={{ color: '#ef4444', mb: 3, fontWeight: 'bold' }}>
                        My Favorite Articles ({favorites?.length || 0})
                    </Typography>
                    
                    {favorites?.length === 0 ? (
                        <Paper sx={{ 
                            p: 4, 
                            backgroundColor: '#1e293b', 
                            border: '1px solid #334155',
                            textAlign: 'center'
                        }}>
                            <Typography variant="h6" sx={{ color: '#94a3b8', mb: 3 }}>
                                Start adding your favorite articles!
                            </Typography>
                            <Button
                                variant="contained"
                                size="large"
                                startIcon={<Visibility />}
                                onClick={() => router.get('/student/published-articles')}
                                sx={{ 
                                    px: 4,
                                    bgcolor: '#10b981',
                                    '&:hover': { bgcolor: '#059669' }
                                }}
                            >
                                Browse Articles
                            </Button>
                        </Paper>
                    ) : (
                        <Grid container spacing={3}>
                            {favorites.map((favorite, index) => (
                                <Grid item xs={12} md={6} lg={4} key={favorite.id}>
                                    <Card sx={{ 
                                        backgroundColor: '#1e293b', 
                                        border: '1px solid #334155',
                                        height: '100%'
                                    }}>
                                        <CardContent>
                                            <Box sx={{ display: 'flex', alignItems: 'flex-start', mb: 2 }}>
                                                <Avatar sx={{ mr: 2, bgcolor: '#ef4444' }}>
                                                    {favorite.article?.writer?.name?.charAt(0) || 'W'}
                                                </Avatar>
                                                <Box sx={{ flexGrow: 1 }}>
                                                    <Typography variant="h6" sx={{ color: '#ffffff', mb: 1 }}>
                                                        Favorite {index + 1}
                                                    </Typography>
                                                    <Typography variant="subtitle1" sx={{ color: '#94a3b8' }}>
                                                        {favorite.article?.title}
                                                    </Typography>
                                                    <Typography variant="body2" sx={{ color: '#64748b' }}>
                                                        By {favorite.article?.writer?.name}
                                                    </Typography>
                                                </Box>
                                                <IconButton 
                                                    onClick={() => handleToggleFavorite(favorite.article_id)}
                                                    sx={{ 
                                                        color: '#ef4444',
                                                        '&:hover': { color: '#dc2626' }
                                                    }}
                                                >
                                                    <Star />
                                                </IconButton>
                                            </Box>
                                            
                                            <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
                                                <Chip
                                                    icon={<Visibility />}
                                                    label={favorite.article?.category && typeof favorite.article?.category === 'object' ? (favorite.article.category.name || favorite.article.category.label || 'Uncategorized') : 'Uncategorized'}
                                                    size="small"
                                                    sx={{ bgcolor: '#0f172a', color: '#ef4444', border: '1px solid #ef4444' }}
                                                />
                                                <Chip
                                                    label={typeof favorite.article?.status === 'string' ? favorite.article.status : (favorite.article?.status && typeof favorite.article?.status === 'object' ? (favorite.article.status.label || favorite.article.status.name || 'unknown') : 'unknown')}
                                                    size="small"
                                                    sx={{ bgcolor: '#10b981', color: '#fff' }}
                                                />
                                            </Box>

                                            <Typography variant="body2" sx={{ 
                                                color: '#94a3b8',
                                                overflow: 'hidden',
                                                textOverflow: 'ellipsis',
                                                display: '-webkit-box',
                                                WebkitLineClamp: 2,
                                                WebkitBoxOrient: 'vertical',
                                                mb: 2
                                            }}>
                                                {favorite.article?.content}
                                            </Typography>
                                        </CardContent>
                                        
                                        <CardActions>
                                            <Button
                                                size="small"
                                                startIcon={<Visibility />}
                                                onClick={() => router.get(`/student/articles/${favorite.article_id}`)}
                                                sx={{ 
                                                    color: '#10b981',
                                                    borderColor: '#10b981',
                                                    '&:hover': { borderColor: '#059669', color: '#059669' }
                                                }}
                                            >
                                                Read Article
                                            </Button>
                                            <Button
                                                size="small"
                                                startIcon={<Comment />}
                                                onClick={() => router.get(`/student/articles/${favorite.article_id}`)}
                                                sx={{ 
                                                    color: '#60a5fa',
                                                    borderColor: '#60a5fa',
                                                    '&:hover': { borderColor: '#3b82f6', color: '#3b82f6' }
                                                }}
                                            >
                                                Comment
                                            </Button>
                                        </CardActions>
                                    </Card>
                                </Grid>
                            ))}
                        </Grid>
                    )}
                </Box>
            </Box>
        </ThemeProvider>
    );
};

export default StudentFavorites;
