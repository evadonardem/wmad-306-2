import React from 'react';
import { 
    IconButton, 
    Tooltip, 
    Box 
} from '@mui/material';
import { 
    ArrowBack 
} from '@mui/icons-material';
import { router, usePage } from '@inertiajs/react';
import { useThemeContext } from '../Context/ThemeContext';

const BackToDashboard = ({ dashboardRoute, label = "Back to Dashboard" }) => {
    const { mode } = useThemeContext();
    const { auth } = usePage().props;

    const handleBackToDashboard = () => {
        router.get(dashboardRoute);
    };

    const getButtonColor = () => {
        switch (mode) {
            case 'light':
                return '#3b82f6';
            case 'dark':
                return '#06b6d4';
            case 'galaxy':
                return '#8b5cf6';
            default:
                return '#3b82f6';
        }
    };

    const getHoverColor = () => {
        switch (mode) {
            case 'light':
                return 'rgba(59, 130, 246, 0.1)';
            case 'dark':
                return 'rgba(6, 182, 212, 0.1)';
            case 'galaxy':
                return 'rgba(139, 92, 246, 0.1)';
            default:
                return 'rgba(59, 130, 246, 0.1)';
        }
    };

    return (
        <Box sx={{ mb: 2 }}>
            <Tooltip title={label}>
                <IconButton
                    onClick={handleBackToDashboard}
                    sx={{
                        color: getButtonColor(),
                        backgroundColor: mode === 'light' ? 'rgba(59, 130, 246, 0.05)' :
                                       mode === 'dark' ? 'rgba(6, 182, 212, 0.05)' :
                                       'rgba(139, 92, 246, 0.05)',
                        border: `1px solid ${getButtonColor()}20`,
                        borderRadius: 2,
                        padding: 1,
                        '&:hover': {
                            backgroundColor: getHoverColor(),
                            transform: 'translateX(-4px)',
                        },
                        transition: 'all 0.3s ease',
                    }}
                >
                    <ArrowBack />
                </IconButton>
            </Tooltip>
        </Box>
    );
};

export default BackToDashboard;
