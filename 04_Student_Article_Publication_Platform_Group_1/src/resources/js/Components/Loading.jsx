import { Box, CircularProgress, Typography, LinearProgress } from '@mui/material';
import { 
    SentimentDissatisfied,
    SentimentNeutral,
    SentimentSatisfied,
    Refresh
} from '@mui/icons-material';

export default function Loading({ 
    type = 'default', 
    message = 'Loading...', 
    progress = null,
    size = 'medium',
    fullScreen = false 
}) {
    const getLoadingIcon = () => {
        switch (type) {
            case 'error':
                return <SentimentDissatisfied sx={{ fontSize: 48, color: 'error.main' }} />;
            case 'warning':
                return <SentimentNeutral sx={{ fontSize: 48, color: 'warning.main' }} />;
            case 'success':
                return <SentimentSatisfied sx={{ fontSize: 48, color: 'success.main' }} />;
            default:
                return <CircularProgress size={size} />;
        }
    };

    const getLoadingColor = () => {
        switch (type) {
            case 'error':
                return 'error.main';
            case 'warning':
                return 'warning.main';
            case 'success':
                return 'success.main';
            default:
                return 'primary.main';
        }
    };

    const content = (
        <Box sx={{ 
            display: 'flex', 
            flexDirection: 'column', 
            alignItems: 'center', 
            justifyContent: 'center',
            gap: 2,
            p: 3
        }}>
            {getLoadingIcon()}
            
            <Typography 
                variant="h6" 
                sx={{ 
                    fontWeight: 500,
                    color: getLoadingColor(),
                    textAlign: 'center'
                }}
            >
                {message}
            </Typography>

            {progress !== null && (
                <Box sx={{ width: '100%', mt: 2 }}>
                    <LinearProgress
                        variant="determinate"
                        value={progress}
                        sx={{
                            height: 8,
                            borderRadius: 4,
                            backgroundColor: 'rgba(0, 0, 0, 0.1)',
                            '& .MuiLinearProgress-bar': {
                                borderRadius: 4,
                            }
                        }}
                    />
                    <Typography variant="caption" sx={{ mt: 1, color: 'text.secondary' }}>
                        {progress}% Complete
                    </Typography>
                </Box>
            )}

            {type === 'default' && (
                <Typography 
                    variant="body2" 
                    sx={{ 
                        mt: 2,
                        color: 'text.secondary',
                        textAlign: 'center',
                        fontStyle: 'italic'
                    }}
                >
                    This may take a few moments...
                </Typography>
            )}
        </Box>
    );

    if (fullScreen) {
        return (
            <Box
                sx={{
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    backgroundColor: 'rgba(255, 255, 255, 0.95)',
                    backdropFilter: 'blur(8px)',
                    zIndex: 9999,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                }}
            >
                <Box
                    sx={{
                        backgroundColor: 'background.paper',
                        borderRadius: 3,
                        boxShadow: '0 8px 32px rgba(0,0,0,0.12)',
                        p: 4,
                        minWidth: 300,
                        maxWidth: 400
                    }}
                >
                    {content}
                </Box>
            </Box>
        );
    }

    return (
        <Box
            sx={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                minHeight: 200,
                p: 4
            }}
        >
            {content}
        </Box>
    );
}

// Loading states for different scenarios
export const LoadingStates = {
    DEFAULT: 'default',
    ERROR: 'error',
    WARNING: 'warning',
    SUCCESS: 'success'
};

// Predefined loading messages
export const LoadingMessages = {
    AUTHENTICATING: 'Authenticating...',
    LOADING_DATA: 'Loading data...',
    SAVING_CHANGES: 'Saving changes...',
    SUBMITTING_ARTICLE: 'Submitting article...',
    PUBLISHING_ARTICLE: 'Publishing article...',
    UPLOADING_FILE: 'Uploading file...',
    PROCESSING_REQUEST: 'Processing your request...',
    NETWORK_ERROR: 'Network error. Please try again.',
    SERVER_ERROR: 'Server error. Please try again later.',
    AUTHENTICATION_ERROR: 'Authentication failed. Please check your credentials.',
    PERMISSION_DENIED: 'Permission denied. You don\'t have access to this resource.',
    DATA_LOADED: 'Data loaded successfully!',
    CHANGES_SAVED: 'Changes saved successfully!',
    ARTICLE_SUBMITTED: 'Article submitted successfully!',
    ARTICLE_PUBLISHED: 'Article published successfully!',
    FILE_UPLOADED: 'File uploaded successfully!'
};
