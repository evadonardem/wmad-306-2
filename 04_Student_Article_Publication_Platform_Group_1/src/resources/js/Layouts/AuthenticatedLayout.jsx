import ApplicationLogo from '@/Components/ApplicationLogo';
import Dropdown from '@/Components/Dropdown';
import NavLink from '@/Components/NavLink';
import { Link, usePage } from '@inertiajs/react';
import { useState } from 'react';
import {
    Box,
    AppBar,
    Toolbar,
    Typography,
    IconButton,
    Menu,
    MenuItem,
    Avatar,
    Badge,
    useMediaQuery,
    useTheme,
    Drawer,
    List,
    ListItem,
    ListItemIcon,
    ListItemText,
    Divider
} from '@mui/material';
import {
    Menu as MenuIcon,
    Notifications,
    Settings,
    Logout,
    Dashboard,
    Article,
    Person
} from '@mui/icons-material';

export default function AuthenticatedLayout({ header, children }) {
    const user = usePage().props.auth.user;
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [showingNavigationDropdown, setShowingNavigationDropdown] = useState(false);
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

    const handleLogout = () => {
        setShowingNavigationDropdown(false);
        // Inertia will handle the logout
    };

    const navigationItems = [
        {
            label: 'Dashboard',
            href: route('dashboard'),
            icon: <Dashboard />,
        },
        {
            label: 'Articles',
            href: '#',
            icon: <Article />,
        },
        {
            label: 'Profile',
            href: route('profile.edit'),
            icon: <Person />,
        },
    ];

    const drawerContent = (
        <Box onClick={() => setMobileMenuOpen(false)} sx={{ width: 280 }}>
            <Box sx={{ p: 2, display: 'flex', alignItems: 'center', gap: 2 }}>
                <ApplicationLogo sx={{ height: 40, width: 40 }} />
                <Typography variant="h6" sx={{ fontWeight: 'bold', color: 'primary.main' }}>
                    Article Platform
                </Typography>
            </Box>
            <Divider />
            <List sx={{ pt: 2 }}>
                {navigationItems.map((item, index) => (
                    <ListItem
                        key={index}
                        component={Link}
                        href={item.href}
                        sx={{
                            px: 2,
                            py: 1.5,
                            mb: 1,
                            mx: 1,
                            borderRadius: 1,
                            color: 'text.primary',
                            textDecoration: 'none',
                            '&:hover': {
                                backgroundColor: 'primary.light',
                                color: 'primary.main',
                            },
                        }}
                    >
                        <ListItemIcon sx={{ color: 'inherit' }}>
                            {item.icon}
                        </ListItemIcon>
                        <ListItemText primary={item.label} />
                    </ListItem>
                ))}
            </List>
        </Box>
    );

    return (
        <Box sx={{ display: 'flex', minHeight: '100vh' }}>
            {/* Navigation Bar */}
            <AppBar
                position="fixed"
                sx={{
                    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                    zIndex: theme.zIndex.appBar + 1,
                }}
            >
                <Toolbar sx={{ px: { xs: 2, sm: 3 } }}>
                    {/* Logo and Brand */}
                    <Box sx={{ display: 'flex', alignItems: 'center', flexGrow: 1 }}>
                        <Link href="/" style={{ textDecoration: 'none' }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                <ApplicationLogo sx={{ height: 32, width: 32 }} />
                                <Typography
                                    variant="h6"
                                    sx={{
                                        fontWeight: 'bold',
                                        color: 'white',
                                        display: { xs: 'none', sm: 'block' }
                                    }}
                                >
                                    Article Platform
                                </Typography>
                            </Box>
                        </Link>
                    </Box>

                    {/* Desktop Navigation */}
                    <Box sx={{ display: { xs: 'none', md: 'flex' }, alignItems: 'center', gap: 1 }}>
                        {navigationItems.map((item, index) => (
                            <NavLink
                                key={index}
                                href={item.href}
                                sx={{
                                    color: 'white',
                                    mx: 1,
                                    '&:hover': {
                                        backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                    },
                                }}
                            >
                                {item.label}
                            </NavLink>
                        ))}
                        
                        {/* Notifications */}
                        <IconButton
                            size="large"
                            sx={{ color: 'white', mx: 1 }}
                        >
                            <Badge badgeContent={0} color="error">
                                <Notifications />
                            </Badge>
                        </IconButton>

                        {/* User Menu */}
                        <Box sx={{ position: 'relative' }}>
                            <IconButton
                                size="large"
                                onClick={() => setShowingNavigationDropdown((previous) => !previous)}
                                sx={{ color: 'white' }}
                            >
                                <Avatar
                                    src={user.avatar}
                                    alt={user.name}
                                    sx={{ width: 32, height: 32 }}
                                >
                                    {user.name.charAt(0).toUpperCase()}
                                </Avatar>
                            </IconButton>

                            <Dropdown>
                                <Dropdown.Trigger>
                                    <span className="inline-flex rounded-md">
                                        <button
                                            type="button"
                                            className="inline-flex items-center rounded-md border border-transparent bg-white px-3 py-2 text-sm font-medium leading-4 text-gray-500 transition duration-150 ease-in-out hover:text-gray-700 focus:outline-none"
                                        >
                                            {user.name}
                                        </button>
                                    </span>
                                </Dropdown.Trigger>
                                <Dropdown.Content>
                                    <Dropdown.Link href={route('profile.edit')}>
                                        <Person sx={{ mr: 2 }} />
                                        Profile
                                    </Dropdown.Link>
                                    <Dropdown.Link href={route('settings')}>
                                        <Settings sx={{ mr: 2 }} />
                                        Settings
                                    </Dropdown.Link>
                                    <Dropdown.Link href={route('logout')} method="post" onClick={handleLogout}>
                                        <Logout sx={{ mr: 2 }} />
                                        Log Out
                                    </Dropdown.Link>
                                </Dropdown.Content>
                            </Dropdown>
                        </Box>
                    </Box>

                    {/* Mobile Menu Button */}
                    <IconButton
                        size="large"
                        onClick={() => setMobileMenuOpen(true)}
                        sx={{ 
                            color: 'white', 
                            display: { xs: 'flex', md: 'none' } 
                        }}
                    >
                        <MenuIcon />
                    </IconButton>
                </Toolbar>
            </AppBar>

            {/* Mobile Navigation Drawer */}
            <Drawer
                anchor="left"
                open={mobileMenuOpen}
                onClose={() => setMobileMenuOpen(false)}
                sx={{
                    display: { xs: 'block', md: 'none' },
                }}
            >
                {drawerContent}
            </Drawer>

            {/* Main Content */}
            <Box
                component="main"
                sx={{
                    flexGrow: 1,
                    pt: { xs: 14, sm: 16 }, // AppBar height
                    pb: 3,
                    backgroundColor: 'background.default',
                    minHeight: '100vh',
                }}
            >
                {/* Page Header */}
                {header && (
                    <Box sx={{ mb: 4 }}>
                        {header}
                    </Box>
                )}
                {/* Page Content */}
                <Box sx={{ px: { xs: 2, sm: 3 } }}>
                    {children}
                </Box>
            </Box>
        </Box>
    );
}
