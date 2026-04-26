import { useState } from 'react';
import { Link, usePage, router } from '@inertiajs/react';
import {
    AppBar,
    Box,
    Drawer,
    IconButton,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    Toolbar,
    Typography,
    Button,
    Avatar,
    Menu,
    MenuItem,
    useMediaQuery,
    useTheme as MuiTheme,
} from '@mui/material';
import {
    Menu as MenuIcon,
    ChevronLeft as ChevronLeftIcon,
    DarkMode,
    Flare,
    Logout,
} from '@mui/icons-material';
import { useThemeContext } from '@/Components/ThemeProvider';

const drawerWidth = 240;

const AuthenticatedLayout = ({ header, children }) => {
    const { theme, toggleTheme, isDark } = useThemeContext();
    const { props } = usePage();
    const user = props.auth?.user;
    const muiTheme = MuiTheme();
    const [mobileOpen, setMobileOpen] = useState(false);
    const [anchorEl, setAnchorEl] = useState(null);
    const isMobile = useMediaQuery(muiTheme.breakpoints.down('md'));

    const handleDrawerToggle = () => {
        setMobileOpen(!mobileOpen);
    };

    const handleMenuOpen = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    // Proper logout function using POST request with CSRF
    const handleLogout = (e) => {
        e.preventDefault();
        router.post(route('logout'));
    };

    const menuItems = [
        { text: 'Dashboard', href: route('dashboard')},
    ];

    const drawer = (
        <Box>
            <Toolbar>
                <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 'bold' }}>
                    Project Tracker
                </Typography>
            </Toolbar>
            <List>
                {menuItems.map((item) => (
                    <ListItem key={item.text} disablePadding>
                        <ListItemButton component={Link} href={item.href}>
                            <ListItemIcon>{item.icon}</ListItemIcon>
                            <ListItemText primary={item.text} />
                        </ListItemButton>
                    </ListItem>
                ))}
            </List>
        </Box>
    );

    return (
        <Box sx={{ display: 'flex' }}>
            <AppBar
                position="fixed"
                sx={{
                    width: { lg: `calc(113% - ${drawerWidth}px)` },
                    backgroundColor: theme.palette.background.paper,
                    color: theme.palette.text.primary,
                    boxShadow: '0 1px 3px rgba(0,0,0,0.12)',
                }}
            >
                <Toolbar>
                    <IconButton
                        color="inherit"
                        aria-label="open drawer"
                        edge="start"
                        onClick={handleDrawerToggle}
                        sx={{ mr: 2, display: { md: 'none' } }}
                    >
                        <MenuIcon />
                    </IconButton>

                    {/* Header content if provided */}
                    {header && (
                        <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                            {header}
                        </Typography>
                    )}

                    {/* Right side icons - Original Functionality */}
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        {/* Stats Icon */}
                        <IconButton
                            color="inherit"
                            component={Link}
                            href={route('dashboard')}
                            title="View Stats"
                            sx={{
                                '&:hover': {
                                    backgroundColor: theme.palette.action.hover,
                                }
                            }}
                        >
                        </IconButton>

                        {/* Theme Toggle */}
                        <IconButton
                            color="inherit"
                            onClick={toggleTheme}
                            title="Toggle Theme"
                            sx={{
                                '&:hover': {
                                    backgroundColor: theme.palette.action.hover,
                                }
                            }}
                        >
                            {isDark ? <Flare /> : <DarkMode />}
                        </IconButton>

                        {/* User Menu */}
                        <IconButton
                            color="inherit"
                            onClick={handleMenuOpen}
                            title="User Menu"
                            sx={{
                                '&:hover': {
                                    backgroundColor: theme.palette.action.hover,
                                }
                            }}
                        >
                            <Avatar
                                sx={{
                                    width: 32,
                                    height: 32,
                                    bgcolor: theme.palette.primary.main,
                                }}
                            >
                                {user?.name?.charAt(0)?.toUpperCase() || 'U'}
                            </Avatar>
                        </IconButton>

                        <Menu
                            anchorEl={anchorEl}
                            open={Boolean(anchorEl)}
                            onClose={handleMenuClose}
                            onClick={handleMenuClose}
                            PaperProps={{
                                elevation: 3,
                                sx: {
                                    overflow: 'visible',
                                    filter: 'drop-shadow(0px 2px 8px rgba(0,0,0,0.32))',
                                    mt: 1.5,
                                    '& .MuiAvatar-root': {
                                        width: 32,
                                        height: 32,
                                        mr: 1,
                                    },
                                },
                            }}
                        >
                            <MenuItem component={Link} href={route('profile.edit')}>
                                <Avatar /> Profile
                            </MenuItem>
                            <MenuItem onClick={handleLogout}>
                                <ListItemIcon>
                                    <Logout fontSize="small" />
                                </ListItemIcon>
                                Logout
                            </MenuItem>
                        </Menu>
                    </Box>
                </Toolbar>
            </AppBar>

            <Box
                component="main"
                sx={{
                    flexGrow: 1,
                    p: 3,
                    width: { md: `calc(100% - ${drawerWidth}px)` },
                    backgroundColor: theme.palette.background.default,
                    minHeight: '100vh',
                }}
            >
                <Toolbar />
                {children}
            </Box>
        </Box>
    );
};

export default AuthenticatedLayout;
