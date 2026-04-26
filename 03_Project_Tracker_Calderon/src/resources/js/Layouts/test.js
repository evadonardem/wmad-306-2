import React, { useState } from 'react';
import { Head, Link } from '@inertiajs/react';
import {
    AppBar,
    Box,
    Container,
    Drawer,
    IconButton,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    Toolbar,
    Typography,
    Avatar,
    Menu,
    MenuItem,
    useTheme,
    useMediaQuery,
} from '@mui/material';
import {
    Menu as MenuIcon,
    Dashboard,
    Assignment,
    Task,
    Person,
    ChevronLeft,
} from '@mui/icons-material';

const drawerWidth = 280;

const menuItems = [
    { text: 'Dashboard', icon: <Dashboard />, href: route('dashboard') },
    { text: 'Projects', icon: <Assignment />, href: route('projects.index') },
    { text: 'Tasks', icon: <Task />, href: route('tasks.index') },
    { text: 'Profile', icon: <Person />, href: route('profile.edit') },
];

export default function AppLayout({ auth, header, children }) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [mobileOpen, setMobileOpen] = useState(false);
    const [anchorEl, setAnchorEl] = useState(null);

    const handleDrawerToggle = () => {
        setMobileOpen(!mobileOpen);
    };

    const handleProfileMenuOpen = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleProfileMenuClose = () => {
        setAnchorEl(null);
    };

    return (
        <Box sx={{ display: 'flex', minHeight: '100vh' }}>
            <Head title={header} />
            
            {/* AppBar */}
            <AppBar
                position="fixed"
                sx={{
                    width: { md: `calc(100% - ${drawerWidth}px)` },
                    ml: { md: `${drawerWidth}px` },
                    zIndex: theme.zIndex.drawer + 1,
                }}
            >
                <Toolbar>              
                    {/* Profile Menu */}
                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                        <IconButton
                            onClick={handleProfileMenuOpen}
                            sx={{ p: 0 }}
                        >
                            <Avatar alt={auth?.user?.name ?? 'User'} src="/images/placeholder.jpg" />
                        </IconButton>
                        <Menu
                            anchorEl={anchorEl}
                            open={Boolean(anchorEl)}
                            onClose={handleProfileMenuClose}
                            onClick={handleProfileMenuClose}
                            PaperProps={{
                                elevation: 3,
                                sx: {
                                    mt: 1.5,
                                    minWidth: 200,
                                    borderRadius: 2,
                                },
                            }}
                        >
                            <MenuItem component={Link} href={route('profile.edit')}>
                                <Typography textAlign="center">Profile</Typography>
                            </MenuItem>
                            <MenuItem component={Link} href={route('logout')} method="post" as="button">
                                <Typography textAlign="center">Logout</Typography>
                            </MenuItem>
                        </Menu>
                    </Box>
                </Toolbar>
            </AppBar>


            {/* Main Content */}
            <Box
                component="main"
                sx={{
                    flexGrow: 1,
                    p: 3,
                    width: { md: `calc(100% - ${drawerWidth}px)` },
                    backgroundColor: theme.palette.grey[50],
                    overflowY: 'auto',
                }}
            >
                <Toolbar />
                <Container maxWidth="lg">
                    {children}
                </Container>
            </Box>
        </Box>
    );
}
