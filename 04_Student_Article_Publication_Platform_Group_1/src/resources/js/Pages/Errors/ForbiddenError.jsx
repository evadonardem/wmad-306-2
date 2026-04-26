import React from 'react';
import { Box, Typography, Button, Paper, Alert, AlertTitle } from '@mui/material';
import {
    Error as ErrorIcon,
    Refresh,
    Home,
    ArrowBack,
    Lock
} from '@mui/icons-material';
import { Link } from '@inertiajs/react';

export default function ForbiddenError() {
    const handleReload = () => {
        window.location.reload();
    };

    const handleGoHome = () => {
        window.location.href = '/';
    };

    const handleGoBack = () => {
        window.history.back();
    };

    return (
        <Box
            sx={{
                minHeight: '100vh',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                p: 3,
                backgroundColor: 'background.default',
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
            }}
        >
            <Paper
                sx={{
                    maxWidth: 600,
                    p: 4,
                    textAlign: 'center',
                    borderRadius: 3,
                    boxShadow: '0 8px 32px rgba(0,0,0,0.12)',
                    backgroundColor: 'rgba(255, 255, 255, 0.95)',
                    backdropFilter: 'blur(10px)'
                }}
            >
                {/* Error Icon */}
                <Box sx={{ mb: 3 }}>
                    <Lock
                        sx={{
                            fontSize: 64,
                            color: 'warning.main',
                            mb: 2
                        }}
                    />
                </Box>

                {/* Error Title */}
                <Typography
                    variant="h4"
                    sx={{
                        mb: 2,
                        fontWeight: 'bold',
                        color: 'text.primary'
                    }}
                >
                    Access Denied
                </Typography>

                {/* Error Message */}
                <Alert
                    severity="warning"
                    sx={{
                        mb: 3,
                        textAlign: 'left'
                    }}
                >
                    <AlertTitle>403 Forbidden</AlertTitle>
                    You don't have permission to access this resource. This might be because:
                    <ul style={{ textAlign: 'left', marginTop: 8, marginBottom: 0 }}>
                        <li>Your account doesn't have the required role</li>
                        <li>The resource is restricted to specific user types</li>
                        <li>You need to log in with a different account</li>
                        <li>The system is still setting up your permissions</li>
                    </ul>
                </Alert>

                {/* Development Notice */}
                {process.env.NODE_ENV === 'development' && (
                    <Alert
                        severity="info"
                        sx={{
                            mb: 3,
                            textAlign: 'left'
                        }}
                    >
                        <AlertTitle>Development Mode</AlertTitle>
                        If you're seeing this in development, the role middleware might need to be updated. 
                        Try running <code>php artisan app:setup-roles</code> to set up test accounts.
                    </Alert>
                )}

                {/* Action Buttons */}
                <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', mt: 3, flexWrap: 'wrap' }}>
                    <Button
                        variant="contained"
                        startIcon={<Refresh />}
                        onClick={handleReload}
                        sx={{
                            background: 'linear-gradient(45deg, #667eea 0%, #764ba2 100%)',
                            '&:hover': {
                                background: 'linear-gradient(45deg, #5a6fd8 0%, #6a4190 100%)',
                            }
                        }}
                    >
                        Reload Page
                    </Button>

                    <Button
                        variant="outlined"
                        startIcon={<Home />}
                        component={Link}
                        href="/"
                        sx={{
                            color: 'primary.main',
                            borderColor: 'primary.main',
                            '&:hover': {
                                backgroundColor: 'primary.light',
                            }
                        }}
                    >
                        Go Home
                    </Button>

                    <Button
                        variant="text"
                        startIcon={<ArrowBack />}
                        onClick={handleGoBack}
                        sx={{
                            color: 'text.secondary',
                            '&:hover': {
                                backgroundColor: 'action.hover',
                            }
                        }}
                    >
                        Go Back
                    </Button>
                </Box>

                {/* Quick Access Options */}
                <Box sx={{ mt: 4, pt: 3, borderTop: '1px solid rgba(0,0,0,0.1)' }}>
                    <Typography variant="h6" sx={{ mb: 2, color: 'text.secondary' }}>
                        Quick Access
                    </Typography>
                    <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', flexWrap: 'wrap' }}>
                        <Button
                            variant="text"
                            component={Link}
                            href="/dashboard"
                            size="small"
                        >
                            Main Dashboard
                        </Button>
                        <Button
                            variant="text"
                            component={Link}
                            href="/writer/dashboard"
                            size="small"
                        >
                            Writer Dashboard
                        </Button>
                        <Button
                            variant="text"
                            component={Link}
                            href="/editor/dashboard"
                            size="small"
                        >
                            Editor Dashboard
                        </Button>
                        <Button
                            variant="text"
                            component={Link}
                            href="/student/dashboard"
                            size="small"
                        >
                            Student Dashboard
                        </Button>
                    </Box>
                </Box>

                {/* Support Info */}
                <Box sx={{ mt: 3 }}>
                    <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                        If you believe this is an error, please contact your system administrator.
                    </Typography>
                    <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                        Email: support@articleplatform.com | Phone: 1-800-ARTICLES
                    </Typography>
                </Box>
            </Paper>
        </Box>
    );
}
