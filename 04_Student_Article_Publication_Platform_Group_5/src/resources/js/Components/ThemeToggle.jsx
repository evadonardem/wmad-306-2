import React from 'react';
import { 
    IconButton, 
    Tooltip, 
    Menu, 
    MenuItem, 
    ListItemIcon, 
    Typography,
    Box 
} from '@mui/material';
import { 
    LightMode, 
    DarkMode, 
    NightsStay, 
    ArrowDropDown 
} from '@mui/icons-material';
import { useThemeContext } from '../Context/ThemeContext';

const ThemeToggle = () => {
    const { mode, updateMode } = useThemeContext();
    const [anchorEl, setAnchorEl] = React.useState(null);

    const handleClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleClose = () => {
        setAnchorEl(null);
    };

    const handleThemeChange = (newMode) => {
        updateMode(newMode);
        handleClose();
    };

    const getThemeIcon = () => {
        switch (mode) {
            case 'light':
                return <LightMode />;
            case 'dark':
                return <DarkMode />;
            case 'galaxy':
                return <NightsStay />;
            default:
                return <LightMode />;
        }
    };

    const getThemeLabel = () => {
        switch (mode) {
            case 'light':
                return 'Light Mode';
            case 'dark':
                return 'Dark Mode';
            case 'galaxy':
                return 'Galaxy Mode';
            default:
                return 'Light Mode';
        }
    };

    return (
        <Box>
            <Tooltip title={`Current: ${getThemeLabel()}`}>
                <IconButton
                    onClick={handleClick}
                    sx={{
                        color: mode === 'light' ? '#3b82f6' : 
                               mode === 'dark' ? '#06b6d4' : '#8b5cf6',
                        '&:hover': {
                            backgroundColor: mode === 'light' ? 'rgba(59, 130, 246, 0.1)' :
                                           mode === 'dark' ? 'rgba(6, 182, 212, 0.1)' :
                                           'rgba(139, 92, 246, 0.1)',
                        }
                    }}
                >
                    {getThemeIcon()}
                </IconButton>
            </Tooltip>
            
            <Menu
                anchorEl={anchorEl}
                open={Boolean(anchorEl)}
                onClose={handleClose}
                PaperProps={{
                    sx: {
                        mt: 1,
                        '& .MuiAvatar-root': {
                            width: 32,
                            height: 32,
                            ml: -0.5,
                            mr: 1,
                        },
                    },
                }}
            >
                <MenuItem onClick={() => handleThemeChange('light')}>
                    <ListItemIcon>
                        <LightMode sx={{ color: '#3b82f6' }} />
                    </ListItemIcon>
                    <Typography>Light Mode</Typography>
                </MenuItem>
                <MenuItem onClick={() => handleThemeChange('dark')}>
                    <ListItemIcon>
                        <DarkMode sx={{ color: '#06b6d4' }} />
                    </ListItemIcon>
                    <Typography>Dark Mode</Typography>
                </MenuItem>
                <MenuItem onClick={() => handleThemeChange('galaxy')}>
                    <ListItemIcon>
                        <NightsStay sx={{ color: '#8b5cf6' }} />
                    </ListItemIcon>
                    <Typography>Galaxy Mode</Typography>
                </MenuItem>
            </Menu>
        </Box>
    );
};

export default ThemeToggle;
