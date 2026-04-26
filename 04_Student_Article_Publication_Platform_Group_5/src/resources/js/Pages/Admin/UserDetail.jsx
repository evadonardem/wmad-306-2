import React, { useState } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Typography,
    Box,
    Button,
    Paper,
    Avatar,
    IconButton,
    Menu,
    MenuItem,
    ListItemIcon,
    Divider,
    Grid,
    Card,
    CardContent,
    CardActions,
    Chip,
    ThemeProvider,
    createTheme,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Select,
    FormControl,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions
} from '@mui/material';
import {
    ArrowBack,
    People,
    Person,
    Edit,
    RateReview,
    Visibility,
    Delete,
    Settings,
    Logout,
    Menu as MenuIcon,
    Article,
    History,
    Assignment
} from '@mui/icons-material';

const AdminUserDetail = ({ user }) => {
    const [anchorEl, setAnchorEl] = useState(null);
    const [deleteDialog, setDeleteDialog] = useState(false);

    const { auth } = usePage().props;

    const theme = createTheme({
        palette: {
            mode: 'dark',
            background: {
                default: '#0b1220',
                paper: '#1e293b',
            },
            primary: {
                main: '#8b5cf6',
            },
            secondary: {
                main: '#06b6d4',
            },
            success: {
                main: '#10b981',
            },
            warning: {
                main: '#f59e0b',
            },
            error: {
                main: '#ef4444',
            },
            text: {
                primary: '#ffffff',
                secondary: '#94a3b8',
            },
        },
        typography: {
            fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
        },
    });

    const handleLogout = () => {
        router.post('/logout', {}, {
            onFinish: () => {
                handleMenuClose();
            }
        });
    };

    const handleMenuClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    const handleBackToUsers = () => {
        router.get('/admin/users');
    };

    const handleUpdateRole = (newRole) => {
        router.put(`/admin/users/${user.id}/role`, { role: newRole }, {
            onSuccess: () => {
                router.reload();
            }
        });
    };

    const handleDeleteUser = () => {
        router.delete(`/admin/users/${user.id}`, {
            onSuccess: () => {
                router.get('/admin/users');
            }
        });
    };

    const getRoleColor = (role) => {
        switch(role) {
            case 'admin': return '#ef4444';
            case 'editor': return '#f59e0b';
            case 'writer': return '#10b981';
            case 'student': return '#3b82f6';
            default: return '#6b7280';
        }
    };

    const getPrimaryRole = (user) => {
        if (user.roles.some(r => r.name === 'admin')) return 'admin';
        if (user.roles.some(r => r.name === 'editor')) return 'editor';
        if (user.roles.some(r => r.name === 'writer')) return 'writer';
        if (user.roles.some(r => r.name === 'student')) return 'student';
        return 'none';
    };

    const getStatusColor = (status) => {
        switch(status) {
            case 'approved': return '#10b981';
            case 'pending': return '#f59e0b';
            case 'rejected': return '#ef4444';
            default: return '#6b7280';
        }
    };

    return (
        <ThemeProvider theme={theme}>
            <Head title={`User Details - ${user.name}`} />
            
            <Box sx={{ 
                minHeight: "100vh", 
                backgroundColor: "#0b1220",
                display: 'flex',
                flexDirection: 'column',
                background: 'radial-gradient(circle at 20% 50%, rgba(139, 92, 246, 0.1) 0%, transparent 50%), radial-gradient(circle at 80% 80%, rgba(139, 92, 246, 0.05) 0%, transparent 50%), #0b1220'
            }}>
                {/* Header */}
                <Box sx={{ 
                    backgroundColor: 'rgba(30, 41, 59, 0.8)', 
                    borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
                    p: 3,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    backdropFilter: 'blur(20px)'
                }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <IconButton 
                            onClick={handleBackToUsers}
                            sx={{ color: '#ffffff' }}
                        >
                            <ArrowBack />
                        </IconButton>
                        <Typography variant="h4" sx={{ color: '#ffffff', fontWeight: 800, letterSpacing: '-0.01em' }}>
                            User Details
                        </Typography>
                    </Box>

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <IconButton onClick={handleMenuClick} sx={{ color: '#ffffff' }}>
                            <MenuIcon />
                        </IconButton>
                        <Menu
                            anchorEl={anchorEl}
                            open={Boolean(anchorEl)}
                            onClose={handleMenuClose}
                        >
                            <MenuItem onClick={handleLogout}>
                                <ListItemIcon><Logout /></ListItemIcon>
                                Logout
                            </MenuItem>
                        </Menu>
                    </Box>
                </Box>

                {/* Main Content */}
                <Container maxWidth="xl" sx={{ flexGrow: 1, py: 4 }}>
                    <Grid container spacing={4}>
                        {/* User Profile Card */}
                        <Grid item xs={12} md={4}>
                            <Card sx={{ backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                                <CardContent sx={{ textAlign: 'center', pb: 2 }}>
                                    <Avatar 
                                        sx={{ 
                                            width: 80, 
                                            height: 80, 
                                            backgroundColor: getRoleColor(getPrimaryRole(user)),
                                            margin: '0 auto 2rem'
                                        }}
                                    >
                                        {user.name.charAt(0).toUpperCase()}
                                    </Avatar>
                                    <Typography variant="h4" sx={{ color: '#ffffff', mb: 1 }}>
                                        {user.name}
                                    </Typography>
                                    <Typography variant="body1" sx={{ color: '#94a3b8', mb: 2 }}>
                                        {user.email}
                                    </Typography>
                                    <Box sx={{ display: 'flex', justifyContent: 'center', gap: 1, mb: 2 }}>
                                        {user.roles.map((role) => (
                                            <Chip 
                                                key={role.id}
                                                label={role.name}
                                                size="small"
                                                sx={{ 
                                                    backgroundColor: getRoleColor(role.name), 
                                                    color: '#ffffff',
                                                    textTransform: 'capitalize'
                                                }} 
                                            />
                                        ))}
                                    </Box>
                                    <Typography variant="body2" sx={{ color: '#64748b', mb: 3 }}>
                                        Member since {new Date(user.created_at).toLocaleDateString()}
                                    </Typography>
                                    
                                    {/* Role Management */}
                                    <Box sx={{ mb: 3 }}>
                                        <Typography variant="h6" sx={{ color: '#ffffff', mb: 2, textAlign: 'left' }}>
                                            Change Role
                                        </Typography>
                                        <FormControl fullWidth disabled={user.id === auth.user.id}>
                                            <Select
                                                value={getPrimaryRole(user)}
                                                onChange={(e) => handleUpdateRole(e.target.value)}
                                                sx={{
                                                    color: '#ffffff',
                                                    backgroundColor: '#0f172a',
                                                    '& .MuiOutlinedInput-notchedOutline': {
                                                        borderColor: '#334155',
                                                    },
                                                    '&:hover .MuiOutlinedInput-notchedOutline': {
                                                        borderColor: '#475569',
                                                    },
                                                    '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                                                        borderColor: '#8b5cf6',
                                                    },
                                                    '& .MuiSvgIcon-root': {
                                                        color: '#94a3b8',
                                                    }
                                                }}
                                            >
                                                <MenuItem value="student">Student</MenuItem>
                                                <MenuItem value="writer">Writer</MenuItem>
                                                <MenuItem value="editor">Editor</MenuItem>
                                                <MenuItem value="admin">Admin</MenuItem>
                                            </Select>
                                        </FormControl>
                                        {user.id === auth.user.id && (
                                            <Typography variant="caption" sx={{ color: '#64748b', mt: 1, display: 'block' }}>
                                                You cannot change your own role
                                            </Typography>
                                        )}
                                    </Box>
                                    
                                    {/* Actions */}
                                    <Box sx={{ display: 'flex', gap: 1, justifyContent: 'center' }}>
                                        {user.id !== auth.user.id && (
                                            <Button 
                                                variant="outlined"
                                                color="error"
                                                startIcon={<Delete />}
                                                onClick={() => setDeleteDialog(true)}
                                                sx={{ 
                                                    borderColor: '#ef4444',
                                                    color: '#ef4444',
                                                    '&:hover': { borderColor: '#dc2626', color: '#dc2626' }
                                                }}
                                            >
                                                Delete User
                                            </Button>
                                        )}
                                    </Box>
                                </CardContent>
                            </Card>
                        </Grid>

                        {/* User Activity */}
                        <Grid item xs={12} md={8}>
                            <Grid container spacing={3}>
                                {/* Statistics */}
                                <Grid item xs={12}>
                                    <Card sx={{ backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                                        <CardContent>
                                            <Typography variant="h6" sx={{ color: '#ffffff', mb: 3 }}>
                                                Activity Statistics
                                            </Typography>
                                            <Grid container spacing={3}>
                                                <Grid item xs={6} md={3}>
                                                    <Box sx={{ textAlign: 'center' }}>
                                                        <Typography variant="h4" sx={{ color: '#8b5cf6', fontWeight: 'bold' }}>
                                                            {user.articles?.length || 0}
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                                            Articles
                                                        </Typography>
                                                    </Box>
                                                </Grid>
                                                <Grid item xs={6} md={3}>
                                                    <Box sx={{ textAlign: 'center' }}>
                                                        <Typography variant="h4" sx={{ color: '#10b981', fontWeight: 'bold' }}>
                                                            {user.role_requests?.length || 0}
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                                            Role Requests
                                                        </Typography>
                                                    </Box>
                                                </Grid>
                                                <Grid item xs={6} md={3}>
                                                    <Box sx={{ textAlign: 'center' }}>
                                                        <Typography variant="h4" sx={{ color: '#f59e0b', fontWeight: 'bold' }}>
                                                            {user.role_requests?.filter(r => r.status === 'pending').length || 0}
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                                            Pending
                                                        </Typography>
                                                    </Box>
                                                </Grid>
                                                <Grid item xs={6} md={3}>
                                                    <Box sx={{ textAlign: 'center' }}>
                                                        <Typography variant="h4" sx={{ color: '#ef4444', fontWeight: 'bold' }}>
                                                            {user.role_requests?.filter(r => r.status === 'rejected').length || 0}
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                                            Rejected
                                                        </Typography>
                                                    </Box>
                                                </Grid>
                                            </Grid>
                                        </CardContent>
                                    </Card>
                                </Grid>

                                {/* Role Requests History */}
                                <Grid item xs={12}>
                                    <Card sx={{ backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                                        <CardContent>
                                            <Typography variant="h6" sx={{ color: '#ffffff', mb: 3 }}>
                                                Role Request History
                                            </Typography>
                                            {user.role_requests && user.role_requests.length > 0 ? (
                                                <TableContainer>
                                                    <Table>
                                                        <TableHead>
                                                            <TableRow sx={{ backgroundColor: '#0f172a' }}>
                                                                <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Requested Role</TableCell>
                                                                <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Status</TableCell>
                                                                <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Date</TableCell>
                                                                <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Reason</TableCell>
                                                            </TableRow>
                                                        </TableHead>
                                                        <TableBody>
                                                            {user.role_requests.map((request) => (
                                                                <TableRow key={request.id} sx={{ '&:hover': { backgroundColor: '#0f172a' } }}>
                                                                    <TableCell>
                                                                        <Chip 
                                                                            label={request.requested_role}
                                                                            size="small"
                                                                            sx={{ 
                                                                                backgroundColor: '#3b82f6', 
                                                                                color: '#ffffff',
                                                                                textTransform: 'capitalize'
                                                                            }} 
                                                                        />
                                                                    </TableCell>
                                                                    <TableCell>
                                                                        <Chip 
                                                                            label={request.status}
                                                                            size="small"
                                                                            sx={{ 
                                                                                backgroundColor: getStatusColor(request.status), 
                                                                                color: '#ffffff',
                                                                                textTransform: 'capitalize'
                                                                            }} 
                                                                        />
                                                                    </TableCell>
                                                                    <TableCell sx={{ color: '#94a3b8' }}>
                                                                        {new Date(request.created_at).toLocaleDateString()}
                                                                    </TableCell>
                                                                    <TableCell sx={{ color: '#cbd5e0' }}>
                                                                        {request.reason || 'No reason provided'}
                                                                    </TableCell>
                                                                </TableRow>
                                                            ))}
                                                        </TableBody>
                                                    </Table>
                                                </TableContainer>
                                            ) : (
                                                <Box sx={{ textAlign: 'center', py: 4 }}>
                                                    <Typography variant="body1" sx={{ color: '#94a3b8' }}>
                                                        No role requests found
                                                    </Typography>
                                                </Box>
                                            )}
                                        </CardContent>
                                    </Card>
                                </Grid>

                                {/* Articles */}
                                <Grid item xs={12}>
                                    <Card sx={{ backgroundColor: '#1e293b', border: '1px solid #334155' }}>
                                        <CardContent>
                                            <Typography variant="h6" sx={{ color: '#ffffff', mb: 3 }}>
                                                Articles
                                            </Typography>
                                            {user.articles && user.articles.length > 0 ? (
                                                <TableContainer>
                                                    <Table>
                                                        <TableHead>
                                                            <TableRow sx={{ backgroundColor: '#0f172a' }}>
                                                                <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Title</TableCell>
                                                                <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Status</TableCell>
                                                                <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Created</TableCell>
                                                            </TableRow>
                                                        </TableHead>
                                                        <TableBody>
                                                            {user.articles.map((article) => (
                                                                <TableRow key={article.id} sx={{ '&:hover': { backgroundColor: '#0f172a' } }}>
                                                                    <TableCell sx={{ color: '#ffffff' }}>
                                                                        {article.title}
                                                                    </TableCell>
                                                                    <TableCell>
                                                                        <Chip 
                                                                            label={article.status || 'draft'}
                                                                            size="small"
                                                                            sx={{ 
                                                                                backgroundColor: getStatusColor(article.status), 
                                                                                color: '#ffffff',
                                                                                textTransform: 'capitalize'
                                                                            }} 
                                                                        />
                                                                    </TableCell>
                                                                    <TableCell sx={{ color: '#94a3b8' }}>
                                                                        {new Date(article.created_at).toLocaleDateString()}
                                                                    </TableCell>
                                                                </TableRow>
                                                            ))}
                                                        </TableBody>
                                                    </Table>
                                                </TableContainer>
                                            ) : (
                                                <Box sx={{ textAlign: 'center', py: 4 }}>
                                                    <Typography variant="body1" sx={{ color: '#94a3b8' }}>
                                                        No articles found
                                                    </Typography>
                                                </Box>
                                            )}
                                        </CardContent>
                                    </Card>
                                </Grid>
                            </Grid>
                        </Grid>
                    </Grid>

                    {/* Delete Confirmation Dialog */}
                    <Dialog open={deleteDialog} onClose={() => setDeleteDialog(false)}>
                        <DialogTitle sx={{ color: '#ffffff', backgroundColor: '#1e293b' }}>
                            Confirm User Deletion
                        </DialogTitle>
                        <DialogContent sx={{ backgroundColor: '#1e293b' }}>
                            <Typography sx={{ color: '#ffffff' }}>
                                Are you sure you want to delete user "{user.name}"? This action cannot be undone.
                            </Typography>
                        </DialogContent>
                        <DialogActions sx={{ backgroundColor: '#1e293b' }}>
                            <Button 
                                onClick={() => setDeleteDialog(false)}
                                sx={{ color: '#94a3b8' }}
                            >
                                Cancel
                            </Button>
                            <Button 
                                onClick={handleDeleteUser}
                                variant="contained"
                                sx={{ 
                                    backgroundColor: '#ef4444',
                                    '&:hover': { backgroundColor: '#dc2626' }
                                }}
                            >
                                Delete
                            </Button>
                        </DialogActions>
                    </Dialog>
                </Container>
            </Box>
        </ThemeProvider>
    );
};

export default AdminUserDetail;
