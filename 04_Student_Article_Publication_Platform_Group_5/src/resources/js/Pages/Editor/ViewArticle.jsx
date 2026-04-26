import React, { useState, useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Typography,
    Box,
    Button,
    Card,
    CardContent,
    Avatar,
    IconButton,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    Chip,
    Container,
    Fade,
    Paper,
    alpha
} from '@mui/material';
import { useThemeContext } from '@/Context/ThemeContext';
import BackToDashboard from '@/Components/BackToDashboard';
import ThemeToggle from '@/Components/ThemeToggle';
import {
    Person,
    Category,
    Schedule,
    ArrowBack,
    Menu as MenuIcon,
    Logout,
    Share,
    Edit,
    Visibility
} from '@mui/icons-material';
import JoditEditor from 'jodit-react';

const ViewArticle = ({ article }) => {
    const { mode } = useThemeContext();
    const { auth } = usePage().props;
    const [anchorEl, setAnchorEl] = useState(null);
    const [mounted, setMounted] = useState(false);

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

    const handleShare = () => {
        if (navigator.share) {
            navigator.share({
                title: article?.title,
                text: article?.excerpt || 'Check out this article',
                url: window.location.href
            });
        } else {
            navigator.clipboard.writeText(window.location.href);
        }
    };

    const handleEdit = () => {
        router.get(`/editor/articles/${article.id}/review`);
    };

    const config = {
        readonly: true,
        placeholder: '',
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
            <Head title={`View: ${article?.title || 'Article'}`} />
            
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
                            Published Article
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

            {/* Article Content */}
            <Box sx={{ p: 3 }}>
                <Fade in={mounted} timeout={800}>
                    <Box sx={{ 
                        background: mode === 'dark' ? 'rgba(30, 41, 59, 0.9)' : 
                                   mode === 'galaxy' ? 'rgba(15, 23, 42, 0.9)' : 
                                   'rgba(30, 41, 59, 0.9)',
                        border: mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                 mode === 'galaxy' ? '1px solid rgba(139, 92, 246, 0.2)' : 
                                 '1px solid rgba(148, 163, 184, 0.1)',
                        borderRadius: 3,
                        overflow: 'hidden'
                    }}>
                        {/* Article Header */}
                        <Box sx={{ 
                            p: 4, 
                            borderBottom: mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                            mode === 'galaxy' ? '1px solid rgba(139, 92, 246, 0.2)' : 
                                            '1px solid rgba(148, 163, 184, 0.1)',
                            background: mode === 'dark' ? 'rgba(248, 250, 252, 0.05)' : 
                                         mode === 'galaxy' ? 'rgba(248, 250, 252, 0.05)' : 
                                         'rgba(248, 250, 252, 0.05)'
                        }}>
                            <Typography variant="h3" sx={{ 
                                color: mode === 'dark' ? '#f8fafc' : 
                                       mode === 'galaxy' ? '#e0e7ff' : 
                                       '#f8fafc', 
                                fontWeight: 700, 
                                mb: 3 
                            }}>
                                {article?.title || 'Untitled Article'}
                            </Typography>
                            
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 3, mb: 3 }}>
                                <Avatar sx={{ 
                                    bgcolor: alpha('#06b6d4', 0.2),
                                    color: '#06b6d4',
                                    width: 56,
                                    height: 56
                                }}>
                                    <Person />
                                </Avatar>
                                <Box>
                                    <Typography variant="h6" sx={{ 
                                        color: mode === 'dark' ? '#f8fafc' : 
                                               mode === 'galaxy' ? '#e0e7ff' : 
                                               '#f8fafc', 
                                        fontWeight: 600 
                                    }}>
                                        {article?.writer?.name || 'Unknown Writer'}
                                    </Typography>
                                    <Typography variant="body2" sx={{ 
                                        color: mode === 'dark' ? '#94a3b8' : 
                                               mode === 'galaxy' ? '#a78bfa' : 
                                               '#94a3b8' 
                                    }}>
                                        {article?.writer?.email || 'No email'}
                                    </Typography>
                                </Box>
                            </Box>

                            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mb: 3 }}>
                                <Chip
                                    icon={<Category />}
                                    label={article?.category && typeof article?.category === 'object' ? (article.category.name || article.category.label || 'Uncategorized') : 'Uncategorized'}
                                    size="medium"
                                    sx={{ 
                                        backgroundColor: mode === 'dark' ? 'rgba(16, 185, 129, 0.2)' : 
                                                       mode === 'galaxy' ? 'rgba(16, 185, 129, 0.2)' : 
                                                       'rgba(16, 185, 129, 0.2)',
                                        color: '#10b981',
                                        border: mode === 'dark' ? '1px solid rgba(16, 185, 129, 0.4)' : 
                                                 mode === 'galaxy' ? '1px solid rgba(16, 185, 129, 0.4)' : 
                                                 '1px solid rgba(16, 185, 129, 0.4)'
                                    }}
                                />
                                <Chip
                                    icon={<Schedule />}
                                    label={`Published: ${new Date(article?.updated_at || article?.created_at).toLocaleDateString()}`}
                                    size="medium"
                                    sx={{ 
                                        backgroundColor: mode === 'dark' ? 'rgba(6, 182, 212, 0.2)' : 
                                                       mode === 'galaxy' ? 'rgba(6, 182, 212, 0.2)' : 
                                                       'rgba(6, 182, 212, 0.2)',
                                        color: '#06b6d4',
                                        border: mode === 'dark' ? '1px solid rgba(6, 182, 212, 0.4)' : 
                                                 mode === 'galaxy' ? '1px solid rgba(6, 182, 212, 0.4)' : 
                                                 '1px solid rgba(6, 182, 212, 0.4)'
                                    }}
                                />
                            </Box>

                            {/* Action Buttons */}
                            <Box sx={{ display: 'flex', gap: 2 }}>
                                <Button
                                    variant="contained"
                                    startIcon={<Edit />}
                                    onClick={handleEdit}
                                    sx={{
                                        background: 'linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%)',
                                        '&:hover': {
                                            background: 'linear-gradient(135deg, #1d4ed8 0%, #1e40af 100%)',
                                        }
                                    }}
                                >
                                    Edit Article
                                </Button>
                                <Button
                                    variant="outlined"
                                    startIcon={<Share />}
                                    onClick={handleShare}
                                    sx={{
                                        borderColor: mode === 'dark' ? '#06b6d4' : 
                                                     mode === 'galaxy' ? '#8b5cf6' : 
                                                     '#06b6d4',
                                        color: mode === 'dark' ? '#06b6d4' : 
                                               mode === 'galaxy' ? '#8b5cf6' : 
                                               '#06b6d4',
                                        '&:hover': {
                                            borderColor: mode === 'dark' ? '#0891b2' : 
                                                         mode === 'galaxy' ? '#7c3aed' : 
                                                         '#0891b2',
                                            backgroundColor: alpha(mode === 'dark' ? '#06b6d4' : 
                                                            mode === 'galaxy' ? '#8b5cf6' : 
                                                            '#06b6d4', 0.1)
                                        }
                                    }}
                                >
                                    Share
                                </Button>
                            </Box>
                        </Box>

                        {/* Article Content */}
                        <Box sx={{ p: 4 }}>
                            <JoditEditor
                                value={article?.content || ''}
                                config={config}
                                tabIndex={1}
                            />
                        </Box>
                    </Box>
                </Fade>
            </Box>

            {/* User Menu */}
            <Menu
                anchorEl={anchorEl}
                open={Boolean(anchorEl)}
                onClose={handleMenuClose}
                PaperProps={{
                    sx: {
                        background: mode === 'dark' ? '#1e293b' : 
                                     mode === 'galaxy' ? 'rgba(15, 23, 42, 0.9)' : 
                                     '#1e293b',
                        border: mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                 mode === 'galaxy' ? '1px solid rgba(139, 92, 246, 0.2)' : 
                                 '1px solid rgba(148, 163, 184, 0.1)',
                        mt: 1
                    }
                }}
            >
                <MenuItem sx={{ color: mode === 'dark' ? '#f8fafc' : 
                                       mode === 'galaxy' ? '#e0e7ff' : 
                                       '#f8fafc' }}>
                    <ListItemIcon>
                        <Person sx={{ color: mode === 'dark' ? '#94a3b8' : 
                                             mode === 'galaxy' ? '#a78bfa' : 
                                             '#94a3b8' }} />
                    </ListItemIcon>
                    {auth?.user?.name || 'Unknown User'}
                </MenuItem>
                <Divider />
                <MenuItem onClick={() => router.post('/logout')} sx={{ color: mode === 'dark' ? '#f8fafc' : 
                                                                               mode === 'galaxy' ? '#e0e7ff' : 
                                                                               '#f8fafc' }}>
                    <ListItemIcon>
                        <Logout sx={{ color: mode === 'dark' ? '#94a3b8' : 
                                           mode === 'galaxy' ? '#a78bfa' : 
                                           '#94a3b8' }} />
                    </ListItemIcon>
                    Logout
                </MenuItem>
            </Menu>
        </Box>
    );
};

export default ViewArticle;
