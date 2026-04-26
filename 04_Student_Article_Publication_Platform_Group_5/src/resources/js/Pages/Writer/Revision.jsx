import React, { useState, useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Container,
    Typography,
    Box,
    Button,
    Chip,
    Card,
    CardContent,
    Avatar,
    IconButton,
    Fade,
    Menu,
    MenuItem,
    ListItemIcon,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    alpha
} from '@mui/material';
import {
    Edit,
    Person,
    Logout,
    ArrowBack,
    Assignment,
    Menu as MenuIcon,
    Visibility,
    Send,
    RateReview,
    Description
} from '@mui/icons-material';
import { useThemeContext } from '@/Context/ThemeContext';
import BackToDashboard from '@/Components/BackToDashboard';
import ThemeToggle from '@/Components/ThemeToggle';
import JoditEditorComponent from '@/Components/JoditEditor';

const WriterRevision = ({ needsRevision }) => {
    const { mode } = useThemeContext();
    const [anchorEl, setAnchorEl] = useState(null);
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [reviseDialog, setReviseDialog] = useState(false);
    const [articleContent, setArticleContent] = useState('');
    const [mounted, setMounted] = useState(false);

    const { flash, auth } = usePage().props;

    // Ensure we have arrays even if props are undefined
    const revisionArray = Array.isArray(needsRevision) ? needsRevision : [];

    useEffect(() => {
        setMounted(true);
    }, []);

    useEffect(() => {
        // Set theme attribute on JoditEditor containers
        const joditContainers = document.querySelectorAll('.jodit-container');
        joditContainers.forEach(container => {
            container.setAttribute('data-theme', mode);
        });
    }, [mode]);

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

    const openReviseDialog = (article) => {
        setSelectedArticle(article);
        setArticleContent(article.content?.replace(/<p><\/p>/g, '') || '');
        setReviseDialog(true);
    };

    const handleReviseArticle = () => {
        if (selectedArticle && articleContent.trim()) {
            // Clean content before submitting
            const cleanContent = articleContent.replace(/<p><\/p>/g, '');
            
            router.put(`/writer/articles/${selectedArticle.id}/revise`, {
                content: cleanContent
            }, {
                onSuccess: () => {
                    setReviseDialog(false);
                    setArticleContent('');
                    setSelectedArticle(null);
                    // Navigate to revision page to see updated status
                    router.get('/writer/revision');
                },
                onError: (errors) => {
                    console.error('Revision failed:', errors);
                    alert('Failed to revise article. Please try again.');
                }
            });
        } else {
            alert('Please provide revised content before submitting.');
        }
    };

    const handleResubmitArticle = (article) => {
        if (confirm('Are you sure you want to resubmit this article for editor review?')) {
            // Change status from 'needs_revision' back to 'submitted'
            router.put(`/writer/articles/${article.id}/resubmit`, {}, {
                onSuccess: () => {
                    // Navigate to revision page to see updated status
                    router.get('/writer/revision');
                },
                onError: (errors) => {
                    console.error('Resubmit failed:', errors);
                    alert('Failed to resubmit article. Please try again.');
                }
            });
        }
    };

    const handleViewArticle = (article) => {
        router.get(`/writer/articles/${article.id}`);
    };

    return (
        <>
            <Head title="Articles Needing Revision" />
            
            <Box sx={{
                minHeight: "100vh",
                display: 'flex',
                flexDirection: 'column',
                background: mode === 'light' ? 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)' :
                           mode === 'dark' ? 'radial-gradient(circle at 20% 50%, rgba(245, 158, 11, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(6, 182, 212, 0.05) 0%, transparent 50%), #0a0e27' :
                           'radial-gradient(circle at 20% 50%, rgba(139, 92, 246, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(236, 72, 153, 0.05) 0%, transparent 50%), #000000',
                position: 'relative',
                overflow: 'hidden'
            }}>
                {/* Animated Background Elements */}
                <Box sx={{
                    position: 'absolute',
                    width: 400,
                    height: 400,
                    borderRadius: '50%',
                    background: mode === 'light' ? 'linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(147, 51, 234, 0.05) 100%)' :
                               mode === 'dark' ? 'linear-gradient(135deg, rgba(245, 158, 11, 0.2) 0%, rgba(6, 182, 212, 0.1) 100%)' :
                               'linear-gradient(135deg, rgba(139, 92, 246, 0.2) 0%, rgba(236, 72, 153, 0.1) 100%)',
                    top: '-200px',
                    right: '-200px',
                    filter: 'blur(40px)',
                    animation: 'float 6s ease-in-out infinite'
                }} />
                <Box sx={{
                    position: 'absolute',
                    width: 300,
                    height: 300,
                    borderRadius: '50%',
                    background: mode === 'light' ? 'linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(6, 182, 212, 0.05) 100%)' :
                               mode === 'dark' ? 'linear-gradient(135deg, rgba(6, 182, 212, 0.15) 0%, rgba(245, 158, 11, 0.08) 100%)' :
                               'linear-gradient(135deg, rgba(236, 72, 153, 0.15) 0%, rgba(139, 92, 246, 0.08) 100%)',
                    bottom: '-150px',
                    left: '-150px',
                    filter: 'blur(30px)',
                    animation: 'float 8s ease-in-out infinite reverse'
                }} />

                {/* Header */}
                <Container maxWidth="lg" sx={{ py: 3, position: 'relative', zIndex: 2 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 4 }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                            <BackToDashboard dashboardRoute="/writer/dashboard" label="Back to Writer Dashboard" />
                            <Typography variant="h4" sx={{ 
                                color: mode === 'light' ? '#1e293b' : 
                                       mode === 'dark' ? '#f8fafc' : '#f8fafc',
                                fontWeight: 700,
                                background: mode === 'light' ? 'linear-gradient(135deg, #3b82f6 0%, #10b981 100%)' : 
                                               mode === 'dark' ? 'linear-gradient(135deg, #10b981 0%, #f59e0b 100%)' : 
                                               'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                WebkitBackgroundClip: 'text',
                                WebkitTextFillColor: 'transparent',
                                backgroundClip: 'text'
                            }}>
                                Articles Needing Revision
                            </Typography>
                        </Box>
                        
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                            <ThemeToggle />
                            <IconButton
                                onClick={handleMenuOpen}
                                sx={{ 
                                    color: mode === 'light' ? '#64748b' : 
                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                                }}
                            >
                                <MenuIcon />
                            </IconButton>
                            <Menu
                                anchorEl={anchorEl}
                                open={Boolean(anchorEl)}
                                onClose={handleMenuClose}
                                PaperProps={{
                                    sx: {
                                        background: mode === 'light' ? '#ffffff' : 
                                                   mode === 'dark' ? '#1e293b' : '#0f172a',
                                        border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                                     mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                                     '1px solid rgba(139, 92, 246, 0.2)',
                                        borderRadius: 2
                                    }
                                }}
                            >
                                <MenuItem onClick={() => { router.get('/writer/profile'); handleMenuClose(); }}>
                                    <ListItemIcon><Person /></ListItemIcon>
                                    <Typography>Profile</Typography>
                                </MenuItem>
                                <MenuItem onClick={() => { router.post('/logout'); handleMenuClose(); }}>
                                    <ListItemIcon><Logout /></ListItemIcon>
                                    <Typography>Logout</Typography>
                                </MenuItem>
                            </Menu>
                        </Box>
                    </Box>
                </Container>

                {/* Main Content */}
                <Container maxWidth="lg" sx={{ flex: 1, py: 4, position: 'relative', zIndex: 1 }}>
                    <Fade in={mounted} timeout={800}>
                        <Box>
                            {/* Flash Messages */}
                            {flash?.success && (
                                <Box sx={{ 
                                    p: 3, 
                                    mb: 3, 
                                    borderRadius: 2,
                                    backgroundColor: mode === 'light' ? 'rgba(16, 185, 129, 0.1)' : 
                                                   mode === 'dark' ? 'rgba(16, 185, 129, 0.2)' : 
                                                   'rgba(139, 92, 246, 0.2)',
                                    border: mode === 'light' ? '1px solid rgba(16, 185, 129, 0.3)' : 
                                             mode === 'dark' ? '1px solid rgba(16, 185, 129, 0.4)' : 
                                             '1px solid rgba(139, 92, 246, 0.4)',
                                    color: mode === 'light' ? '#065f46' : 
                                           mode === 'dark' ? '#10b981' : 
                                           '#8b5cf6'
                                }}>
                                    {flash.success}
                                </Box>
                            )}
                            
                            {flash?.error && (
                                <Box sx={{ 
                                    p: 3, 
                                    mb: 3, 
                                    borderRadius: 2,
                                    backgroundColor: mode === 'light' ? 'rgba(239, 68, 68, 0.1)' : 
                                                   mode === 'dark' ? 'rgba(239, 68, 68, 0.2)' : 
                                                   'rgba(239, 68, 68, 0.2)',
                                    border: mode === 'light' ? '1px solid rgba(239, 68, 68, 0.3)' : 
                                             mode === 'dark' ? '1px solid rgba(239, 68, 68, 0.4)' : 
                                             '1px solid rgba(239, 68, 68, 0.4)',
                                    color: mode === 'light' ? '#991b1b' : 
                                           mode === 'dark' ? '#ef4444' : 
                                           '#ef4444'
                                }}>
                                    {flash.error}
                                </Box>
                            )}

                            {/* Articles List */}
                            {revisionArray.length === 0 ? (
                                <Card sx={{ 
                                    p: 4, 
                                    background: mode === 'light' ? 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)' : 
                                               mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' : 
                                               'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                                    border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                             mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                             '1px solid rgba(139, 92, 246, 0.2)',
                                    borderRadius: 3,
                                    backdropFilter: 'blur(20px)',
                                    textAlign: 'center'
                                }}>
                                    <RateReview sx={{ fontSize: 48, color: mode === 'light' ? '#64748b' : '#cbd5e1', mb: 2 }} />
                                    <Typography variant="h6" sx={{ 
                                        color: mode === 'light' ? '#1e293b' : 
                                               mode === 'dark' ? '#f8fafc' : '#f8fafc' 
                                    }}>
                                        No articles need revision
                                    </Typography>
                                    <Typography variant="body2" sx={{ 
                                        color: mode === 'light' ? '#64748b' : 
                                               mode === 'dark' ? '#94a3b8' : '#94a3b8' 
                                    }}>
                                        All your articles are in good status!
                                    </Typography>
                                </Card>
                            ) : (
                                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                                    {revisionArray.map((article) => (
                                        <Card key={article.id} sx={{ 
                                            p: 4, 
                                            background: mode === 'light' ? 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)' : 
                                                       mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' : 
                                                       'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)', 
                                            border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                                     mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                                     '1px solid rgba(139, 92, 246, 0.2)',
                                            borderRadius: 3,
                                            backdropFilter: 'blur(20px)',
                                            transition: 'all 0.3s ease',
                                            '&:hover': { 
                                                transform: 'translateY(-4px)',
                                                boxShadow: mode === 'light' ? '0 10px 30px rgba(0, 0, 0, 0.1)' : 
                                                           mode === 'dark' ? '0 10px 30px rgba(0, 0, 0, 0.3)' : 
                                                           '0 10px 30px rgba(139, 92, 246, 0.2)'
                                            }
                                        }}>
                                            {/* Article Header */}
                                            <Box sx={{ 
                                                p: 3,
                                                borderBottom: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                                             mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                                             '1px solid rgba(139, 92, 246, 0.2)',
                                                mb: 3
                                            }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                    <Avatar sx={{ 
                                                        backgroundColor: mode === 'light' ? 'rgba(239, 68, 68, 0.1)' : 
                                                                       mode === 'dark' ? 'rgba(239, 68, 68, 0.2)' : 
                                                                       'rgba(239, 68, 68, 0.2)',
                                                        color: mode === 'light' ? '#ef4444' : 
                                                               mode === 'dark' ? '#ef4444' : '#ef4444',
                                                        width: 40,
                                                        height: 40
                                                    }}>
                                                        <RateReview />
                                                    </Avatar>
                                                    <Box sx={{ flex: 1 }}>
                                                        <Typography variant="h6" sx={{ 
                                                            color: mode === 'light' ? '#1e293b' : 
                                                                   mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                                            fontWeight: 600, mb: 1 
                                                        }}>
                                                            {article.title || 'Untitled Article'}
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ 
                                                            color: mode === 'light' ? '#475569' : 
                                                                   mode === 'dark' ? '#cbd5e1' : '#cbd5e1', 
                                                            mb: 2 
                                                        }}>
                                                            {article.excerpt || article.content?.substring(0, 100) || 'No excerpt available'}...
                                                        </Typography>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                                            <Chip 
                                                                label="Needs Revision"
                                                                size="small"
                                                                sx={{ 
                                                                    backgroundColor: mode === 'light' ? 'rgba(239, 68, 68, 0.1)' : 
                                                                                   mode === 'dark' ? 'rgba(239, 68, 68, 0.2)' : 
                                                                                   'rgba(239, 68, 68, 0.2)',
                                                                    color: mode === 'light' ? '#ef4444' : 
                                                                           mode === 'dark' ? '#ef4444' : '#ef4444',
                                                                    fontWeight: 'bold'
                                                                }}
                                                            />
                                                            <Typography variant="caption" sx={{ 
                                                                color: mode === 'light' ? '#64748b' : 
                                                                       mode === 'dark' ? '#94a3b8' : '#94a3b8' 
                                                            }}>
                                                                {article.created_at ? `Created ${new Date(article.created_at).toLocaleDateString('en-US', { 
                                                                    month: 'short', 
                                                                    day: 'numeric', 
                                                                    year: 'numeric' 
                                                                })}` : 'No date'}
                                                            </Typography>
                                                        </Box>
                                                        {article.category && typeof article.category === 'object' && (article.category.name || article.category.label) && (
                                                            <Chip 
                                                                label={article.category.name || article.category.label || 'Uncategorized'}
                                                                size="small"
                                                                sx={{ 
                                                                    backgroundColor: mode === 'light' ? 'rgba(59, 130, 246, 0.1)' : 
                                                                                   mode === 'dark' ? 'rgba(16, 185, 129, 0.2)' : 
                                                                                   'rgba(139, 92, 246, 0.2)',
                                                                    color: mode === 'light' ? '#3b82f6' : 
                                                                           mode === 'dark' ? '#10b981' : 
                                                                           '#8b5cf6',
                                                                    fontWeight: 'bold'
                                                                }}
                                                            />
                                                        )}
                                                    </Box>
                                                </Box>

                                                {article.revisions && article.revisions.length > 0 && (
                                                    <Box sx={{ 
                                                        p: 2, 
                                                        backgroundColor: mode === 'light' ? 'rgba(239, 68, 68, 0.05)' : 
                                                                       mode === 'dark' ? 'rgba(239, 68, 68, 0.1)' : 
                                                                       'rgba(239, 68, 68, 0.1)', 
                                                        borderRadius: 2,
                                                        mb: 3
                                                    }}>
                                                        <Typography variant="body2" sx={{ 
                                                            color: mode === 'light' ? '#991b1b' : 
                                                                   mode === 'dark' ? '#ef4444' : '#ef4444', 
                                                            fontWeight: 500, mb: 1 
                                                        }}>
                                                            Latest Revision Comment:
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ 
                                                            color: mode === 'light' ? '#7f1d1d' : 
                                                                   mode === 'dark' ? '#f87171' : '#f87171',
                                                            mb: 1 
                                                        }}>
                                                            {article.revisions[article.revisions.length - 1].comments}
                                                        </Typography>
                                                        <Typography variant="caption" sx={{ 
                                                            color: mode === 'light' ? '#991b1b' : 
                                                                   mode === 'dark' ? '#f87171' : '#f87171' 
                                                        }}>
                                                            By {article.revisions[article.revisions.length - 1].editor?.name} on {new Date(article.revisions[article.revisions.length - 1].created_at).toLocaleDateString()}
                                                        </Typography>
                                                    </Box>
                                                )}
                                            </Box>

                                            {/* Article Content Preview */}
                                            <Box sx={{ 
                                                p: 3,
                                                backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.5)' : 
                                                               mode === 'dark' ? 'rgba(248, 250, 252, 0.05)' : 
                                                               'rgba(248, 250, 252, 0.05)',
                                                borderRadius: 2,
                                                mb: 3
                                            }}>
                                                <Typography variant="body2" sx={{ 
                                                    color: mode === 'light' ? '#475569' : 
                                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1',
                                                    lineHeight: 1.6
                                                }}>
                                                    {article.content ? article.content.substring(0, 150) + '...' : 'No content available'}
                                                </Typography>
                                            </Box>

                                            {/* Action Buttons */}
                                            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
                                                <Button
                                                    variant="outlined"
                                                    onClick={() => handleViewArticle(article)}
                                                    startIcon={<Visibility />}
                                                    sx={{ 
                                                        borderColor: mode === 'light' ? '#3b82f6' : 
                                                                   mode === 'dark' ? '#06b6d4' : '#8b5cf6',
                                                        color: mode === 'light' ? '#3b82f6' : 
                                                               mode === 'dark' ? '#06b6d4' : '#8b5cf6',
                                                        '&:hover': { 
                                                            borderColor: mode === 'light' ? '#2563eb' : 
                                                                       mode === 'dark' ? '#0891b2' : '#7c3aed',
                                                            color: mode === 'light' ? '#2563eb' : 
                                                                   mode === 'dark' ? '#0891b2' : '#7c3aed'
                                                        }
                                                    }}
                                                >
                                                    View Article
                                                </Button>
                                                
                                                <Button
                                                    variant="outlined"
                                                    onClick={() => handleResubmitArticle(article)}
                                                    startIcon={<Send />}
                                                    sx={{ 
                                                        borderColor: mode === 'light' ? '#10b981' : 
                                                                   mode === 'dark' ? '#f59e0b' : 
                                                                   '#ec4899',
                                                        color: mode === 'light' ? '#10b981' : 
                                                               mode === 'dark' ? '#f59e0b' : 
                                                               '#ec4899',
                                                        '&:hover': { 
                                                            borderColor: mode === 'light' ? '#059669' : 
                                                                       mode === 'dark' ? '#d97706' : 
                                                                       '#db2777',
                                                            color: mode === 'light' ? '#059669' : 
                                                                   mode === 'dark' ? '#d97706' : 
                                                                   '#db2777'
                                                        }
                                                    }}
                                                >
                                                    Resubmit
                                                </Button>
                                                
                                                <Button
                                                    variant="contained"
                                                    onClick={() => openReviseDialog(article)}
                                                    startIcon={<Edit />}
                                                    sx={{ 
                                                        background: mode === 'light' ? 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)' : 
                                                                   mode === 'dark' ? 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' : 
                                                                   'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)',
                                                        '&:hover': { 
                                                            background: mode === 'light' ? 'linear-gradient(135deg, #dc2626 0%, #b91c1c 100%)' : 
                                                                       mode === 'dark' ? 'linear-gradient(135deg, #d97706 0%, #b45309 100%)' : 
                                                                       'linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%)' 
                                                        }
                                                    }}
                                                >
                                                    Revise & Resubmit
                                                </Button>
                                            </Box>
                                        </Card>
                                    ))}
                                </Box>
                            )}
                        </Box>
                    </Fade>
                </Container>

                {/* Revision Dialog */}
                <Dialog open={reviseDialog} onClose={() => setReviseDialog(false)} maxWidth="md" fullWidth>
                    <DialogTitle sx={{ 
                        backgroundColor: mode === 'light' ? '#ffffff' : 
                                       mode === 'dark' ? '#1e293b' : '#0f172a',
                        color: mode === 'light' ? '#1e293b' : 
                               mode === 'dark' ? '#f8fafc' : '#f8fafc'
                    }}>
                        Revise Article: {selectedArticle?.title}
                    </DialogTitle>
                    <DialogContent sx={{ 
                        backgroundColor: mode === 'light' ? '#ffffff' : 
                                       mode === 'dark' ? '#1e293b' : '#0f172a'
                    }}>
                        <Box sx={{ mt: 2 }}>
                            <Typography variant="body2" sx={{ 
                                color: mode === 'light' ? '#475569' : 
                                       mode === 'dark' ? '#cbd5e1' : '#cbd5e1', 
                                mb: 2 
                            }}>
                                Update your article content based on the editor's feedback:
                            </Typography>
                            <Box sx={{
                                backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.8)' : 
                                               mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 
                                               'rgba(255, 255, 255, 0.05)',
                                borderRadius: 2,
                                border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                         mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.2)' : 
                                         '1px solid rgba(139, 92, 246, 0.2)',
                                overflow: 'hidden',
                                '& .jodit-container': {
                                    backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.8)' : 
                                                   mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 
                                                   'rgba(255, 255, 255, 0.05)',
                                },
                                '& .jodit-wysiwyg': {
                                    backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.8)' : 
                                                   mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 
                                                   'rgba(255, 255, 255, 0.05)',
                                    color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#f8fafc' : '#f8fafc',
                                },
                                '& .jodit-wysiwyg p': {
                                    color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#f8fafc' : '#f8fafc',
                                }
                            }}>
                                <JoditEditorComponent
                                    value={articleContent}
                                    onChange={setArticleContent}
                                    placeholder="Revise your article content here..."
                                />
                            </Box>
                        </Box>
                    </DialogContent>
                    <DialogActions sx={{ 
                        backgroundColor: mode === 'light' ? '#ffffff' : 
                                       mode === 'dark' ? '#1e293b' : '#0f172a'
                    }}>
                        <Button onClick={() => setReviseDialog(false)} sx={{ 
                            color: mode === 'light' ? '#64748b' : 
                                   mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                        }}>
                            Cancel
                        </Button>
                        <Button 
                            onClick={handleReviseArticle} 
                            variant="contained"
                            sx={{ 
                                background: mode === 'light' ? 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)' : 
                                           mode === 'dark' ? 'linear-gradient(135deg, #f59e0b 0%, #d97706 100%)' : 
                                           'linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)',
                                '&:hover': { 
                                    background: mode === 'light' ? 'linear-gradient(135deg, #dc2626 0%, #b91c1c 100%)' : 
                                               mode === 'dark' ? 'linear-gradient(135deg, #d97706 0%, #b45309 100%)' : 
                                               'linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%)' 
                                }
                            }}
                        >
                            Submit Revision
                        </Button>
                    </DialogActions>
                </Dialog>

                {/* Global Styles for Animations and Theme */}
                <style jsx>{`
                    @keyframes float {
                        0%, 100% { transform: translateY(0px); }
                        50% { transform: translateY(-20px); }
                    }
                    
                    /* Force text colors for light mode */
                    .jodit-container[data-theme="light"] .jodit-wysiwyg {
                        color: #1e293b !important;
                        background-color: rgba(248, 250, 252, 0.8) !important;
                    }
                    
                    .jodit-container[data-theme="light"] .jodit-wysiwyg p {
                        color: #1e293b !important;
                    }
                    
                    /* Force text colors for dark mode */
                    .jodit-container[data-theme="dark"] .jodit-wysiwyg,
                    .jodit-container[data-theme="galaxy"] .jodit-wysiwyg {
                        color: #f8fafc !important;
                        background-color: rgba(255, 255, 255, 0.05) !important;
                    }
                    
                    .jodit-container[data-theme="dark"] .jodit-wysiwyg p,
                    .jodit-container[data-theme="galaxy"] .jodit-wysiwyg p {
                        color: #f8fafc !important;
                    }
                `}</style>
            </Box>
        </>
    );
};

export default WriterRevision;

