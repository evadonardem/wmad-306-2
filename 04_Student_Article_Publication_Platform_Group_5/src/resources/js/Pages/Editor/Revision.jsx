import React, { useState } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Typography,
    Box,
    Button,
    Chip,
    Paper,
    Avatar,
    IconButton,
    Tooltip,
    Fade,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions
} from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import {
    RateReview,
    Publish,
    Person,
    Logout,
    ArrowBack,
    Assignment,
    Edit,
    Menu as MenuIcon,
    Visibility
} from '@mui/icons-material';

const NeedsRevision = ({ needsRevision }) => {
    const [anchorEl, setAnchorEl] = useState(null);
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [revisionDialog, setRevisionDialog] = useState(false);
    const [revisionComments, setRevisionComments] = useState('');
    const [profileDialog, setProfileDialog] = useState(false);

    const { flash, auth } = usePage().props;

    // Ensure we have arrays even if props are undefined
    const revisionArray = Array.isArray(needsRevision) ? needsRevision : [];

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

    const handleProfileOpen = () => {
        setProfileDialog(true);
        handleMenuClose();
    };

    const handleProfileClose = () => {
        setProfileDialog(false);
    };

    const handleLogout = () => {
        router.post('/logout', {}, {
            onFinish: () => {
                handleMenuClose();
            }
        });
    };

    const handleReview = (article) => {
        router.get(`/editor/articles/${article.id}/review`);
    };

    const openRevisionDialog = (article) => {
        setSelectedArticle(article);
        setRevisionDialog(true);
    };

    const handleRequestRevision = () => {
        if (selectedArticle && revisionComments.trim()) {
            router.post(`/editor/articles/${selectedArticle.id}/revision`, {
                comments: revisionComments
            }, {
                onSuccess: () => {
                    setRevisionDialog(false);
                    setRevisionComments('');
                    setSelectedArticle(null);
                },
                onError: (errors) => {
                    console.error('Revision request failed:', errors);
                    alert('Failed to send revision request. Please try again.');
                }
            });
        } else {
            alert('Please provide revision comments before submitting.');
        }
    };

    const ArticleCard = ({ article }) => (
        <Paper 
            sx={{ 
                p: 3, 
                mb: 2, 
                borderRadius: 3,
                backgroundColor: '#1e293b',
                color: '#ffffff',
                border: '1px solid #334155',
                '&:hover': {
                    backgroundColor: '#334155',
                    transform: 'translateY(-2px)',
                    transition: 'all 0.2s ease-in-out'
                }
            }}
        >
            <Box sx={{ display: 'flex', alignItems: 'flex-start', mb: 2 }}>
                <Avatar 
                    sx={{ 
                        bgcolor: '#ef4444', 
                        width: 48, 
                        height: 48,
                        mr: 2,
                        boxShadow: '0 4px 8px rgba(0,0,0,0.2)'
                    }}
                >
                    <Edit sx={{ color: '#fff' }} />
                </Avatar>
                <Box sx={{ flexGrow: 1 }}>
                    <Typography variant="h6" component="div" sx={{ fontWeight: 'bold', mb: 0.5, lineHeight: 1.2, color: '#ffffff' }}>
                        {article.title}
                    </Typography>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                        <Chip 
                            label={typeof article.status === 'string' ? article.status : (article.status && typeof article.status === 'object' ? (article.status.label || article.status.name || 'unknown') : 'unknown')}
                            color="default"
                            size="small"
                            sx={{ fontWeight: 'bold', bgcolor: '#ef4444', color: '#fff' }}
                        />
                        <Typography variant="body2" sx={{ fontSize: '0.875rem', color: '#94a3b8' }}>
                            By {article.writer?.name}
                        </Typography>
                        <Typography variant="body2" sx={{ fontSize: '0.875rem', color: '#94a3b8' }}>
                            Category: {article.category && typeof article.category === 'object' ? (article.category.name || article.category.label || 'Uncategorized') : 'Uncategorized'}
                        </Typography>
                    </Box>
                    {article.revisions && article.revisions.length > 0 && (
                        <Box sx={{ mt: 1, p: 2, backgroundColor: '#0f172a', borderRadius: 1, border: '1px solid #334155' }}>
                            <Typography variant="body2" sx={{ color: '#ffffff', mb: 1, fontWeight: 'bold' }}>
                                Latest revision request:
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#ffffff', fontStyle: 'italic' }}>
                                "{article.revisions[article.revisions.length - 1].comments}"
                            </Typography>
                        </Box>
                    )}
                </Box>
            </Box>
            
            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                <Tooltip title="View article details">
                    <Button
                        size="small"
                        onClick={() => handleReview(article)}
                        sx={{ 
                            bgcolor: '#60a5fa', 
                            color: '#fff',
                            '&:hover': { bgcolor: '#3b82f6' }
                        }}
                    >
                        View Details
                    </Button>
                </Tooltip>
                
                <Tooltip title="Request additional revision">
                    <Button
                        size="small"
                        onClick={() => openRevisionDialog(article)}
                        sx={{ 
                            bgcolor: '#f59e0b', 
                            color: '#fff',
                            '&:hover': { bgcolor: '#d97706' }
                        }}
                    >
                        Request Revision
                    </Button>
                </Tooltip>
            </Box>
        </Paper>
    );

    return (
        <ThemeProvider theme={theme}>
            <Head title="Needs Revision - Editor" />
            
            {/* Background */}
            <Box
                sx={{
                    minHeight: "100vh",
                    width: "100%",
                    background: "linear-gradient(135deg,#0f172a,#1e293b,#334155)",
                    position: "relative",
                    overflow: "hidden"
                }}
            >
                {/* Floating Balls */}
                {[...Array(10)].map((_, i) => (
                    <Box
                        key={i}
                        sx={{
                            position: "absolute",
                            width: 60,
                            height: 60,
                            borderRadius: "50%",
                            background: "linear-gradient(135deg,#60a5fa,#22d3ee)",
                            opacity: 0.3,
                            top: `${Math.random() * 100}%`,
                            left: `${Math.random() * 100}%`
                        }}
                    />
                ))}

                {/* Header with Menu */}
                <Box sx={{ position: 'fixed', top: 0, left: 0, right: 0, zIndex: 1300, backgroundColor: '#0f172a', borderBottom: '1px solid #334155' }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', p: 2 }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                            <IconButton onClick={() => router.get('/editor/dashboard')} sx={{ color: '#ffffff' }}>
                                <ArrowBack />
                            </IconButton>
                            <Typography variant="h4" sx={{ fontWeight: 'bold', color: '#ffffff' }}>
                                Needs Revision
                            </Typography>
                        </Box>
                        
                        <IconButton color="inherit" onClick={handleMenuOpen} sx={{ color: '#ffffff' }}>
                            <MenuIcon />
                        </IconButton>
                    </Box>
                </Box>

                {/* Menu Dropdown */}
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
                    <MenuItem onClick={handleProfileOpen}>
                        <ListItemIcon>
                            <Person sx={{ color: '#60a5fa' }} />
                        </ListItemIcon>
                        Profile
                    </MenuItem>
                    
                    {/* Role Switcher */}
                    <Divider sx={{ backgroundColor: '#334155' }} />
                    <MenuItem onClick={() => { router.get('/writer/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Edit sx={{ color: '#f59e0b' }} />
                        </ListItemIcon>
                        Switch to Writer
                    </MenuItem>
                    <MenuItem onClick={() => { router.get('/student/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <Visibility sx={{ color: '#10b981' }} />
                        </ListItemIcon>
                        Switch to Student
                    </MenuItem>
                    <MenuItem onClick={() => { router.get('/editor/dashboard'); handleMenuClose(); }}>
                        <ListItemIcon>
                            <RateReview sx={{ color: '#ef4444' }} />
                        </ListItemIcon>
                        Switch to Editor
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
                <Box sx={{ pt: 15, px: 3, pb: 3 }}>
                    <Fade in={true} timeout={800}>
                        <Box>
                            {flash?.success && (
                                <Box sx={{ mb: 3 }}>
                                    <Paper 
                                        sx={{ 
                                            p: 3, 
                                            backgroundColor: '#10b981', 
                                            color: '#fff',
                                            borderRadius: 2,
                                            display: 'flex',
                                            alignItems: 'center',
                                            border: '1px solid #34d399'
                                        }}
                                    >
                                        <Typography variant="h6" sx={{ mr: 2 }}>
                                            ✓ Success
                                        </Typography>
                                        <Typography variant="body1">
                                            {flash.success}
                                        </Typography>
                                    </Paper>
                                </Box>
                            )}
                            
                            {/* Info Box */}
                            <Paper sx={{ p: 4, backgroundColor: '#1e293b', border: '1px solid #334155', mb: 3 }}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 3, mb: 3 }}>
                                    <Box sx={{ 
                                        width: 60, 
                                        height: 60, 
                                        borderRadius: '50%', 
                                        backgroundColor: '#ef4444',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        boxShadow: '0 4px 12px rgba(0,0,0,0.3)'
                                    }}>
                                        <Edit sx={{ color: '#fff' }} />
                                    </Box>
                                    <Box sx={{ flexGrow: 1 }}>
                                        <Typography variant="h4" sx={{ fontWeight: 'bold', color: '#ef4444', mb: 1 }}>
                                            Needs Revision
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: '#94a3b8', mb: 2 }}>
                                            Articles that have been sent back to writers for revisions and updates
                                        </Typography>
                                        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                                            <Chip 
                                                label={`${revisionArray.length} articles`}
                                                sx={{ 
                                                    backgroundColor: '#ef4444', 
                                                    color: '#fff',
                                                    fontWeight: 'bold'
                                                }} 
                                            />
                                            <Chip 
                                                label={`Last updated: ${new Date().toLocaleDateString()}`}
                                                sx={{ 
                                                    backgroundColor: '#0f172a', 
                                                    color: '#94a3b8',
                                                    borderColor: '#334155',
                                                    border: '1px solid'
                                                }} 
                                            />
                                        </Box>
                                    </Box>
                                </Box>
                            </Paper>

                            {/* Articles List */}
                            {revisionArray.length === 0 ? (
                                <Paper sx={{ p: 6, textAlign: 'center', backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                                    <Box sx={{ 
                                        width: 80, 
                                        height: 80, 
                                        borderRadius: '50%', 
                                        backgroundColor: '#0f172a',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        mx: 'auto',
                                        mb: 3
                                    }}>
                                        <Edit sx={{ color: '#ef4444' }} />
                                    </Box>
                                    <Typography variant="h5" sx={{ color: '#94a3b8', mb: 2 }}>
                                        No articles need revision
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#64748b' }}>
                                        Articles requiring revisions will appear here once sent back.
                                    </Typography>
                                </Paper>
                            ) : (
                                <Box>
                                    {revisionArray.map((article) => (
                                        <ArticleCard
                                            key={article.id}
                                            article={article}
                                        />
                                    ))}
                                </Box>
                            )}
                        </Box>
                    </Fade>
                </Box>

                {/* Revision Dialog */}
                <Dialog open={revisionDialog} onClose={() => setRevisionDialog(false)} maxWidth="md" fullWidth>
                    <DialogTitle sx={{ backgroundColor: '#1e293b', color: '#ffffff', borderBottom: '1px solid #334155' }}>
                        Request Additional Revision for "{selectedArticle?.title}"
                    </DialogTitle>
                    <DialogContent sx={{ backgroundColor: '#1e293b', color: '#ffffff' }}>
                        <TextField
                            fullWidth
                            multiline
                            rows={4}
                            label="Revision Comments"
                            value={revisionComments}
                            onChange={(e) => setRevisionComments(e.target.value)}
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
                    <DialogActions sx={{ backgroundColor: '#1e293b', borderTop: '1px solid #334155' }}>
                        <Button onClick={() => setRevisionDialog(false)} sx={{ color: '#94a3b8' }}>
                            Cancel
                        </Button>
                        <Button 
                            onClick={handleRequestRevision} 
                            variant="contained"
                            sx={{ 
                                bgcolor: '#60a5fa', 
                                color: '#fff',
                                '&:hover': { bgcolor: '#3b82f6' }
                            }}
                        >
                            Send Revision Request
                        </Button>
                    </DialogActions>
                </Dialog>

                {/* Profile Dialog */}
                <Dialog open={profileDialog} onClose={handleProfileClose} maxWidth="sm" fullWidth>
                    <DialogTitle sx={{ backgroundColor: '#1e293b', color: '#ffffff', borderBottom: '1px solid #334155' }}>
                        User Profile
                    </DialogTitle>
                    <DialogContent sx={{ backgroundColor: '#1e293b', color: '#ffffff' }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3, mt: 2 }}>
                            <Avatar sx={{ width: 64, height: 64, bgcolor: '#60a5fa', mr: 3 }}>
                                {auth?.user?.name?.charAt(0) || 'U'}
                            </Avatar>
                            <Box>
                                <Typography variant="h6" sx={{ color: '#ffffff', mb: 0.5 }}>
                                    {auth?.user?.name || 'Unknown User'}
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                    {auth?.user?.email || 'No email'}
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#94a3b8', mt: 1 }}>
                                    Role: Editor
                                </Typography>
                            </Box>
                        </Box>
                        
                        <Divider sx={{ backgroundColor: '#334155', mb: 3 }} />
                        
                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                            <Box>
                                <Typography variant="body2" sx={{ color: '#94a3b8', mb: 0.5 }}>
                                    Account Status
                                </Typography>
                                <Chip 
                                    label="Active" 
                                    size="small" 
                                    sx={{ bgcolor: '#10b981', color: '#fff' }} 
                                />
                            </Box>
                            
                            <Box>
                                <Typography variant="body2" sx={{ color: '#94a3b8', mb: 0.5 }}>
                                    Member Since
                                </Typography>
                                <Typography variant="body1" sx={{ color: '#ffffff' }}>
                                    {auth?.user?.created_at ? new Date(auth.user.created_at).toLocaleDateString() : 'Unknown'}
                                </Typography>
                            </Box>
                        </Box>
                    </DialogContent>
                    <DialogActions sx={{ backgroundColor: '#1e293b', borderTop: '1px solid #334155' }}>
                        <Button onClick={handleProfileClose} sx={{ color: '#94a3b8' }}>
                            Close
                        </Button>
                        <Button 
                            onClick={() => router.get('/profile.edit')}
                            variant="contained"
                            sx={{ 
                                bgcolor: '#60a5fa', 
                                color: '#fff',
                                '&:hover': { bgcolor: '#3b82f6' }
                            }}
                        >
                            Edit Profile
                        </Button>
                    </DialogActions>
                </Dialog>
            </Box>
        </ThemeProvider>
    );
};

export default NeedsRevision;
