import React, { useState } from 'react';
import { Head, router } from '@inertiajs/react';
import {
    Container,
    Typography,
    Box,
    Button,
    Card,
    CardContent,
    Alert,
    Fade,
    AppBar,
    Toolbar,
    Drawer,
    List,
    ListItem,
    ListItemIcon,
    ListItemText,
    Divider,
    IconButton,
    Avatar,
    Chip,
    Stack
} from '@mui/material';
import {
    ArrowBack,
    Article,
    Comment,
    Menu,
    Dashboard,
    Visibility,
    Chat,
    Person,
    Logout
} from '@mui/icons-material';

const drawerWidth = 240;

const PublishedArticlesSimple = ({ publishedArticles }) => {
    const [comments, setComments] = useState({});

    const handleComment = (articleId) => {
        const content = comments[articleId];
        
        if (content && content.trim()) {
            router.post(`/student/articles/${articleId}/comment`, {
                content: content
            }, {
                onSuccess: () => {
                    setComments(prev => ({ ...prev, [articleId]: '' }));
                    alert('Comment posted successfully!');
                },
                onError: (errors) => {
                    alert('Error posting comment: ' + JSON.stringify(errors));
                }
            });
        }
    };

    const handleCommentChange = (articleId, value) => {
        setComments(prev => ({ ...prev, [articleId]: value }));
    };

    const handleBackToDashboard = () => {
        router.visit('/student/dashboard');
    };

    const drawer = (
        <div>
            <Toolbar>
                <Typography variant="h6" noWrap component="div">
                    Student Panel
                </Typography>
            </Toolbar>
            <Divider />
            <List>
                <ListItem button onClick={() => router.visit('/student/dashboard')}>
                    <ListItemIcon>
                        <Dashboard />
                    </ListItemIcon>
                    <ListItemText primary="Dashboard" />
                </ListItem>
                <ListItem button onClick={() => router.visit('/student/published-articles')}>
                    <ListItemIcon>
                        <Article />
                    </ListItemIcon>
                    <ListItemText primary="Published Articles" />
                </ListItem>
                <ListItem button onClick={() => router.visit('/student/my-comments')}>
                    <ListItemIcon>
                        <Comment />
                    </ListItemIcon>
                    <ListItemText primary="My Comments" />
                </ListItem>
            </List>
        </div>
    );

    return (
        <>
            <Head title="Published Articles" />
            <Box sx={{ display: 'flex' }}>
                <AppBar
                    position="fixed"
                    sx={{ width: `calc(100% - ${drawerWidth}px)`, ml: `${drawerWidth}px` }}
                >
                    <Toolbar>
                        <IconButton
                            color="inherit"
                            aria-label="open drawer"
                            edge="start"
                            sx={{ mr: 2, display: { sm: 'none' } }}
                        >
                            <Menu />
                        </IconButton>
                        <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
                            Published Articles
                        </Typography>
                    </Toolbar>
                </AppBar>
                <Box
                    component="nav"
                    sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
                >
                    <Drawer
                        variant="temporary"
                        open={false}
                        ModalProps={{
                            keepMounted: true,
                        }}
                        sx={{
                            display: { xs: 'block', sm: 'none' },
                            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
                        }}
                    >
                        {drawer}
                    </Drawer>
                    <Drawer
                        variant="permanent"
                        sx={{
                            display: { xs: 'none', sm: 'block' },
                            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
                        }}
                        open
                    >
                        {drawer}
                    </Drawer>
                </Box>
                <Box
                    component="main"
                    sx={{ flexGrow: 1, p: 3, width: { sm: `calc(100% - ${drawerWidth}px)` } }}
                >
                    <Toolbar />
                    <Container maxWidth="lg">
                        <Fade in={true} timeout={1000}>
                            <Box>
                                <Button
                                    startIcon={<ArrowBack />}
                                    onClick={handleBackToDashboard}
                                    sx={{ mb: 3 }}
                                >
                                    Back to Dashboard
                                </Button>

                                <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold', color: '#1976d2' }}>
                                    Published Articles ({publishedArticles?.length || 0})
                                </Typography>

                                {!publishedArticles || publishedArticles.length === 0 ? (
                                    <Alert severity="info" sx={{ mt: 2 }}>
                                        <Typography color="text.secondary">
                                            No published articles available yet. Check back later for new content!
                                        </Typography>
                                    </Alert>
                                ) : (
                                    <Stack spacing={3}>
                                        {publishedArticles.map((article) => (
                                            <Card key={article.id} sx={{ p: 3 }}>
                                                <CardContent>
                                                    <Typography variant="h6" gutterBottom>
                                                        {article.title}
                                                    </Typography>
                                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                                                        By {article.writer?.name}
                                                    </Typography>
                                                    <Chip
                                                        label={article.category && typeof article.category === 'object' ? (article.category.name || article.category.label || 'Uncategorized') : 'Uncategorized'}
                                                        size="small"
                                                        sx={{ mr: 1 }}
                                                    />
                                                    <Chip
                                                        label="Published"
                                                        color="success"
                                                        size="small"
                                                    />
                                                    <Typography variant="body2" sx={{ mt: 2, mb: 2 }}>
                                                        {article.content?.substring(0, 200)}...
                                                    </Typography>
                                                    
                                                    {article.comments?.length > 0 && (
                                                        <Box sx={{ mt: 2 }}>
                                                            <Typography variant="subtitle2" gutterBottom>
                                                                Comments ({article.comments.length})
                                                            </Typography>
                                                            {article.comments.slice(0, 2).map((comment) => (
                                                                <Box key={comment.id} sx={{ mb: 1, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
                                                                    <Typography variant="body2" sx={{ mb: 1 }}>
                                                                        <strong>{comment.student?.name}:</strong> {comment.content}
                                                                    </Typography>
                                                                </Box>
                                                            ))}
                                                        </Box>
                                                    )}
                                                    
                                                    <TextField
                                                        fullWidth
                                                        multiline
                                                        rows={3}
                                                        label="Add a comment"
                                                        value={comments[article.id] || ''}
                                                        onChange={(e) => handleCommentChange(article.id, e.target.value)}
                                                        placeholder="Share your thoughts..."
                                                        sx={{ mt: 2 }}
                                                    />
                                                    <Button
                                                        variant="contained"
                                                        onClick={() => handleComment(article.id)}
                                                        disabled={!comments[article.id]?.trim()}
                                                        startIcon={<Chat />}
                                                        sx={{ mt: 1 }}
                                                    >
                                                        Post Comment
                                                    </Button>
                                                </CardContent>
                                            </Card>
                                        ))}
                                    </Stack>
                                )}
                            </Box>
                        </Fade>
                    </Container>
                </Box>
            </Box>
        </>
    );
};

export default PublishedArticlesSimple;
