import React, { useState, useCallback, useEffect, useMemo } from 'react';
import { Head, Link, router, usePage } from '@inertiajs/react';
import {
    Container,
    Typography,
    Box,
    Paper,
    Grid,
    TextField,
    Button,
    Select,
    MenuItem,
    FormControl,
    InputLabel,
    Chip,
    Divider,
    Alert,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    List,
    ListItem,
    ListItemText,
    CircularProgress,
    Menu,
    MenuItem as MuiMenuItem,
    ListItemIcon,
    IconButton
} from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { 
    ArrowBack, 
    Save, 
    Send, 
    Category,
    Menu as MenuIcon,
    Person,
    Logout,
    Edit,
    Visibility
} from '@mui/icons-material';
import JoditEditorComponent from '@/Components/JoditEditor';

const WriterEdit = ({ article, categories }) => {
    const { flash, auth } = usePage().props;

    const [formData, setFormData] = useState({
        title: article?.title || '',
        content: article?.content?.replace(/<p><\/p>/g, '') || '',
        category_id: article?.category_id || article?.category?.id || ''
    });

    const [anchorEl, setAnchorEl] = useState(null);
    const [chatOpen, setChatOpen] = useState(false);
    const [chatLoading, setChatLoading] = useState(false);
    const [chatMessages, setChatMessages] = useState([]);
    const [chatText, setChatText] = useState('');

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

    const handleInputChange = (field, value) => {
        setFormData(prev => ({ ...prev, [field]: value }));
    };

    const handleContentChange = (newContent) => {
        setFormData(prev => ({ ...prev, content: newContent }));
    };

    const handleSaveDraft = () => {
        // Clean content before saving
        const cleanFormData = {
            ...formData,
            content: formData.content.replace(/<p><\/p>/g, '')
        };
        router.put(`/writer/articles/${article.id}`, cleanFormData);
    };

    const handleResubmitRevision = () => {
        // Clean content before submitting
        const cleanFormData = {
            ...formData,
            content: formData.content.replace(/<p><\/p>/g, '')
        };
        router.put(`/writer/articles/${article.id}/revise`, cleanFormData);
    };

    const isNeedsRevision = article?.status?.name === 'needs_revision';

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

    const csrfToken = useMemo(() => {
        const el = document.querySelector('meta[name="csrf-token"]');
        return el?.getAttribute('content') || '';
    }, []);

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

    const latestRevisionComment = (() => {
        if (!article?.revisions || article.revisions.length === 0) return null;
        return article.revisions[0]?.comments || null;
    })();

    return (
        <ThemeProvider theme={theme}>
            <Head title={`Edit: ${article?.title ?? 'Article'}`} />
            
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
                            onClick={() => router.get('/writer/dashboard')}
                            sx={{ color: '#ffffff' }}
                        >
                            <ArrowBack />
                        </IconButton>
                        <Typography variant="h4" sx={{ color: '#ffffff', fontWeight: 'bold' }}>
                            Edit Article
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
                    <MuiMenuItem onClick={handleMenuClose}>
                        <ListItemIcon>
                            <Person sx={{ color: '#60a5fa' }} />
                        </ListItemIcon>
                        Profile
                    </MuiMenuItem>
                    
                    <Divider sx={{ backgroundColor: '#334155' }} />
                    <MuiMenuItem onClick={() => { router.get('/writer/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Edit sx={{ color: '#f59e0b' }} />
                        </ListItemIcon>
                        Switch to Writer
                    </MuiMenuItem>
                    <MuiMenuItem onClick={() => { router.get('/editor/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Category sx={{ color: '#ef4444' }} />
                        </ListItemIcon>
                        Switch to Editor
                    </MuiMenuItem>
                    <MuiMenuItem onClick={() => { router.get('/student/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Visibility sx={{ color: '#10b981' }} />
                        </ListItemIcon>
                        Switch to Student
                    </MuiMenuItem>
                    
                    <Divider sx={{ backgroundColor: '#334155' }} />
                    <MuiMenuItem onClick={handleLogout}>
                        <ListItemIcon>
                            <Logout sx={{ color: '#f59e0b' }} />
                        </ListItemIcon>
                        Logout
                    </MuiMenuItem>
                </Menu>

                {/* Main Content */}
                <Box sx={{ flexGrow: 1, p: 3 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 3 }}>
                        <Box>
                            <Typography variant="h4" sx={{ fontWeight: 'bold', color: '#f59e0b' }}>
                                Edit Article
                            </Typography>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                                <Chip
                                    size="small"
                                    icon={<Category />}
                                    label={article?.category && typeof article?.category === 'object' ? (article.category.name || article.category.label || 'Uncategorized') : 'Uncategorized'}
                                    sx={{ bgcolor: '#0f172a', color: '#f59e0b', border: '1px solid #f59e0b' }}
                                />
                                <Chip
                                    size="small"
                                    label={article?.status?.label || article?.status?.name || 'Status'}
                                    sx={{ bgcolor: isNeedsRevision ? '#ef4444' : '#94a3b8', color: '#fff' }}
                                />
                            </Box>
                        </Box>

                        <Box sx={{ display: 'flex', gap: 1 }}>
                            <Button 
                                onClick={() => setChatOpen(true)}
                                sx={{ 
                                    color: '#60a5fa',
                                    borderColor: '#60a5fa',
                                    '&:hover': { borderColor: '#3b82f6', color: '#3b82f6' }
                                }}
                            >
                                Open Chat
                            </Button>
                            <Button
                                onClick={() => router.get('/writer/dashboard')}
                                startIcon={<ArrowBack />}
                                sx={{ 
                                    color: '#94a3b8',
                                    borderColor: '#334155',
                                    '&:hover': { borderColor: '#60a5fa', color: '#60a5fa' }
                                }}
                            >
                                Back to Dashboard
                            </Button>
                        </Box>
                    </Box>

                    {/* Flash Messages */}
                    {(flash?.success || flash?.error) && (
                        <Box sx={{ mb: 3 }}>
                            <Paper sx={{ 
                                p: 2, 
                                backgroundColor: flash?.success ? '#10b981' : '#ef4444', 
                                color: '#fff'
                            }}>
                                <Typography>{flash?.success || flash?.error}</Typography>
                            </Paper>
                        </Box>
                    )}

                    {/* Editor Feedback */}
                    {isNeedsRevision && latestRevisionComment && (
                        <Paper sx={{ 
                            p: 3, 
                            mb: 3, 
                            backgroundColor: '#1e293b',
                            border: '1px solid #334155',
                            borderLeft: '4px solid #ef4444'
                        }}>
                            <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 1, color: '#ef4444' }}>
                                Editor Feedback
                            </Typography>
                            <Typography variant="body1" sx={{ color: '#94a3b8' }}>
                                {latestRevisionComment}
                            </Typography>
                        </Paper>
                    )}

                    {/* Edit Form */}
                    <Paper sx={{ p: 4, backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                        <Grid container spacing={3}>
                            <Grid item xs={12} md={8}>
                                <TextField
                                    fullWidth
                                    label="Article Title"
                                    value={formData.title}
                                    onChange={(e) => handleInputChange('title', e.target.value)}
                                    required
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
                            <Grid item xs={12} md={4}>
                                <FormControl fullWidth required>
                                    <InputLabel sx={{ color: '#94a3b8' }}>Category</InputLabel>
                                    <Select
                                        value={formData.category_id}
                                        label="Category"
                                        onChange={(e) => handleInputChange('category_id', e.target.value)}
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
                                        {categories.map((category) => (
                                            <MenuItem key={category.id} value={category.id}>
                                                {category.name}
                                            </MenuItem>
                                        ))}
                                    </Select>
                                </FormControl>
                            </Grid>

                            <Grid item xs={12}>
                                <Divider sx={{ backgroundColor: '#334155', mb: 2 }} />
                                <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1, color: '#ffffff' }}>
                                    Content
                                </Typography>
                                <Box sx={{ 
                                    border: '1px solid #334155',
                                    borderRadius: 1,
                                    '& .jodit-container': {
                                        backgroundColor: '#0f172a !important',
                                    }
                                }}>
                                    <JoditEditorComponent
                                        value={formData.content}
                                        onChange={handleContentChange}
                                        placeholder="Write your article content here..."
                                    />
                                </Box>
                            </Grid>

                            <Grid item xs={12}>
                                <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2, mt: 1 }}>
                                    {!isNeedsRevision && (
                                        <Button
                                            variant="contained"
                                            startIcon={<Save />}
                                            onClick={handleSaveDraft}
                                            sx={{ 
                                                bgcolor: '#60a5fa',
                                                '&:hover': { bgcolor: '#3b82f6' }
                                            }}
                                        >
                                            Save Changes
                                        </Button>
                                    )}

                                    {isNeedsRevision && (
                                        <Button
                                            variant="contained"
                                            startIcon={<Send />}
                                            onClick={handleResubmitRevision}
                                            sx={{ 
                                                bgcolor: '#ef4444',
                                                '&:hover': { bgcolor: '#dc2626' }
                                            }}
                                        >
                                            Revise & Resubmit
                                        </Button>
                                    )}
                                </Box>
                            </Grid>
                        </Grid>
                    </Paper>
                </Box>

                {/* Chat Dialog */}
                <Dialog open={chatOpen} onClose={() => setChatOpen(false)} maxWidth="sm" fullWidth>
                    <DialogTitle sx={{ backgroundColor: '#1e293b', color: '#ffffff' }}>
                        Article Discussion
                    </DialogTitle>
                    <DialogContent sx={{ backgroundColor: '#1e293b', color: '#ffffff' }}>
                        <Box sx={{ minHeight: 260, maxHeight: 360, overflowY: 'auto', mb: 2 }}>
                            {chatLoading && (
                                <Box sx={{ display: 'flex', justifyContent: 'center', py: 2 }}>
                                    <CircularProgress size={24} sx={{ color: '#60a5fa' }} />
                                </Box>
                            )}
                            {!chatLoading && chatMessages.length === 0 && (
                                <Typography variant="body2" sx={{ color: '#94a3b8', py: 2 }}>
                                    No messages yet. Start the conversation.
                                </Typography>
                            )}
                            {!chatLoading && chatMessages.length > 0 && (
                                <List dense>
                                    {chatMessages.map((m) => (
                                        <ListItem key={m.id} alignItems="flex-start" disableGutters>
                                            <ListItemText
                                                primary={m.sender?.name || 'User'}
                                                primaryTypographyProps={{ color: '#ffffff' }}
                                                secondary={m.message}
                                                secondaryTypographyProps={{ color: '#94a3b8' }}
                                            />
                                        </ListItem>
                                    ))}
                                </List>
                            )}
                        </Box>

                        <TextField
                            fullWidth
                            multiline
                            minRows={2}
                            label="Message"
                            value={chatText}
                            onChange={(e) => setChatText(e.target.value)}
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
                    </DialogContent>
                    <DialogActions sx={{ backgroundColor: '#1e293b' }}>
                        <Button onClick={() => setChatOpen(false)} sx={{ color: '#94a3b8' }}>
                            Close
                        </Button>
                        <Button 
                            onClick={sendChat} 
                            variant="contained"
                            disabled={chatLoading || !chatText.trim()}
                            sx={{ 
                                bgcolor: '#60a5fa',
                                '&:hover': { bgcolor: '#3b82f6' },
                                '&:disabled': { bgcolor: '#374151' }
                            }}
                        >
                            Send
                        </Button>
                    </DialogActions>
                </Dialog>
            </Box>
        </ThemeProvider>
    );
};

export default WriterEdit;
