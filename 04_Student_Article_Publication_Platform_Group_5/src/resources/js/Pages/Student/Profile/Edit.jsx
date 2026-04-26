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
    Avatar,
    Chip,
    Divider,
    Alert,
    CircularProgress,
    Menu,
    MenuItem,
    ListItemIcon,
    IconButton
} from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import {
    ArrowBack,
    Person,
    Logout,
    Edit,
    Visibility,
    Menu as MenuIcon
} from '@mui/icons-material';

const StudentProfileEdit = () => {
    const [anchorEl, setAnchorEl] = useState(null);
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        current_password: '',
        new_password: '',
        new_password_confirmation: ''
    });

    const { auth, flash } = usePage().props;

    // Professional Theme with enhanced styling
    const theme = createTheme({
        palette: {
            mode: "dark",
            background: { 
                default: "#0f172a", 
                paper: "#1e293b" 
            },
            primary: { 
                main: "#60a5fa", 
                light: "#93c5fd", 
                dark: "#3b82f6" 
            },
            secondary: { 
                main: "#22d3ee", 
                light: "#63a3ff", 
                dark: "#1e40af" 
            },
            text: { 
                primary: "#ffffff", 
                secondary: "#94a3b8" 
            },
            divider: "#2d3748"
        },
        typography: { 
            fontFamily: '"Inter", "SF Pro Display", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            h1: {
                fontWeight: 800,
                fontSize: '2.5rem',
                lineHeight: 1.2,
                letterSpacing: '-0.02em'
            },
            h2: {
                fontWeight: 700,
                fontSize: '2rem',
                lineHeight: 1.3,
                letterSpacing: '-0.01em'
            },
            h3: {
                fontWeight: 600,
                fontSize: '1.75rem',
                lineHeight: 1.4
            },
            h4: { 
                fontWeight: 600,
                fontSize: '1.5rem',
                lineHeight: 1.4
            },
            h5: { 
                fontWeight: 600,
                fontSize: '1.25rem',
                lineHeight: 1.5
            },
            h6: { 
                fontWeight: 600,
                fontSize: '1.125rem',
                lineHeight: 1.5
            },
            body1: {
                fontSize: '1rem',
                lineHeight: 1.6,
                fontWeight: 400
            },
            body2: {
                fontSize: '0.875rem',
                lineHeight: 1.5,
                fontWeight: 400
            }
        },
        shape: {
            borderRadius: 12
        },
        spacing: 8,
        components: {
            MuiPaper: {
                styleOverrides: {
                    root: {
                        backgroundImage: 'none',
                        backgroundColor: '#1e293b',
                        border: '1px solid rgba(255, 255, 255, 0.1)',
                        transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
                        backdropFilter: 'blur(10px)',
                        '&:hover': {
                            transform: 'translateY(-4px)',
                            boxShadow: '0 20px 40px rgba(0, 0, 0, 0.3), 0 0 20px rgba(96, 165, 250, 0.1)',
                            borderColor: 'rgba(96, 165, 250, 0.3)'
                        }
                    }
                }
            },
            MuiButton: {
                styleOverrides: {
                    root: {
                        textTransform: 'none',
                        fontWeight: 600,
                        fontSize: '0.875rem',
                        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                        borderRadius: 10,
                        padding: '10px 24px',
                        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
                        '&:hover': {
                            transform: 'translateY(-2px)',
                            boxShadow: '0 8px 12px rgba(0, 0, 0, 0.2)'
                        },
                        '&:active': {
                            transform: 'translateY(0)'
                        }
                    },
                    contained: {
                        background: 'linear-gradient(135deg, #60a5fa 0%, #3b82f6 100%)',
                        '&:hover': { 
                            background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
                            transform: 'translateY(-2px)',
                            boxShadow: '0 8px 24px rgba(59, 130, 246, 0.4)'
                        }
                    },
                    outlined: {
                        borderWidth: 2,
                        '&:hover': {
                            borderWidth: 2
                        }
                    }
                }
            },
            MuiTextField: {
                styleOverrides: {
                    root: {
                        backgroundColor: 'rgba(255, 255, 255, 0.05)',
                        borderRadius: 10,
                        transition: 'all 0.3s ease',
                        '&:hover': {
                            backgroundColor: 'rgba(255, 255, 255, 0.08)',
                            '& .MuiOutlinedInput-notchedOutline': {
                                borderColor: '#60a5fa',
                                borderWidth: 2
                            }
                        },
                        '&.Mui-focused': {
                            backgroundColor: 'rgba(255, 255, 255, 0.1)',
                            '& .MuiOutlinedInput-notchedOutline': {
                                borderColor: '#60a5fa',
                                borderWidth: 2,
                                boxShadow: '0 0 0 3px rgba(96, 165, 250, 0.1)'
                            }
                        }
                    }
                }
            }
        }
    });

    const handleInputChange = (field) => (event) => {
        setFormData(prev => ({
            ...prev,
            [field]: event.target.value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        
        try {
            await router.patch('/profile', formData, {
                onSuccess: () => {
                    router.get('/student/dashboard');
                },
                onError: (errors) => {
                    console.error('Profile update errors:', errors);
                }
            });
        } catch (error) {
            console.error('Profile update error:', error);
        }
    };

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

    return (
        <ThemeProvider theme={theme}>
            <Head title="Edit Profile" />
            
            <Box sx={{ 
                minHeight: "100vh", 
                backgroundColor: "#0f172a",
                display: 'flex',
                flexDirection: 'column'
            }}>
                
                {/* Header */}
                <Box sx={{ 
                    backgroundColor: '#1e293b', 
                    borderBottom: '1px solid #334155',
                    p: 2,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between'
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <IconButton 
                            onClick={() => router.get('/student/dashboard')}
                            sx={{ color: '#ffffff' }}
                        >
                            <ArrowBack />
                        </IconButton>
                        <Typography variant="h4" sx={{ color: '#ffffff', fontWeight: 'bold' }}>
                            Edit Profile
                        </Typography>
                    </Box>
                    
                    <IconButton color="inherit" onClick={handleMenuOpen} sx={{ color: '#ffffff' }}>
                        <MenuIcon />
                    </IconButton>
                    
                    <Menu
                        anchorEl={anchorEl}
                        open={Boolean(anchorEl)}
                        PaperProps={{
                            sx: {
                                backgroundColor: 'rgba(30, 41, 59, 0.95)',
                                color: '#f7fafc',
                                border: '1px solid rgba(255, 255, 255, 0.1)',
                                borderRadius: 3,
                                backdropFilter: 'blur(20px)',
                                boxShadow: '0 20px 40px rgba(0, 0, 0, 0.3)'
                            }
                        }}
                    >
                        <MenuItem onClick={() => { router.get('/profile.edit'); handleMenuClose(); }}>
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
                            Logout
                        </MenuItem>
                    </Menu>
                </Box>
            </Box>

            {/* Main Content */}
            <Container maxWidth="md" sx={{ flexGrow: 1, py: 4 }}>
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

                <Paper sx={{ 
                    p: 4, 
                    backgroundColor: 'rgba(30, 41, 59, 0.95)', 
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    borderRadius: 3,
                    backdropFilter: 'blur(10px)',
                    boxShadow: '0 20px 40px rgba(0, 0, 0, 0.2)'
                }}>
                    <Typography variant="h4" sx={{ 
                        color: '#60a5fa', 
                        mb: 3, 
                        fontWeight: 700 
                    }}>
                        Profile Information
                    </Typography>
                    
                    <Box component="form" onSubmit={handleSubmit} sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                        <Grid container spacing={3}>
                            <Grid item xs={12} md={6}>
                                <TextField
                                    fullWidth
                                    label="Name"
                                    value={formData.name}
                                    onChange={handleInputChange('name')}
                                    sx={{
                                        '& .MuiOutlinedInput-root': {
                                            backgroundColor: 'rgba(255, 255, 255, 0.05)',
                                            borderRadius: 2,
                                            '&:hover': {
                                                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                                                '& .MuiOutlinedInput-notchedOutline': {
                                                    borderColor: '#60a5fa',
                                                    borderWidth: 2
                                                }
                                            }
                                        }
                                    }}
                                />
                            </Grid>
                            
                            <Grid item xs={12} md={6}>
                                <TextField
                                    fullWidth
                                    label="Email"
                                    type="email"
                                    value={formData.email}
                                    onChange={handleInputChange('email')}
                                    sx={{
                                        '& .MuiOutlinedInput-root': {
                                            backgroundColor: 'rgba(255, 255, 255, 0.05)',
                                            borderRadius: 2,
                                            '&:hover': {
                                                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                                                '& .MuiOutlinedInput-notchedOutline': {
                                                    borderColor: '#60a5fa',
                                                    borderWidth: 2
                                                }
                                            }
                                        }
                                    }}
                                />
                            </Grid>
                            
                            <Grid item xs={12} md={6}>
                                <TextField
                                    fullWidth
                                    label="Current Password"
                                    type="password"
                                    value={formData.current_password}
                                    onChange={handleInputChange('current_password')}
                                    sx={{
                                        '& .MuiOutlinedInput-root': {
                                            backgroundColor: 'rgba(255, 255, 255, 0.05)',
                                            borderRadius: 2,
                                            '&:hover': {
                                                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                                                '& .MuiOutlinedInput-notchedOutline': {
                                                    borderColor: '#60a5fa',
                                                    borderWidth: 2
                                                }
                                            }
                                        }
                                    }}
                                />
                            </Grid>
                            
                            <Grid item xs={12} md={6}>
                                <TextField
                                    fullWidth
                                    label="New Password"
                                    type="password"
                                    value={formData.new_password}
                                    onChange={handleInputChange('new_password')}
                                    sx={{
                                        '& .MuiOutlinedInput-root': {
                                            backgroundColor: 'rgba(255, 255, 255, 0.05)',
                                            borderRadius: 2,
                                            '&:hover': {
                                                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                                                '& .MuiOutlinedInput-notchedOutline': {
                                                    borderColor: '#60a5fa',
                                                    borderWidth: 2
                                                }
                                            }
                                        }
                                    }}
                                />
                            </Grid>
                            
                            <Grid item xs={12} md={6}>
                                <TextField
                                    fullWidth
                                    label="Confirm New Password"
                                    type="password"
                                    value={formData.new_password_confirmation}
                                    onChange={handleInputChange('new_password_confirmation')}
                                    sx={{
                                        '& .MuiOutlinedInput-root': {
                                            backgroundColor: 'rgba(255, 255, 255, 0.05)',
                                            borderRadius: 2,
                                            '&:hover': {
                                                backgroundColor: 'rgba(255, 255, 255, 0.08)',
                                                '& .MuiOutlinedInput-notchedOutline': {
                                                    borderColor: '#60a5fa',
                                                    borderWidth: 2
                                                }
                                            }
                                        }
                                    }}
                                />
                            </Grid>
                        </Grid>
                        
                        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end', mt: 4 }}>
                            <Button
                                type="submit"
                                variant="contained"
                                sx={{ 
                                    background: 'linear-gradient(135deg, #60a5fa 0%, #3b82f6 100%)',
                                    '&:hover': { 
                                        background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
                                        transform: 'translateY(-2px)',
                                        boxShadow: '0 8px 24px rgba(59, 130, 246, 0.4)'
                                    }
                                }}
                            >
                                Update Profile
                            </Button>
                        </Box>
                    </Box>
                </Paper>
            </Container>
    </ThemeProvider>
    );
};

export default StudentProfileEdit;
