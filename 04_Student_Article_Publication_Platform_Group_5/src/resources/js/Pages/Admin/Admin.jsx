import React, { useState, useEffect } from 'react';
import { Head, router } from '@inertiajs/react';
import {
    Container,
    Typography,
    Box,
    Paper,
    Button,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Chip,
    Avatar,
    IconButton,
    Menu,
    MenuItem,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    TextField,
    Alert,
    Snackbar,
    CircularProgress,
    Toolbar,
    AppBar,
    Tooltip
} from '@mui/material';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import {
    AdminPanelSettings,
    Person,
    Edit,
    Delete,
    MoreVert,
    AssignmentInd,
    School,
    Visibility,
    Logout,
    Menu as MenuIcon,
    Refresh,
    Search,
    FilterList
} from '@mui/icons-material';

export default function Admin({ users: initialUsers, auth }) {
    const [users, setUsers] = useState(initialUsers || []);
    const [loading, setLoading] = useState(false);
    const [anchorEl, setAnchorEl] = useState(null);
    const [selectedUser, setSelectedUser] = useState(null);
    const [deleteDialog, setDeleteDialog] = useState(false);
    const [roleDialog, setRoleDialog] = useState(false);
    const [newRole, setNewRole] = useState('');
    const [searchTerm, setSearchTerm] = useState('');
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    // Professional Theme
    const theme = createTheme({
        palette: {
            mode: 'dark',
            background: { 
                default: '#0f0f23',
                paper: '#1a1a2e'
            },
            primary: { 
                main: '#667eea',
                light: '#764ba2',
                dark: '#4c51bf'
            },
            secondary: { 
                main: '#f093fb',
                light: '#f5576c',
                dark: '#e53e3e'
            },
            success: { 
                main: '#48bb78',
                light: '#68d391',
                dark: '#38a169'
            },
            warning: { 
                main: '#ed8936',
                light: '#f6ad55',
                dark: '#dd6b20'
            },
            error: { 
                main: '#f56565',
                light: '#fc8181',
                dark: '#e53e3e'
            },
            text: { 
                primary: '#f7fafc',
                secondary: '#cbd5e0',
                disabled: '#718096'
            },
            divider: '#2d3748'
        },
        typography: { 
            fontFamily: '"Inter", "SF Pro Display", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            h4: {
                fontWeight: 700,
                fontSize: '2rem',
                lineHeight: 1.2
            },
            h5: {
                fontWeight: 600,
                fontSize: '1.5rem',
                lineHeight: 1.3
            },
            body1: {
                fontSize: '1rem',
                lineHeight: 1.6
            }
        },
        shape: {
            borderRadius: 12
        },
        components: {
            MuiPaper: {
                styleOverrides: {
                    root: {
                        backgroundImage: 'none',
                        backgroundColor: '#1a1a2e',
                        border: '1px solid rgba(255, 255, 255, 0.1)',
                        transition: 'all 0.3s ease',
                        '&:hover': {
                            transform: 'translateY(-2px)',
                            boxShadow: '0 8px 16px rgba(0, 0, 0, 0.2)'
                        }
                    }
                }
            },
            MuiButton: {
                styleOverrides: {
                    root: {
                        textTransform: 'none',
                        fontWeight: 600,
                        borderRadius: 8,
                        transition: 'all 0.3s ease'
                    },
                    contained: {
                        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                        '&:hover': {
                            background: 'linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%)'
                        }
                    }
                }
            }
        }
    });

    const handleMenuOpen = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const handleMenuClose = () => {
        setAnchorEl(null);
        setSelectedUser(null);
    };

    const handleUserMenuOpen = (event, user) => {
        setAnchorEl(event.currentTarget);
        setSelectedUser(user);
    };

    const handleDeleteUser = () => {
        setLoading(true);
        router.delete(`/admin/users/${selectedUser.id}`, {
            onSuccess: () => {
                setUsers(users.filter(u => u.id !== selectedUser.id));
                setDeleteDialog(false);
                handleMenuClose();
                setSnackbar({ open: true, message: 'User removed successfully', severity: 'success' });
            },
            onError: () => {
                setSnackbar({ open: true, message: 'Failed to remove user', severity: 'error' });
            },
            onFinish: () => setLoading(false)
        });
    };

    const handleChangeRole = () => {
        setLoading(true);
        router.put(`/admin/users/${selectedUser.id}/role`, { role: newRole }, {
            onSuccess: () => {
                setUsers(users.map(u => 
                    u.id === selectedUser.id ? { ...u, role: newRole } : u
                ));
                setRoleDialog(false);
                handleMenuClose();
                setSnackbar({ open: true, message: 'Role updated successfully', severity: 'success' });
                setNewRole('');
            },
            onError: () => {
                setSnackbar({ open: true, message: 'Failed to update role', severity: 'error' });
            },
            onFinish: () => setLoading(false)
        });
    };

    const handleRefresh = () => {
        setLoading(true);
        router.reload({
            onSuccess: (page) => {
                setUsers(page.props.users || []);
                setSnackbar({ open: true, message: 'Users refreshed successfully', severity: 'success' });
            },
            onFinish: () => setLoading(false)
        });
    };

    const getRoleColor = (role) => {
        switch(role) {
            case 'admin': return '#f56565';
            case 'editor': return '#ed8936';
            case 'writer': return '#667eea';
            case 'student': return '#48bb78';
            default: return '#718096';
        }
    };

    const getRoleIcon = (role) => {
        switch(role) {
            case 'admin': return <AdminPanelSettings />;
            case 'editor': return <Edit />;
            case 'writer': return <AssignmentInd />;
            case 'student': return <School />;
            default: return <Person />;
        }
    };

    const filteredUsers = users.filter(user => 
        user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user.role.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <ThemeProvider theme={theme}>
            <Head title="Admin Dashboard" />
            
            <Box sx={{ 
                minHeight: '100vh', 
                backgroundColor: "#0f0f23",
                display: 'flex',
                flexDirection: 'column'
            }}>
                {/* Header */}
                <AppBar position="static" sx={{ backgroundColor: '#1a1a2e' }}>
                    <Toolbar>
                        <Box sx={{ display: 'flex', alignItems: 'center', flexGrow: 1 }}>
                            <AdminPanelSettings sx={{ mr: 2, color: '#667eea' }} />
                            <Typography variant="h4" sx={{ color: '#ffffff', fontWeight: 'bold' }}>
                                Admin Dashboard
                            </Typography>
                        </Box>
                        
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <Tooltip title="Refresh Users">
                                <IconButton color="inherit" onClick={handleRefresh} disabled={loading}>
                                    {loading ? <CircularProgress size={24} color="inherit" /> : <Refresh />}
                                </IconButton>
                            </Tooltip>
                            
                            <IconButton color="inherit" onClick={handleMenuOpen}>
                                <MenuIcon sx={{ color: '#ffffff' }} />
                            </IconButton>
                        </Box>
                    </Toolbar>
                </AppBar>

                {/* User Profile Menu */}
                <Menu
                    anchorEl={anchorEl}
                    open={Boolean(anchorEl) && !selectedUser}
                    onClose={handleMenuClose}
                    PaperProps={{
                        sx: {
                            backgroundColor: '#1a1a2e',
                            border: '1px solid rgba(255, 255, 255, 0.1)',
                            mt: 1
                        }
                    }}
                >
                    <MenuItem onClick={() => router.post('/logout')} sx={{ color: '#f7fafc' }}>
                        <Logout sx={{ mr: 2 }} /> Logout
                    </MenuItem>
                </Menu>

                {/* Main Content */}
                <Container maxWidth="xl" sx={{ py: 4, flexGrow: 1 }}>
                    {/* Stats Cards */}
                    <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)', md: 'repeat(4, 1fr)' }, gap: 3, mb: 4 }}>
                        <Paper sx={{ p: 3, textAlign: 'center' }}>
                            <Typography variant="h3" color="#667eea" fontWeight="bold">
                                {users.length}
                            </Typography>
                            <Typography variant="body2" color="#cbd5e0">
                                Total Users
                            </Typography>
                        </Paper>
                        <Paper sx={{ p: 3, textAlign: 'center' }}>
                            <Typography variant="h3" color="#48bb78" fontWeight="bold">
                                {users.filter(u => u.role === 'student').length}
                            </Typography>
                            <Typography variant="body2" color="#cbd5e0">
                                Students
                            </Typography>
                        </Paper>
                        <Paper sx={{ p: 3, textAlign: 'center' }}>
                            <Typography variant="h3" color="#667eea" fontWeight="bold">
                                {users.filter(u => u.role === 'writer').length}
                            </Typography>
                            <Typography variant="body2" color="#cbd5e0">
                                Writers
                            </Typography>
                        </Paper>
                        <Paper sx={{ p: 3, textAlign: 'center' }}>
                            <Typography variant="h3" color="#ed8936" fontWeight="bold">
                                {users.filter(u => u.role === 'editor').length}
                            </Typography>
                            <Typography variant="body2" color="#cbd5e0">
                                Editors
                            </Typography>
                        </Paper>
                    </Box>

                    {/* Search Bar */}
                    <Paper sx={{ p: 2, mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Search sx={{ color: '#cbd5e0' }} />
                        <TextField
                            fullWidth
                            placeholder="Search users by name, email, or role..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            variant="standard"
                            InputProps={{
                                disableUnderline: true,
                                style: { color: '#f7fafc' }
                            }}
                            sx={{ flexGrow: 1 }}
                        />
                        <IconButton>
                            <FilterList sx={{ color: '#cbd5e0' }} />
                        </IconButton>
                    </Paper>

                    {/* Users Table */}
                    <Paper sx={{ overflow: 'hidden' }}>
                        <TableContainer>
                            <Table>
                                <TableHead sx={{ backgroundColor: '#2d3748' }}>
                                    <TableRow>
                                        <TableCell sx={{ color: '#f7fafc', fontWeight: 600 }}>User</TableCell>
                                        <TableCell sx={{ color: '#f7fafc', fontWeight: 600 }}>Email</TableCell>
                                        <TableCell sx={{ color: '#f7fafc', fontWeight: 600 }}>Role</TableCell>
                                        <TableCell sx={{ color: '#f7fafc', fontWeight: 600 }}>Joined</TableCell>
                                        <TableCell sx={{ color: '#f7fafc', fontWeight: 600 }}>Status</TableCell>
                                        <TableCell sx={{ color: '#f7fafc', fontWeight: 600 }}>Actions</TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {filteredUsers.map((user) => (
                                        <TableRow key={user.id} hover>
                                            <TableCell>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                                    <Avatar sx={{ bgcolor: getRoleColor(user.role) }}>
                                                        {getRoleIcon(user.role)}
                                                    </Avatar>
                                                    <Typography sx={{ color: '#f7fafc', fontWeight: 500 }}>
                                                        {user.name}
                                                    </Typography>
                                                </Box>
                                            </TableCell>
                                            <TableCell sx={{ color: '#cbd5e0' }}>{user.email}</TableCell>
                                            <TableCell>
                                                <Chip
                                                    icon={getRoleIcon(user.role)}
                                                    label={user.role.charAt(0).toUpperCase() + user.role.slice(1)}
                                                    sx={{
                                                        bgcolor: getRoleColor(user.role),
                                                        color: '#ffffff',
                                                        fontWeight: 600
                                                    }}
                                                    size="small"
                                                />
                                            </TableCell>
                                            <TableCell sx={{ color: '#cbd5e0' }}>
                                                {new Date(user.created_at).toLocaleDateString()}
                                            </TableCell>
                                            <TableCell>
                                                <Chip
                                                    label="Active"
                                                    sx={{
                                                        bgcolor: '#38a169',
                                                        color: '#ffffff',
                                                        fontWeight: 600
                                                    }}
                                                    size="small"
                                                />
                                            </TableCell>
                                            <TableCell>
                                                <IconButton
                                                    onClick={(e) => handleUserMenuOpen(e, user)}
                                                    sx={{ color: '#cbd5e0' }}
                                                >
                                                    <MoreVert />
                                                </IconButton>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </TableContainer>
                    </Paper>
                </Container>

                {/* User Actions Menu */}
                <Menu
                    anchorEl={anchorEl}
                    open={Boolean(anchorEl) && selectedUser}
                    onClose={handleMenuClose}
                    PaperProps={{
                        sx: {
                            backgroundColor: '#1a1a2e',
                            border: '1px solid rgba(255, 255, 255, 0.1)',
                            mt: 1
                        }
                    }}
                >
                    <MenuItem onClick={() => { setRoleDialog(true); }} sx={{ color: '#f7fafc' }}>
                        <Edit sx={{ mr: 2 }} /> Change Role
                    </MenuItem>
                    <MenuItem onClick={() => { setDeleteDialog(true); }} sx={{ color: '#f56565' }}>
                        <Delete sx={{ mr: 2 }} /> Remove User
                    </MenuItem>
                </Menu>

                {/* Delete User Dialog */}
                <Dialog open={deleteDialog} onClose={() => setDeleteDialog(false)}>
                    <DialogTitle sx={{ color: '#f7fafc', bgcolor: '#1a1a2e' }}>
                        Remove User
                    </DialogTitle>
                    <DialogContent sx={{ bgcolor: '#1a1a2e' }}>
                        <Typography sx={{ color: '#cbd5e0', mb: 2 }}>
                            Are you sure you want to remove <strong>{selectedUser?.name}</strong> from the system?
                            This action cannot be undone.
                        </Typography>
                        <Alert severity="warning" sx={{ mb: 2 }}>
                            This will permanently delete the user and all their associated data.
                        </Alert>
                    </DialogContent>
                    <DialogActions sx={{ bgcolor: '#1a1a2e' }}>
                        <Button onClick={() => setDeleteDialog(false)} sx={{ color: '#cbd5e0' }}>
                            Cancel
                        </Button>
                        <Button 
                            onClick={handleDeleteUser} 
                            color="error" 
                            variant="contained"
                            disabled={loading}
                        >
                            {loading ? <CircularProgress size={20} /> : 'Remove User'}
                        </Button>
                    </DialogActions>
                </Dialog>

                {/* Change Role Dialog */}
                <Dialog open={roleDialog} onClose={() => setRoleDialog(false)}>
                    <DialogTitle sx={{ color: '#f7fafc', bgcolor: '#1a1a2e' }}>
                        Change User Role
                    </DialogTitle>
                    <DialogContent sx={{ bgcolor: '#1a1a2e' }}>
                        <Typography sx={{ color: '#cbd5e0', mb: 2 }}>
                            Change role for <strong>{selectedUser?.name}</strong>
                        </Typography>
                        <TextField
                            select
                            fullWidth
                            label="New Role"
                            value={newRole}
                            onChange={(e) => setNewRole(e.target.value)}
                            SelectProps={{
                                native: true
                            }}
                            sx={{ 
                                '& .MuiOutlinedInput-root': {
                                    color: '#f7fafc',
                                    '& fieldset': {
                                        borderColor: '#4a5568'
                                    }
                                },
                                '& .MuiInputLabel-root': {
                                    color: '#cbd5e0'
                                }
                            }}
                        >
                            <option value="">Select role...</option>
                            <option value="student">Student</option>
                            <option value="writer">Writer</option>
                            <option value="editor">Editor</option>
                            <option value="admin">Admin</option>
                        </TextField>
                    </DialogContent>
                    <DialogActions sx={{ bgcolor: '#1a1a2e' }}>
                        <Button onClick={() => setRoleDialog(false)} sx={{ color: '#cbd5e0' }}>
                            Cancel
                        </Button>
                        <Button 
                            onClick={handleChangeRole} 
                            variant="contained"
                            disabled={!newRole || loading}
                        >
                            {loading ? <CircularProgress size={20} /> : 'Update Role'}
                        </Button>
                    </DialogActions>
                </Dialog>

                {/* Snackbar */}
                <Snackbar
                    open={snackbar.open}
                    autoHideDuration={6000}
                    onClose={() => setSnackbar({ ...snackbar, open: false })}
                >
                    <Alert 
                        onClose={() => setSnackbar({ ...snackbar, open: false })} 
                        severity={snackbar.severity}
                        sx={{ width: '100%' }}
                    >
                        {snackbar.message}
                    </Alert>
                </Snackbar>
            </Box>
        </ThemeProvider>
    );
}
