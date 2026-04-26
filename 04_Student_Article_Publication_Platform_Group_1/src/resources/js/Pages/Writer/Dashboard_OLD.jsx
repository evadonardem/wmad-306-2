import { useState, useEffect } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import {
    Box,
    Container,
    Card,
    CardContent,
    Typography,
    Button,
    Chip,
    IconButton,
    Tooltip,
    LinearProgress,
    Fab,
    Menu,
    MenuItem,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Grid,
    Paper,
    Avatar,
    List,
    ListItem,
    ListItemText,
    ListItemIcon,
    Divider,
    AppBar,
    Toolbar,
    useMediaQuery,
    useTheme,
    Select,
    FormControl,
    InputLabel,
    Snackbar,
    Alert
} from '@mui/material';
import {
    Add,
    Edit,
    Delete,
    Visibility,
    MoreVert,
    Search,
    FilterList,
    Article,
    Schedule,
    Send,
    History,
    Menu as MenuIcon,
    CreateNewFolder,
    CheckCircle,
    AutoStories,
    AccountCircle,
    Dashboard as DashboardIcon,
    Description
} from '@mui/icons-material';
import { router } from '@inertiajs/react';
import DashboardSidebar from '@/Components/DashboardSidebar';

export default function WriterDashboard({ 
    draftArticles, 
    submittedArticles, 
    revisionArticles, 
    publishedArticles 
}) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    
    // Combine all articles for display
    const allArticles = [
        ...(draftArticles || []),
        ...(submittedArticles || []),
        ...(revisionArticles || []),
        ...(publishedArticles || [])
    ];
    
    const [articles, setArticles] = useState(allArticles);
    const [searchTerm, setSearchTerm] = useState('');
    const [filter, setFilter] = useState('all');
    const [anchorEl, setAnchorEl] = useState(null);
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [sidebarOpen, setSidebarOpen] = useState(!isMobile);
    
    // New Article Form state
    const [newArticle, setNewArticle] = useState({
        title: '',
        content: '',
        category: ''
    });
    const [notification, setNotification] = useState({ open: false, message: '', severity: 'success' });

    useEffect(() => {
        // Update articles when props change
        const newArticles = [
            ...(draftArticles || []),
            ...(submittedArticles || []),
            ...(revisionArticles || []),
            ...(publishedArticles || [])
        ];
        setArticles(newArticles);
    }, [draftArticles, submittedArticles, revisionArticles, publishedArticles]);

    // Fallback to mock data if no articles from backend
    useEffect(() => {
        if (allArticles.length === 0) {
            const mockArticles = [
            {
                id: 1,
                title: 'Getting Started with Laravel',
                content: 'A comprehensive guide to setting up your first Laravel application...',
                status: 'draft',
                created_at: '2024-01-15',
                updated_at: '2024-01-15'
            },
            {
                id: 2,
                title: 'Understanding React Hooks',
                content: 'Deep dive into useState, useEffect, and custom hooks...',
                status: 'submitted',
                created_at: '2024-01-10',
                updated_at: '2024-01-12'
            },
            {
                id: 3,
                title: 'Advanced CSS Techniques',
                content: 'Modern CSS layouts, animations, and responsive design...',
                status: 'needs_revision',
                created_at: '2024-01-08',
                updated_at: '2024-01-14'
            },
            {
                id: 4,
                title: 'JavaScript Best Practices',
                content: 'Clean code, performance optimization, and debugging tips...',
                status: 'published',
                created_at: '2024-01-05',
                updated_at: '2024-01-16'
            }
        ];
        setArticles(mockArticles);
        }
    }, [allArticles.length]);

    const handleMenuOpen = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    const handleDeleteClick = (article) => {
        setSelectedArticle(article);
        setDeleteDialogOpen(true);
        handleMenuClose();
    };

    const confirmDelete = () => {
        console.log('Deleting article:', selectedArticle?.id);
        setDeleteDialogOpen(false);
        setSelectedArticle(null);
    };

    const handleNewArticleChange = (field) => (event) => {
        setNewArticle(prev => ({
            ...prev,
            [field]: event.target.value
        }));
    };

    const handleNewArticleSubmit = (e) => {
        e.preventDefault();
        // Here you would normally submit to backend
        setNotification({
            open: true,
            message: 'Article created successfully!',
            severity: 'success'
        });
        setNewArticle({ title: '', content: '', category: '' });
    };

    const handleNotificationClose = () => {
        setNotification(prev => ({ ...prev, open: false }));
    };

    const getStatusColor = (status) => {
        switch (status) {
            case 'draft': return 'default';
            case 'submitted': return 'warning';
            case 'needs_revision': return 'error';
            case 'published': return 'success';
            default: return 'default';
        }
    };

    const getStatusLabel = (status) => {
        switch (status) {
            case 'draft': return 'Draft';
            case 'submitted': return 'Submitted';
            case 'needs_revision': return 'Needs Revision';
            case 'published': return 'Published';
            default: return status;
        }
    };

    const filteredArticles = articles.filter(article => {
        const matchesSearch = article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                               article.content.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesFilter = filter === 'all' || article.status === filter;
        return matchesSearch && matchesFilter;
    });

    // Dashboard stats
    const stats = {
        draft: articles.filter(a => a.status === 'draft').length,
        submitted: articles.filter(a => a.status === 'submitted').length,
        revision: articles.filter(a => a.status === 'needs_revision').length,
        published: articles.filter(a => a.status === 'published').length
    };

    const sidebarMenuItems = [
        {
            label: 'Dashboard',
            icon: <DashboardIcon />,
            href: '/writer/dashboard',
            active: true
        },
        {
            label: 'Create Article',
            icon: <CreateNewFolder />,
            href: '/writer/articles/create',
            active: false
        },
        {
            label: `My Drafts (${stats.draft})`,
            icon: <Article />,
            href: '#drafts',
            active: filter === 'draft'
        },
        {
            label: `Submitted Articles (${stats.submitted})`,
            icon: <Send />,
            href: '#submitted',
            active: filter === 'submitted'
        },
        {
            label: `Needs Revision (${stats.revision})`,
            icon: <Edit />,
            href: '#revision',
            active: filter === 'needs_revision'
        },
        {
            label: `Published (${stats.published})`,
            icon: <CheckCircle />,
            href: '#published',
            active: filter === 'published'
        }
    ];

    return (
        <>
            <Head title="Writer Dashboard" />
            
            <Box sx={{ display: 'flex', minHeight: '100vh' }}>
                {/* Top App Bar */}
                <AppBar position="fixed" sx={{ 
                    zIndex: (theme) => theme.zIndex.drawer + 1,
                    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                    boxShadow: '0 4px 20px rgba(0,0,0,0.1)'
                }}>
                    <Toolbar sx={{ display: 'flex', justifyContent: 'space-between' }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                            <IconButton
                                color="inherit"
                                edge="start"
                                onClick={() => setSidebarOpen(!sidebarOpen)}
                                sx={{ mr: 2 }}
                            >
                                <MenuIcon />
                            </IconButton>
                            <AutoStories sx={{ fontSize: 32, color: 'white' }} />
                            <Typography variant="h6" sx={{ fontWeight: 'bold', color: 'white' }}>
                                ✍️ Writer Dashboard
                            </Typography>
                        </Box>
                        <Box sx={{ display: 'flex', gap: 2 }}>
                            <IconButton
                                component={Link}
                                href="/profile"
                                sx={{
                                    color: 'white',
                                    backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                    '&:hover': {
                                        backgroundColor: 'rgba(255, 255, 255, 0.2)',
                                    }
                                }}
                            >
                                <AccountCircle />
                            </IconButton>
                        </Box>
                    </Toolbar>
                </AppBar>

                {/* Sidebar */}
                <DashboardSidebar
                    menuItems={sidebarMenuItems}
                    open={sidebarOpen}
                    onClose={() => setSidebarOpen(false)}
                    title="Dashboard"
                />

                {/* Main Content */}
                <Box
                    component="main"
                    sx={{
                        flexGrow: 1,
                        p: 3,
                        pt: 10,
                        pl: sidebarOpen && !isMobile ? 0 : 3,
                        ml: sidebarOpen && !isMobile ? '280px' : 0,
                        backgroundColor: 'background.default',
                        overflow: 'auto',
                        transition: 'margin-left 0.3s ease, padding-left 0.3s ease',
                        minHeight: '100vh'
                    }}
                >
                    <Container maxWidth="lg">
                        {/* Stats Cards */}
                        <Grid container spacing={3} sx={{ mb: 4 }}>
                            <Grid item xs={12} sm={6} md={3}>
                                <Card sx={{ 
                                    height: '100%', 
                                    boxShadow: '0 10px 40px rgba(0,0,0,0.1)', 
                                    transition: 'all 0.3s ease',
                                    background: 'rgba(255, 255, 255, 0.95)',
                                    backdropFilter: 'blur(10px)',
                                    border: '1px solid rgba(255, 255, 255, 0.2)',
                                    '&:hover': { 
                                        transform: 'translateY(-8px) scale(1.02)',
                                        boxShadow: '0 20px 60px rgba(0,0,0,0.15)'
                                    }
                                }}>
                                    <CardContent sx={{ textAlign: 'center', p: 3 }}>
                                        <Article sx={{ fontSize: 40, color: 'primary.main', mb: 2 }} />
                                        <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 1 }}>
                                            {stats.draft}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary">
                                            Drafts
                                        </Typography>
                                    </CardContent>
                                </Card>
                            </Grid>
                            <Grid item xs={12} sm={6} md={3}>
                                <Card sx={{ 
                                    height: '100%', 
                                    boxShadow: '0 10px 40px rgba(0,0,0,0.1)', 
                                    transition: 'all 0.3s ease',
                                    background: 'rgba(255, 255, 255, 0.95)',
                                    backdropFilter: 'blur(10px)',
                                    border: '1px solid rgba(255, 255, 255, 0.2)',
                                    '&:hover': { 
                                        transform: 'translateY(-8px) scale(1.02)',
                                        boxShadow: '0 20px 60px rgba(0,0,0,0.15)'
                                    }
                                }}>
                                    <CardContent sx={{ textAlign: 'center', p: 3 }}>
                                        <Send sx={{ fontSize: 40, color: 'warning.main', mb: 2 }} />
                                        <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 1 }}>
                                            {stats.submitted}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary">
                                            Submitted
                                        </Typography>
                                    </CardContent>
                                </Card>
                            </Grid>
                            <Grid item xs={12} sm={6} md={3}>
                                <Card sx={{ 
                                    height: '100%', 
                                    boxShadow: '0 10px 40px rgba(0,0,0,0.1)', 
                                    transition: 'all 0.3s ease',
                                    background: 'rgba(255, 255, 255, 0.95)',
                                    backdropFilter: 'blur(10px)',
                                    border: '1px solid rgba(255, 255, 255, 0.2)',
                                    '&:hover': { 
                                        transform: 'translateY(-8px) scale(1.02)',
                                        boxShadow: '0 20px 60px rgba(0,0,0,0.15)'
                                    }
                                }}>
                                    <CardContent sx={{ textAlign: 'center', p: 3 }}>
                                        <Edit sx={{ fontSize: 40, color: 'error.main', mb: 2 }} />
                                        <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 1 }}>
                                            {stats.revision}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary">
                                            Needs Revision
                                        </Typography>
                                    </CardContent>
                                </Card>
                            </Grid>
                            <Grid item xs={12} sm={6} md={3}>
                                <Card sx={{ 
                                    height: '100%', 
                                    boxShadow: '0 10px 40px rgba(0,0,0,0.1)', 
                                    transition: 'all 0.3s ease',
                                    background: 'rgba(255, 255, 255, 0.95)',
                                    backdropFilter: 'blur(10px)',
                                    border: '1px solid rgba(255, 255, 255, 0.2)',
                                    '&:hover': { 
                                        transform: 'translateY(-8px) scale(1.02)',
                                        boxShadow: '0 20px 60px rgba(0,0,0,0.15)'
                                    }
                                }}>
                                    <CardContent sx={{ textAlign: 'center', p: 3 }}>
                                        <CheckCircle sx={{ fontSize: 40, color: 'success.main', mb: 2 }} />
                                        <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 1 }}>
                                            {stats.published}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary">
                                            Published
                                        </Typography>
                                    </CardContent>
                                </Card>
                            </Grid>
                        </Grid>

                        {/* New Article Form */}
                        <Card sx={{ 
                            mb: 4,
                            backgroundColor: 'rgba(255, 255, 255, 0.95)',
                            backdropFilter: 'blur(10px)',
                            border: '1px solid rgba(255, 255, 255, 0.2)',
                            boxShadow: '0 10px 40px rgba(0,0,0,0.1)',
                            transition: 'all 0.3s ease',
                            '&:hover': { 
                                boxShadow: '0 15px 50px rgba(0,0,0,0.12)'
                            }
                        }}>
                            <CardContent sx={{ p: 4 }}>
                                <Typography variant="h5" sx={{ mb: 3, fontWeight: 'bold', color: 'primary.main' }}>
                                    ✍️ Create New Article
                                </Typography>
                                <Box component="form" onSubmit={handleNewArticleSubmit}>
                                    <Grid container spacing={3}>
                                        <Grid item xs={12}>
                                            <TextField
                                                fullWidth
                                                label="Article Title"
                                                value={newArticle.title}
                                                onChange={handleNewArticleChange('title')}
                                                variant="outlined"
                                                required
                                                sx={{ 
                                                    '& .MuiOutlinedInput-root': {
                                                        borderRadius: 2
                                                    }
                                                }}
                                            />
                                        </Grid>
                                        <Grid item xs={12}>
                                            <TextField
                                                fullWidth
                                                label="Content"
                                                value={newArticle.content}
                                                onChange={handleNewArticleChange('content')}
                                                multiline
                                                rows={6}
                                                variant="outlined"
                                                required
                                                sx={{ 
                                                    '& .MuiOutlinedInput-root': {
                                                        borderRadius: 2
                                                    }
                                                }}
                                            />
                                        </Grid>
                                        <Grid item xs={12} md={6}>
                                            <FormControl fullWidth variant="outlined" required>
                                                <InputLabel>Category</InputLabel>
                                                <Select
                                                    value={newArticle.category}
                                                    onChange={handleNewArticleChange('category')}
                                                    label="Category"
                                                    sx={{ borderRadius: 2 }}
                                                >
                                                    <MenuItem value="technology">Technology</MenuItem>
                                                    <MenuItem value="business">Business</MenuItem>
                                                    <MenuItem value="lifestyle">Lifestyle</MenuItem>
                                                    <MenuItem value="education">Education</MenuItem>
                                                    <MenuItem value="entertainment">Entertainment</MenuItem>
                                                </Select>
                                            </FormControl>
                                        </Grid>
                                        <Grid item xs={12} md={6}>
                                            <Button
                                                type="submit"
                                                variant="contained"
                                                size="large"
                                                fullWidth
                                                sx={{
                                                    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                                                    '&:hover': {
                                                        background: 'linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%)',
                                                        transform: 'translateY(-2px)',
                                                        boxShadow: '0 8px 25px rgba(102, 126, 234, 0.4)'
                                                    },
                                                    transition: 'all 0.3s ease',
                                                    borderRadius: 2,
                                                    py: 1.5,
                                                    fontWeight: 'bold'
                                                }}
                                            >
                                                Submit Article
                                            </Button>
                                        </Grid>
                                    </Grid>
                                </Box>
                            </CardContent>
                        </Card>

                        {/* Search and Filter */}
                        <Paper sx={{ 
                            p: 3, 
                            mb: 4,
                            backgroundColor: 'rgba(255, 255, 255, 0.95)',
                            backdropFilter: 'blur(10px)',
                            border: '1px solid rgba(255, 255, 255, 0.2)',
                            boxShadow: '0 10px 40px rgba(0,0,0,0.1)',
                            transition: 'all 0.3s ease',
                            '&:hover': { 
                                boxShadow: '0 15px 50px rgba(0,0,0,0.12)'
                            }
                        }}>
                            <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', flexWrap: 'wrap' }}>
                                <TextField
                                    placeholder="Search articles..."
                                    size="small"
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    InputProps={{
                                        startAdornment: (
                                            <Search sx={{ mr: 1, color: 'text.secondary' }} />
                                        ),
                                    }}
                                    sx={{ minWidth: 250, flexGrow: 1 }}
                                />
                                
                                <TextField
                                    select
                                    size="small"
                                    value={filter}
                                    onChange={(e) => setFilter(e.target.value)}
                                    sx={{ minWidth: 150 }}
                                >
                                    <MenuItem value="all">All Articles</MenuItem>
                                    <MenuItem value="draft">Drafts</MenuItem>
                                    <MenuItem value="submitted">Submitted</MenuItem>
                                    <MenuItem value="needs_revision">Needs Revision</MenuItem>
                                    <MenuItem value="published">Published</MenuItem>
                                </TextField>
                            </Box>
                        </Paper>

                        {/* Articles Grid */}
                        <Grid container spacing={3}>
                            {filteredArticles.length > 0 ? (
                                filteredArticles.map((article) => (
                                    <Grid item xs={12} md={6} lg={4} key={article.id}>
                                        <Card sx={{ 
                                            height: '100%', 
                                            display: 'flex', 
                                            flexDirection: 'column',
                                            boxShadow: '0 10px 40px rgba(0,0,0,0.1)', 
                                            transition: 'all 0.3s ease',
                                            background: 'rgba(255, 255, 255, 0.95)',
                                            backdropFilter: 'blur(10px)',
                                            border: '1px solid rgba(255, 255, 255, 0.2)',
                                            '&:hover': { 
                                                transform: 'translateY(-8px) scale(1.02)',
                                                boxShadow: '0 20px 60px rgba(0,0,0,0.15)'
                                            }
                                        }}>
                                            <CardContent sx={{ flexGrow: 1, pb: 1 }}>
                                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                                                    <Box sx={{ flex: 1 }}>
                                                        <Typography variant="h6" component="h3" sx={{ mb: 1 }}>
                                                            {article.title}
                                                        </Typography>
                                                        <Typography variant="body2" color="text.secondary">
                                                            Created: {new Date(article.created_at).toLocaleDateString()}
                                                        </Typography>
                                                    </Box>
                                                    
                                                    <Chip
                                                        label={getStatusLabel(article.status)}
                                                        color={getStatusColor(article.status)}
                                                        size="small"
                                                        sx={{ ml: 1 }}
                                                    />
                                                </Box>
                                                
                                                <Typography
                                                    variant="body2"
                                                    color="text.secondary"
                                                    sx={{
                                                        mb: 2,
                                                        display: '-webkit-box',
                                                        WebkitLineClamp: 2,
                                                        WebkitBoxOrient: 'vertical',
                                                        overflow: 'hidden',
                                                        textOverflow: 'ellipsis'
                                                    }}
                                                >
                                                    {article.content}
                                                </Typography>
                                            </CardContent>
                                            
                                            <Divider />
                                            
                                            <Box sx={{ p: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                <Typography variant="caption" color="text.secondary">
                                                    Updated: {new Date(article.updated_at).toLocaleDateString()}
                                                </Typography>
                                                <IconButton size="small" onClick={handleMenuOpen}>
                                                    <MoreVert />
                                                </IconButton>
                                            </Box>
                                        </Card>
                                    </Grid>
                                ))
                            ) : (
                                <Grid item xs={12}>
                                    <Card sx={{ 
                                        backgroundColor: 'rgba(255, 255, 255, 0.95)',
                                        backdropFilter: 'blur(10px)',
                                        border: '1px solid rgba(255, 255, 255, 0.2)',
                                        boxShadow: '0 10px 40px rgba(0,0,0,0.1)',
                                        transition: 'all 0.3s ease',
                                        '&:hover': { 
                                            boxShadow: '0 15px 50px rgba(0,0,0,0.12)'
                                        }
                                    }}>
                                        <CardContent sx={{ textAlign: 'center', py: 6 }}>
                                            <Typography color="text.secondary" sx={{ mb: 3, fontSize: '1.1rem' }}>
                                                No articles found
                                            </Typography>
                                            <Button
                                                variant="contained"
                                                startIcon={<Add />}
                                                onClick={() => router.get('/writer/articles/create')}
                                                sx={{
                                                    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                                                    '&:hover': {
                                                        background: 'linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%)',
                                                        transform: 'translateY(-2px)',
                                                        boxShadow: '0 8px 25px rgba(102, 126, 234, 0.4)'
                                                    },
                                                    transition: 'all 0.3s ease',
                                                    borderRadius: 2,
                                                    px: 3
                                                }}
                                            >
                                                Create Your First Article
                                            </Button>
                                        </CardContent>
                                    </Card>
                                </Grid>
                            )}
                        </Grid>
                    </Container>
                </Box>

                {/* Footer */}
                <Box
                    component="footer"
                    sx={{
                        backgroundColor: 'background.paper',
                        borderTop: '1px solid',
                        borderColor: 'divider',
                        py: 2,
                        px: 3,
                        ml: sidebarOpen && !isMobile ? '280px' : 0,
                        transition: 'margin-left 0.3s ease'
                    }}
                >
                    <Container maxWidth="lg">
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap' }}>
                            <Typography variant="body2" color="text.secondary">
                                © 2024 Writer Dashboard. All rights reserved.
                            </Typography>
                            <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                                <Typography variant="body2" color="text.secondary">
                                    Status: Active
                                </Typography>
                                <Chip 
                                    label="Connected" 
                                    size="small" 
                                    color="success" 
                                    variant="outlined"
                                />
                            </Box>
                        </Box>
                    </Container>
                </Box>

                {/* Notification Snackbar */}
                <Snackbar
                    open={notification.open}
                    autoHideDuration={6000}
                    onClose={handleNotificationClose}
                    anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
                >
                    <Alert 
                        onClose={handleNotificationClose} 
                        severity={notification.severity}
                        sx={{ width: '100%' }}
                    >
                        {notification.message}
                    </Alert>
                </Snackbar>

                {/* Article Menu */}
                <Menu
                    anchorEl={anchorEl}
                    open={Boolean(anchorEl)}
                    onClose={handleMenuClose}
                >
                    <MenuItem onClick={handleMenuClose}>
                        <Edit sx={{ mr: 2, fontSize: 20 }} />
                        Edit
                    </MenuItem>
                    <MenuItem onClick={handleMenuClose}>
                        <Send sx={{ mr: 2, fontSize: 20 }} />
                        Submit for Review
                    </MenuItem>
                    <MenuItem onClick={() => handleDeleteClick(selectedArticle)}>
                        <Delete sx={{ mr: 2, fontSize: 20 }} />
                        Delete
                    </MenuItem>
                    <MenuItem onClick={handleMenuClose}>
                        <History sx={{ mr: 2, fontSize: 20 }} />
                        View Revisions
                    </MenuItem>
                </Menu>

                {/* Delete Confirmation Dialog */}
                <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
                    <DialogTitle>Confirm Delete</DialogTitle>
                    <DialogContent>
                        <Typography>
                            Are you sure you want to delete this article? This action cannot be undone.
                        </Typography>
                    </DialogContent>
                    <DialogActions>
                        <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
                        <Button onClick={confirmDelete} color="error" variant="contained">
                            Delete
                        </Button>
                    </DialogActions>
                </Dialog>

                {/* Floating Action Button */}
                <Fab
                    color="primary"
                    aria-label="create"
                    onClick={() => router.get('/writer/articles/create')}
                    sx={{
                        position: 'fixed',
                        bottom: 24,
                        right: 24,
                        zIndex: 1000,
                        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #5a6fd8 0%, #6a4190 100%)',
                            transform: 'translateY(-2px)',
                            boxShadow: '0 8px 25px rgba(102, 126, 234, 0.4)'
                        },
                        transition: 'all 0.3s ease'
                    }}
                >
                    <Add />
                </Fab>
            </Box>
        </>
    );
}
