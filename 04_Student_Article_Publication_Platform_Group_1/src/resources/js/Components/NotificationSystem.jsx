import React, { createContext, useContext, useState, useCallback } from 'react';
import {
    Snackbar,
    Alert,
    AlertTitle,
    IconButton,
    Box,
    Typography,
    Slide,
    Fade,
    Grow
} from '@mui/material';
import {
    Close as CloseIcon,
    CheckCircle as SuccessIcon,
    Error as ErrorIcon,
    Warning as WarningIcon,
    Info as InfoIcon
} from '@mui/icons-material';

// Create notification context
const NotificationContext = createContext();

export const useNotifications = () => useContext(NotificationContext);

// Notification provider component
export function NotificationProvider({ children }) {
    const [notifications, setNotifications] = useState([]);

    const addNotification = useCallback((notification) => {
        const id = Date.now() + Math.random();
        const newNotification = {
            id,
            ...notification,
            timestamp: new Date()
        };

        setNotifications(prev => [...prev, newNotification]);

        // Auto-remove notification after duration
        if (notification.autoHide !== false) {
            setTimeout(() => {
                removeNotification(id);
            }, notification.duration || 5000);
        }
    }, []);

    const removeNotification = useCallback((id) => {
        setNotifications(prev => prev.filter(n => n.id !== id));
    }, []);

    const clearAllNotifications = useCallback(() => {
        setNotifications([]);
    }, []);

    const showSuccess = useCallback((message, options = {}) => {
        addNotification({
            type: 'success',
            message,
            duration: 4000,
            ...options
        });
    }, [addNotification]);

    const showError = useCallback((message, options = {}) => {
        addNotification({
            type: 'error',
            message,
            duration: 6000,
            ...options
        });
    }, [addNotification]);

    const showWarning = useCallback((message, options = {}) => {
        addNotification({
            type: 'warning',
            message,
            duration: 5000,
            ...options
        });
    }, [addNotification]);

    const showInfo = useCallback((message, options = {}) => {
        addNotification({
            type: 'info',
            message,
            duration: 4000,
            ...options
        });
    }, [addNotification]);

    const value = {
        notifications,
        addNotification,
        removeNotification,
        clearAllNotifications,
        showSuccess,
        showError,
        showWarning,
        showInfo
    };

    return (
        <NotificationContext.Provider value={value}>
            {children}
        </NotificationContext.Provider>
    );
}

// Individual notification component
function NotificationItem({ notification, onClose }) {
    const getIcon = () => {
        switch (notification.type) {
            case 'success':
                return <SuccessIcon />;
            case 'error':
                return <ErrorIcon />;
            case 'warning':
                return <WarningIcon />;
            case 'info':
            return <InfoIcon />;
            default:
                return <InfoIcon />;
        }
    };

    const getSeverity = () => {
        switch (notification.type) {
            case 'success':
                return 'success';
            case 'error':
                return 'error';
            case 'warning':
                return 'warning';
            case 'info':
                return 'info';
            default:
                return 'info';
        }
    };

    return (
        <Alert
            severity={getSeverity()}
            icon={getIcon()}
            action={
                <IconButton
                    size="small"
                    aria-label="Close"
                    color="inherit"
                    onClick={() => onClose(notification.id)}
                >
                    <CloseIcon fontSize="small" />
                </IconButton>
            }
            sx={{
                mb: 1,
                width: '100%',
                '& .MuiAlert-message': {
                    width: '100%'
                }
            }}
        >
            {notification.title && (
                <AlertTitle>{notification.title}</AlertTitle>
            )}
            {notification.message}
        </Alert>
    );
}

// Notification container component
export function NotificationContainer() {
    const { notifications, clearAllNotifications } = useNotifications();

    if (notifications.length === 0) {
        return null;
    }

    return (
        <Box
            sx={{
                position: 'fixed',
                top: 20,
                right: 20,
                zIndex: 9999,
                maxWidth: 400
            }}
        >
            {/* Clear all button */}
            {notifications.length > 1 && (
                <Box sx={{ mb: 1, textAlign: 'right' }}>
                    <IconButton
                        size="small"
                        onClick={clearAllNotifications}
                        sx={{
                            backgroundColor: 'rgba(0, 0, 0, 0.8)',
                            color: 'white',
                            '&:hover': {
                                backgroundColor: 'rgba(0, 0, 0, 0.9)',
                            }
                        }}
                    >
                        <CloseIcon fontSize="small" />
                    </IconButton>
                </Box>
            )}

            {/* Notifications */}
            <Box>
                {(notifications || []).map((notification) => {
                    // Validate notification to prevent React error #31
                    if (!notification || typeof notification !== 'object') return null;
                    
                    return (
                        <NotificationItem
                            key={notification.id || `notification-${Math.random()}`}
                            notification={notification}
                            onClose={(id) => {
                                const { removeNotification } = useNotifications();
                                removeNotification(id);
                            }}
                        />
                    );
                })}
            </Box>
        </Box>
    );
}

// Toast notification for mobile
export function ToastNotification({ notification, onClose }) {
    return (
        <Snackbar
            open={true}
            autoHideDuration={notification.duration || 5000}
            onClose={onClose}
            anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
            TransitionComponent={Grow}
        >
            <Alert
                severity={notification.type === 'success' ? 'success' : 
                        notification.type === 'error' ? 'error' : 
                        notification.type === 'warning' ? 'warning' : 'info'}
                action={
                    <IconButton
                        size="small"
                        aria-label="Close"
                        color="inherit"
                        onClick={onClose}
                    >
                        <CloseIcon fontSize="small" />
                    </IconButton>
                }
                sx={{
                    width: '100%',
                    maxWidth: 400
                }}
            >
                {notification.message}
            </Alert>
        </Snackbar>
    );
}

// Hook for showing notifications
export function useNotification() {
    const { showSuccess, showError, showWarning, showInfo } = useNotifications();

    return {
        success: showSuccess,
        error: showError,
        warning: showWarning,
        info: showInfo
    };
}

// Predefined notification messages
export const NotificationMessages = {
    // Success messages
    ARTICLE_SAVED: 'Article saved successfully!',
    ARTICLE_SUBMITTED: 'Article submitted for review!',
    ARTICLE_PUBLISHED: 'Article published successfully!',
    PROFILE_UPDATED: 'Profile updated successfully!',
    COMMENT_POSTED: 'Comment posted successfully!',
    LIKE_ADDED: 'Article liked!',
    FILE_UPLOADED: 'File uploaded successfully!',
    CHANGES_SAVED: 'Changes saved successfully!',

    // Error messages
    SAVE_FAILED: 'Failed to save article. Please try again.',
    SUBMIT_FAILED: 'Failed to submit article. Please try again.',
    PUBLISH_FAILED: 'Failed to publish article. Please try again.',
    NETWORK_ERROR: 'Network error. Please check your connection.',
    UPLOAD_FAILED: 'Failed to upload file. Please try again.',
    INVALID_INPUT: 'Please check your input and try again.',
    PERMISSION_DENIED: 'You don\'t have permission to perform this action.',
    SERVER_ERROR: 'Server error. Please try again later.',

    // Warning messages
    UNSAVED_CHANGES: 'You have unsaved changes. Are you sure you want to leave?',
    SESSION_EXPIRING: 'Your session will expire soon. Please save your work.',
    LARGE_FILE: 'File size is large. Upload may take some time.',

    // Info messages
    LOADING: 'Loading...',
    PROCESSING: 'Processing your request...',
    NO_CHANGES: 'No changes to save.',
    WELCOME: 'Welcome to the Article Publication Platform!'
};
