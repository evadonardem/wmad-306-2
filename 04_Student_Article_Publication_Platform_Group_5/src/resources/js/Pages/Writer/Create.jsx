import React, { useState, useCallback, useEffect } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
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
    CircularProgress,
    Fade,
    Card,
    CardContent,
    Avatar,
    IconButton,
    Menu,
    alpha
} from '@mui/material';
import { 
    ArrowBack, 
    Save, 
    Send, 
    Category,
    Person,
    Logout,
    Menu as MenuIcon,
    Description,
    Title
} from '@mui/icons-material';
import { useThemeContext } from '@/Context/ThemeContext';
import BackToDashboard from '@/Components/BackToDashboard';
import ThemeToggle from '@/Components/ThemeToggle';
import JoditEditorComponent from '@/Components/JoditEditor';

const WriterCreate = ({ categories }) => {
    const { mode } = useThemeContext();
    const { flash, auth } = usePage().props;
    const [anchorEl, setAnchorEl] = useState(null);
    const [mounted, setMounted] = useState(false);

    // Debug: Log the current mode
    console.log('Current theme mode:', mode);

    const [formData, setFormData] = useState({
        title: '',
        content: '',
        category_id: ''
    });

    const [isSubmitting, setIsSubmitting] = useState(false);

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

    const handleMenuClick = (event) => {
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

    const handleInputChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        
        if (!formData.title.trim() || !formData.content.trim() || !formData.category_id) {
            alert('Please fill in all required fields.');
            return;
        }

        setIsSubmitting(true);
        
        // Clean content before submitting
        const cleanFormData = {
            ...formData,
            content: formData.content.replace(/<p><\/p>/g, '')
        };
        
        try {
            await router.post('/writer/articles', cleanFormData, {
                onSuccess: () => {
                    router.get('/writer/dashboard');
                },
                onError: (errors) => {
                    console.error('Submission failed:', errors);
                    alert('Failed to create article. Please try again.');
                },
                onFinish: () => {
                    setIsSubmitting(false);
                }
            });
        } catch (error) {
            console.error('Error:', error);
            setIsSubmitting(false);
        }
    };

    const handleSaveDraft = async () => {
        if (!formData.title.trim() || !formData.content.trim()) {
            alert('Please add title and content before saving as draft.');
            return;
        }

        setIsSubmitting(true);
        
        // Clean content before saving
        const cleanFormData = {
            ...formData,
            content: formData.content.replace(/<p><\/p>/g, ''),
            save_as_draft: true
        };
        
        try {
            await router.post('/writer/articles', cleanFormData, {
                onSuccess: () => {
                    router.get('/writer/dashboard');
                },
                onError: (errors) => {
                    console.error('Draft save failed:', errors);
                    alert('Failed to save draft. Please try again.');
                },
                onFinish: () => {
                    setIsSubmitting(false);
                }
            });
        } catch (error) {
            console.error('Error:', error);
            setIsSubmitting(false);
        }
    };

    return (
        <>
            <Head title="Create Article" />
            
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
                    top: '10%',
                    left: '5%',
                    width: 300,
                    height: 300,
                    borderRadius: '50%',
                    background: mode === 'light' ? 'radial-gradient(circle, rgba(59, 130, 246, 0.1) 0%, transparent 70%)' : 
                               mode === 'dark' ? 'radial-gradient(circle, rgba(245, 158, 11, 0.05) 0%, transparent 70%)' : 
                               'radial-gradient(circle, rgba(139, 92, 246, 0.05) 0%, transparent 70%)',
                    filter: 'blur(40px)',
                    animation: 'float 6s ease-in-out infinite',
                    zIndex: 0
                }} />
                <Box sx={{
                    position: 'absolute',
                    bottom: '15%',
                    right: '10%',
                    width: 250,
                    height: 250,
                    borderRadius: '50%',
                    background: mode === 'light' ? 'radial-gradient(circle, rgba(16, 185, 129, 0.1) 0%, transparent 70%)' : 
                               mode === 'dark' ? 'radial-gradient(circle, rgba(6, 182, 212, 0.05) 0%, transparent 70%)' : 
                               'radial-gradient(circle, rgba(236, 72, 153, 0.05) 0%, transparent 70%)',
                    filter: 'blur(35px)',
                    animation: 'float 8s ease-in-out infinite reverse',
                    zIndex: 0
                }} />

                {/* Header */}
                <Box sx={{ 
                    p: 3, 
                    borderBottom: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                 mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                 '1px solid rgba(139, 92, 246, 0.2)',
                    position: 'relative',
                    zIndex: 1,
                    backgroundColor: mode === 'light' ? 'rgba(255, 255, 255, 0.9)' : 
                                   mode === 'dark' ? 'rgba(10, 14, 39, 0.9)' : 
                                   'rgba(0, 0, 0, 0.9)',
                    backdropFilter: 'blur(20px)'
                }}>
                    <Container maxWidth="lg">
                        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                <BackToDashboard dashboardRoute="/writer/dashboard" />
                                <Avatar sx={{ 
                                    backgroundColor: mode === 'light' ? 'rgba(59, 130, 246, 0.1)' : 
                                                   mode === 'dark' ? 'rgba(16, 185, 129, 0.2)' : 
                                                   'rgba(139, 92, 246, 0.2)',
                                    color: mode === 'light' ? '#3b82f6' : 
                                           mode === 'dark' ? '#10b981' : 
                                           '#8b5cf6',
                                    width: 48,
                                    height: 48
                                }}>
                                    <Description />
                                </Avatar>
                                <Box>
                                    <Typography variant="h4" sx={{ 
                                        color: mode === 'light' ? '#1e293b' : 
                                               mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                        fontWeight: 800, 
                                        letterSpacing: '-0.01em' 
                                    }}>
                                        Create Article
                                    </Typography>
                                    <Typography variant="body2" sx={{ 
                                        color: mode === 'light' ? '#475569' : 
                                               mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                                    }}>
                                        Write and publish your content
                                    </Typography>
                                </Box>
                            </Box>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                <ThemeToggle />
                                <IconButton 
                                    onClick={handleMenuClick}
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
                                            backgroundColor: mode === 'light' ? '#ffffff' : 
                                                           mode === 'dark' ? '#1e293b' : '#0f172a',
                                            border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                                     mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                                     '1px solid rgba(139, 92, 246, 0.2)',
                                            mt: 1
                                        }
                                    }}
                                >
                                    <MenuItem onClick={handleLogout} sx={{ 
                                        color: mode === 'light' ? '#1e293b' : 
                                               mode === 'dark' ? '#f8fafc' : '#f8fafc' 
                                    }}>
                                        <Person sx={{ mr: 2 }} />
                                        {auth.user?.name}
                                    </MenuItem>
                                    <MenuItem onClick={handleLogout} sx={{ 
                                        color: mode === 'light' ? '#1e293b' : 
                                               mode === 'dark' ? '#f8fafc' : '#f8fafc' 
                                    }}>
                                        <Logout sx={{ mr: 2 }} />
                                        Logout
                                    </MenuItem>
                                </Menu>
                            </Box>
                        </Box>
                    </Container>
                </Box>

                {/* Main Content */}
                <Container maxWidth="lg" sx={{ flex: 1, py: 4, position: 'relative', zIndex: 1 }}>
                    <Fade in={mounted} timeout={800}>
                        <Box>
                            {/* Flash Messages */}
                            {flash?.success && (
                                <Alert severity="success" sx={{ mb: 3 }}>
                                    {flash.success}
                                </Alert>
                            )}
                            
                            {flash?.error && (
                                <Alert severity="error" sx={{ mb: 3 }}>
                                    {flash.error}
                                </Alert>
                            )}

                            {/* Form */}
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
                                boxShadow: mode === 'light' ? '0 10px 30px rgba(0, 0, 0, 0.1)' : 
                                               mode === 'dark' ? '0 10px 30px rgba(0, 0, 0, 0.3)' : 
                                               '0 10px 30px rgba(0, 0, 0, 0.5)'
                            }}>
                                <form onSubmit={handleSubmit}>
                                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                                        {/* Title */}
                                        <Box>
                                            <Typography variant="h6" sx={{ 
                                                color: mode === 'light' ? '#1e293b' : 
                                                       mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                                mb: 2, 
                                                fontWeight: 600,
                                                display: 'flex',
                                                alignItems: 'center',
                                                gap: 1
                                            }}>
                                                <Title />
                                                Article Title
                                            </Typography>
                                            <TextField
                                                fullWidth
                                                placeholder="Enter a compelling title for your article"
                                                value={formData.title}
                                                onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
                                                required
                                                sx={{
                                                    '& .MuiOutlinedInput-root': {
                                                        backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.8)' : 
                                                                       mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 
                                                                       'rgba(255, 255, 255, 0.05)',
                                                        borderRadius: 2,
                                                        '& fieldset': {
                                                            borderColor: mode === 'light' ? 'rgba(226, 232, 240, 0.8)' : 
                                                                         mode === 'dark' ? 'rgba(148, 163, 184, 0.2)' : 
                                                                         'rgba(139, 92, 246, 0.2)',
                                                        },
                                                        '&:hover fieldset': {
                                                            borderColor: mode === 'light' ? '#3b82f6' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6',
                                                        },
                                                        '&.Mui-focused fieldset': {
                                                            borderColor: mode === 'light' ? '#3b82f6' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6',
                                                            boxShadow: mode === 'light' ? '0 0 0 3px rgba(59, 130, 246, 0.1)' : 
                                                                       mode === 'dark' ? '0 0 0 3px rgba(6, 182, 212, 0.1)' : 
                                                                       '0 0 0 3px rgba(139, 92, 246, 0.1)'
                                                        },
                                                        '& .MuiInputBase-input': {
                                                            color: mode === 'light' ? '#1e293b' : 
                                                                   mode === 'dark' ? '#f8fafc' : '#f8fafc'
                                                        }
                                                    }
                                                }}
                                            />
                                        </Box>

                                        {/* Category */}
                                        <Box>
                                            <Typography variant="h6" sx={{ 
                                                color: mode === 'light' ? '#1e293b' : 
                                                       mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                                mb: 2, 
                                                fontWeight: 600,
                                                display: 'flex',
                                                alignItems: 'center',
                                                gap: 1
                                            }}>
                                                <Category />
                                                Category
                                            </Typography>
                                            <FormControl fullWidth required>
                                                <Select
                                                    value={formData.category_id}
                                                    onChange={(e) => setFormData(prev => ({ ...prev, category_id: e.target.value }))}
                                                    displayEmpty
                                                    sx={{
                                                        backgroundColor: mode === 'light' ? 'rgba(248, 250, 252, 0.8)' : 
                                                                       mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 
                                                                       'rgba(255, 255, 255, 0.05)',
                                                        '& .MuiOutlinedInput-notchedOutline': {
                                                            borderColor: mode === 'light' ? 'rgba(226, 232, 240, 0.8)' : 
                                                                         mode === 'dark' ? 'rgba(148, 163, 184, 0.2)' : 
                                                                         'rgba(139, 92, 246, 0.2)',
                                                        },
                                                        '&:hover .MuiOutlinedInput-notchedOutline': {
                                                            borderColor: mode === 'light' ? '#3b82f6' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6',
                                                        },
                                                        '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                                                            borderColor: mode === 'light' ? '#3b82f6' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6',
                                                            boxShadow: mode === 'light' ? '0 0 0 3px rgba(59, 130, 246, 0.1)' : 
                                                                       mode === 'dark' ? '0 0 0 3px rgba(6, 182, 212, 0.1)' : 
                                                                       '0 0 0 3px rgba(139, 92, 246, 0.1)'
                                                        },
                                                        '& .MuiSelect-select': {
                                                            color: mode === 'light' ? '#1e293b' : 
                                                                   mode === 'dark' ? '#f8fafc' : '#f8fafc'
                                                        }
                                                    }}
                                                >
                                                    <MenuItem value="" disabled>
                                                        <em>Select a category</em>
                                                    </MenuItem>
                                                    {categories?.map((category) => (
                                                        <MenuItem key={category.id} value={category.id}>
                                                            {category.name || category.label || 'Unknown Category'}
                                                        </MenuItem>
                                                    ))}
                                                </Select>
                                            </FormControl>
                                        </Box>

                                        {/* Content */}
                                        <Box>
                                            <Typography variant="h6" sx={{ 
                                                color: mode === 'light' ? '#1e293b' : 
                                                       mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                                mb: 2, 
                                                fontWeight: 600,
                                                display: 'flex',
                                                alignItems: 'center',
                                                gap: 1
                                            }}>
                                                <Description />
                                                Content
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
                                                    value={formData.content}
                                                    onChange={(content) => setFormData(prev => ({ ...prev, content }))}
                                                    placeholder="Write your article content here..."
                                                />
                                            </Box>
                                        </Box>

                                        {/* Action Buttons */}
                                        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end', mt: 4 }}>
                                            <Button
                                                variant="outlined"
                                                onClick={() => router.get('/writer/dashboard')}
                                                disabled={isSubmitting}
                                                startIcon={<ArrowBack />}
                                                sx={{ 
                                                    borderColor: mode === 'light' ? '#3b82f6' : 
                                                               mode === 'dark' ? '#06b6d4' : 
                                                               '#8b5cf6',
                                                    color: mode === 'light' ? '#3b82f6' : 
                                                           mode === 'dark' ? '#06b6d4' : 
                                                           '#8b5cf6',
                                                    '&:hover': { 
                                                        borderColor: mode === 'light' ? '#2563eb' : 
                                                                   mode === 'dark' ? '#0891b2' : 
                                                                   '#7c3aed',
                                                        color: mode === 'light' ? '#2563eb' : 
                                                               mode === 'dark' ? '#0891b2' : 
                                                               '#7c3aed'
                                                    }
                                                }}
                                            >
                                                Back to Dashboard
                                            </Button>
                                            <Button
                                                variant="outlined"
                                                onClick={handleSaveDraft}
                                                disabled={isSubmitting}
                                                startIcon={<Save />}
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
                                                Save Draft
                                            </Button>
                                            <Button
                                                type="submit"
                                                variant="contained"
                                                disabled={isSubmitting}
                                                startIcon={isSubmitting ? <CircularProgress size={20} /> : <Send />}
                                                sx={{ 
                                                    background: mode === 'light' ? 'linear-gradient(135deg, #3b82f6 0%, #10b981 100%)' : 
                                                               mode === 'dark' ? 'linear-gradient(135deg, #10b981 0%, #f59e0b 100%)' : 
                                                               'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                                    '&:hover': { 
                                                        background: mode === 'light' ? 'linear-gradient(135deg, #2563eb 0%, #059669 100%)' : 
                                                                   mode === 'dark' ? 'linear-gradient(135deg, #059669 0%, #d97706 100%)' : 
                                                                   'linear-gradient(135deg, #7c3aed 0%, #db2777 100%)' 
                                                    }
                                                }}
                                            >
                                                {isSubmitting ? 'Submitting...' : 'Submit Article'}
                                            </Button>
                                        </Box>
                                    </Box>
                                </form>
                            </Card>
                        </Box>
                    </Fade>
                </Container>

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

export default WriterCreate;
