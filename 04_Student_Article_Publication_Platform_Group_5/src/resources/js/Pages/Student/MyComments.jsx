import React, { useState } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Typography,
    Box,
    Button,
    Paper,
    Avatar,
    IconButton,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    Grid,
    Card,
    CardContent,
    CardActions,
    ThemeProvider,
    createTheme
} from '@mui/material';
import {
    ArrowBack,
    Comment,
    Visibility,
    Person,
    Logout,
    Menu as MenuIcon
} from '@mui/icons-material';

const MyComments = ({ myComments }) => {
    const [anchorEl, setAnchorEl] = useState(null);

    const { auth } = usePage().props;

    // Theme from Student Dashboard
    const theme = createTheme({
        palette: {
            mode: 'dark',
            background: {
                default: '#0b1220',
                paper: '#1e293b',
            },
            text: {
                primary: '#ffffff',
                secondary: '#94a3b8',
            },
        },
        typography: {
            fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
        },
        components: {
            MuiCssBaseline: {
                styleOverrides: {
                    body: {
                        backgroundColor: '#0b1220',
                        color: '#ffffff',
                    },
                },
            },
        },
    });

    const handleViewArticle = (article) => {
        router.visit(`/student/articles/${article.id}`);
    };

    const handleLogout = () => {
        router.post('/logout', {}, {
            onFinish: () => {
                handleMenuClose();
            }
        });
    };

    const switchRole = (role) => {
        router.post(`/switch-role/${role}`, {}, {
            onFinish: () => {
                handleMenuClose();
            }
        });
    };

    const handleMenuClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    const handleBackToDashboard = () => {
        router.visit('/student/dashboard');
    };

    return (
        <ThemeProvider theme={theme}>
            <Head title="My Comments" />
            
            <Box sx={{ 
                minHeight: "100vh", 
                backgroundColor: "#0b1220",
                display: 'flex',
                flexDirection: 'column'
            }}>
                {/* Header */}
                <Box sx={{ 
                    backgroundColor: '#0f172a', 
                    borderBottom: '1px solid #334155',
                    p: 2,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between'
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <IconButton component="a" href="/student/dashboard" sx={{ color: '#ffffff' }}>
                            <ArrowBack />
                        </IconButton>
                        <Typography variant="h4" sx={{ color: '#ffffff', fontWeight: 'bold' }}>
                            My Comments
                        </Typography>
                    </Box>
                    
                    <IconButton color="inherit" onClick={handleMenuClick} sx={{ color: '#ffffff' }}>
                        <MenuIcon />
                    </IconButton>
                </Box>

                {/* Main Content */}
                <Box sx={{ flexGrow: 1, p: 3 }}>
                    {!myComments || myComments.length === 0 ? (
                        <Paper sx={{ 
                            p: 6, 
                            backgroundColor: '#1e293b', 
                            border: '1px solid #334155',
                            textAlign: 'center',
                            borderRadius: 2
                        }}>
                            <Comment sx={{ fontSize: 64, color: '#10b981', mb: 3 }} />
                            <Typography variant="h6" sx={{ color: '#ffffff', mb: 2, fontWeight: 'bold' }}>
                                No Comments Yet
                            </Typography>
                            <Typography variant="body1" sx={{ color: '#94a3b8', mb: 4, maxWidth: 500, mx: 'auto' }}>
                                You haven't commented on any articles yet. Start engaging with published articles and share your thoughts!
                            </Typography>
                            <Button
                                variant="contained"
                                component="a"
                                href="/student/published-articles"
                                sx={{ 
                                    bgcolor: '#10b981',
                                    '&:hover': { bgcolor: '#059669' }
                                }}
                            >
                                Browse Articles
                            </Button>
                        </Paper>
                    ) : (
                        <Grid container spacing={3}>
                            {myComments.map((comment) => (
                                <Grid item xs={12} md={6} lg={4} key={comment.id}>
                                    <Paper sx={{ 
                                        p: 3, 
                                        backgroundColor: '#1e293b', 
                                        border: '1px solid #334155',
                                        borderRadius: 2,
                                        height: '100%',
                                        display: 'flex',
                                        flexDirection: 'column',
                                        '&:hover': { border: '1px solid #10b981' }
                                    }}>
                                        <CardContent sx={{ flexGrow: 1 }}>
                                            <Box sx={{ display: 'flex', alignItems: 'flex-start', mb: 2 }}>
                                                <Avatar sx={{ 
                                                    mr: 2, 
                                                    bgcolor: '#10b981',
                                                    width: 40,
                                                    height: 40
                                                }}>
                                                    {comment.article?.title?.charAt(0) || 'A'}
                                                </Avatar>
                                                <Box sx={{ flex: 1 }}>
                                                    <Typography variant="subtitle1" fontWeight="bold" sx={{ color: '#10b981' }}>
                                                        {comment.article?.title}
                                                    </Typography>
                                                    <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                                        By {comment.article?.writer?.name}
                                                    </Typography>
                                                </Box>
                                            </Box>
                                            
                                            <Typography variant="body1" sx={{ 
                                                mb: 2, 
                                                lineHeight: 1.6,
                                                color: '#ffffff',
                                                display: '-webkit-box',
                                                WebkitLineClamp: 3,
                                                WebkitBoxOrient: 'vertical',
                                                overflow: 'hidden'
                                            }}>
                                                {comment.content}
                                            </Typography>
                                            
                                            <Typography variant="caption" sx={{ color: '#94a3b8' }}>
                                                {new Date(comment.created_at).toLocaleDateString()} at {new Date(comment.created_at).toLocaleTimeString()}
                                            </Typography>
                                        </CardContent>
                                        <CardActions sx={{ pt: 0 }}>
                                            <Button
                                                size="small"
                                                onClick={() => handleViewArticle(comment.article)}
                                                startIcon={<Visibility />}
                                                variant="outlined"
                                                sx={{ 
                                                    color: '#10b981',
                                                    borderColor: '#10b981',
                                                    '&:hover': { 
                                                        borderColor: '#059669', 
                                                        color: '#059669',
                                                        bgcolor: 'rgba(16, 185, 129, 0.1)'
                                                    }
                                                }}
                                            >
                                                View Article
                                            </Button>
                                        </CardActions>
                                    </Paper>
                                </Grid>
                            ))}
                        </Grid>
                    )}
                </Box>

                {/* Profile Menu */}
                <Menu
                    anchorEl={anchorEl}
                    open={Boolean(anchorEl)}
                    onClose={handleMenuClose}
                    PaperProps={{
                        sx: {
                            backgroundColor: '#1e293b',
                            border: '1px solid #334155',
                            '& .MuiMenuItem-root': {
                                color: '#ffffff',
                                '&:hover': {
                                    backgroundColor: '#334155',
                                }
                            }
                        }
                    }}
                >
                    <MenuItem onClick={() => { switchRole('writer'); }}>
                        <ListItemIcon>
                            <Person sx={{ color: '#94a3b8' }} />
                        </ListItemIcon>
                        Switch to Writer
                    </MenuItem>
                    <MenuItem onClick={() => { switchRole('editor'); }}>
                        <ListItemIcon>
                            <Person sx={{ color: '#94a3b8' }} />
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
            </Box>
        </ThemeProvider>
    );
};

export default MyComments;
