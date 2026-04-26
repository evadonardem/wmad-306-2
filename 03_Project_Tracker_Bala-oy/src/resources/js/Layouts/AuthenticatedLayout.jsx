import { useState } from 'react';
import { Link, router } from '@inertiajs/react';
import { 
    AppBar, Toolbar, Box, Typography, IconButton, Menu, MenuItem, 
    Avatar, Button, Container, Drawer, List, ListItem, 
    ListItemText, ListItemIcon, Divider
} from '@mui/material';
import { 
    EmojiEvents as RHJEIcon, // Updated to Crown/Trophy Icon
    Menu as MenuIcon,
    Dashboard as DashboardIcon,
    FolderCopy as ProjectIcon,
    CheckCircle as TaskIcon,
    Person as ProfileIcon,
    Logout as LogoutIcon,
    ExpandMore as ArrowDownIcon
} from '@mui/icons-material';

export default function Authenticated({ user, header, children }) {
    const [anchorEl, setAnchorEl] = useState(null);
    const [mobileOpen, setMobileOpen] = useState(false);

    const navLinks = [
        { name: 'Dashboard', route: 'dashboard', icon: <DashboardIcon /> },
        { name: 'Projects', route: 'projects.index', icon: <ProjectIcon /> }, 
        { name: 'Tasks', route: 'tasks.index', icon: <TaskIcon /> },          
    ];

    const handleMenuOpen = (event) => setAnchorEl(event.currentTarget);
    const handleMenuClose = () => setAnchorEl(null);
    const toggleMobileDrawer = () => setMobileOpen(!mobileOpen);

    const handleLogout = () => {
        handleMenuClose();
        router.post(route('logout'));
    };

    const styles = {
        appBar: {
            backgroundColor: 'rgba(255, 255, 255, 0.8)', 
            backdropFilter: 'blur(20px)',                
            borderBottom: '1px solid rgba(255, 255, 255, 0.3)',
            boxShadow: '0 4px 30px rgba(0, 0, 0, 0.03)',
            color: '#1d1d1f',
        },
        logoText: {
            color: '#1d1d1f', // Solid dark color for the bold RHJE look
            fontWeight: 900,
            letterSpacing: '-0.04em',
            textTransform: 'uppercase'
        },
        navButton: (active) => ({
            textTransform: 'none',
            fontWeight: active ? 700 : 500,
            color: active ? '#0071e3' : '#6e6e73',
            fontSize: '0.95rem',
            mx: 1,
            '&:hover': {
                backgroundColor: 'rgba(0, 113, 227, 0.08)',
                color: '#0071e3',
            }
        })
    };

    return (
        <Box sx={{ minHeight: '100vh', backgroundColor: '#c2e4f1' }}> {/* Updated Background Color */}
            
            <AppBar position="sticky" elevation={0} sx={styles.appBar}>
                <Container maxWidth="xl">
                    <Toolbar disableGutters sx={{ justifyContent: 'space-between', height: 64 }}>
                        
                        {/* LEFT: Logo & Brand */}
                        <Box display="flex" alignItems="center">
                            <IconButton 
                                onClick={toggleMobileDrawer}
                                sx={{ display: { xs: 'flex', md: 'none' }, mr: 1, color: '#1d1d1f' }}
                            >
                                <MenuIcon />
                            </IconButton>

                            <Link href={route('dashboard')} style={{ textDecoration: 'none', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <Box sx={{ 
                                    width: 36, height: 36, borderRadius: '10px', 
                                    bgcolor: '#0071e3', display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    boxShadow: '0 4px 12px rgba(0,113,227,0.3)'
                                }}>
                                    <RHJEIcon sx={{ color: 'white', fontSize: 20 }} />
                                </Box>
                                <Typography variant="h5" sx={styles.logoText}>
                                    RHJE
                                </Typography>
                            </Link>

                            {/* Desktop Navigation */}
                            <Box sx={{ display: { xs: 'none', md: 'flex' }, ml: 4 }}>
                                {navLinks.map((link) => (
                                    <Button
                                        key={link.name}
                                        component={Link}
                                        href={route(link.route)}
                                        sx={styles.navButton(route().current(link.route))}
                                    >
                                        {link.name}
                                    </Button>
                                ))}
                            </Box>
                        </Box>

                        {/* RIGHT: User Profile */}
                        <Box>
                            <Button 
                                onClick={handleMenuOpen}
                                endIcon={<ArrowDownIcon sx={{ fontSize: 16, opacity: 0.5 }} />}
                                sx={{ textTransform: 'none', color: '#1d1d1f', p: 1, borderRadius: '12px' }}
                            >
                                <Avatar 
                                    sx={{ width: 32, height: 32, mr: 1, bgcolor: '#86868b', fontSize: 14 }}
                                    alt={user.name}
                                >
                                    {user.name.charAt(0)}
                                </Avatar>
                                <Typography variant="body2" fontWeight="600" sx={{ display: { xs: 'none', sm: 'block' } }}>
                                    {user.name}
                                </Typography>
                            </Button>

                            <Menu
                                anchorEl={anchorEl}
                                open={Boolean(anchorEl)}
                                onClose={handleMenuClose}
                                PaperProps={{
                                    elevation: 0,
                                    sx: {
                                        mt: 1.5,
                                        width: 200,
                                        borderRadius: '16px',
                                        boxShadow: '0 10px 40px rgba(0,0,0,0.1)',
                                        border: '1px solid rgba(0,0,0,0.05)'
                                    }
                                }}
                                transformOrigin={{ horizontal: 'right', vertical: 'top' }}
                                anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
                            >
                                <MenuItem component={Link} href={route('profile.edit')} onClick={handleMenuClose} sx={{ py: 1.5 }}>
                                    <ListItemIcon><ProfileIcon fontSize="small" /></ListItemIcon>
                                    <ListItemText primary="Profile" />
                                </MenuItem>
                                <Divider sx={{ my: 1 }} />
                                <MenuItem onClick={handleLogout} sx={{ py: 1.5, color: '#FF2D55' }}>
                                    <ListItemIcon><LogoutIcon fontSize="small" sx={{ color: '#FF2D55' }} /></ListItemIcon>
                                    <ListItemText primary="Log Out" />
                                </MenuItem>
                            </Menu>
                        </Box>
                    </Toolbar>
                </Container>
            </AppBar>

            {/* Page Header */}
            {header && (
                <Box sx={{ 
                    bgcolor: 'rgba(255,255,255,0.4)', // Slightly more transparent for the blue background
                    borderBottom: '1px solid rgba(0,0,0,0.05)',
                    py: 3 
                }}>
                    <Container maxWidth="xl">
                        {header}
                    </Container>
                </Box>
            )}

            <main>{children}</main>

            {/* Mobile Drawer */}
            <Drawer
                variant="temporary"
                open={mobileOpen}
                onClose={toggleMobileDrawer}
                ModalProps={{ keepMounted: true }}
                sx={{ '& .MuiDrawer-paper': { width: 280, borderRadius: '0 20px 20px 0' } }}
            >
                <Box sx={{ p: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Box sx={{ width: 40, height: 40, borderRadius: '12px', bgcolor: '#0071e3', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <RHJEIcon sx={{ color: 'white' }} />
                    </Box>
                    <Typography variant="h6" fontWeight="900" sx={{ letterSpacing: '-0.04em' }}>RHJE</Typography>
                </Box>
                <Divider />
                <List sx={{ px: 2, py: 2 }}>
                    {navLinks.map((link) => (
                        <ListItem 
                            key={link.name} 
                            button 
                            component={Link} 
                            href={route(link.route)} 
                            sx={{ 
                                borderRadius: '12px', 
                                mb: 1,
                                backgroundColor: route().current(link.route) ? 'rgba(0, 113, 227, 0.1)' : 'transparent',
                                color: route().current(link.route) ? '#0071e3' : 'inherit'
                            }}
                        >
                            <ListItemIcon sx={{ color: route().current(link.route) ? '#0071e3' : 'inherit' }}>
                                {link.icon}
                            </ListItemIcon>
                            <ListItemText primary={link.name} primaryTypographyProps={{ fontWeight: 600 }} />
                        </ListItem>
                    ))}
                    <Divider sx={{ my: 1 }} />
                    <ListItem button onClick={handleLogout} sx={{ borderRadius: '12px', color: '#FF2D55' }}>
                        <ListItemIcon><LogoutIcon sx={{ color: '#FF2D55' }} /></ListItemIcon>
                        <ListItemText primary="Log Out" primaryTypographyProps={{ fontWeight: 600 }} />
                    </ListItem>
                </List>
            </Drawer>
        </Box>
    );
}