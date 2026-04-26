import { useState } from 'react';
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
    ExpandMore,
} from '@mui/icons-material';
import {
    LayoutDashboard,
    FileText,
    Edit3,
    Eye,
    Clock,
    Star,
    MessageSquare,
    TrendingUp,
    Users,
    Settings,
    LogOut,
    Menu as MenuIcon,
    X,
    Sparkles,
    CheckCircle,
    AlertCircle
} from 'lucide-react';

export default function LucideDashboardSidebar({ menuItems, open, onClose, title, userRole, userName = 'User' }) {
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));
    const [expandedItems, setExpandedItems] = useState({});
    const drawerWidth = 280;

    const getRoleIcon = (role) => {
        const iconSize = 24;
        const iconProps = { size: iconSize, strokeWidth: 2 };
        
        switch (role) {
            case 'writer':
                return <Edit3 {...iconProps} style={{ color: '#3B82F6' }} />;
            case 'editor':
                return <Eye {...iconProps} style={{ color: '#059669' }} />;
            case 'student':
                return <Star {...iconProps} style={{ color: '#0EA5E9' }} />;
            default:
                return <LayoutDashboard {...iconProps} style={{ color: '#3B82F6' }} />;
        }
    };

    const getRoleGradient = (role) => {
        switch (role) {
            case 'writer':
                return 'linear-gradient(135deg, #3B82F6 0%, #1E40AF 100%)';
            case 'editor':
                return 'linear-gradient(135deg, #059669 0%, #065F46 100%)';
            case 'student':
                return 'linear-gradient(135deg, #0EA5E9 0%, #0284C7 100%)';
            default:
                return 'linear-gradient(135deg, #3B82F6 0%, #059669 100%)';
        }
    };

    const getRoleColor = (role) => {
        switch (role) {
            case 'writer':
                return '#3B82F6';
            case 'editor':
                return '#059669';
            case 'student':
                return '#0EA5E9';
            default:
                return '#3B82F6';
        }
    };

    const handleToggleExpand = (itemLabel) => {
        setExpandedItems(prev => ({
            ...prev,
            [itemLabel]: !prev[itemLabel]
        }));
    };

    const handleClose = () => {
        if (isMobile) {
            onClose();
        }
    };

    const mainAvatarColor = getRoleColor(userRole);

    const content = (
        <Box sx={{ 
            height: '100%', 
            display: 'flex', 
            flexDirection: 'column',
            background: 'rgba(15, 23, 42, 0.95)',
            backdropFilter: 'blur(20px)',
            position: 'relative',
            overflow: 'hidden',
        }}>
            {/* Animated background */}
            <Box sx={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                height: '2px',
                background: `linear-gradient(90deg, transparent, ${mainAvatarColor}, transparent)`,
                animation: 'slideInLeft 3s ease-in-out infinite',
            }} />

            {/* Header with role gradient */}
            <Box sx={{ 
                p: 3,
                background: getRoleGradient(userRole),
                color: 'white',
                position: 'relative',
                overflow: 'hidden',
                animation: 'slideInDown 0.6s ease-out',
                '&::before': {
                    content: '""',
                    position: 'absolute',
                    top: 0,
                    left: '-100%',
                    width: '100%',
                    height: '100%',
                    background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent)',
                    transition: 'left 0.6s',
                },
                '&:hover::before': {
                    left: '100%',
                }
            }}>
                {/* Close button for mobile */}
                {isMobile && (
                    <IconButton
                        onClick={onClose}
                        sx={{
                            position: 'absolute',
                            top: 8,
                            right: 8,
                            color: 'white',
                        }}
                    >
                        <X size={20} />
                    </IconButton>
                )}

                {/* Header content */}
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                    <Box sx={{
                        animation: 'bounceIn 0.6s cubic-bezier(0.34, 1.56, 0.64, 1)',
                        display: 'flex',
                        alignItems: 'center',
                    }}>
                        {getRoleIcon(userRole)}
                    </Box>
                    <Box>
                        <Typography variant="h6" sx={{ fontWeight: 700, letterSpacing: '-0.5px' }}>
                            {title}
                        </Typography>
                        <Typography variant="caption" sx={{ opacity: 0.8, fontSize: '0.7rem' }}>
                            Role Dashboard
                        </Typography>
                    </Box>
                </Box>
                
                {/* User Avatar Section */}
                <Box sx={{ 
                    display: 'flex', 
                    alignItems: 'center', 
                    gap: 2,
                    animation: 'slideInLeft 0.8s ease-out'
                }}>
                    <Avatar
                        sx={{ 
                            width: 36, 
                            height: 36,
                            backgroundColor: 'rgba(255, 255, 255, 0.3)',
                            border: '2px solid rgba(255, 255, 255, 0.5)',
                            fontSize: '1rem',
                            fontWeight: 700,
                        }}
                    >
                        {userName?.charAt(0).toUpperCase()}
                    </Avatar>
                    <Box sx={{ flex: 1 }}>
                        <Typography variant="body2" sx={{ opacity: 0.95, fontWeight: 600 }}>
                            {userName}
                        </Typography>
                        <Typography variant="caption" sx={{ opacity: 0.7 }}>
                            {userRole?.charAt(0).toUpperCase() + (userRole?.slice(1) || 'User')}
                        </Typography>
                    </Box>
                </Box>
            </Box>

            <Divider sx={{ borderColor: 'rgba(148, 163, 184, 0.1)' }} />

            {/* Navigation Items */}
            <List sx={{ 
                pt: 2, 
                px: 1,
                pb: 2,
                flex: 1,
                overflow: 'auto',
                '&::-webkit-scrollbar': {
                    width: '6px',
                },
                '&::-webkit-scrollbar-track': {
                    background: 'rgba(148, 163, 184, 0.05)',
                },
                '&::-webkit-scrollbar-thumb': {
                    background: 'rgba(148, 163, 184, 0.2)',
                    borderRadius: '3px',
                    '&:hover': {
                        background: 'rgba(148, 163, 184, 0.3)',
                    }
                }
            }}>
                {(menuItems || []).map((item, index) => {
                    if (!item || typeof item !== 'object') return null;
                    
                    const hasSubItems = item.subItems && item.subItems.length > 0;
                    const isExpanded = expandedItems[item.label];

                    return (
                        <Box key={item.id || index} className="list-item-stagger">
                            {/* Main Item */}
                            <ListItem
                                component={hasSubItems ? 'div' : Link}
                                href={!hasSubItems ? (item.href || '#') : undefined}
                                onClick={() => {
                                    if (hasSubItems) {
                                        handleToggleExpand(item.label);
                                    } else {
                                        handleClose();
                                    }
                                }}
                                sx={{
                                    px: 2,
                                    py: 1.5,
                                    mb: 0.5,
                                    borderRadius: 1.5,
                                    color: 'rgba(241, 245, 249, 0.85)',
                                    textDecoration: 'none',
                                    transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                                    cursor: hasSubItems ? 'pointer' : 'inherit',
                                    position: 'relative',
                                    overflow: 'hidden',
                                    '&::before': {
                                        content: '""',
                                        position: 'absolute',
                                        left: 0,
                                        top: '50%',
                                        transform: 'translateY(-50%)',
                                        width: '3px',
                                        height: '0%',
                                        background: mainAvatarColor,
                                        transition: 'height 0.3s ease',
                                    },
                                    '&:hover': {
                                        backgroundColor: 'rgba(59, 130, 246, 0.1)',
                                        color: 'white',
                                        transform: 'translateX(4px)',
                                        '&::before': {
                                            height: '70%',
                                        }
                                    },
                                    '&:hover .menu-icon': {
                                        animation: 'bounceScale 0.6s ease-out',
                                        color: mainAvatarColor,
                                    }
                                }}
                            >
                                <ListItemIcon 
                                    className="menu-icon"
                                    sx={{ 
                                        color: 'inherit',
                                        minWidth: 40,
                                        fontSize: 20,
                                        transition: 'all 0.3s ease',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                    }}
                                >
                                    {item.icon || <LayoutDashboard size={18} />}
                                </ListItemIcon>
                                <ListItemText 
                                    primary={item.label} 
                                    primaryTypographyProps={{
                                        fontSize: '0.9rem',
                                        fontWeight: 500,
                                        letterSpacing: '-0.3px',
                                    }}
                                />
                                
                                {/* Count Badge */}
                                {item.count && (
                                    <Badge
                                        badgeContent={item.count}
                                        sx={{
                                            '& .MuiBadge-badge': {
                                                background: mainAvatarColor,
                                                color: 'white',
                                                fontWeight: 600,
                                                fontSize: '0.7rem',
                                            }
                                        }}
                                    />
                                )}

                                {/* Expand/Collapse Icon */}
                                {hasSubItems && (
                                    <Box sx={{ 
                                        ml: 1,
                                        display: 'flex',
                                        transition: 'transform 0.3s ease',
                                        transform: isExpanded ? 'rotate(180deg)' : 'rotate(0deg)',
                                    }}>
                                        <ExpandMore size={18} />
                                    </Box>
                                )}
                            </ListItem>

                            {/* Sub Items */}
                            {hasSubItems && (
                                <Collapse in={isExpanded} timeout="auto" unmountOnExit>
                                    <List sx={{ pl: 2, py: 0 }}>
                                        {(item.subItems || []).map((subItem, subIndex) => {
                                            if (!subItem || typeof subItem !== 'object') return null;
                                            
                                            return (
                                                <ListItem
                                                    key={subItem.id || subIndex}
                                                    component={Link}
                                                    href={subItem.href || '#'}
                                                    onClick={handleClose}
                                                    sx={{
                                                        px: 2,
                                                        py: 1,
                                                        mb: 0.5,
                                                        borderRadius: 1,
                                                        color: 'rgba(241, 245, 249, 0.7)',
                                                        textDecoration: 'none',
                                                        transition: 'all 0.3s ease',
                                                        fontSize: '0.85rem',
                                                        ml: 1,
                                                        '&::before': {
                                                            content: '""',
                                                            position: 'absolute',
                                                            left: '16px',
                                                            top: 0,
                                                            bottom: 0,
                                                            width: '1px',
                                                            background: 'rgba(148, 163, 184, 0.2)',
                                                        },
                                                        '&:hover': {
                                                            backgroundColor: 'rgba(59, 130, 246, 0.15)',
                                                            color: 'white',
                                                            transform: 'translateX(4px)',
                                                        },
                                                    }}
                                                >
                                                    <ListItemIcon sx={{ 
                                                        color: 'inherit',
                                                        minWidth: 32,
                                                        fontSize: 16
                                                    }}>
                                                        {subItem.icon || <LayoutDashboard size={14} />}
                                                    </ListItemIcon>
                                                    <ListItemText 
                                                        primary={subItem.label} 
                                                        primaryTypographyProps={{
                                                            fontSize: '0.8rem',
                                                            fontWeight: 400
                                                        }}
                                                    />
                                                </ListItem>
                                            );
                                        })}
                                    </List>
                                </Collapse>
                            )}
                        </Box>
                    );
                })}
            </List>

            <Divider sx={{ borderColor: 'rgba(148, 163, 184, 0.1)' }} />

            {/* Footer - Settings & Logout */}
            <Box sx={{ 
                p: 2,
                display: 'flex',
                flexDirection: 'column',
                gap: 0.5,
            }}>
                <ListItem
                    component={Link}
                    href={route('profile.edit')}
                    sx={{
                        px: 2,
                        py: 1,
                        borderRadius: 1,
                        color: 'rgba(241, 245, 249, 0.7)',
                        textDecoration: 'none',
                        transition: 'all 0.3s ease',
                        '&:hover': {
                            backgroundColor: 'rgba(59, 130, 246, 0.1)',
                            color: 'white',
                        },
                    }}
                >
                    <ListItemIcon sx={{ color: 'inherit', minWidth: 32 }}>
                        <Settings size={16} />
                    </ListItemIcon>
                    <ListItemText 
                        primary="Profile" 
                        primaryTypographyProps={{
                            fontSize: '0.85rem',
                            fontWeight: 500
                        }}
                    />
                </ListItem>

                <ListItem
                    component={Link}
                    href={route('logout')}
                    method="post"
                    sx={{
                        px: 2,
                        py: 1,
                        borderRadius: 1,
                        color: 'rgba(241, 245, 249, 0.7)',
                        textDecoration: 'none',
                        transition: 'all 0.3s ease',
                        '&:hover': {
                            backgroundColor: 'rgba(239, 68, 68, 0.1)',
                            color: '#F87171',
                        },
                    }}
                >
                    <ListItemIcon sx={{ color: 'inherit', minWidth: 32 }}>
                        <LogOut size={16} />
                    </ListItemIcon>
                    <ListItemText 
                        primary="Logout" 
                        primaryTypographyProps={{
                            fontSize: '0.85rem',
                            fontWeight: 500
                        }}
                    />
                </ListItem>
            </Box>
        </Box>
    );

    return (
        <>
            {/* Mobile Menu Button */}
            {isMobile && !open && (
                <IconButton
                    onClick={() => onClose?.()}
                    sx={{
                        position: 'fixed',
                        bottom: 20,
                        left: 20,
                        zIndex: 1000,
                        background: 'linear-gradient(135deg, #3B82F6 0%, #059669 100%)',
                        color: 'white',
                        '&:hover': {
                            transform: 'scale(1.1)',
                            boxShadow: '0 0 30px rgba(59, 130, 246, 0.6)',
                        }
                    }}
                >
                    <MenuIcon size={24} />
                </IconButton>
            )}

            {/* Desktop Drawer */}
            {!isMobile ? (
                <Box
                    sx={{
                        width: drawerWidth,
                        height: '100vh',
                        position: 'sticky',
                        top: 0,
                        boxShadow: '2px 0 20px rgba(0,0,0,0.2)',
                        borderRight: '1px solid rgba(148, 163, 184, 0.1)',
                    }}
                >
                    {content}
                </Box>
            ) : (
                <Drawer
                    anchor="left"
                    open={open}
                    onClose={onClose}
                    sx={{
                        width: drawerWidth,
                        flexShrink: 0,
                        '& .MuiDrawer-paper': {
                            width: drawerWidth,
                            boxSizing: 'border-box',
                        },
                    }}
                >
                    {content}
                </Drawer>
            )}
        </>
    );
}
