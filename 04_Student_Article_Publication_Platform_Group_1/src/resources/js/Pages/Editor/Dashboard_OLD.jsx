import { useState, useEffect } from 'react';
import { Head } from '@inertiajs/react';
import {
    Box,
    Container,
    Card,
    CardContent,
    Typography,
    Button,
    Chip,
    IconButton,
    Menu,
    MenuItem,
    TextField,
    Grid,
    Paper,
    Divider,
    AppBar,
    Toolbar,
    useMediaQuery,
    useTheme,
    Avatar,
    List,
    ListItem,
    ListItemIcon,
    ListItemText,
    Drawer
} from '@mui/material';
import {
    MoreVert,
    Search,
    RateReview,
    Send,
    Publish,
    History,
    Edit,
    Schedule,
    CheckCircle,
    Menu as MenuIcon,
    Dashboard,
    Visibility,
    Article,
    Pending,
    AssignmentTurnedIn,
    LibraryBooks,
    AutoStories
} from '@mui/icons-material';
import { router } from '@inertiajs/react';

export default function EditorDashboard({ 
    submittedArticles, 
    revisionArticles, 
    publishedArticles 
}) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    
    const [articles, setArticles] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [anchorEl, setAnchorEl] = useState(null);
    const [sidebarOpen, setSidebarOpen] = useState(!isMobile);
    const [activeSection, setActiveSection] = useState('pending');

    // Combine all articles for display
    const allArticles = [
        ...(submittedArticles || []),
        ...(revisionArticles || []),
        ...(publishedArticles || [])
    ];

    useEffect(() => {
        // Update articles when props change
        const newArticles = [
            ...(submittedArticles || []),
            ...(revisionArticles || []),
            ...(publishedArticles || [])
        ];
        setArticles(newArticles);
    }, [submittedArticles, revisionArticles, publishedArticles]);

    // Fallback to mock data if no articles from backend
    useEffect(() => {
        if (allArticles.length === 0) {
            const mockArticles = [
                {
                    id: 1,
                    title: 'Understanding React Hooks',
                    content: 'A comprehensive guide to useState, useEffect, and custom hooks for modern React development. This article covers the fundamentals and advanced patterns.',
                    status: 'submitted',
                    writer: { id: 1, name: 'John Doe' },
                    created_at: '2024-01-10',
                    updated_at: '2024-01-12'
                },
                {
                    id: 2,
                    title: 'Advanced CSS Techniques',
                    content: 'Modern CSS layouts, animations, and responsive design techniques for creating beautiful web interfaces.',
                    status: 'needs_revision',
                    writer: { id: 2, name: 'Jane Smith' },
                    created_at: '2024-01-08',
                    updated_at: '2024-01-15'
                },
                {
                    id: 3,
                    title: 'JavaScript Best Practices',
                    content: 'Clean code, performance optimization, and debugging tips for JavaScript developers.',
                    status: 'published',
                    writer: { id: 3, name: 'Bob Johnson' },
                    created_at: '2024-01-05',
                    updated_at: '2024-01-16'
                },
                {
                    id: 4,
                    title: 'Laravel Performance Tips',
                    content: 'Database optimization, caching strategies, and application tuning for high-performance Laravel applications.',
                    status: 'submitted',
                    writer: { id: 4, name: 'Alice Brown' },
                    created_at: '2024-01-20',
                    updated_at: '2024-01-21'
                }
            ];
            setArticles(mockArticles);
        }
    }, [allArticles.length]);

    const handleMenuOpen = (event, article) => {
        setSelectedArticle(article);
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    const handleReview = (article) => {
        router.get(`/editor/articles/${article.id}/review`);
        handleMenuClose();
    };

    const handleRequestRevision = (article) => {
        console.log('Requesting revision for article:', article.id);
        setArticles(articles.map(a => 
            a.id === article.id ? { ...a, status: 'needs_revision' } : a
        ));
        handleMenuClose();
    };

    const getStatusColor = (status) => {
        switch (status) {
            case 'submitted': return 'warning';
            case 'needs_revision': return 'error';
            case 'published': return 'success';
            default: return 'default';
        }
    };

    const getStatusLabel = (status) => {
        switch (status) {
            case 'submitted': return 'Pending Review';
            case 'needs_revision': return 'Needs Revision';
            case 'published': return 'Published';
            default: return status;
        }
    };

    const getFilteredArticles = () => {
        let filtered = articles;
        
        // Filter by section
        if (activeSection === 'pending') {
            filtered = filtered.filter(a => a.status === 'submitted');
        } else if (activeSection === 'revision') {
            filtered = filtered.filter(a => a.status === 'needs_revision');
        } else if (activeSection === 'published') {
            filtered = filtered.filter(a => a.status === 'published');
        }
        
        // Filter by search
        if (searchTerm) {
            filtered = filtered.filter(article => 
                article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                article.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
                article.writer.name.toLowerCase().includes(searchTerm.toLowerCase())
            );
        }
        
        return filtered;
    };

    const sidebarItems = [
        {
            id: 'pending',
            label: 'Pending Articles',
            icon: <Pending />,
            count: articles.filter(a => a.status === 'submitted').length,
            active: activeSection === 'pending'
        },
        {
            id: 'revision',
            label: 'Needs Revision',
            icon: <Edit />,
            count: articles.filter(a => a.status === 'needs_revision').length,
            active: activeSection === 'revision'
        },
        {
            id: 'published',
            label: 'Published Articles',
            icon: <LibraryBooks />,
            count: articles.filter(a => a.status === 'published').length,
            active: activeSection === 'published'
        }
    ];

    const drawerContent = (
        <Box sx={{ width: 280, height: '100%', bgcolor: 'background.paper' }}>
            <Box sx={{ p: 2, borderBottom: 1, borderColor: 'divider' }}>
                <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                    Editor Dashboard
                </Typography>
            </Box>
            
            <List sx={{ p: 0 }}>
                {sidebarItems.map((item) => (
                    <ListItem
                        key={item.id}
                        button
                        selected={item.active}
                        onClick={() => setActiveSection(item.id)}
                        sx={{
                            '&.Mui-selected': {
                                backgroundColor: 'primary.main',
                                color: 'white',
                                '&:hover': {
                                    backgroundColor: 'primary.dark',
                                }
                            }
                        }}
                    >
                        <ListItemIcon sx={{ color: item.active ? 'inherit' : 'primary.main' }}>
                            {item.icon}
                        </ListItemIcon>
                        <ListItemText 
                            primary={item.label}
                            secondary={`${item.count} articles`}
                            primaryTypographyProps={{
                                fontWeight: item.active ? 'bold' : 'normal'
                            }}
                        />
                    </ListItem>
                ))}
            </List>
            
            <Divider sx={{ my: 2 }} />
            
            <Box sx={{ p: 2 }}>
                <Typography variant="body2" color="text.secondary">
                    Total Articles: {articles.length}
                </Typography>
            </Box>
        </Box>
    );

    return (
        <>
            <Head title="Editor Dashboard" />
            <Box sx={{ display: 'flex', height: '100vh' }}>
                {/* Header */}
                <AppBar position="fixed" sx={{ 
                    zIndex: theme.zIndex.drawer + 1,
                    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                    boxShadow: '0 4px 20px rgba(0,0,0,0.1)'
                }}>
                    <Toolbar sx={{ display: 'flex', justifyContent: 'space-between' }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                            <IconButton
                                color="inherit"
                                onClick={() => setSidebarOpen(true)}
                                sx={{ mr: 2, display: { md: 'none' } }}
                            >
                                <MenuIcon />
                            </IconButton>
                            <AutoStories sx={{ fontSize: 32, color: 'white' }} />
                            <Typography variant="h6" sx={{ fontWeight: 'bold', color: 'white' }}>
                                👁️ Editor Dashboard
                            </Typography>
                        </Box>
                        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                            <Button
                                component="button"
                                onClick={() => router.get('/')}
                                variant="outlined"
                                size="small"
                                sx={{ color: 'white', borderColor: 'white' }}
                            >
                                Home
                            </Button>
                            <Button
                                component="button"
                                onClick={() => router.get('/profile')}
                                variant="contained"
                                size="small"
                                sx={{
                                    backgroundColor: 'white',
                                    color: 'primary.main',
                                    '&:hover': {
                                        backgroundColor: 'grey.100',
                                    }
                                }}
                            >
                                Profile
                            </Button>
                            <Avatar sx={{ ml: 2, bgcolor: 'white', color: 'primary.main' }}>E</Avatar>
                        </Box>
                    </Toolbar>
                </AppBar>

                {/* Sidebar */}
                <Drawer
                    variant={isMobile ? 'temporary' : 'persistent'}
                    open={sidebarOpen}
                    onClose={() => setSidebarOpen(false)}
                    sx={{
                        width: 280,
                        flexShrink: 0,
                        '& .MuiDrawer-paper': {
                            width: 280,
                            boxSizing: 'border-box',
                            top: 64,
                            height: 'calc(100vh - 64px)',
                        },
                    }}
                >
                    {drawerContent}
                </Drawer>

                {/* Main Content */}
                <Box sx={{ 
                    flexGrow: 1, 
                    display: 'flex', 
                    flexDirection: 'column',
                    ml: isMobile ? 0 : 30,
                    mt: 8
                }}>
                    <Container maxWidth="lg" sx={{ py: 3 }}>
                        {/* Search Bar */}
                        <Paper sx={{ p: 2, mb: 3 }}>
                            <TextField
                                fullWidth
                                size="small"
                                placeholder="Search articles..."
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                                InputProps={{
                                    startAdornment: <Search sx={{ mr: 1, color: 'text.secondary' }} />
                                }}
                            />
                        </Paper>

                        {/* Articles List */}
                        <Grid container spacing={3}>
                            {getFilteredArticles().length > 0 ? (
                                getFilteredArticles().map((article) => (
                                    <Grid item xs={12} key={article.id}>
                                        <Card sx={{ mb: 2 }}>
                                            <CardContent>
                                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                                                    <Box sx={{ flex: 1 }}>
                                                        <Typography variant="h6" sx={{ mb: 1, fontWeight: 'bold' }}>
                                                            {article.title}
                                                        </Typography>
                                                        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                                                            by {article.writer.name}
                                                        </Typography>
                                                        <Typography 
                                                            variant="body2" 
                                                            sx={{ 
                                                                display: '-webkit-box',
                                                                WebkitLineClamp: 3,
                                                                WebkitBoxOrient: 'vertical',
                                                                overflow: 'hidden',
                                                                textOverflow: 'ellipsis',
                                                                lineHeight: 1.5,
                                                                mb: 2
                                                            }}
                                                        >
                                                            {article.content}
                                                        </Typography>
                                                        <Box sx={{ display: 'flex', gap: 1, alignItems: 'center', mb: 2 }}>
                                                            <Chip
                                                                label={getStatusLabel(article.status)}
                                                                color={getStatusColor(article.status)}
                                                                size="small"
                                                            />
                                                            <Typography variant="caption" color="text.secondary">
                                                                {new Date(article.created_at).toLocaleDateString()}
                                                            </Typography>
                                                        </Box>
                                                    </Box>
                                                    
                                                    <Box sx={{ display: 'flex', gap: 1 }}>
                                                        {article.status === 'submitted' && (
                                                            <>
                                                                <Button
                                                                    size="small"
                                                                    variant="contained"
                                                                    startIcon={<RateReview />}
                                                                    onClick={() => handleReview(article)}
                                                                >
                                                                    Review
                                                                </Button>
                                                                <Button
                                                                    size="small"
                                                                    variant="outlined"
                                                                    color="warning"
                                                                    startIcon={<Send />}
                                                                    onClick={(e) => handleMenuOpen(e, article)}
                                                                >
                                                                    Request Revision
                                                                </Button>
                                                            </>
                                                        )}
                                                        {article.status === 'needs_revision' && (
                                                            <Button
                                                                size="small"
                                                                variant="contained"
                                                                color="warning"
                                                                startIcon={<Edit />}
                                                            >
                                                                View Revision
                                                            </Button>
                                                        )}
                                                        {article.status === 'published' && (
                                                            <Button
                                                                size="small"
                                                                variant="outlined"
                                                                startIcon={<Visibility />}
                                                            >
                                                                View Published
                                                            </Button>
                                                        )}
                                                        <IconButton
                                                            size="small"
                                                            onClick={(e) => handleMenuOpen(e, article)}
                                                        >
                                                            <MoreVert />
                                                        </IconButton>
                                                    </Box>
                                                </Box>
                                            </CardContent>
                                        </Card>
                                    </Grid>
                                ))
                            ) : (
                                <Grid item xs={12}>
                                    <Card sx={{ textAlign: 'center', py: 8 }}>
                                        <CardContent>
                                            <Typography variant="h6" color="text.secondary" gutterBottom>
                                                No {activeSection === 'pending' ? 'pending' : activeSection === 'revision' ? 'revision' : 'published'} articles found
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Try adjusting your search or check back later
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                            )}
                        </Grid>
                    </Container>
                </Box>

                {/* Article Actions Menu */}
                <Menu
                    anchorEl={anchorEl}
                    open={Boolean(anchorEl)}
                    onClose={handleMenuClose}
                >
                    <MenuItem onClick={() => handleReview(selectedArticle)}>
                        <RateReview sx={{ mr: 2 }} />
                        Review Article
                    </MenuItem>
                    <MenuItem onClick={() => handleRequestRevision(selectedArticle)}>
                        <Send sx={{ mr: 2 }} />
                        Request Revision
                    </MenuItem>
                    <MenuItem onClick={() => router.get(`/editor/articles/${selectedArticle?.id}/history`)}>
                        <History sx={{ mr: 2 }} />
                        View History
                    </MenuItem>
                </Menu>
            </Box>
        </>
    );
}
