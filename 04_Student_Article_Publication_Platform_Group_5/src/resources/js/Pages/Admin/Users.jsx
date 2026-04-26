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
    TextField,
    InputAdornment,
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
    DialogActions,
    Container
} from '@mui/material';
import {
    ArrowBack,
    People,
    Person,
    Edit,
    RateReview,
    Visibility,
    Delete,
    Search,
    Settings,
    Logout,
    Menu as MenuIcon,
    FilterList
} from '@mui/icons-material';

const AdminUsers = ({ users }) => {
    const [anchorEl, setAnchorEl] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [roleFilter, setRoleFilter] = useState('all');
    const [deleteDialog, setDeleteDialog] = useState(null);

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

    const handleBackToDashboard = () => {
        router.get('/admin/dashboard');
    };

    const handleUpdateRole = (userId, newRole) => {
        router.put(`/admin/users/${userId}/role`, { role: newRole }, {
            onSuccess: () => {
                router.reload();
            }
        });
    };

    const handleViewUser = (userId) => {
        router.get(`/admin/users/${userId}`);
    };

    const handleDeleteUser = (userId) => {
        router.delete(`/admin/users/${userId}`, {
            onSuccess: () => {
                setDeleteDialog(null);
                router.reload();
            }
        });
    };

    const filteredUsers = users.filter(user => {
        const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                            user.email.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesRole = roleFilter === 'all' || 
                           (roleFilter === 'student' && user.roles.some(r => r.name === 'student')) ||
                           (roleFilter === 'writer' && user.roles.some(r => r.name === 'writer')) ||
                           (roleFilter === 'editor' && user.roles.some(r => r.name === 'editor')) ||
                           (roleFilter === 'admin' && user.roles.some(r => r.name === 'admin'));
        
        return matchesSearch && matchesRole;
    });

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

    return (
        <ThemeProvider theme={theme}>
            <Head title="Manage Users - Admin" />
            
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
                            onClick={handleBackToDashboard}
                            sx={{ color: '#ffffff' }}
                        >
                            <ArrowBack />
                        </IconButton>
                        <Typography variant="h4" sx={{ color: '#ffffff', fontWeight: 800, letterSpacing: '-0.01em' }}>
                            Manage Users
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
                    {/* Filters */}
                    <Paper sx={{ 
                        backgroundColor: '#1e293b', 
                        border: '1px solid #334155',
                        p: 3,
                        mb: 4
                    }}>
                        <Grid container spacing={3} alignItems="center">
                            <Grid item xs={12} md={6}>
                                <TextField
                                    fullWidth
                                    placeholder="Search users by name or email..."
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    InputProps={{
                                        startAdornment: (
                                            <InputAdornment position="start">
                                                <Search sx={{ color: '#94a3b8' }} />
                                            </InputAdornment>
                                        ),
                                        sx: {
                                            color: '#ffffff',
                                            '& .MuiOutlinedInput-notchedOutline': {
                                                borderColor: '#334155',
                                            },
                                            '&:hover .MuiOutlinedInput-notchedOutline': {
                                                borderColor: '#475569',
                                            },
                                            '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
                                                borderColor: '#8b5cf6',
                                            },
                                        }
                                    }}
                                    sx={{
                                        '& .MuiInputBase-input': {
                                            color: '#ffffff',
                                        }
                                    }}
                                />
                            </Grid>
                            <Grid item xs={12} md={3}>
                                <FormControl fullWidth>
                                    <Select
                                        value={roleFilter}
                                        onChange={(e) => setRoleFilter(e.target.value)}
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
                                        <MenuItem value="all">All Roles</MenuItem>
                                        <MenuItem value="student">Students</MenuItem>
                                        <MenuItem value="writer">Writers</MenuItem>
                                        <MenuItem value="editor">Editors</MenuItem>
                                        <MenuItem value="admin">Admins</MenuItem>
                                    </Select>
                                </FormControl>
                            </Grid>
                            <Grid item xs={12} md={3}>
                                <Typography variant="h6" sx={{ color: '#ffffff', textAlign: 'center' }}>
                                    {filteredUsers.length} users found
                                </Typography>
                            </Grid>
                        </Grid>
                    </Paper>

                    {/* Users Table */}
                    <Paper sx={{ 
                        backgroundColor: '#1e293b', 
                        border: '1px solid #334155',
                        overflow: 'hidden'
                    }}>
                        <TableContainer>
                            <Table>
                                <TableHead>
                                    <TableRow sx={{ backgroundColor: '#0f172a' }}>
                                        <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>User</TableCell>
                                        <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Email</TableCell>
                                        <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Role</TableCell>
                                        <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Joined</TableCell>
                                        <TableCell sx={{ color: '#ffffff', fontWeight: 'bold' }}>Actions</TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {filteredUsers.map((user) => {
                                        const primaryRole = getPrimaryRole(user);
                                        return (
                                            <TableRow key={user.id} sx={{ '&:hover': { backgroundColor: '#0f172a' } }}>
                                                <TableCell>
                                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                                        <Avatar sx={{ backgroundColor: getRoleColor(primaryRole) }}>
                                                            {user.name.charAt(0).toUpperCase()}
                                                        </Avatar>
                                                        <Typography sx={{ color: '#ffffff' }}>
                                                            {user.name}
                                                        </Typography>
                                                    </Box>
                                                </TableCell>
                                                <TableCell sx={{ color: '#94a3b8' }}>
                                                    {user.email}
                                                </TableCell>
                                                <TableCell>
                                                    <FormControl size="small" sx={{ minWidth: 120 }}>
                                                        <Select
                                                            value={primaryRole}
                                                            onChange={(e) => handleUpdateRole(user.id, e.target.value)}
                                                            disabled={user.id === auth.user.id}
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
                                                </TableCell>
                                                <TableCell sx={{ color: '#94a3b8' }}>
                                                    {new Date(user.created_at).toLocaleDateString()}
                                                </TableCell>
                                                <TableCell>
                                                    <Box sx={{ display: 'flex', gap: 1 }}>
                                                        <IconButton 
                                                            size="small"
                                                            onClick={() => handleViewUser(user.id)}
                                                            sx={{ color: '#3b82f6' }}
                                                        >
                                                            <Visibility />
                                                        </IconButton>
                                                        {user.id !== auth.user.id && (
                                                            <IconButton 
                                                                size="small"
                                                                onClick={() => setDeleteDialog(user)}
                                                                sx={{ color: '#ef4444' }}
                                                            >
                                                                <Delete />
                                                            </IconButton>
                                                        )}
                                                    </Box>
                                                </TableCell>
                                            </TableRow>
                                        );
                                    })}
                                </TableBody>
                            </Table>
                        </TableContainer>
                    </Paper>

                    {/* Delete Confirmation Dialog */}
                    <Dialog open={Boolean(deleteDialog)} onClose={() => setDeleteDialog(null)}>
                        <DialogTitle sx={{ color: '#ffffff', backgroundColor: '#1e293b' }}>
                            Confirm User Deletion
                        </DialogTitle>
                        <DialogContent sx={{ backgroundColor: '#1e293b' }}>
                            <Typography sx={{ color: '#ffffff' }}>
                                Are you sure you want to delete user "{deleteDialog?.name}"? This action cannot be undone.
                            </Typography>
                        </DialogContent>
                        <DialogActions sx={{ backgroundColor: '#1e293b' }}>
                            <Button 
                                onClick={() => setDeleteDialog(null)}
                                sx={{ color: '#94a3b8' }}
                            >
                                Cancel
                            </Button>
                            <Button 
                                onClick={() => handleDeleteUser(deleteDialog.id)}
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

export default AdminUsers;
