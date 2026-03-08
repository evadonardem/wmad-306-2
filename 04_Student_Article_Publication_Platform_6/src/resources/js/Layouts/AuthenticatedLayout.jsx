import AIAssistantWidget from '@/Components/AIAssistantWidget';
import ApplicationLogo from '@/Components/ApplicationLogo';
import ThemeModeToggle from '@/Components/ThemeModeToggle';
import { Link, router, usePage } from '@inertiajs/react';
import MenuIcon from '@mui/icons-material/Menu';
import {
    AppBar,
    Avatar,
    Box,
    Button,
    Chip,
    Container,
    Drawer,
    IconButton,
    List,
    ListItem,
    ListItemButton,
    ListItemText,
    Stack,
    Toolbar,
    Typography,
} from '@mui/material';
import { alpha, useTheme } from '@mui/material/styles';
import { useMemo, useState } from 'react';

export default function AuthenticatedLayout({ header, children, fullWidth = false }) {
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';
    
    const { auth } = usePage().props;
    const user = auth?.user;
    
    // SAFE ARRAY FIX: Ensures Laravel's roles are always read as a JavaScript Array
    const rawRoles = auth?.roles ?? [];
    const roles = Array.isArray(rawRoles) ? rawRoles : Object.values(rawRoles);
    const isSuperAdmin = roles.includes('superadmin') || roles.includes('super-admin');
    
    const [mobileOpen, setMobileOpen] = useState(false);

    // 1. Determine the highest ranking role to display on the Badge
    const roleMeta = useMemo(() => {
        if (isSuperAdmin) {
            return { label: 'Super Admin', tone: 'error', homeHref: route('admin.requests') };
        }
        if (roles.includes('editor')) {
            return { label: 'Editor', tone: 'secondary', homeHref: route('editor.dashboard') };
        }
        if (roles.includes('writer')) {
            return { label: 'Writer', tone: 'info', homeHref: route('writer.dashboard') };
        }
        if (roles.includes('student')) {
            return { label: 'Student', tone: 'success', homeHref: route('student.dashboard') };
        }
        return { label: 'Member', tone: 'default', homeHref: route('dashboard') };
    }, [isSuperAdmin, roles]);

    // 2. Build the Navigation array dynamically based on ALL roles the user has
    const navItems = useMemo(() => {
        const items = [];
        
        // EVERYONE gets the Main Dashboard at the very top of their menu
        items.push({ label: 'Journals', href: route('dashboard'), name: 'dashboard' });
        
        if (isSuperAdmin) {
            items.push({ label: 'Admin Panel', href: route('admin.requests'), name: 'admin.requests' });
            items.push({ label: 'Moderation', href: route('admin.content'), name: 'admin.content' });
        }
        if (roles.includes('editor')) {
            items.push({ label: 'Editor Desk', href: route('editor.dashboard'), name: 'editor.dashboard' });
        }
        if (roles.includes('writer')) {
            items.push({ label: 'Writer Hub', href: route('writer.dashboard'), name: 'writer.dashboard' });
            items.push({ label: 'New Article', href: route('writer.articles.create'), name: 'writer.articles.create' });
        }
        
        // Everyone gets the Student dashboard to read articles (or if they have no role yet)
        if (roles.includes('student') || items.length === 1) { // length === 1 means only Main Dashboard is there
            items.push({ label: 'Campus Journals', href: route('student.dashboard'), name: 'student.dashboard' });
        }

        items.push({ label: 'Profile', href: route('profile.edit'), name: 'profile.edit' });
        
        return items;
    }, [isSuperAdmin, roles]);

    const navList = (
        <Box sx={{ width: 300, minWidth: 300, height: '100%', display: 'flex', flexDirection: 'column', bgcolor: 'background.default' }}>
            <Stack
                component={Link}
                href={roleMeta.homeHref}
                direction="row"
                spacing={1.5}
                alignItems="center"
                sx={{ p: 2.5, textDecoration: 'none', color: 'text.primary', borderBottom: '1px solid', borderColor: 'divider' }}
            >
                <ApplicationLogo style={{ width: 32, height: 32, color: '#2f6fdb' }} />
                <Box>
                    <Typography variant="h6" sx={{ fontWeight: 800, lineHeight: 1.2 }}>Campus Press</Typography>
                    <Typography variant="caption" color="text.secondary">Student Journal Platform</Typography>
                </Box>
            </Stack>
            <List sx={{ py: 2, px: 1.5, flex: 1 }}>
                {navItems.map((item) => {
                    const isActive = route().current(item.name);
                    return (
                        <ListItem key={item.name} disablePadding sx={{ mb: 0.5 }}>
                            <ListItemButton
                                component={Link}
                                href={item.href}
                                selected={isActive}
                                onClick={() => setMobileOpen(false)}
                                sx={{
                                    borderRadius: '1rem',
                                    py: 1.25,
                                    px: 2,
                                    '&.Mui-selected': {
                                        bgcolor: alpha('#2f6fdb', isDark ? 0.2 : 0.1),
                                        color: '#2f6fdb',
                                        fontWeight: 700,
                                        '&:hover': { bgcolor: alpha('#2f6fdb', isDark ? 0.28 : 0.16) },
                                    },
                                    '&:hover': { bgcolor: alpha('#2f6fdb', 0.06) },
                                }}
                            >
                                <ListItemText primary={item.label} primaryTypographyProps={{ fontWeight: isActive ? 700 : 500 }} />
                            </ListItemButton>
                        </ListItem>
                    );
                })}
            </List>
            <Box sx={{ p: 2, borderTop: '1px solid', borderColor: 'divider' }}>
                <Button
                    fullWidth
                    variant="outlined"
                    onClick={() => router.post(route('logout'))}
                    sx={{
                        borderRadius: '1rem',
                        fontWeight: 700,
                        py: 1.25,
                        borderColor: alpha('#2f6fdb', 0.4),
                        color: 'text.primary',
                        '&:hover': { borderColor: '#2f6fdb', bgcolor: alpha('#2f6fdb', 0.06) },
                    }}
                >
                    Log Out
                </Button>
            </Box>
        </Box>
    );

    return (
        <Box
            sx={{
                minHeight: '100vh',
                background: `radial-gradient(1200px 420px at 15% -15%, ${alpha('#2f6fdb', isDark ? 0.2 : 0.12)}, transparent), ${theme.palette.background.default}`,
                transition: 'background 0.3s ease',
            }}
        >
            <AppBar
                position="sticky"
                elevation={0}
                sx={{
                    borderBottom: `1px solid ${theme.palette.divider}`,
                    backgroundColor: alpha(theme.palette.background.paper, 0.92),
                    backdropFilter: 'blur(12px)',
                    color: 'text.primary',
                    transition: 'background-color 0.3s ease, border-color 0.3s ease',
                }}
            >
                <Toolbar sx={{ minHeight: { xs: 64, md: 72 }, px: { xs: 1.5, md: 2 } }}>
                    <IconButton
                        aria-label="Open menu"
                        sx={{ display: { lg: 'none' }, mr: 0.5, color: 'text.primary' }}
                        onClick={() => setMobileOpen(true)}
                    >
                        <MenuIcon />
                    </IconButton>

                    <Stack
                        component={Link}
                        href={roleMeta.homeHref}
                        direction="row"
                        spacing={1.5}
                        sx={{ textDecoration: 'none', alignItems: 'center', color: 'text.primary', flexGrow: { xs: 1, lg: 0 }, minWidth: 0, mr: { lg: 4 } }}
                    >
                        <ApplicationLogo style={{ width: 32, height: 32, color: '#2f6fdb', flexShrink: 0 }} />
                        <Box sx={{ minWidth: 0 }}>
                            <Typography variant="h6" sx={{ fontWeight: 800, lineHeight: 1.2, letterSpacing: '-0.02em' }}>
                                Campus Press
                            </Typography>
                        </Box>
                    </Stack>

                    <Stack direction="row" spacing={0.5} sx={{ display: { xs: 'none', lg: 'flex' }, flexGrow: 1, alignItems: 'center' }}>
                        {navItems.map((item) => {
                            const isActive = route().current(item.name);
                            return (
                                <Button
                                    key={item.name}
                                    component={Link}
                                    href={item.href}
                                    sx={{
                                        px: 2,
                                        py: 1,
                                        borderRadius: '0.75rem',
                                        fontWeight: isActive ? 800 : 600,
                                        color: isActive ? '#2f6fdb' : 'text.primary',
                                        bgcolor: isActive ? alpha('#2f6fdb', 0.08) : 'transparent',
                                        '&:hover': {
                                            bgcolor: alpha('#2f6fdb', 0.1),
                                            color: '#2f6fdb',
                                        },
                                    }}
                                >
                                    {item.label}
                                </Button>
                            );
                        })}
                    </Stack>

                    <Stack direction="row" spacing={1.5} alignItems="center" sx={{ ml: 2 }}>
                        <ThemeModeToggle />
                        <Chip
                            size="small"
                            label={roleMeta.label}
                            color={roleMeta.tone}
                            variant="outlined"
                            sx={{ fontWeight: 800, borderRadius: '0.5rem', display: { xs: 'none', sm: 'flex' } }}
                        />
                        <Avatar
                            src={user?.avatar_url ?? undefined}
                            alt={user?.name ?? 'User'}
                            sx={{ width: 38, height: 38, bgcolor: '#2f6fdb', fontWeight: 700, fontSize: '0.95rem' }}
                        >
                            {!user?.avatar_url ? (user?.name?.[0] ?? 'U') : null}
                        </Avatar>
                        <Typography variant="body2" sx={{ display: { xs: 'none', md: 'block' }, fontWeight: 700 }} noWrap>
                            {user?.name}
                        </Typography>
                        <Button
                            variant="outlined"
                            sx={{
                                display: { xs: 'none', lg: 'inline-flex' },
                                borderRadius: '0.75rem',
                                fontWeight: 700,
                                borderColor: alpha('#2f6fdb', 0.4),
                                '&:hover': { borderColor: '#2f6fdb', bgcolor: alpha('#2f6fdb', 0.06) },
                            }}
                            onClick={() => router.post(route('logout'))}
                        >
                            Logout
                        </Button>
                    </Stack>
                </Toolbar>
            </AppBar>

            <Drawer
                anchor="left"
                open={mobileOpen}
                onClose={() => setMobileOpen(false)}
                sx={{ display: { lg: 'none' } }}
                PaperProps={{
                    sx: {
                        width: 300,
                        maxWidth: '85vw',
                        borderRight: '1px solid',
                        borderColor: 'divider',
                        bgcolor: 'background.paper',
                    },
                }}
            >
                {navList}
            </Drawer>

            <Container
                maxWidth={fullWidth ? false : 'xl'}
                className="cp-page-enter"
                sx={{
                    py: { xs: 2.5, md: 4 },
                    px: fullWidth ? { xs: 2, md: 3 } : undefined,
                    transition: 'padding 0.2s ease',
                }}
            >
                {header ? <Box sx={{ mb: 3 }}>{header}</Box> : null}
                {children}
            </Container>

            <AIAssistantWidget />
        </Box>
    );
}
