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
    Divider
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

const PublishedArticles = ({ published }) => {
    const [anchorEl, setAnchorEl] = useState(null);

    const { flash } = usePage().props;

    // Ensure we have arrays even if props are undefined
    const publishedArray = Array.isArray(published) ? published : [];

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

    const handleViewArticle = (article) => {
        router.get(`/editor/articles/${article.id}/review`);
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
                        bgcolor: '#10b981', 
                        width: 48, 
                        height: 48,
                        mr: 2,
                        boxShadow: '0 4px 8px rgba(0,0,0,0.2)'
                    }}
                >
                    <Publish sx={{ color: '#fff' }} />
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
                            sx={{ fontWeight: 'bold', bgcolor: '#10b981', color: '#fff' }}
                        />
                        <Typography variant="body2" sx={{ fontSize: '0.875rem', color: '#94a3b8' }}>
                            By {article.writer?.name}
                        </Typography>
                        <Typography variant="body2" sx={{ fontSize: '0.875rem', color: '#94a3b8' }}>
                            Category: {article.category && typeof article.category === 'object' ? (article.category.name || article.category.label || 'Uncategorized') : 'Uncategorized'}
                        </Typography>
                    </Box>
                    {article.published_at && (
                        <Typography variant="body2" sx={{ color: '#10b981', fontSize: '0.8rem' }}>
                            Published on {new Date(article.published_at).toLocaleDateString()}
                        </Typography>
                    )}
                </Box>
            </Box>
            
            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                <Tooltip title="View article details">
                    <Button
                        size="small"
                        onClick={() => handleViewArticle(article)}
                        sx={{ 
                            bgcolor: '#60a5fa', 
                            color: '#fff',
                            '&:hover': { bgcolor: '#3b82f6' }
                        }}
                    >
                        View Article
                    </Button>
                </Tooltip>
            </Box>
        </Paper>
    );

    return (
        <ThemeProvider theme={theme}>
            <Head title="Published Articles - Editor" />
            
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
                                Published Articles
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
                    <MenuItem onClick={handleMenuClose}>
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
                                        backgroundColor: '#10b981',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        boxShadow: '0 4px 12px rgba(0,0,0,0.3)'
                                    }}>
                                        <Publish sx={{ color: '#fff' }} />
                                    </Box>
                                    <Box sx={{ flexGrow: 1 }}>
                                        <Typography variant="h4" sx={{ fontWeight: 'bold', color: '#10b981', mb: 1 }}>
                                            Published Articles
                                        </Typography>
                                        <Typography variant="body1" sx={{ color: '#94a3b8', mb: 2 }}>
                                            Articles that have been approved and are now live for students to read
                                        </Typography>
                                        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                                            <Chip 
                                                label={`${publishedArray.length} articles`}
                                                sx={{ 
                                                    backgroundColor: '#10b981', 
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
                            {publishedArray.length === 0 ? (
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
                                        <Publish sx={{ color: '#10b981' }} />
                                    </Box>
                                    <Typography variant="h5" sx={{ color: '#94a3b8', mb: 2 }}>
                                        No published articles
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: '#64748b' }}>
                                        Published articles will appear here once approved.
                                    </Typography>
                                </Paper>
                            ) : (
                                <Box>
                                    {publishedArray.map((article) => (
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
            </Box>
        </ThemeProvider>
    );
};

export default PublishedArticles;
