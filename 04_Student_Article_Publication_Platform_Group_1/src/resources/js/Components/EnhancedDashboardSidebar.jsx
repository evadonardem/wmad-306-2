import { Link } from '@inertiajs/react';
import {
    Box,
    Drawer,
    List,
    ListItem,
    ListItemIcon,
    ListItemText,
    Typography,
    Divider,
    useMediaQuery,
    useTheme,
    IconButton,
    Avatar,
    Badge,
    Collapse
} from '@mui/material';
import {
    Dashboard,
    Article,
    Edit,
    Visibility,
    History,
    Star,
    Comment,
    TrendingUp,
    People,
    Settings,
    ExpandLess,
    ExpandMore,
    Menu as MenuIcon
} from '@mui/icons-material';

export default function DashboardSidebar({ menuItems, open, onClose, title, userRole }) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const drawerWidth = 280;

    const getRoleIcon = (role) => {
        switch (role) {
            case 'writer':
                return <Edit sx={{ color: 'primary.main' }} />;
            case 'editor':
                return <Visibility sx={{ color: 'secondary.main' }} />;
            case 'student':
                return <Star sx={{ color: 'success.main' }} />;
            default:
                return <Dashboard sx={{ color: 'info.main' }} />;
        }
    };

    const getRoleColor = (role) => {
        switch (role) {
            case 'writer':
                return 'primary.main';
            case 'editor':
                return 'secondary.main';
            case 'student':
                return 'success.main';
            default:
                return 'info.main';
        }
    };

    const [expandedItems, setExpandedItems] = useState({});

    const handleToggleExpand = (item) => {
        setExpandedItems(prev => ({
            ...prev,
            [item.label]: !prev[item.label]
        }));
    };

    const content = (
        <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
            {/* Header */}
            <Box sx={{ 
                p: 3, 
                background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                color: 'white'
            }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    {getRoleIcon(userRole)}
                    <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                        {title}
                    </Typography>
                </Box>
                
                {/* User Avatar */}
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Avatar
                        sx={{ 
                            width: 32, 
                            height: 32,
                            backgroundColor: 'rgba(255, 255, 255, 0.2)',
                            border: '2px solid rgba(255, 255, 255, 0.3)'
                        }}
                    >
                        <Typography variant="caption" sx={{ fontWeight: 'bold' }}>
                            U
                        </Typography>
                    </Avatar>
                    <Box sx={{ flex: 1 }}>
                        <Typography variant="body2" sx={{ opacity: 0.9 }}>
                            User Name
                        </Typography>
                        <Typography variant="caption" sx={{ opacity: 0.7 }}>
                            {userRole?.charAt(0).toUpperCase() + userRole?.slice(1)}
                        </Typography>
                    </Box>
                </Box>
            </Box>

            <Divider sx={{ backgroundColor: 'rgba(255, 255, 255, 0.1)' }} />

            {/* Navigation Items */}
            <List sx={{ 
                pt: 2, 
                pb: 2,
                flex: 1,
                overflow: 'auto'
            }}>
                {(menuItems || []).map((item, index) => {
                    // Validate item to prevent React error #31
                    if (!item || typeof item !== 'object') return null;
                    
                    return (
                        <Box key={item.id || index}>
                            <ListItem
                                component={Link}
                                href={item.href || '#'}
                                onClick={() => isMobile && onClose()}
                                sx={{
                                    px: 2,
                                    py: 1.5,
                                    mb: 0.5,
                                    mx: 1,
                                    borderRadius: 1,
                                color: 'rgba(255, 255, 255, 0.9)',
                                textDecoration: 'none',
                                transition: 'all 0.3s ease',
                                '&:hover': {
                                    backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                    color: 'white',
                                    transform: 'translateX(4px)',
                                },
                                '&.Mui-selected': {
                                    backgroundColor: 'rgba(255, 255, 255, 0.15)',
                                    color: 'white',
                                    borderLeft: `3px solid ${theme.palette.primary.main}`,
                                },
                            }}
                        >
                            <ListItemIcon sx={{ 
                                color: 'inherit',
                                minWidth: 40,
                                fontSize: 20
                            }}>
                                {item.icon}
                            </ListItemIcon>
                            <ListItemText 
                                primary={item.label} 
                                primaryTypographyProps={{
                                    fontSize: '0.875rem',
                                    fontWeight: 500
                                }}
                            />
                            
                            {/* Badge for notifications or counts */}
                            {item.badge && (
                                <Badge
                                    badgeContent={item.badge}
                                    color="error"
                                    sx={{
                                        position: 'absolute',
                                        right: 16,
                                        top: '50%',
                                        transform: 'translateY(-50%)'
                                    }}
                                />
                            )}
                        </ListItem>

                        {/* Sub-items with expand/collapse */}
                        {item.subItems && (
                            <Box>
                                <ListItem
                                    onClick={() => handleToggleExpand(item)}
                                    sx={{
                                        px: 2,
                                        py: 1,
                                        mx: 1,
                                        borderRadius: 1,
                                        color: 'rgba(255, 255, 255, 0.7)',
                                        cursor: 'pointer',
                                        transition: 'all 0.3s ease',
                                        '&:hover': {
                                            backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                            color: 'rgba(255, 255, 255, 0.9)',
                                        },
                                    }}
                                >
                                    <ListItemIcon sx={{ color: 'inherit', minWidth: 40 }}>
                                        {expandedItems[item.label] ? <ExpandLess /> : <ExpandMore />}
                                    </ListItemIcon>
                                    <ListItemText 
                                        primary={item.label} 
                                        primaryTypographyProps={{
                                            fontSize: '0.8rem',
                                            fontWeight: 400
                                        }}
                                    />
                                </ListItem>
                                
                                <Collapse in={expandedItems[item.label]} timeout="auto" unmountOnExit>
                                    <List sx={{ pl: 4 }}>
                                        {(item.subItems || []).map((subItem, subIndex) => {
                                            // Validate subItem to prevent React error #31
                                            if (!subItem || typeof subItem !== 'object') return null;
                                            
                                            return (
                                                <ListItem
                                                    key={subItem.id || subIndex}
                                                    component={Link}
                                                    href={subItem.href || '#'}
                                                    onClick={() => isMobile && onClose()}
                                                    sx={{
                                                        px: 2,
                                                        py: 1,
                                                        mx: 1,
                                                        borderRadius: 1,
                                                        color: 'rgba(255, 255, 255, 0.7)',
                                                        textDecoration: 'none',
                                                        transition: 'all 0.3s ease',
                                                        '&:hover': {
                                                            backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                                            color: 'rgba(255, 255, 255, 0.9)',
                                                        },
                                                    }}
                                                >
                                                    <ListItemIcon sx={{ 
                                                        color: 'inherit',
                                                        minWidth: 32,
                                                        fontSize: 16
                                                    }}>
                                                        {subItem.icon}
                                                    </ListItemIcon>
                                                    <ListItemText 
                                                    primary={subItem.label} 
                                                    primaryTypographyProps={{
                                                        fontSize: '0.8rem',
                                                        fontWeight: 400
                                                    }}
                                                />
                                            </ListItem>
                                        ))}
                                    </List>
                                </Collapse>
                            </Box>
                        )}
                    </Box>
                    );
                })}
            </List>

            {/* Footer */}
            <Box sx={{ 
                p: 2, 
                borderTop: '1px solid rgba(255, 255, 255, 0.1)',
                mt: 'auto'
            }}>
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                    <ListItem
                        component={Link}
                        href={route('settings')}
                        sx={{
                            px: 1,
                            py: 0.5,
                            borderRadius: 1,
                            color: 'rgba(255, 255, 255, 0.7)',
                            textDecoration: 'none',
                            transition: 'all 0.3s ease',
                            '&:hover': {
                                backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                color: 'rgba(255, 255, 255, 0.9)',
                            },
                        }}
                    >
                        <ListItemIcon sx={{ color: 'inherit', minWidth: 32 }}>
                            <Settings sx={{ fontSize: 16 }} />
                        </ListItemIcon>
                        <ListItemText 
                            primary="Settings" 
                            primaryTypographyProps={{
                                fontSize: '0.8rem',
                                fontWeight: 400
                            }}
                        />
                    </ListItem>
                    
                    <ListItem
                        component={Link}
                        href={route('logout')}
                        method="post"
                        sx={{
                            px: 1,
                            py: 0.5,
                            borderRadius: 1,
                            color: 'rgba(255, 255, 255, 0.7)',
                            textDecoration: 'none',
                            transition: 'all 0.3s ease',
                            '&:hover': {
                                backgroundColor: 'rgba(255, 255, 255, 0.1)',
                                color: 'rgba(255, 255, 255, 0.9)',
                            },
                        }}
                    >
                        <ListItemIcon sx={{ color: 'inherit', minWidth: 32 }}>
                            <MenuIcon sx={{ fontSize: 16 }} />
                        </ListItemIcon>
                        <ListItemText 
                            primary="Logout" 
                            primaryTypographyProps={{
                                fontSize: '0.8rem',
                                fontWeight: 400
                            }}
                        />
                    </ListItem>
                </Box>
            </Box>
        </Box>
    );

    return (
        <Drawer
            variant={isMobile ? 'temporary' : 'persistent'}
            anchor="left"
            open={open}
            onClose={onClose}
            sx={{
                width: drawerWidth,
                flexShrink: 0,
                '& .MuiDrawer-paper': {
                    width: drawerWidth,
                    boxSizing: 'border-box',
                    background: 'linear-gradient(180deg, #667eea 0%, #764ba2 100%)',
                    borderRight: '1px solid rgba(255, 255, 255, 0.1)',
                    boxShadow: '2px 0 8px rgba(0,0,0,0.15)',
                },
            }}
        >
            {content}
        </Drawer>
    );
}
