import React, { useState, useCallback, useEffect, useMemo } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import { useThemeContext } from '@/Context/ThemeContext';
import {
    Typography,
    Box,
    Paper,
    Button,
    Card,
    CardContent,
    Avatar,
    Chip,
    Divider,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    List,
    ListItem,
    ListItemText,
    ListItemIcon,
    TextField,
    CircularProgress,
    Menu,
    MenuItem,
    IconButton,
    Container,
    Fade,
    alpha
} from '@mui/material';
import {
    ArrowBack,
    Person,
    Logout,
    Menu as MenuIcon,
    Edit,
    Visibility,
    RateReview,
    Comment,
    Send,
    Star,
    StarBorder,
    Delete
} from '@mui/icons-material';

const StudentShowArticle = ({ article, isFavorite: initialFavorite = false }) => {
    const { mode } = useThemeContext();
    const [anchorEl, setAnchorEl] = useState(null);
    const [commentText, setCommentText] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [isFavorite, setIsFavorite] = useState(initialFavorite);
    const [mounted, setMounted] = useState(false);

    const { auth } = usePage().props;

    useEffect(() => {
        setMounted(true);
    }, []);

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

    const handleToggleFavorite = () => {
        router.post(`/student/articles/${article.id}/favorite`, {}, {
            preserveScroll: true,
            onSuccess: () => {
                setIsFavorite(!isFavorite);
            }
        });
    };

    const handleSubmitComment = () => {
        if (!commentText.trim()) return;
        
        setIsSubmitting(true);
        router.post(`/student/articles/${article.id}/comment`, {
            content: commentText.trim()
        }, {
            preserveScroll: true,
            onFinish: () => {
                setIsSubmitting(false);
                setCommentText('');
            },
            onSuccess: () => {
                // Comments will be reloaded with the next page refresh
                // or we could use Inertia's reload functionality
            }
        });
    };

    const handleDeleteComment = (commentId) => {
        if (confirm('Are you sure you want to delete this comment?')) {
            router.delete(`/student/comments/${commentId}`, {
                preserveScroll: true,
                onSuccess: () => {
                    // Comment will be removed after page reload
                }
            });
        }
    };

    return (
        <>
            <Head title={`Read: ${article.title}`} />
            
            <Box sx={{ 
                minHeight: "100vh", 
                background: mode === 'light'
                    ? 'linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #bae6fd 100%)'
                    : mode === 'dark' 
                    ? 'linear-gradient(135deg, #0a0e27 0%, #1e293b 50%, #334155 100%)'
                    : 'radial-gradient(circle at 20% 50%, rgba(139, 92, 246, 0.15) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(236, 72, 153, 0.1) 0%, transparent 50%), linear-gradient(135deg, #0a0e27 0%, #1e293b 100%)',
                display: 'flex',
                flexDirection: 'column',
                position: 'relative',
                overflow: 'hidden'
            }}>
                {/* Animated Background Elements */}
                <Box
                    sx={{
                        position: 'absolute',
                        top: '10%',
                        left: '10%',
                        width: 400,
                        height: 400,
                        background: mode === 'light' 
                            ? 'radial-gradient(circle, rgba(99, 102, 241, 0.1) 0%, transparent 70%)'
                            : mode === 'dark'
                            ? 'radial-gradient(circle, rgba(6, 182, 212, 0.1) 0%, transparent 70%)'
                            : 'radial-gradient(circle, rgba(139, 92, 246, 0.15) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 8s ease-in-out infinite',
                    }}
                />
                <Box
                    sx={{
                        position: 'absolute',
                        bottom: '10%',
                        right: '10%',
                        width: 300,
                        height: 300,
                        background: mode === 'light' 
                            ? 'radial-gradient(circle, rgba(236, 72, 153, 0.1) 0%, transparent 70%)'
                            : mode === 'dark'
                            ? 'radial-gradient(circle, rgba(245, 158, 11, 0.1) 0%, transparent 70%)'
                            : 'radial-gradient(circle, rgba(236, 72, 153, 0.1) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 10s ease-in-out infinite reverse',
                    }}
                />

                {/* Header */}
                <Box sx={{ 
                    background: mode === 'light' ? 'linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(248, 250, 252, 0.9) 100%)' : 
                                   mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' : 
                                   'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                    backdropFilter: 'blur(20px)',
                    borderBottom: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                     mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                     '1px solid rgba(139, 92, 246, 0.2)',
                    p: 3,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    position: 'relative',
                    zIndex: 10
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <IconButton 
                            onClick={() => router.get('/student/dashboard')}
                            sx={{ color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#f8fafc' : '#f8fafc' }}
                        >
                            <ArrowBack />
                        </IconButton>
                        <Typography variant="h4" sx={{ 
                            color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                            fontWeight: 'bold' 
                        }}>
                            Read Article
                        </Typography>
                    </Box>
                    
                    <IconButton color="inherit" onClick={handleMenuOpen} sx={{ 
                        color: mode === 'light' ? '#1e293b' : 
                               mode === 'dark' ? '#f8fafc' : '#f8fafc' 
                    }}>
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
                    <MenuItem onClick={() => { router.get('/profile'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Person sx={{ color: '#60a5fa' }} />
                        </ListItemIcon>
                        Profile
                    </MenuItem>
                    
                    <Divider sx={{ backgroundColor: '#334155' }} />
                    <MenuItem onClick={handleLogout}>
                        <ListItemIcon>
                            <Logout sx={{ color: '#f59e0b' }} />
                        </ListItemIcon>
                        <Typography sx={{ 
                            color: '#f8fafc' 
                        }}>Logout</Typography>
                    </MenuItem>
                </Menu>

                        <Divider sx={{ backgroundColor: '#334155', mb: 3 }} />

                        <Box sx={{ mb: 4 }}>
                            <Typography variant="h6" gutterBottom sx={{ color: '#ffffff' }}>
                                Article Content
                            </Typography>
                            <Paper sx={{ 
                                p: 3, 
                                backgroundColor: '#ffffff', 
                                border: '1px solid #334155'
                            }}>
                                <div 
                                    dangerouslySetInnerHTML={{ __html: article.content }}
                                    style={{ 
                                        color: '#000000', 
                                        lineHeight: 1.6,
                                        fontSize: '16px'
                                    }}
                                />
                            </Paper>
                        </Box>

                        <Divider sx={{ backgroundColor: '#334155', mb: 3 }} />

                        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
                            <Button
                                variant="outlined"
                                size="large"
                                startIcon={<Comment />}
                                onClick={() => document.getElementById('comments-section').scrollIntoView({ behavior: 'smooth' })}
                                sx={{ 
                                    px: 4,
                                    color: '#60a5fa',
                                    borderColor: '#60a5fa',
                                    '&:hover': { borderColor: '#3b82f6', color: '#3b82f6' }
                                }}
                            >
                                View Comments ({article.comments?.length || 0})
                            </Button>
                            <Button
                                variant="contained"
                                size="large"
                                startIcon={<ArrowBack />}
                                onClick={() => router.get('/student/dashboard')}
                                sx={{ 
                                    px: 4,
                                    bgcolor: '#10b981',
                                    '&:hover': { bgcolor: '#059669' }
                                }}
                            >
                                Back to Dashboard
                            </Button>
                        </Box>
                    </Box>

                    {/* Statistics Section */}
                    <Paper sx={{ p: 4, backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                        <Typography variant="h5" sx={{ color: '#10b981', mb: 3, fontWeight: 'bold' }}>
                            Article Statistics
                        </Typography>
                        <Box sx={{ display: 'flex', gap: 3, flexWrap: 'wrap' }}>
                            <Box sx={{ textAlign: 'center' }}>
                                <Typography variant="h4" sx={{ color: '#60a5fa', fontWeight: 'bold' }}>
                                    {article.comments?.length || 0}
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                    Comments
                                </Typography>
                            </Box>
                            <Box sx={{ textAlign: 'center' }}>
                                <Typography variant="h4" sx={{ color: '#10b981', fontWeight: 'bold' }}>
                                    {article.views || 0}
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                    Views
                                </Typography>
                            </Box>
                            <Box sx={{ textAlign: 'center' }}>
                                <Typography variant="h4" sx={{ color: '#f59e0b', fontWeight: 'bold' }}>
                                    {new Date(article.created_at).toLocaleDateString()}
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                    Published Date
                                </Typography>
                            </Box>
                        </Box>
                    </Paper>

                    {/* Comments Section */}
                    <Paper id="comments-section" sx={{ p: 4, backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                        <Typography variant="h5" sx={{ color: '#10b981', mb: 3, fontWeight: 'bold' }}>
                            Comments & Discussion
                        </Typography>
                        
                        {/* Comments List */}
                        <Box sx={{ mb: 4 }}>
                            {article.comments && article.comments.length > 0 ? (
                                <List>
                                    {article.comments.map((comment) => (
                                        <ListItem key={comment.id} alignItems="flex-start" disableGutters sx={{ mb: 2 }}>
                                            <ListItemIcon>
                                                <Avatar sx={{ width: 40, height: 40, bgcolor: '#60a5fa' }}>
                                                    {comment.student?.name?.charAt(0) || 'S'}
                                                </Avatar>
                                            </ListItemIcon>
                                            <ListItemText
                                                primary={
                                                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                        <Typography variant="subtitle1" sx={{ color: '#ffffff', fontWeight: 'bold' }}>
                                                            {comment.student?.name || 'Student'}
                                                        </Typography>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                            <Typography variant="caption" sx={{ color: '#94a3b8' }}>
                                                                {new Date(comment.created_at).toLocaleDateString()}
                                                            </Typography>
                                                            {comment.student_id === auth?.user?.id && (
                                                                <IconButton
                                                                    size="small"
                                                                    onClick={() => handleDeleteComment(comment.id)}
                                                                    sx={{ 
                                                                        color: '#ef4444',
                                                                        '&:hover': { color: '#dc2626', bgcolor: 'rgba(239, 68, 68, 0.1)' }
                                                                    }}
                                                                    title="Delete your comment"
                                                                >
                                                                    <Delete fontSize="small" />
                                                                </IconButton>
                                                            )}
                                                        </Box>
                                                    </Box>
                                                }
                                                secondary={
                                                    <Typography variant="body2" sx={{ color: '#ffffff', mt: 1 }}>
                                                        {comment.content}
                                                    </Typography>
                                                }
                                            />
                                        </ListItem>
                                    ))}
                                </List>
                            ) : (
                                <Typography variant="body2" sx={{ color: '#94a3b8', textAlign: 'center', py: 4 }}>
                                    No comments yet. Be the first to share your thoughts!
                                </Typography>
                            )}
                        </Box>

                        {/* Add Comment Form */}
                        <Divider sx={{ backgroundColor: '#334155', mb: 3 }} />
                        
                        <Typography variant="h6" sx={{ color: '#ffffff', mb: 2 }}>
                            Add Your Comment
                        </Typography>
                        
                        <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-end' }}>
                            <TextField
                                fullWidth
                                multiline
                                minRows={3}
                                label="Share your thoughts on this article..."
                                value={commentText}
                                onChange={(e) => setCommentText(e.target.value)}
                                disabled={isSubmitting}
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
                            <Button
                                variant="contained"
                                onClick={handleSubmitComment}
                                disabled={isSubmitting || !commentText.trim()}
                                sx={{ 
                                    bgcolor: '#60a5fa',
                                    '&:hover': { bgcolor: '#3b82f6' },
                                    '&:disabled': { bgcolor: '#374151' },
                                    px: 3,
                                    py: 2
                                }}
                            >
                                {isSubmitting ? 'Posting...' : 'Post Comment'}
                            </Button>
                        </Box>
                    </Paper>
        </>
    );
};

export default StudentShowArticle;
