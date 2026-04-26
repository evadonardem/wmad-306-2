import React, { useState, useEffect } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import { useThemeContext } from '@/Context/ThemeContext';
import {
    Typography,
    Box,
    Button,
    Card,
    CardContent,
    Avatar,
    IconButton,
    InputAdornment,
    Tooltip,
    Paper,
    Container,
    Divider,
    Fade,
    alpha,
    Grid,
    Checkbox,
    TextField
} from '@mui/material';
import {
    LockOutlined,
    Email,
    ArrowBack,
    Visibility,
    VisibilityOff,
    Person,
    Edit,
    Assignment,
    RocketLaunch
} from '@mui/icons-material';

export default function Login() {
    const { mode } = useThemeContext();
    const [showPassword, setShowPassword] = useState(false);
    const [mounted, setMounted] = useState(false);
    const [rememberMe, setRememberMe] = useState(false);

    useEffect(() => {
        setMounted(true);
    }, []);

    const { data, setData, post, processing } = useForm({
        email: "",
        password: ""
    });

    const submit = (e) => {
        e.preventDefault();
        post("/login");
    };

    const handleTogglePassword = () => {
        setShowPassword(!showPassword);
    };

    return (
        <React.Fragment>
            <Head title="Login - Campus Article Platform" />
            
            <Box sx={{ 
                minHeight: "100vh", 
                backgroundColor: mode === 'light' ? '#f8fafc' : 
                               mode === 'dark' ? '#0a0e27' : 
                               '#0a0e27',
                display: 'flex',
                flexDirection: 'column',
                background: mode === 'light' ? 'linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%)' : 
                               mode === 'dark' ? 'radial-gradient(circle at 20% 50%, rgba(245, 158, 11, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(6, 182, 212, 0.05) 0%, transparent 50%), #0a0e27' : 
                               'radial-gradient(circle at 20% 50%, rgba(245, 158, 11, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(6, 182, 212, 0.05) 0%, transparent 50%), #0a0e27',
                position: 'relative',
                overflow: 'hidden'
            }}>
                {/* Animated Background Elements */}
                <Box
                    sx={{
                        position: 'absolute',
                        top: '10%',
                        left: '10%',
                        width: 300,
                        height: 300,
                        background: 'radial-gradient(circle, rgba(245, 158, 11, 0.1) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 6s ease-in-out infinite',
                    }}
                />
                <Box
                    sx={{
                        position: 'absolute',
                        bottom: '10%',
                        right: '10%',
                        width: 200,
                        height: 200,
                        background: 'radial-gradient(circle, rgba(6, 182, 212, 0.1) 0%, transparent 70%)',
                        borderRadius: '50%',
                        animation: 'float 8s ease-in-out infinite reverse',
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
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                        <Avatar sx={{ 
                            backgroundColor: mode === 'light' ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)' : 
                                             mode === 'dark' ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)' : 
                                             'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                            width: 48,
                            height: 48
                        }}>
                            <LockOutlined />
                        </Avatar>
                        <Box>
                            <Typography variant="h4" sx={{ 
                                color: mode === 'light' ? '#1e293b' : 
                                           mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                fontWeight: 800, 
                                letterSpacing: '-0.01em' 
                            }}>
                                Welcome Back
                            </Typography>
                            <Typography variant="body2" sx={{ 
                                color: mode === 'light' ? '#64748b' : 
                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                            }}>
                                Sign in to your account to continue
                            </Typography>
                        </Box>
                    </Box>

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Tooltip title="Back to Home">
                            <Button
                                variant="outlined"
                                startIcon={<ArrowBack />}
                                component={Link}
                                href="/"
                                sx={{ 
                                    borderColor: mode === 'light' ? '#6366f1' : 
                                                 mode === 'dark' ? '#06b6d4' : 
                                                 '#8b5cf6',
                                    color: mode === 'light' ? '#6366f1' : 
                                           mode === 'dark' ? '#06b6d4' : 
                                           '#8b5cf6',
                                    '&:hover': { 
                                        borderColor: mode === 'light' ? '#4f46e5' : 
                                                     mode === 'dark' ? '#0891b2' : 
                                                     '#7c3aed',
                                        color: mode === 'light' ? '#4f46e5' : 
                                               mode === 'dark' ? '#0891b2' : 
                                               '#7c3aed' 
                                    }
                                }}
                            >
                                Home
                            </Button>
                        </Tooltip>
                    </Box>
                </Box>

                {/* Main Content */}
                <Container maxWidth="sm" sx={{ flexGrow: 1, py: 4, position: 'relative', zIndex: 1 }}>
                    <Fade in={mounted} timeout={1000}>
                        <Grid container spacing={0} justifyContent="center">
                            <Grid item xs={12} md={10}>
                                <Card sx={{ 
                                    background: mode === 'light' ? 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)' : 
                                                   mode === 'dark' ? 'linear-gradient(135deg, rgba(21, 25, 50, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)' : 
                                                   'linear-gradient(135deg, rgba(15, 23, 42, 0.9) 0%, rgba(30, 41, 59, 0.9) 100%)',
                                    border: mode === 'light' ? '1px solid rgba(226, 232, 240, 0.8)' : 
                                             mode === 'dark' ? '1px solid rgba(148, 163, 184, 0.1)' : 
                                             '1px solid rgba(139, 92, 246, 0.2)',
                                    position: 'relative',
                                    overflow: 'hidden',
                                    '&:hover': { 
                                        transform: 'translateY(-8px)',
                                        boxShadow: mode === 'light' ? '0 25px 50px rgba(0, 0, 0, 0.15), 0 0 25px rgba(99, 102, 241, 0.1)' : 
                                                     mode === 'dark' ? '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 25px rgba(6, 182, 212, 0.1)' : 
                                                     '0 25px 50px rgba(0, 0, 0, 0.3), 0 0 25px rgba(139, 92, 246, 0.1)'
                                    }
                                }}>
                                    <CardContent sx={{ p: 4 }}>
                                        {/* Back Button */}
                                        <Box sx={{ display: 'flex', justifyContent: 'flex-start', mb: 3 }}>
                                            <Button
                                                variant="outlined"
                                                startIcon={<ArrowBack />}
                                                component={Link}
                                                href="/"
                                                sx={{ 
                                                    borderColor: mode === 'light' ? '#e2e8f0' : 
                                                                 mode === 'dark' ? '#374151' : 
                                                                 '#374151',
                                                    color: mode === 'light' ? '#64748b' : 
                                                               mode === 'dark' ? '#9ca3af' : 
                                                               '#9ca3af',
                                                    '&:hover': {
                                                        backgroundColor: mode === 'light' ? 'rgba(226, 232, 240, 0.05)' : 
                                                                       mode === 'dark' ? 'rgba(148, 163, 184, 0.1)' : 
                                                                       'rgba(148, 163, 184, 0.1)'
                                                    }
                                                }}
                                            >
                                                Back to Home
                                            </Button>
                                        </Box>

                                        {/* Login Form Header */}
                                        <Box sx={{ textAlign: 'center', mb: 4 }}>
                                            <Avatar
                                                sx={{
                                                    width: 80,
                                                    height: 80,
                                                    bgcolor: mode === 'light' ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)' : 
                                                                 mode === 'dark' ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)' : 
                                                                 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                                    mb: 3,
                                                    mx: 'auto',
                                                    boxShadow: mode === 'light' ? '0 8px 24px rgba(99, 102, 241, 0.3)' : 
                                                                 mode === 'dark' ? '0 8px 24px rgba(6, 182, 212, 0.1)' : 
                                                                 '0 8px 24px rgba(139, 92, 246, 0.1)'
                                                }}
                                            >
                                                <LockOutlined sx={{ fontSize: 40 }} />
                                            </Avatar>

                                            <Typography variant="h3" sx={{ 
                                                color: mode === 'light' ? '#1e293b' : 
                                                           mode === 'dark' ? '#f8fafc' : '#f8fafc', 
                                                mb: 1,
                                                fontWeight: 700 
                                            }}>
                                                Sign In
                                            </Typography>
                                            <Typography variant="body2" sx={{ 
                                                color: mode === 'light' ? '#64748b' : 
                                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1',
                                                mb: 4 
                                            }}>
                                                Access your account to continue your creative journey
                                            </Typography>
                                        </Box>

                                        {/* Login Form */}
                                        <Box component="form" onSubmit={submit}>
                                            <TextField
                                                fullWidth
                                                label="Email Address"
                                                type="email"
                                                sx={{ 
                                                    mb: 3,
                                                    '& .MuiOutlinedInput-root': {
                                                        backgroundColor: mode === 'light' ? 'rgba(255, 255, 255, 0.05)' : 
                                                                       mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 
                                                                       'rgba(255, 255, 255, 0.05)',
                                                        borderRadius: 2,
                                                        '&:hover fieldset': {
                                                            borderColor: mode === 'light' ? '#6366f1' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6'
                                                        },
                                                        '&.Mui-focused fieldset': {
                                                            borderColor: mode === 'light' ? '#6366f1' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6',
                                                            borderWidth: 2
                                                        }
                                                    }
                                                }}
                                                value={data.email}
                                                onChange={(e) => setData("email", e.target.value)}
                                                InputProps={{
                                                    startAdornment: (
                                                        <InputAdornment position="start">
                                                            <Email sx={{ 
                                                                color: mode === 'light' ? '#64748b' : 
                                                                           mode === 'dark' ? '#9ca3af' : 
                                                                           '#9ca3af' 
                                                            }} />
                                                        </InputAdornment>
                                                    )
                                                }}
                                            />

                                            <TextField
                                                fullWidth
                                                label="Password"
                                                type={showPassword ? "text" : "password"}
                                                sx={{ 
                                                    mb: 3,
                                                    '& .MuiOutlinedInput-root': {
                                                        backgroundColor: mode === 'light' ? 'rgba(255, 255, 255, 0.05)' : 
                                                                       mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 
                                                                       'rgba(255, 255, 255, 0.05)',
                                                        borderRadius: 2,
                                                        '&:hover fieldset': {
                                                            borderColor: mode === 'light' ? '#6366f1' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6'
                                                        },
                                                        '&.Mui-focused fieldset': {
                                                            borderColor: mode === 'light' ? '#6366f1' : 
                                                                         mode === 'dark' ? '#06b6d4' : 
                                                                         '#8b5cf6',
                                                            borderWidth: 2
                                                        }
                                                    }
                                                }}
                                                value={data.password}
                                                onChange={(e) => setData("password", e.target.value)}
                                                InputProps={{
                                                    startAdornment: (
                                                        <InputAdornment position="start">
                                                            <LockOutlined sx={{ 
                                                                color: mode === 'light' ? '#64748b' : 
                                                                           mode === 'dark' ? '#9ca3af' : 
                                                                           '#9ca3af' 
                                                            }} />
                                                        </InputAdornment>
                                                    ),
                                                    endAdornment: (
                                                        <InputAdornment position="end">
                                                            <IconButton
                                                                onClick={handleTogglePassword}
                                                                edge="end"
                                                                sx={{ 
                                                                    color: mode === 'light' ? '#64748b' : 
                                                                               mode === 'dark' ? '#9ca3af' : 
                                                                               '#9ca3af' 
                                                                }}
                                                            >
                                                                {showPassword ? <VisibilityOff /> : <Visibility />}
                                                            </IconButton>
                                                        </InputAdornment>
                                                    )
                                                }}
                                            />

                                            <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                                                <Checkbox
                                                    checked={rememberMe}
                                                    onChange={(e) => setRememberMe(e.target.checked)}
                                                    sx={{
                                                        color: mode === 'light' ? '#6366f1' : 
                                                               mode === 'dark' ? '#9ca3af' : 
                                                               '#9ca3af'
                                                    }}
                                                />
                                                <Typography variant="body2" sx={{ 
                                                    color: mode === 'light' ? '#64748b' : 
                                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1' 
                                                }}>
                                                    Remember me
                                                </Typography>
                                            </Box>

                                            <Button
                                                type="submit"
                                                fullWidth
                                                variant="contained"
                                                size="large"
                                                disabled={processing}
                                                sx={{ 
                                                    py: 3, 
                                                    fontSize: '1.125rem',
                                                    fontWeight: 700,
                                                    mb: 3,
                                                    background: mode === 'light' ? 'linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%)' : 
                                                                 mode === 'dark' ? 'linear-gradient(135deg, #06b6d4 0%, #10b981 100%)' : 
                                                                 'linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%)',
                                                    '&:hover': { 
                                                        background: mode === 'light' ? 'linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%)' : 
                                                                     mode === 'dark' ? 'linear-gradient(135deg, #0891b2 0%, #0e7490 100%)' : 
                                                                     'linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%)' 
                                                    }
                                                }}
                                            >
                                                {processing ? 'Signing In...' : 'Sign In'}
                                            </Button>

                                            <Divider sx={{ my: 3 }}>
                                                <Typography variant="body2" sx={{ 
                                                    color: mode === 'light' ? '#9ca3af' : 
                                                           mode === 'dark' ? '#6b7280' : 
                                                           '#6b7280' 
                                                }}>
                                                    OR
                                                </Typography>
                                            </Divider>

                                            <Box sx={{ textAlign: 'center' }}>
                                                <Typography variant="body2" sx={{ 
                                                    color: mode === 'light' ? '#64748b' : 
                                                           mode === 'dark' ? '#cbd5e1' : '#cbd5e1',
                                                    mb: 2 
                                                }}>
                                                    Don't have an account?{" "}
                                                    <Link 
                                                        href="/register" 
                                                        style={{ 
                                                            color: mode === 'light' ? '#6366f1' : 
                                                                   mode === 'dark' ? '#06b6d4' : 
                                                                   '#8b5cf6',
                                                            fontWeight: 600,
                                                            textDecoration: 'none'
                                                        }}
                                                    >
                                                        Create an account
                                                    </Link>
                                                </Typography>
                                            </Box>
                                        </Box>
                                    </CardContent>
                                </Card>
                            </Grid>
                        </Grid>
                    </Fade>
                </Container>

                {/* Add floating animation */}
                <style jsx>{`
                    @keyframes float {
                        0%, 100% { transform: translateY(0px) rotate(0deg); }
                        33% { transform: translateY(-20px) rotate(120deg); }
                        66% { transform: translateY(10px) rotate(240deg); }
                    }
                `}</style>
            </Box>
        </React.Fragment>
    );
}