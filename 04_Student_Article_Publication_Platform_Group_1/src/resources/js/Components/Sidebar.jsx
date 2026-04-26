import { useState } from 'react';
import { Link } from '@inertiajs/react';
import {
    Box,
    Drawer,
    List,
    ListItem,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    IconButton,
    Typography,
    Divider,
    useMediaQuery,
    useTheme
} from '@mui/material';
import {
    Menu as MenuIcon,
    Close as CloseIcon,
    Dashboard as DashboardIcon,
    Edit as EditIcon,
    RateReview as ReviewIcon,
    Publish as PublishIcon,
    Comment as CommentIcon,
    Add as AddIcon,
    Assignment as AssignmentIcon
} from '@mui/icons-material';

export default function Sidebar({ userRole = 'student', currentPath = '/' }) {
    const [open, setOpen] = useState(false);
    const theme = useTheme();
    const isMobile = useMediaQuery(theme.breakpoints.down('md'));

    const getMenuItems = () => {
        const baseItems = [
            { label: 'Dashboard', icon: <DashboardIcon />, href: '/dashboard', roles: ['student', 'writer', 'editor'] }
        ];

        const roleSpecificItems = {
            writer: [
                { label: 'Create Article', icon: <AddIcon />, href: '/writer/articles/create' },
                { label: 'My Drafts', icon: <EditIcon />, href: '/writer/drafts' },
                { label: 'Submitted Articles', icon: <AssignmentIcon />, href: '/writer/submitted' }
            ],
            editor: [
                { label: 'Pending Articles', icon: <ReviewIcon />, href: '/editor/pending' },
                { label: 'Published Articles', icon: <PublishIcon />, href: '/editor/published' },
                { label: 'Reviews', icon: <RateReview />, href: '/editor/reviews' }
            ],
            student: [
                { label: 'Published Articles', icon: <PublishIcon />, href: '/student/articles' },
                { label: 'My Comments', icon: <CommentIcon />, href: '/student/comments' }
            ]
        };

        return [...baseItems, ...(roleSpecificItems[userRole] || [])];
    };

    const menuItems = getMenuItems();

    const drawerContent = (
        <Box sx={{ width: isMobile ? 250 : 280, pt: 2 }}>
            <Box sx={{ px: 2, mb: 2 }}>
                <Typography variant="h6" sx={{ fontWeight: 'bold', color: 'primary.main' }}>
                    Article Platform
                </Typography>
                <Typography variant="caption" sx={{ color: 'text.secondary', textTransform: 'capitalize' }}>
                    {userRole} Dashboard
                </Typography>
            </Box>
            <Divider sx={{ mb: 2 }} />
            <List>
                {menuItems.map((item, index) => (
                    <ListItem key={index} disablePadding>
                        <ListItemButton
                            component={Link}
                            href={item.href}
                            selected={currentPath === item.href}
                            sx={{
                                '&.Mui-selected': {
                                    backgroundColor: 'primary.light',
                                    color: 'primary.main',
                                    '& .MuiListItemIcon-root': {
                                        color: 'primary.main'
                                    }
                                },
                                '&:hover': {
                                    backgroundColor: 'action.hover'
                                }
                            }}
                        >
                            <ListItemIcon sx={{ minWidth: 40 }}>
                                {item.icon}
                            </ListItemIcon>
                            <ListItemText primary={item.label} />
                        </ListItemButton>
                    </ListItem>
                ))}
            </List>
            <Divider sx={{ my: 2 }} />
            <Box sx={{ px: 2 }}>
                <Typography variant="caption" sx={{ color: 'text.secondary' }}>
                    Quick Actions
                </Typography>
            </Box>
        </Box>
    );

    return (
        <>
            {/* Mobile Toggle Button */}
            {isMobile && (
                <IconButton
                    onClick={() => setOpen(true)}
                    sx={{
                        position: 'fixed',
                        top: 16,
                        left: 16,
                        zIndex: 1300,
                        backgroundColor: 'primary.main',
                        color: 'white',
                        '&:hover': {
                            backgroundColor: 'primary.dark'
                        }
                    }}
                >
                    <MenuIcon />
                </IconButton>
            )}

            {/* Mobile Drawer */}
            {isMobile && (
                <Drawer
                    anchor="left"
                    open={open}
                    onClose={() => setOpen(false)}
                >
                    <Box
                        sx={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            px: 2,
                            py: 1
                        }}
                    >
                        <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                            Menu
                        </Typography>
                        <IconButton onClick={() => setOpen(false)} size="small">
                            <CloseIcon />
                        </IconButton>
                    </Box>
                    {drawerContent}
                </Drawer>
            )}

            {/* Desktop Sidebar */}
            {!isMobile && (
                <Box
                    sx={{
                        width: 280,
                        position: 'fixed',
                        left: 0,
                        top: 0,
                        height: '100vh',
                        backgroundColor: 'background.paper',
                        boxShadow: 1,
                        overflowY: 'auto',
                        borderRight: '1px solid',
                        borderColor: 'divider'
                    }}
                >
                    {drawerContent}
                </Box>
            )}
        </>
    );
}
