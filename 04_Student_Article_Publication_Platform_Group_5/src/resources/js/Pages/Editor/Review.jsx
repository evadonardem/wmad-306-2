import React, { useState, useRef, useMemo, useCallback, useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Container,
    Typography,
    Box,
    Paper,
    Button,
    Card,
    CardContent,
    TextField,
    Avatar,
    Chip,
    Fade,
    Slide,
    AppBar,
    Toolbar,
    IconButton,
    Divider,
    Grid,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    List,
    ListItem,
    ListItemText,
    CircularProgress,
    Menu,
    MenuItem,
    ListItemIcon,
    alpha
} from '@mui/material';
import {
    Person,
    Category,
    Publish,
    Refresh,
    RateReview,
    Schedule,
    Logout,
    Menu as MenuIcon,
    Edit,
    Visibility,
    ArrowBack,
    Send,
    Description,
    Timeline,
    Assessment,
    CheckCircle,
    Cancel,
    Speed,
    AutoAwesome,
    Lightbulb,
    Grade,
    Bookmark,
    Article,
    Share
} from '@mui/icons-material';
import { useThemeContext } from '@/Context/ThemeContext';
import BackToDashboard from '@/Components/BackToDashboard';
import ThemeToggle from '@/Components/ThemeToggle';
import JoditEditor from 'jodit-react';

