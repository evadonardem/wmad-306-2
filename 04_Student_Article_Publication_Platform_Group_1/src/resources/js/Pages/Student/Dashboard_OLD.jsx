import { useState, useEffect } from 'react';
import { Head } from '@inertiajs/react';
import {
    Box,
    Card,
    CardContent,
    CardHeader,
    Typography,
    Button,
    IconButton,
    TextField,
    Grid,
    Paper,
    AppBar,
    Toolbar,
    useMediaQuery,
    useTheme,
    Avatar,
    CircularProgress,
    Modal,
    Backdrop,
    Menu,
    MenuItem,
    ListItemIcon,
    ListItemText
} from '@mui/material';
import {
    Search,
    ThumbUp,
    Comment as CommentIcon,
    Share,
    Menu as MenuIcon,
    Article,
    ChatBubble,
    Favorite,
    FavoriteBorder,
    MoreVert,
    AutoStories,
    Person,
    ExitToApp,
    VisibilityOff,
    Block
} from '@mui/icons-material';
import { router } from '@inertiajs/react';
import DashboardSidebar from '../../Components/DashboardSidebar';
import Comments from './Comments';

export default function StudentDashboard() {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    
    const [articles, setArticles] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [filter, setFilter] = useState('all');
    const [sidebarOpen, setSidebarOpen] = useState(!isMobile);
    const [likedArticles, setLikedArticles] = useState([]);
    const [totalComments, setTotalComments] = useState(0);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [commentsModalOpen, setCommentsModalOpen] = useState(false);
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
    const [profileMenuAnchor, setProfileMenuAnchor] = useState(null);
    const [hiddenArticles, setHiddenArticles] = useState([]);
    const [blockedPublishers, setBlockedPublishers] = useState([]);
    const [articleMenuAnchor, setArticleMenuAnchor] = useState(null);
    const [selectedArticleForMenu, setSelectedArticleForMenu] = useState(null);

    useEffect(() => {
        try {
            setLoading(true);
            
            // Load persisted data from localStorage
            const savedLikedArticles = localStorage.getItem('likedArticles');
            const savedHiddenArticles = localStorage.getItem('hiddenArticles');
            const savedBlockedPublishers = localStorage.getItem('blockedPublishers');
            
            if (savedLikedArticles) {
                setLikedArticles(JSON.parse(savedLikedArticles));
            }
            if (savedHiddenArticles) {
                setHiddenArticles(JSON.parse(savedHiddenArticles));
            }
            if (savedBlockedPublishers) {
                setBlockedPublishers(JSON.parse(savedBlockedPublishers));
            }
            
            const mockArticles = [
            {
                id: 1,
                title: 'The Future of Web Development',
                content: 'Exploring the latest trends and technologies in web development, from AI-assisted coding to WebAssembly applications...',
                writer: { id: 1, name: 'John Doe' },
                status: 'published',
                created_at: '2024-01-16',
                views: 234,
                likes: 45,
                comments_count: 12
            },
            {
                id: 2,
                title: 'Understanding Microservices Architecture',
                content: 'A deep dive into microservices architecture, including design patterns, benefits, and challenges...',
                writer: { id: 2, name: 'Jane Smith' },
                status: 'published',
                created_at: '2024-01-14',
                views: 189,
                likes: 38,
                comments_count: 8
            },
            {
                id: 3,
                title: 'Database Performance Optimization',
                content: 'Techniques and strategies for optimizing database performance, including indexing, query optimization, and caching...',
                writer: { id: 3, name: 'Bob Johnson' },
                status: 'published',
                created_at: '2024-01-12',
                views: 312,
                likes: 67,
                comments_count: 23
            },
            {
                id: 4,
                title: 'Cloud Computing Best Practices',
                content: 'Best practices for cloud computing, covering security, cost optimization, and deployment strategies...',
                writer: { id: 4, name: 'Alice Brown' },
                status: 'published',
                created_at: '2024-01-10',
                views: 456,
                likes: 89,
                comments_count: 31
            }
        ];
        setArticles(mockArticles);
            setLoading(false);
        } catch (err) {
            console.error('Error loading articles:', err);
            setError('Failed to load articles');
            setLoading(false);
        }
    }, []);

    // Real-time fetching of articles and comments
    useEffect(() => {
        const fetchLatestData = async () => {
            try {
                // Fetch latest articles
                const articlesResponse = await fetch('/api/latest-articles');
                if (articlesResponse.ok) {
                    const articlesData = await articlesResponse.json();
                    setArticles(articlesData);
                }

                // Fetch comments for all articles if modal is open
                if (selectedArticle) {
                    const commentsResponse = await fetch(`/api/articles/${selectedArticle.id}/comments`);
                    if (commentsResponse.ok) {
                        const commentsData = await commentsResponse.json();
                        // Update comments in localStorage
                        const storageKey = `article_comments_${selectedArticle.id}`;
                        localStorage.setItem(storageKey, JSON.stringify(commentsData));
                    }
                }
            } catch (err) {
                console.error('Error fetching latest data:', err);
            }
        };

        // Set up polling interval (every 30 seconds)
        const interval = setInterval(fetchLatestData, 30000);

        return () => clearInterval(interval); // Cleanup on unmount
    }, [selectedArticle]);

    const toggleLike = (articleId) => {
        if (likedArticles.includes(articleId)) {
            setLikedArticles(likedArticles.filter(id => id !== articleId));
        } else {
            setLikedArticles([...likedArticles, articleId]);
        }
    };

    const handleCommentsClick = (article) => {
        setSelectedArticle(article);
        setCommentsModalOpen(true);
    };

    const handleCloseCommentsModal = () => {
        setCommentsModalOpen(false);
        setSelectedArticle(null);
    };

    const toggleSidebar = () => {
        if (isMobile) {
            // On mobile, toggle the sidebar open/closed
            setSidebarOpen(!sidebarOpen);
        } else {
            // On desktop, toggle the sidebar collapsed state
            setSidebarCollapsed(!sidebarCollapsed);
        }
    };

    const handleProfileMenuOpen = (event) => {
        setProfileMenuAnchor(event.currentTarget);
    };

    const handleProfileMenuClose = () => {
        setProfileMenuAnchor(null);
    };

    const handleSeeProfile = () => {
        handleProfileMenuClose();
        router.get('/profile');
    };

    const handleLogout = () => {
        handleProfileMenuClose();
        router.post('/logout');
    };

    // Article menu handlers
    const handleArticleMenuOpen = (event, article) => {
        setArticleMenuAnchor(event.currentTarget);
        setSelectedArticleForMenu(article);
    };

    const handleArticleMenuClose = () => {
        setArticleMenuAnchor(null);
        setSelectedArticleForMenu(null);
    };

    const handleHideArticle = () => {
        if (selectedArticleForMenu) {
            const updatedHiddenArticles = [...hiddenArticles, selectedArticleForMenu.id];
            setHiddenArticles(updatedHiddenArticles);
            localStorage.setItem('hiddenArticles', JSON.stringify(updatedHiddenArticles));
        }
        handleArticleMenuClose();
    };

    const handleBlockPublisher = () => {
        if (selectedArticleForMenu) {
            const updatedBlockedPublishers = [...blockedPublishers, selectedArticleForMenu.writer.id];
            setBlockedPublishers(updatedBlockedPublishers);
            localStorage.setItem('blockedPublishers', JSON.stringify(updatedBlockedPublishers));
        }
        handleArticleMenuClose();
    };

    const handleLikeArticle = (articleId) => {
        const isLiked = likedArticles.includes(articleId);
        let updatedLikedArticles;
        
        if (isLiked) {
            // Unlike
            updatedLikedArticles = likedArticles.filter(id => id !== articleId);
        } else {
            // Like
            updatedLikedArticles = [...likedArticles, articleId];
        }
        
        setLikedArticles(updatedLikedArticles);
        localStorage.setItem('likedArticles', JSON.stringify(updatedLikedArticles));
        
        // Update the article's like count in the articles array
        setArticles(prevArticles => 
            prevArticles.map(article => {
                if (article.id === articleId) {
                    return {
                        ...article,
                        likes: isLiked ? article.likes - 1 : article.likes + 1
                    };
                }
                return article;
            })
        );
    };

    // Handle new comment for real-time updates
    const handleNewComment = (newComment) => {
        // Update the article's comment count in the articles array
        setArticles(prevArticles => 
            prevArticles.map(article => {
                if (article.id === selectedArticle?.id) {
                    return {
                        ...article,
                        comments_count: article.comments_count + 1
                    };
                }
                return article;
            })
        );

        // Update total comments count
        setTotalComments(prev => prev + 1);
    };

    const filteredArticles = articles.filter(article => {
        const matchesSearch = article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                               article.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
                               article.writer.name.toLowerCase().includes(searchTerm.toLowerCase());
        
        const isHidden = hiddenArticles.includes(article.id);
        const isBlocked = blockedPublishers.includes(article.writer.id);
        
        return matchesSearch && !isHidden && !isBlocked;
    });

    const stats = {
        published: articles.length,
        totalViews: articles.reduce((sum, a) => sum + a.views, 0),
        totalComments: articles.reduce((sum, a) => sum + a.comments_count, 0)
    };

    const sidebarMenuItems = [
        {
            label: 'Published Articles',
            icon: <Article />,
            href: '#articles',
            active: filter === 'all'
        },
        {
            label: 'My Comments',
            icon: <ChatBubble />,
            href: '/student/my-comments',
            active: filter === 'comments'
        }
    ];

    if (error) {
        return (
            <>
                <Head title="Student Dashboard - Error" />
                <Box sx={{ 
                    display: 'flex', 
                    justifyContent: 'center', 
                    alignItems: 'center', 
                    minHeight: '100vh',
                    flexDirection: 'column',
                    gap: 2
                }}>
                    <Typography variant="h6" color="error">
                        ⚠️ Error Loading Dashboard
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                        {error}
                    </Typography>
                    <Button 
                        variant="contained" 
                        onClick={() => window.location.reload()}
                        sx={{ mt: 2 }}
                    >
                        Retry
                    </Button>
                </Box>
            </>
        );
    }

    if (loading) {
        return (
            <>
                <Head title="Loading Student Dashboard" />
                <Box sx={{ 
                    display: 'flex', 
                    justifyContent: 'center', 
                    alignItems: 'center', 
                    minHeight: '100vh',
                    flexDirection: 'column',
                    gap: 2
                }}>
                    <CircularProgress size={40} />
                    <Typography variant="body2" color="text.secondary">
                        Loading Student Dashboard...
                    </Typography>
                </Box>
            </>
        );
    }

    return (
        <>
            <Head title="Student/Reader Dashboard" />
            
            <Box sx={{ display: 'flex', minHeight: '100vh', flexDirection: 'column', overflowX: 'hidden' }}>
                {/* Header */}
                <AppBar position="fixed" sx={{ 
                    zIndex: (theme) => theme.zIndex.drawer + 1,
                    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                }}>
                    <Toolbar>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, flex: 1 }}>
                            <AutoStories sx={{ fontSize: 32, color: 'white' }} />
                            <Typography variant="h6" sx={{ fontWeight: 'bold', color: 'white' }}>
                                Student Dashboard
                            </Typography>
                        </Box>
                        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                            <IconButton
                                onClick={handleProfileMenuOpen}
                                sx={{ 
                                    color: 'white',
                                    '&:hover': {
                                        backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                    }
                                }}
                            >
                                <Avatar sx={{ width: 32, height: 32, bgcolor: 'white', color: 'primary.main' }}>
                                    <Person />
                                </Avatar>
                            </IconButton>
                            <Menu
                                anchorEl={profileMenuAnchor}
                                open={Boolean(profileMenuAnchor)}
                                onClose={handleProfileMenuClose}
                                anchorOrigin={{
                                    vertical: 'bottom',
                                    horizontal: 'right',
                                }}
                                transformOrigin={{
                                    vertical: 'top',
                                    horizontal: 'right',
                                }}
                            >
                                <MenuItem onClick={handleSeeProfile}>
                                    <ListItemIcon>
                                        <Person fontSize="small" />
                                    </ListItemIcon>
                                    <ListItemText>See Profile</ListItemText>
                                </MenuItem>
                                <MenuItem onClick={handleLogout}>
                                    <ListItemIcon>
                                        <ExitToApp fontSize="small" />
                                    </ListItemIcon>
                                    <ListItemText>Logout</ListItemText>
                                </MenuItem>
                            </Menu>
                        </Box>
                    </Toolbar>
                </AppBar>

                <Box sx={{ display: 'flex', flex: 1, overflowX: 'hidden' }}>
                    {/* Sidebar Navigation */}
                    <DashboardSidebar
                        menuItems={sidebarMenuItems}
                        open={sidebarOpen}
                        collapsed={sidebarCollapsed}
                        onClose={() => setSidebarOpen(false)}
                        title="Menu"
                        onToggle={toggleSidebar}
                        hiddenArticles={hiddenArticles}
                        articles={articles}
                        blockedPublishers={blockedPublishers}
                        onUnhideArticle={(articleId) => {
                            const updatedHiddenArticles = hiddenArticles.filter(id => id !== articleId);
                            setHiddenArticles(updatedHiddenArticles);
                            localStorage.setItem('hiddenArticles', JSON.stringify(updatedHiddenArticles));
                        }}
                        onUnblockPublisher={(publisherId) => {
                            const updatedBlockedPublishers = blockedPublishers.filter(id => id !== publisherId);
                            setBlockedPublishers(updatedBlockedPublishers);
                            localStorage.setItem('blockedPublishers', JSON.stringify(updatedBlockedPublishers));
                        }}
                    />

                    {/* Main Content */}
                    <Box
                        component="main"
                        sx={{
                            flex: 1,
                            p: 3,
                            backgroundColor: 'background.default',
                            marginLeft: sidebarCollapsed ? '60px' : '280px',  // Account for fixed sidebar
                            marginTop: '64px',  // Account for fixed header
                            transition: 'margin-left 0.3s ease',  // Smooth transition when sidebar toggles
                        }}
                    >
                        <Box sx={{ 
                            flex: 1, // Take remaining space
                            px: 3, // Internal padding instead of Container
                            display: 'flex',
                            flexDirection: 'column'
                        }}>
                            {/* Stats Cards */}
                            <Grid container spacing={2} sx={{ mb: 4 }}>
                                <Grid item xs={12} sm={4}>
                                    <Card>
                                        <CardContent sx={{ textAlign: 'center' }}>
                                            <Article sx={{ fontSize: 32, color: 'primary.main', mb: 1 }} />
                                            <Typography variant="h5" sx={{ fontWeight: 'bold' }}>
                                                {stats.published}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Articles Available
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                                <Grid item xs={12} sm={4}>
                                    <Card>
                                        <CardContent sx={{ textAlign: 'center' }}>
                                            <Search sx={{ fontSize: 32, color: 'secondary.main', mb: 1 }} />
                                            <Typography variant="h5" sx={{ fontWeight: 'bold' }}>
                                                {stats.totalViews}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Total Views
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                                <Grid item xs={12} sm={4}>
                                    <Card>
                                        <CardContent sx={{ textAlign: 'center' }}>
                                            <ChatBubble sx={{ fontSize: 32, color: '#f57c00', mb: 1 }} />
                                            <Typography variant="h5" sx={{ fontWeight: 'bold' }}>
                                                {totalComments}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                Community Comments
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                </Grid>
                            </Grid>

                            {/* Search */}
                            <Paper sx={{ p: 3, mb: 4 }}>
                                <TextField
                                    placeholder="Search articles..."
                                    fullWidth
                                    size="small"
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                />
                            </Paper>

                            {/* Articles Feed */}
                            <Box sx={{ flex: 1 }}>
                                {filteredArticles.length > 0 ? (
                                    filteredArticles.map((article) => (
                                        <Card key={article.id} sx={{ mb: 3 }}>
                                            {/* Article Header */}
                                            <CardHeader
                                                avatar={<Avatar sx={{ bgcolor: 'primary.main' }}>
                                                    {article.writer.name.charAt(0)}
                                                </Avatar>}
                                                title={article.writer.name}
                                                subheader={
                                                    <Typography 
                                                        variant="caption" 
                                                        sx={{ 
                                                            fontWeight: 'medium',
                                                            color: 'primary.main',
                                                            backgroundColor: 'primary.50',
                                                            px: 1,
                                                            py: 0.5,
                                                            borderRadius: 1,
                                                            display: 'inline-block'
                                                        }}
                                                    >
                                                        {new Date(article.created_at).toLocaleDateString('en-US', {
                                                            month: 'numeric',
                                                            day: 'numeric', 
                                                            year: 'numeric',
                                                            hour: '2-digit',
                                                            minute: '2-digit',
                                                            second: '2-digit',
                                                            hour12: false
                                                        }).replace(',', '')}
                                                    </Typography>
                                                }
                                                action={
                                                    <IconButton onClick={(e) => handleArticleMenuOpen(e, article)}>
                                                        <MoreVert />
                                                    </IconButton>
                                                }
                                            />

                                            {/* Article Content */}
                                            <CardContent>
                                                <Typography variant="h6" sx={{ mb: 2, fontWeight: 'bold' }}>
                                                    {article.title}
                                                </Typography>
                                                <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                                                    {article.content}
                                                </Typography>

                                                {/* Article Stats */}
                                                <Box sx={{ display: 'flex', gap: 2, mb: 2, pb: 2, borderBottom: '1px solid', borderColor: 'divider' }}>
                                                    <Typography variant="caption" color="text.secondary">
                                                        👁️ {article.views} views
                                                    </Typography>
                                                    <Typography variant="caption" color="text.secondary">
                                                        💬 Comments
                                                    </Typography>
                                                </Box>

                                                {/* Action Buttons */}
                                                <Box sx={{ display: 'flex', gap: 1, mb: 3 }}>
                                                    <Button
                                                        size="small"
                                                        startIcon={likedArticles.includes(article.id) ? <Favorite /> : <FavoriteBorder />}
                                                        onClick={() => handleLikeArticle(article.id)}
                                                        color={likedArticles.includes(article.id) ? 'error' : 'inherit'}
                                                    >
                                                        {article.likes} {likedArticles.includes(article.id) ? 'Liked' : 'Like'}
                                                    </Button>
                                                    <Button size="small" startIcon={<CommentIcon />} onClick={() => handleCommentsClick(article)}>
                                                        Comments
                                                    </Button>
                                                    <Button size="small" startIcon={<Share />}>
                                                        Share
                                                    </Button>
                                                </Box>

                                                {/* Comments Section */}
                                                <Comments
                                                    articleId={article.id}
                                                    currentUser="You"
                                                    placeholder="Add a comment..."
                                                    showAvatar={true}
                                                    onCommentsChange={(count) => {
                                                        // Update total comments count
                                                        setTotalComments(prev => prev + count);
                                                    }}
                                                    onNewComment={(newComment) => {
                                                        // Update the article's comment count in real-time
                                                        setArticles(prevArticles => 
                                                            prevArticles.map(a => {
                                                                if (a.id === article.id) {
                                                                    return {
                                                                        ...a,
                                                                        comments_count: a.comments_count + 1
                                                                    };
                                                                }
                                                                return a;
                                                            })
                                                        );
                                                        setTotalComments(prev => prev + 1);
                                                    }}
                                                />
                                            </CardContent>
                                        </Card>
                                    ))
                                ) : (
                                    <Card>
                                        <CardContent sx={{ textAlign: 'center', py: 4 }}>
                                            <Typography color="text.secondary">
                                                No articles found
                                            </Typography>
                                        </CardContent>
                                    </Card>
                                )}
                            </Box>
                        </Box>
                    </Box>
                </Box>

                {/* Footer - Engagement Stats */}
                <Box sx={{ 
                    backgroundColor: 'background.paper', 
                    borderTop: '1px solid', 
                    borderColor: 'divider',
                    py: 2,
                    px: 3,
                    textAlign: 'center'
                }}>
                    <Typography variant="body2" color="text.secondary">
                        📊 Total Engagement: {totalComments} comments across all articles
                    </Typography>
                </Box>

                {/* Comments Modal */}
                <Modal
                    open={commentsModalOpen}
                    onClose={handleCloseCommentsModal}
                    closeAfterTransition
                    BackdropComponent={Backdrop}
                    BackdropProps={{
                        timeout: 500,
                    }}
                    sx={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                    }}
                >
                    <Box sx={{
                        backgroundColor: 'background.paper',
                        borderRadius: 2,
                        boxShadow: 24,
                        p: 4,
                        maxWidth: 600,
                        width: '90%',
                        maxHeight: '80vh',
                        overflow: 'auto',
                        position: 'relative'
                    }}>
                        {/* Close Button */}
                        <IconButton
                            onClick={handleCloseCommentsModal}
                            sx={{
                                position: 'absolute',
                                right: 8,
                                top: 8,
                                color: 'grey.500'
                            }}
                        >
                            ✕
                        </IconButton>

                        {/* Modal Header */}
                        <Typography variant="h6" sx={{ mb: 2, pr: 4 }}>
                            💬 Comments
                        </Typography>

                        {selectedArticle && (
                            <Typography variant="subtitle2" sx={{ mb: 3, color: 'text.secondary' }}>
                                Article: {selectedArticle.title}
                            </Typography>
                        )}

                        {/* Comments List */}
                        <Box sx={{ maxHeight: '50vh', overflow: 'auto', mb: 3 }}>
                            {selectedArticle && (
                                <Comments
                                    articleId={selectedArticle.id}
                                    currentUser="You"
                                    placeholder="Add a comment..."
                                    showAvatar={true}
                                    isOpen={commentsModalOpen}
                                    onCommentsChange={(count) => {
                                        // Update total comments count when comments change
                                        setTotalComments(prev => prev + (count - (selectedArticle.comments?.length || 0)));
                                    }}
                                    onNewComment={handleNewComment}
                                />
                            )}
                        </Box>
                    </Box>
                </Modal>

                {/* Article Menu */}
                <Menu
                    anchorEl={articleMenuAnchor}
                    open={Boolean(articleMenuAnchor)}
                    onClose={handleArticleMenuClose}
                    anchorOrigin={{
                        vertical: 'bottom',
                        horizontal: 'right',
                    }}
                    transformOrigin={{
                        vertical: 'top',
                        horizontal: 'right',
                    }}
                >
                    <MenuItem onClick={handleHideArticle}>
                        <ListItemIcon>
                            <VisibilityOff fontSize="small" />
                        </ListItemIcon>
                        <ListItemText>Hide Article</ListItemText>
                    </MenuItem>
                    <MenuItem onClick={handleBlockPublisher}>
                        <ListItemIcon>
                            <Block fontSize="small" />
                        </ListItemIcon>
                        <ListItemText>Block Publisher</ListItemText>
                    </MenuItem>
                </Menu>
            </Box>
        </>
    );
}