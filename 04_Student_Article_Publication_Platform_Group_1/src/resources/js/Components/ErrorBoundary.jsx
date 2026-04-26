import React from 'react';
import { Box, Typography, Button, Paper, Alert, AlertTitle } from '@mui/material';
import {
    Error as ErrorIcon,
    Refresh,
    Home,
    ArrowBack
} from '@mui/icons-material';

export default class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { 
            hasError: false, 
            error: null, 
            errorInfo: null 
        };
    }

    static getDerivedStateFromError(error) {
        return { hasError: true };
    }

    componentDidCatch(error, errorInfo) {
        console.error('Error Boundary caught an error:', error, errorInfo);
        
        this.setState({
            error: error,
            errorInfo: errorInfo
        });

        // Log error to service
        this.logErrorToService(error, errorInfo);
    }

    logErrorToService = (error, errorInfo) => {
        // In a real app, you would send this to your error tracking service
        try {
            const errorData = {
                message: error.message,
                stack: error.stack,
                componentStack: errorInfo.componentStack,
                timestamp: new Date().toISOString(),
                userAgent: navigator.userAgent,
                url: window.location.href
            };

            // Example: Send to error tracking service
            // fetch('/api/errors', {
            //     method: 'POST',
            //     headers: { 'Content-Type': 'application/json' },
            //     body: JSON.stringify(errorData)
            // });
        } catch (e) {
            console.error('Failed to log error:', e);
        }
    };

    handleReload = () => {
        window.location.reload();
    };

    handleGoHome = () => {
        window.location.href = '/';
    };

    handleGoBack = () => {
        window.history.back();
    };

    render() {
        if (this.state.hasError) {
            return (
                <Box
                    sx={{
                        minHeight: '100vh',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        p: 3,
                        backgroundColor: 'background.default'
                    }}
                >
                    <Paper
                        sx={{
                            maxWidth: 600,
                            p: 4,
                            textAlign: 'center',
                            borderRadius: 3,
                            boxShadow: '0 8px 32px rgba(0,0,0,0.12)'
                        }}
                    >
                        {/* Error Icon */}
                        <Box sx={{ mb: 3 }}>
                            <ErrorIcon
                                sx={{
                                    fontSize: 64,
                                    color: 'error.main',
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
                            Oops! Something went wrong
                        </Typography>

                        {/* Error Message */}
                        <Alert
                            severity="error"
                            sx={{
                                mb: 3,
                                textAlign: 'left'
                            }}
                        >
                            <AlertTitle>Error Details</AlertTitle>
                            {this.state.error?.message || 'An unexpected error occurred'}
                        </Alert>

                        {/* Additional Error Info for Development */}
                        {process.env.NODE_ENV === 'development' && this.state.errorInfo && (
                            <Box
                                sx={{
                                    mt: 2,
                                    p: 2,
                                    backgroundColor: 'grey.100',
                                    borderRadius: 2,
                                    textAlign: 'left'
                                }}
                            >
                                <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 'bold' }}>
                                    Error Stack (Development Only):
                                </Typography>
                                <Typography
                                    variant="body2"
                                    component="pre"
                                    sx={{
                                        fontSize: '0.75rem',
                                        color: 'text.secondary',
                                        whiteSpace: 'pre-wrap',
                                        wordBreak: 'break-word'
                                    }}
                                >
                                    {this.state.error.stack}
                                </Typography>
                            </Box>
                        )}

                        {/* Action Buttons */}
                        <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center', mt: 3 }}>
                            <Button
                                variant="contained"
                                startIcon={<Refresh />}
                                onClick={this.handleReload}
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
                                onClick={this.handleGoHome}
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
                                onClick={this.handleGoBack}
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

                        {/* Support Info */}
                        <Box sx={{ mt: 3 }}>
                            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                                If this problem persists, please contact our support team.
                            </Typography>
                            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                                Email: support@articleplatform.com | Phone: 1-800-ARTICLES
                            </Typography>
                        </Box>
                    </Paper>
                </Box>
            );
        }

        return this.props.children;
    }
}

// HOC for wrapping components with error boundary
export const withErrorBoundary = (Component) => {
    return function WrappedComponent(props) {
        return (
            <ErrorBoundary>
                <Component {...props} />
            </ErrorBoundary>
        );
    };
};