const Review = ({ article }) => {
    const { mode } = useThemeContext();
    const { auth } = usePage().props;
    const [anchorEl, setAnchorEl] = useState(null);
    const [revisionDialog, setRevisionDialog] = useState(false);
    const [revisionComments, setRevisionComments] = useState('');
    const [content, setContent] = useState(article?.content || '');
    const [chatOpen, setChatOpen] = useState(false);
    const [chatLoading, setChatLoading] = useState(false);
    const [chatMessages, setChatMessages] = useState([]);
    const [chatText, setChatText] = useState('');
    const [error, setError] = useState(null);
    const [mounted, setMounted] = useState(false);
    const editor = useRef(null);

    useEffect(() => {
        setMounted(true);
    }, []);

    const config = useMemo(
        () => ({
            readonly: true,
            placeholder: 'Article content...',
            toolbar: false,
            showCharsCounter: false,
            showWordsCounter: false,
            showXPathInStatusbar: false,
            style: {
                color: mode === 'dark' ? '#f8fafc' : 
                       mode === 'galaxy' ? '#e0e7ff' : 
                       '#f8fafc',
                backgroundColor: mode === 'dark' ? '#1e293b' : 
                                 mode === 'galaxy' ? 'rgba(15, 23, 42, 0.9)' : 
                                 '#1e293b'
            }
        }),
        [mode]
    );

    const isSubmitted = typeof article?.status === 'string' ? article.status === 'submitted' : (article?.status && typeof article?.status === 'object' ? (article.status.name === 'submitted' || article.status.label === 'submitted') : false);
    const isPublished = typeof article?.status === 'string' ? article.status === 'published' : (article?.status && typeof article?.status === 'object' ? (article.status.name === 'published' || article.status.label === 'published') : false);
    const canPublish = isSubmitted || isPublished;

    const csrfToken = useMemo(() => {
        const el = document.querySelector('meta[name="csrf-token"]');
        return el?.getAttribute('content') || '';
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

    const loadChat = useCallback(async () => {
        setChatLoading(true);
        try {
            const res = await fetch(`/articles/${article.id}/messages`, {
                headers: {
                    'Accept': 'application/json'
                },
                credentials: 'same-origin'
            });
            const data = await res.json();
            setChatMessages(Array.isArray(data?.messages) ? data.messages : []);
        } finally {
            setChatLoading(false);
        }
    }, [article.id]);

    const sendChat = useCallback(async () => {
        const trimmed = chatText.trim();
        if (!trimmed) return;

        setChatLoading(true);
        try {
            await fetch(`/articles/${article.id}/messages`, {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': csrfToken
                },
                credentials: 'same-origin',
                body: JSON.stringify({ message: trimmed })
            });
            setChatText('');
            await loadChat();
        } finally {
            setChatLoading(false);
        }
    }, [article.id, chatText, csrfToken, loadChat]);

    useEffect(() => {
        if (chatOpen) {
            loadChat();
        }
    }, [chatOpen, loadChat]);

    const handlePublish = () => {
        if (!canPublish) {
            alert('Only submitted articles can be published.');
            return;
        }
        router.post(`/editor/articles/${article.id}/publish`, {}, {
            onSuccess: () => {
                // Redirect to the published article view
                router.get(`/student/articles/${article.id}`);
            }
        });
    };

    const handleRequestRevision = () => {
        if (!isSubmitted) {
            alert('Only submitted articles can be sent back for revision.');
            return;
        }

        if (!revisionComments.trim()) {
            alert('Please enter revision comments before sending.');
            return;
        }
        router.post(`/editor/articles/${article.id}/revision`, {
            comments: revisionComments
        }, {
            onSuccess: () => {
                setRevisionDialog(false);
                setRevisionComments('');
                router.get('/editor/dashboard');
            }
        });
    };

    return (
        <Box sx={{ 
            minHeight: '100vh',
            background: mode === 'dark' ? 'linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #334155 100%)' : 
                       mode === 'galaxy' ? 'linear-gradient(135deg, #0f0f23 0%, #1a1a3e 50%, #2d2d5e 100%)' : 
                       'linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #334155 100%)',
            color: mode === 'dark' ? '#f8fafc' : 
                   mode === 'galaxy' ? '#e0e7ff' : 
                   '#f8fafc',
            position: 'relative',
            overflow: 'hidden',
            '&::before': {
                content: '""',
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                background: 'url("data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%23ffffff" fill-opacity="0.08"%3E%3Ccircle cx="30" cy="30" r="4"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
                opacity: 0.4
            }
        }}>
            <Head title="Review Article" />
            
            {/* Header */}
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', position: 'relative', zIndex: 1, p: 3 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <IconButton 
                            onClick={() => router.get('/editor/dashboard')}
                            sx={{ 
                                color: '#ffffff',
                                backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                '&:hover': {
                                    backgroundColor: 'rgba(255, 255, 255, 0.2)'
                                }
                            }}
                        >
                            <ArrowBack />
                        </IconButton>
                        <Box>
                            <Typography variant="h3" sx={{ fontWeight: 700, mb: 1, color: '#ffffff' }}>
                                Review Article
                            </Typography>
                            <Typography variant="h6" sx={{ opacity: 0.9, color: '#ffffff' }}>
                                {article?.title || 'Untitled Article'}
                            </Typography>
                        </Box>
                    </Box>
                    <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                        <BackToDashboard />
                        <ThemeToggle />
                        <IconButton 
                            onClick={handleMenuOpen}
                            sx={{ 
                                color: '#ffffff',
                                backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                '&:hover': {
                                    backgroundColor: 'rgba(255, 255, 255, 0.2)'
                                }
                            }}
                        >
                            <MenuIcon />
                        </IconButton>
                    </Box>
                </Box>

            {/* Main Content */}
            {/* Article Header */}
            <Box sx={{ 
                p: 3, 
                borderBottom: mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                               '1px solid rgba(139, 92, 246, 0.2)',
                background: mode === 'dark' ? 'rgba(248, 250, 252, 0.05)' : 
                             'rgba(248, 250, 252, 0.05)'
            }}>
                <Typography variant="h4" sx={{ 
                    color: mode === 'dark' ? '#f8fafc' : 
                           '#f8fafc', 
                    fontWeight: 700, 
                    mb: 2 
                }}>
                    {article?.title || 'Untitled Article'}
                </Typography>
                
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Avatar sx={{ 
                        bgcolor: alpha('#06b6d4', 0.2),
                        color: '#06b6d4',
                        width: 48,
                        height: 48
                    }}>
                        <Person />
                    </Avatar>
                    <Box>
                        <Typography variant="body1" sx={{ 
                            color: mode === 'dark' ? '#f8fafc' : 
                                   '#f8fafc', 
                            fontWeight: 600 
                        }}>
                            {article?.writer?.name || 'Unknown Writer'}
                        </Typography>
                        <Typography variant="body2" sx={{ 
                            color: mode === 'dark' ? '#94a3b8' : 
                                   '#94a3b8' 
                        }}>
                            {article?.writer?.email || 'No email'}
                        </Typography>
                    </Box>
                </Box>
            </Box>

            {/* Article Content */}
                                        <JoditEditor
                                            ref={editor}
                                            value={content}
                                            config={config}
                                            tabIndex={1}
                                        />

            
                                {/* Action Buttons */}
                                    <Typography variant="h6" sx={{ 
                                        color: mode === 'dark' ? '#f8fafc' : 
                                               '#f8fafc', 
                                        fontWeight: 600, 
                                        mb: 3 
                                    }}>
                                        Actions
                                    </Typography>
                                    
                                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                                        {canPublish && (
                                            <Button
                                                variant="contained"
                                                startIcon={<Publish />}
                                                onClick={handlePublish}
                                                fullWidth
                                                sx={{
                                                    background: mode === 'dark' ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : 
                                                               'linear-gradient(135deg, #10b981 0%, #059669 100%)',
                                                    '&:hover': {
                                                        background: mode === 'dark' ? 'linear-gradient(135deg, #059669 0%, #047857 100%)' : 
                                                                   'linear-gradient(135deg, #059669 0%, #047857 100%)',
                                                    }
                                                }}
                                            >
                                                Publish Article
                                            </Button>
                                        )}
                                        
                                        {isSubmitted && (
                                            <Button
                                                variant="outlined"
                                                startIcon={<Refresh />}
                                                onClick={() => setRevisionDialog(true)}
                                                fullWidth
                                                sx={{
                                                    borderColor: '#f59e0b',
                                                    color: '#f59e0b',
                                                    '&:hover': {
                                                        borderColor: '#d97706',
                                                        backgroundColor: alpha('#f59e0b', 0.1)
                                                    }
                                                }}
                                            >
                                                Request Revision
                                            </Button>
                                        )}

                                        <Button
                                            variant="outlined"
                                            startIcon={<Share />}
                                            onClick={() => navigator.clipboard.writeText(window.location.href)}
                                            fullWidth
                                            sx={{
                                                borderColor: mode === 'dark' ? '#06b6d4' : 
                                                             '#ec4899',
                                                color: mode === 'dark' ? '#06b6d4' : 
                                                       '#ec4899',
                                                '&:hover': {
                                                    borderColor: mode === 'dark' ? '#0891b2' : 
                                                                 '#db2777',
                                                    backgroundColor: alpha(mode === 'dark' ? '#06b6d4' : 
                                                                    '#ec4899', 0.1)
                                                }
                                            }}
                                        >
                                            Share Link
                                        </Button>

                                        <Button
                                            variant="outlined"
                                            startIcon={<Visibility />}
                                            onClick={() => router.get(`/student/articles/${article.id}`)}
                                            fullWidth
                                            sx={{
                                                borderColor: '#10b981',
                                                color: '#10b981',
                                                '&:hover': {
                                                    borderColor: '#059669',
                                                    backgroundColor: alpha('#10b981', 0.1)
                                                }
                                            }}
                                        >
                                            Preview as Student
                                        </Button>
                                    </Box>

                                {/* Article Stats */}
                                    <Typography variant="h6" sx={{ 
                                        color: mode === 'dark' ? '#f8fafc' : 
                                               '#f8fafc', 
                                        fontWeight: 600, 
                                        mb: 3 
                                    }}>
                                        Article Statistics
                                    </Typography>
                                    
                                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                            <Typography variant="body2" sx={{ color: mode === 'dark' ? '#94a3b8' : '#94a3b8' }}>
                                                Word Count
                                            </Typography>
                                            <Typography variant="body1" sx={{ 
                                                color: mode === 'dark' ? '#f8fafc' : 
                                                       '#f8fafc', 
                                                fontWeight: 600 
                                            }}>
                                                {content?.split(/\s+/).filter(word => word.length > 0).length || 0}
                                            </Typography>
                                        </Box>
                                        
                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                            <Typography variant="body2" sx={{ color: mode === 'dark' ? '#94a3b8' : '#94a3b8' }}>
                                                Character Count
                                            </Typography>
                                            <Typography variant="body1" sx={{ 
                                                color: mode === 'dark' ? '#f8fafc' : 
                                                       '#f8fafc', 
                                                fontWeight: 600 
                                            }}>
                                                {content?.length || 0}
                                            </Typography>
                                        </Box>
                                        
                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                            <Typography variant="body2" sx={{ color: mode === 'dark' ? '#94a3b8' : '#94a3b8' }}>
                                                Reading Time
                                            </Typography>
                                            <Typography variant="body1" sx={{ 
                                                color: mode === 'dark' ? '#f8fafc' : 
                                                       '#f8fafc', 
                                                fontWeight: 600 
                                            }}>
                                                ~{Math.ceil((content?.split(/\s+/).filter(word => word.length > 0).length || 0) / 200)} min
                                            </Typography>
                                        </Box>
                                    </Box>

            {/* User Menu */}
            <Menu
                anchorEl={anchorEl}
                open={Boolean(anchorEl)}
                onClose={handleMenuClose}
                PaperProps={{
                    sx: {
                        background: mode === 'dark' ? '#1e293b' : 
                                     'rgba(15, 23, 42, 0.9)',
                        border: mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                 '1px solid rgba(139, 92, 246, 0.2)',
                        mt: 1
                    }
                }}
            >
                <MenuItem sx={{ color: mode === 'dark' ? '#f8fafc' : '#f8fafc' }}>
                    <ListItemIcon>
                        <Person sx={{ color: mode === 'dark' ? '#94a3b8' : '#94a3b8' }} />
                    </ListItemIcon>
                    {auth?.user?.name || 'Unknown User'}
                </MenuItem>
                <Divider />
                <MenuItem onClick={() => router.post('/logout')} sx={{ color: mode === 'dark' ? '#f8fafc' : '#f8fafc' }}>
                    <ListItemIcon>
                        <Logout sx={{ color: mode === 'dark' ? '#94a3b8' : '#94a3b8' }} />
                    </ListItemIcon>
                    Logout
                </MenuItem>
            </Menu>

            {/* Revision Dialog */}
            <Dialog open={revisionDialog} onClose={() => setRevisionDialog(false)} maxWidth="md" fullWidth>
                <DialogTitle sx={{ 
                    background: mode === 'dark' ? '#1e293b' : 
                               'rgba(15, 23, 42, 0.9)',
                    color: mode === 'dark' ? '#f8fafc' : '#f8fafc',
                    borderBottom: mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                     '1px solid rgba(139, 92, 246, 0.2)'
                }}>
                    Request Revision for "{article?.title}"
                </DialogTitle>
                <DialogContent sx={{ 
                    background: mode === 'dark' ? '#1e293b' : 
                               'rgba(15, 23, 42, 0.9)',
                    color: mode === 'dark' ? '#f8fafc' : '#f8fafc'
                }}>
                    <TextField
                        autoFocus
                        margin="dense"
                        label="Revision Comments"
                        multiline
                        rows={6}
                        fullWidth
                        variant="outlined"
                        value={revisionComments}
                        onChange={(e) => setRevisionComments(e.target.value)}
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                '& fieldset': {
                                    borderColor: mode === 'dark' ? '#374151' : 
                                                 '#4b5563',
                                },
                                '&:hover fieldset': {
                                    borderColor: mode === 'dark' ? '#4b5563' : 
                                                 '#6b7280',
                                },
                                '&.Mui-focused fieldset': {
                                    borderColor: mode === 'dark' ? '#06b6d4' : 
                                                 '#8b5cf6',
                                },
                            },
                            '& .MuiInputLabel-root': {
                                color: mode === 'dark' ? '#9ca3af' : 
                                       '#d1d5db',
                            },
                            '& .MuiInputBase-input': {
                                color: mode === 'dark' ? '#f9fafb' : 
                                       '#e5e7eb',
                            }
                        }}
                    />
                </DialogContent>
                <DialogActions sx={{ 
                    background: mode === 'dark' ? '#1e293b' : 
                               'rgba(15, 23, 42, 0.9)',
                    borderTop: mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                 '1px solid rgba(139, 92, 246, 0.2)'
                }}>
                    <Button onClick={() => setRevisionDialog(false)} sx={{ color: mode === 'dark' ? '#94a3b8' : '#94a3b8' }}>
                        Cancel
                    </Button>
                    <Button 
                        onClick={handleRequestRevision}
                        variant="contained"
                        sx={{
                            background: mode === 'dark' ? 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' : 
                                       'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)',
                            '&:hover': {
                                background: mode === 'dark' ? 'linear-gradient(135deg, #d97706 0%, #b45309 100%)' : 
                                           'linear-gradient(135deg, #d97706 0%, #b45309 100%)',
                            }
                        }}
                    >
                        Send Revision Request
                    </Button>
                </DialogActions>
            </Dialog>
            </Box>
    );
};

export default Review;
