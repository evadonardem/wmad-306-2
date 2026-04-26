import React, { useState } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Typography,
    Box,
    Paper,
    Button,
    Card,
    CardContent,
    CardActions,
    TextField,
    Avatar,
    Chip,
    IconButton,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    FormControl,
    InputLabel,
    Select,
    Grid
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
    Article,
    Search,
    Star,
    StarBorder
} from '@mui/icons-material';

const StudentPublishedArticles = ({ publishedArticles, categories, selectedCategory, favorites }) => {
    const [anchorEl, setAnchorEl] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [categoryFilter, setCategoryFilter] = useState(selectedCategory || '');

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

    const handleCategoryChange = (category) => {
        setCategoryFilter(category);
        router.get('/student/published-articles', { category: category }, { preserveState: true });
    };

    const handleSearch = (event) => {
        setSearchTerm(event.target.value);
    };

    const filteredArticles = publishedArticles?.filter(article => {
        const matchesSearch = article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           article.content.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesCategory = !categoryFilter || article.category_id == categoryFilter;
        return matchesSearch && matchesCategory;
    }) || [];

    const handleViewArticle = (articleId) => {
        router.get(`/student/articles/${articleId}`);
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
            <Head title="Published Articles" />
            
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
                            Published Articles
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
                    {/* Search and Filter Section */}
                    <Paper sx={{ p: 3, backgroundColor: '#1e293b', border: '1px solid #334155', mb: 4 }}>
                        <Grid container spacing={3} alignItems="center">
                            <Grid item xs={12} md={6}>
                                <TextField
                                    fullWidth
                                    placeholder="Search articles..."
                                    value={searchTerm}
                                    onChange={handleSearch}
                                    InputProps={{
                                        startAdornment: <Search sx={{ color: '#94a3b8', mr: 1 }} />
                                    }}
                                    sx={{ 
                                        '& .MuiOutlinedInput-root': {
                                            '& fieldset': {
                                                borderColor: '#334155',
                                            },
                                            '&:hover fieldset': {
                                                borderColor: '#60a5fa',
                                            },
                                            '&.Mui-focused fieldset': {
                                                borderColor: '#60a5fa',
                                            },
                                        },
                                        '& .MuiInputLabel-root': {
                                            color: '#94a3b8',
                                        },
                                        '& .MuiInputLabel-focused': {
                                            color: '#60a5fa',
                                        }
                                    }}
                                />
                            </Grid>
                            <Grid item xs={12} md={6}>
                                <FormControl fullWidth>
                                    <InputLabel sx={{ color: '#94a3b8' }}>Category</InputLabel>
                                    <Select
                                        value={categoryFilter}
                                        label="Category"
                                        onChange={(e) => handleCategoryChange(e.target.value)}
                                        sx={{ 
                                            '& .MuiOutlinedInput-notchedOutline': {
                                                borderColor: '#334155',
                                            },
                                            '&:hover .MuiOutlinedInput-notchedOutline': {
                                                borderColor: '#60a5fa',
                                            },
                                            '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                                                borderColor: '#60a5fa',
                                            },
                                            '& .MuiSvgIcon-root': {
                                                color: '#94a3b8',
                                            }
                                        }}
                                    >
                                        <MenuItem value="">All Categories</MenuItem>
                                        {categories?.map((category) => (
                                            <MenuItem key={category.id} value={category.id}>
                                                {category.name}
                                            </MenuItem>
                                        ))}
                                    </Select>
                                </FormControl>
                            </Grid>
                        </Grid>
                    </Paper>

                    {/* Articles Grid */}
                    {filteredArticles.length === 0 ? (
                        <Paper sx={{ 
                            p: 6, 
                            backgroundColor: '#1e293b', 
                            border: '1px solid #334155',
                            textAlign: 'center'
                        }}>
                            <Typography variant="h6" sx={{ color: '#94a3b8', mb: 2 }}>
                                No published articles found
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#64748b' }}>
                                Try adjusting your search or filter criteria
                            </Typography>
                        </Paper>
                    ) : (
                        <Grid container spacing={3}>
                            {filteredArticles.map((article, index) => (
                                <Grid item xs={12} md={6} lg={4} key={article.id}>
                                    <Card sx={{ 
                                        backgroundColor: '#1e293b', 
                                        border: '1px solid #334155',
                                        height: '100%',
                                        display: 'flex',
                                        flexDirection: 'column'
                                    }}>
                                        <CardContent sx={{ flexGrow: 1 }}>
                                            <Box sx={{ display: 'flex', alignItems: 'flex-start', mb: 2 }}>
                                                <Box sx={{ flexGrow: 1 }}>
                                                    <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                                                        <Avatar sx={{ mr: 2, bgcolor: '#10b981' }}>
                                                            {article.writer?.name?.charAt(0) || 'W'}
                                                        </Avatar>
                                                        <Box sx={{ flexGrow: 1 }}>
                                                            <Typography variant="h6" sx={{ color: '#ffffff', mb: 1 }}>
                                                                {article.title}
                                                            </Typography>
                                                            <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                                                By {article.writer?.name}
                                                            </Typography>
                                                        </Box>
                                                    </Box>
                                                </Box>
                                                <IconButton 
                                                    onClick={() => handleToggleFavorite(article.id)}
                                                    sx={{ 
                                                        color: isFavorite(article.id) ? '#f59e0b' : '#94a3b8',
                                                        '&:hover': { color: '#f59e0b' }
                                                    }}
                                                >
                                                    {isFavorite(article.id) ? <Star /> : <StarBorder />}
                                                </IconButton>
                                            </Box>
                                            
                                            <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
                                                <Chip
                                                    icon={<Article />}
                                                    label={article.category && typeof article.category === 'object' ? (article.category.name || article.category.label || 'Uncategorized') : 'Uncategorized'}
                                                    size="small"
                                                    sx={{ bgcolor: '#0f172a', color: '#10b981', border: '1px solid #10b981' }}
                                                />
                                                <Chip
                                                    label={typeof article.status === 'string' ? article.status : (article.status && typeof article.status === 'object' ? (article.status.label || article.status.name || 'unknown') : 'unknown')}
                                                    size="small"
                                                    sx={{ bgcolor: '#10b981', color: '#fff' }}
                                                />
                                            </Box>

                                            <Typography variant="body2" sx={{ 
                                                color: '#94a3b8',
                                                overflow: 'hidden',
                                                textOverflow: 'ellipsis',
                                                display: '-webkit-box',
                                                WebkitLineClamp: 3,
                                                WebkitBoxOrient: 'vertical',
                                                mb: 2
                                            }}>
                                                {article.content}
                                            </Typography>
                                        </CardContent>
                                        
                                        <CardActions sx={{ p: 2, pt: 0 }}>
                                            <Button
                                                size="small"
                                                startIcon={<Visibility />}
                                                onClick={() => handleViewArticle(article.id)}
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
                                                onClick={() => handleViewArticle(article.id)}
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

export default StudentPublishedArticles;
