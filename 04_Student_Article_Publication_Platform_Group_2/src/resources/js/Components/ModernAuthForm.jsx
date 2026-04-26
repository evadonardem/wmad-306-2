import { useState, useEffect } from 'react';
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
    Paper,
} from '@mui/material';
import { Article as ArticleIcon } from '@mui/icons-material';
import { useTheme } from '@mui/material/styles';
import useMediaQuery from '@mui/material/useMediaQuery';

export default function ModernAuthForm({
    isLogin = true,
    onSubmit,
    formData,
    setFormData,
    errors = {},
    processing = false,
    status = null,
}) {
    const [validationErrors, setValidationErrors] = useState(errors);

    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

    // Sync errors from props to local state
    useEffect(() => {
        setValidationErrors(errors);
    }, [errors]);

    const handleInputChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(name, type === 'checkbox' ? checked : value);
        
        // Clear validation error for this field when user types
        if (validationErrors[name]) {
            setValidationErrors({
                ...validationErrors,
                [name]: undefined,
            });
        }
    };

    return (
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
                    {/* Logo */}
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

                    {/* Status Message */}
                    {status && (
                        <Alert severity="success" sx={{ mb: 3 }}>
                            {status}
                        </Alert>
                    )}

                    {/* Form Title */}
                    <Typography
                        variant="h5"
                        sx={{
                            mb: 3,
                            textAlign: 'center',
                            color: theme.palette.text.primary,
                            fontWeight: 600,
                        }}
                    >
                        {isLogin ? 'Sign In' : 'Create Account'}
                    </Typography>

                    <form onSubmit={onSubmit}>
                        {/* Name Field (Register Only) */}
                        {!isLogin && (
                            <TextField
                                fullWidth
                                label="Full Name"
                                name="name"
                                type="text"
                                value={formData.name || ''}
                                onChange={handleInputChange}
                                error={!!validationErrors.name}
                                helperText={validationErrors.name}
                                variant="outlined"
                                size="medium"
                                sx={{ mb: 2 }}
                                placeholder="Enter your full name"
                                autoComplete="name"
                                required={!isLogin}
                            />
                        )}

                        {/* Email Field */}
                        <TextField
                            fullWidth
                            label="Email Address"
                            name="email"
                            type="email"
                            value={formData.email || ''}
                            onChange={handleInputChange}
                            error={!!validationErrors.email}
                            helperText={validationErrors.email}
                            variant="outlined"
                            size="medium"
                            sx={{ mb: 2 }}
                            placeholder="you@example.com"
                            autoComplete="email"
                            required
                        />

                        {/* Password Field */}
                        <TextField
                            fullWidth
                            label="Password"
                            name="password"
                            type="password"
                            value={formData.password || ''}
                            onChange={handleInputChange}
                            error={!!validationErrors.password}
                            helperText={validationErrors.password}
                            variant="outlined"
                            size="medium"
                            sx={{ mb: 2 }}
                            placeholder="Enter your password"
                            autoComplete={isLogin ? 'current-password' : 'new-password'}
                            required
                        />

                        {/* Confirm Password Field (Register Only) */}
                        {!isLogin && (
                            <TextField
                                fullWidth
                                label="Confirm Password"
                                name="password_confirmation"
                                type="password"
                                value={formData.password_confirmation || ''}
                                onChange={handleInputChange}
                                error={!!validationErrors.password_confirmation}
                                helperText={validationErrors.password_confirmation}
                                variant="outlined"
                                size="medium"
                                sx={{ mb: 2 }}
                                placeholder="Confirm your password"
                                autoComplete="new-password"
                                required={!isLogin}
                            />
                        )}

                        {/* Remember Me & Forgot Password (Login Only) */}
                        {isLogin && (
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
                                            checked={formData.remember || false}
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
                                <Link
                                    href="#"
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
                            }}
                            disabled={processing}
                        >
                            {processing ? (
                                <CircularProgress size={24} color="inherit" />
                            ) : isLogin ? (
                                'Sign In'
                            ) : (
                                'Sign Up'
                            )}
                        </Button>

                        {/* Toggle Link */}
                        <Box sx={{ textAlign: 'center' }}>
                            <Typography variant="body2" sx={{ color: theme.palette.text.secondary }}>
                                {isLogin
                                    ? "Don't have an account? "
                                    : 'Already have an account? '}
                                <Link
                                    href={isLogin ? '/register' : '/login'}
                                    sx={{
                                        color: theme.palette.primary.main,
                                        fontWeight: 600,
                                        textDecoration: 'none',
                                        '&:hover': {
                                            textDecoration: 'underline',
                                        },
                                    }}
                                >
                                    {isLogin ? 'Sign up' : 'Sign in'}
                                </Link>
                            </Typography>
                        </Box>
                    </form>
                </Card>

                {/* Footer */}
                <Box sx={{ textAlign: 'center', mt: 4 }}>
                    <Typography variant="caption" sx={{ color: theme.palette.text.secondary }}>
                        © 2026 SAPP. All rights reserved.
                    </Typography>
                </Box>
            </Container>
        </Box>
    );
}
