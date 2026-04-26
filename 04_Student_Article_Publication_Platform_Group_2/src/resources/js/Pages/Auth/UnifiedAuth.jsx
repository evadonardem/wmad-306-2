import { useState } from 'react';
import { Head, useForm } from '@inertiajs/react';
import {
    Box,
    Card,
    TextField,
    Button,
    Checkbox,
    FormControlLabel,
    Link,
    Typography,
    Container,
    Alert,
    CircularProgress,
} from '@mui/material';
import { Article as ArticleIcon } from '@mui/icons-material';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';

export default function UnifiedAuth({ status, canResetPassword }) {
    const [isLoginMode, setIsLoginMode] = useState(true);
    
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
        remember: false,
    });

    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

    const handleInputChange = (e) => {
        const { name, value, type, checked } = e.target;
        setData(name, type === 'checkbox' ? checked : value);
    };

    const handleSubmit = (e) => {
        e.preventDefault();

        if (isLoginMode) {
            post(route('login'), {
                onFinish: () => reset('password'),
            });
        } else {
            post(route('register'), {
                onFinish: () => reset('password', 'password_confirmation'),
            });
        }
    };

    const toggleMode = () => {
        setIsLoginMode(!isLoginMode);
        reset();
    };

    return (
        <>
            <Head title={isLoginMode ? 'Log in' : 'Register'} />

            <Box
                sx={{
                    minHeight: '100vh',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    background: theme.palette.background.default,
                    py: 4,
                }}
            >
                <Container maxWidth="xs">
                    <Card
                        elevation={2}
                        sx={{
                            padding: isMobile ? 3 : 4,
                            borderRadius: 2,
                            backgroundColor: theme.palette.background.paper,
                        }}
                    >
                        {/* Logo Section */}
                        <Box sx={{ textAlign: 'center', mb: 4 }}>
                                                        <Box
                                                            sx={{
                                                                width: 64,
                                                                height: 64,
                                                                borderRadius: '12px',
                                                                background: 'linear-gradient(135deg, #1B2A4A 0%, #2A7B9B 100%)',
                                                                display: 'flex',
                                                                alignItems: 'center',
                                                                justifyContent: 'center',
                                                                mx: 'auto',
                                                                mb: 2,
                                                            }}
                                                        >
                                                            <ArticleIcon sx={{ color: '#fff', fontSize: 32 }} />
                                                        </Box>
                            <Typography
                                variant="h4"
                                sx={{
                                    fontWeight: 'bold',
                                    color: theme.palette.primary.main,
                                    letterSpacing: '0.05em',
                                }}
                            >
                                UniVox
                            </Typography>
                            <Typography
                                variant="body2"
                                sx={{
                                    color: theme.palette.text.secondary,
                                    mt: 1,
                                }}
                            >
                                Student Article Publication Platform
                            </Typography>
                        </Box>

                        {/* Status Alert */}
                        {status && (
                            <Alert severity="success" sx={{ mb: 3 }}>
                                {status}
                            </Alert>
                        )}

                        {/* Form Header */}
                        <Typography
                            variant="h5"
                            sx={{
                                mb: 3,
                                textAlign: 'center',
                                color: theme.palette.text.primary,
                                fontWeight: 600,
                            }}
                        >
                            {isLoginMode ? 'Sign In to Your Account' : 'Create Your Account'}
                        </Typography>

                        <form onSubmit={handleSubmit}>
                            {/* Name Field (Register Only) */}
                            {!isLoginMode && (
                                <TextField
                                    fullWidth
                                    label="Full Name"
                                    name="name"
                                    type="text"
                                    value={data.name}
                                    onChange={handleInputChange}
                                    error={!!errors.name}
                                    helperText={errors.name}
                                    variant="outlined"
                                    size="medium"
                                    sx={{
                                        mb: 2,
                                        '& .MuiOutlinedInput-root': {
                                            borderRadius: '8px',
                                        },
                                    }}
                                    placeholder="Enter your full name"
                                    autoComplete="name"
                                    required
                                />
                            )}

                            {/* Email Field */}
                            <TextField
                                fullWidth
                                label="Email Address"
                                name="email"
                                type="email"
                                value={data.email}
                                onChange={handleInputChange}
                                error={!!errors.email}
                                helperText={errors.email}
                                variant="outlined"
                                size="medium"
                                sx={{
                                    mb: 2,
                                    '& .MuiOutlinedInput-root': {
                                        borderRadius: '8px',
                                    },
                                }}
                                placeholder="you@example.com"
                                autoComplete="email"
                                required
                                autoFocus={!isLoginMode}
                            />

                            {/* Password Field */}
                            <TextField
                                fullWidth
                                label="Password"
                                name="password"
                                type="password"
                                value={data.password}
                                onChange={handleInputChange}
                                error={!!errors.password}
                                helperText={errors.password}
                                variant="outlined"
                                size="medium"
                                sx={{
                                    mb: 2,
                                    '& .MuiOutlinedInput-root': {
                                        borderRadius: '8px',
                                    },
                                }}
                                placeholder="Enter your password"
                                autoComplete={isLoginMode ? 'current-password' : 'new-password'}
                                required
                            />

                            {/* Confirm Password Field (Register Only) */}
                            {!isLoginMode && (
                                <TextField
                                    fullWidth
                                    label="Confirm Password"
                                    name="password_confirmation"
                                    type="password"
                                    value={data.password_confirmation}
                                    onChange={handleInputChange}
                                    error={!!errors.password_confirmation}
                                    helperText={errors.password_confirmation}
                                    variant="outlined"
                                    size="medium"
                                    sx={{
                                        mb: 2,
                                        '& .MuiOutlinedInput-root': {
                                            borderRadius: '8px',
                                        },
                                    }}
                                    placeholder="Confirm your password"
                                    autoComplete="new-password"
                                    required
                                />
                            )}

                            {/* Remember Me & Forgot Password (Login Only) */}
                            {isLoginMode && (
                                <Box
                                    sx={{
                                        display: 'flex',
                                        justifyContent: 'space-between',
                                        alignItems: 'center',
                                        mb: 3,
                                    }}
                                >
                                    <FormControlLabel
                                        control={
                                            <Checkbox
                                                name="remember"
                                                checked={data.remember}
                                                onChange={handleInputChange}
                                                size="small"
                                                sx={{
                                                    color: theme.palette.primary.main,
                                                }}
                                            />
                                        }
                                        label={
                                            <Typography variant="body2">
                                                Remember me
                                            </Typography>
                                        }
                                    />
                                    {canResetPassword && (
                                        <Link
                                            href={route('password.request')}
                                            variant="body2"
                                            sx={{
                                                color: theme.palette.primary.main,
                                                textDecoration: 'none',
                                                '&:hover': {
                                                    textDecoration: 'underline',
                                                },
                                            }}
                                        >
                                            Forgot Password?
                                        </Link>
                                    )}
                                </Box>
                            )}

                            {/* Submit Button */}
                            <Button
                                type="submit"
                                fullWidth
                                variant="contained"
                                sx={{
                                    py: 1.5,
                                    fontSize: '1rem',
                                    fontWeight: 600,
                                    backgroundColor: theme.palette.primary.main,
                                    '&:hover': {
                                        backgroundColor: theme.palette.primary.dark,
                                        boxShadow: '0 4px 12px rgba(37, 82, 115, 0.3)',
                                    },
                                    mb: 2,
                                    textTransform: 'none',
                                    transition: 'all 0.2s ease',
                                }}
                                disabled={processing}
                            >
                                {processing ? (
                                    <CircularProgress size={24} color="inherit" />
                                ) : isLoginMode ? (
                                    'Sign In'
                                ) : (
                                    'Sign Up'
                                )}
                            </Button>

                            {/* Toggle Link */}
                            <Box sx={{ textAlign: 'center' }}>
                                <Typography
                                    variant="body2"
                                    sx={{
                                        color: theme.palette.text.secondary,
                                    }}
                                >
                                    {isLoginMode
                                        ? "Don't have an account? "
                                        : 'Already have an account? '}
                                    <Link
                                        component="button"
                                        type="button"
                                        onClick={(e) => {
                                            e.preventDefault();
                                            toggleMode();
                                        }}
                                        sx={{
                                            color: theme.palette.primary.main,
                                            fontWeight: 600,
                                            textDecoration: 'none',
                                            '&:hover': {
                                                textDecoration: 'underline',
                                            },
                                            cursor: 'pointer',
                                        }}
                                    >
                                        {isLoginMode ? 'Sign up here' : 'Sign in here'}
                                    </Link>
                                </Typography>
                            </Box>
                        </form>
                    </Card>

                    {/* Footer */}
                    <Box sx={{ textAlign: 'center', mt: 4 }}>
                        <Typography
                            variant="caption"
                            sx={{ color: theme.palette.text.secondary }}
                        >
                            © 2026 SAPP. All rights reserved.
                        </Typography>
                    </Box>
                </Container>
            </Box>
        </>
    );
}
