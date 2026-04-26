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
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Tabs,
    Tab,
    Container
} from '@mui/material';
import {
    ArrowBack,
    Assignment,
    Person,
    CheckCircle,
    Cancel,
    Visibility,
    Search,
    Logout,
    Menu as MenuIcon,
    FilterList,
    History
} from '@mui/icons-material';

const AdminRoleRequests = ({ requests }) => {
    const [anchorEl, setAnchorEl] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [activeTab, setActiveTab] = useState(0);
    const [rejectDialog, setRejectDialog] = useState(null);
    const [adminNotes, setAdminNotes] = useState('');

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

    const handleApproveRequest = (requestId) => {
        router.post(`/admin/role-requests/${requestId}/approve`, {}, {
            onSuccess: () => {
                router.reload();
            }
        });
    };

    const handleRejectRequest = () => {
        router.post(`/admin/role-requests/${rejectDialog.id}/reject`, 
            { admin_notes: adminNotes }, 
            {
                onSuccess: () => {
                    setRejectDialog(null);
                    setAdminNotes('');
                    router.reload();
                }
            }
        );
    };

    const handleTabChange = (event, newValue) => {
        setActiveTab(newValue);
    };

    const filteredRequests = requests.filter(request => {
        const matchesSearch = request.user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                            request.user.email.toLowerCase().includes(searchTerm.toLowerCase());
        
        let matchesStatus = true;
        if (activeTab === 0) matchesStatus = request.status === 'pending';
        else if (activeTab === 1) matchesStatus = request.status === 'approved';
        else if (activeTab === 2) matchesStatus = request.status === 'rejected';
        
        return matchesSearch && matchesStatus;
    });

    const getRoleColor = (role) => {
        switch(role) {
            case 'writer': return '#10b981';
            case 'editor': return '#f59e0b';
            default: return '#6b7280';
        }
    };

    const getStatusColor = (status) => {
        switch(status) {
            case 'pending': return '#f59e0b';
            case 'approved': return '#10b981';
            case 'rejected': return '#ef4444';
            default: return '#6b7280';
        }
    };

    const RequestCard = ({ request }) => (
        <Card sx={{ backgroundColor: '#1e293b', border: '1px solid #334155' }}>
            <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Avatar sx={{ backgroundColor: getRoleColor(request.requested_role) }}>
                            {request.user.name.charAt(0).toUpperCase()}
                        </Avatar>
                        <Box>
                            <Typography variant="h6" sx={{ color: '#ffffff' }}>
                                {request.user.name}
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#94a3b8' }}>
                                {request.user.email}
                            </Typography>
                        </Box>
                    </Box>
                    <Box sx={{ display: 'flex', gap: 1 }}>
                        <Chip 
                            label={request.requested_role} 
                            size="small" 
                            sx={{ 
                                backgroundColor: getRoleColor(request.requested_role), 
                                color: '#ffffff',
                                textTransform: 'capitalize'
                            }} 
                        />
                        <Chip 
                            label={request.status} 
                            size="small" 
                            sx={{ 
                                backgroundColor: getStatusColor(request.status), 
                                color: '#ffffff',
                                textTransform: 'capitalize'
                            }} 
                        />
                    </Box>
                </Box>
                
                {request.reason && (
                    <Box sx={{ mb: 2 }}>
                        <Typography variant="body2" sx={{ color: '#cbd5e0', mb: 1 }}>
                            Reason for request:
                        </Typography>
                        <Paper sx={{ 
                            backgroundColor: '#0f172a', 
                            border: '1px solid #334155',
                            p: 2
                        }}>
                            <Typography variant="body2" sx={{ color: '#e2e8f0' }}>
                                "{request.reason}"
                            </Typography>
                        </Paper>
                    </Box>
                )}

                {request.admin_notes && (
                    <Box sx={{ mb: 2 }}>
                        <Typography variant="body2" sx={{ color: '#cbd5e0', mb: 1 }}>
                            Admin notes:
                        </Typography>
                        <Paper sx={{ 
                            backgroundColor: '#0f172a', 
                            border: '1px solid #334155',
                            p: 2
                        }}>
                            <Typography variant="body2" sx={{ color: '#e2e8f0' }}>
                                {request.admin_notes}
                            </Typography>
                        </Paper>
                    </Box>
                )}

                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="caption" sx={{ color: '#64748b' }}>
                        Requested {new Date(request.created_at).toLocaleDateString()} at {new Date(request.created_at).toLocaleTimeString()}
                    </Typography>
                    {request.approved_by && (
                        <Typography variant="caption" sx={{ color: '#64748b' }}>
                            Processed by {request.approved_by?.name} on {new Date(request.updated_at).toLocaleDateString()}
                        </Typography>
                    )}
                </Box>
            </CardContent>
            {request.status === 'pending' && (
                <CardActions sx={{ gap: 1, px: 2, pb: 2 }}>
                    <Button 
                        size="small" 
                        variant="contained" 
                        startIcon={<CheckCircle />}
                        onClick={() => handleApproveRequest(request.id)}
                        sx={{ 
                            backgroundColor: '#10b981',
                            '&:hover': { backgroundColor: '#059669' }
                        }}
                    >
                        Approve
                    </Button>
                    <Button 
                        size="small" 
                        variant="outlined" 
                        startIcon={<Cancel />}
                        onClick={() => setRejectDialog(request)}
                        sx={{ 
                            borderColor: '#ef4444',
                            color: '#ef4444',
                            '&:hover': { borderColor: '#dc2626', color: '#dc2626' }
                        }}
                    >
                        Reject
                    </Button>
                </CardActions>
            )}
        </Card>
    );

    return (
        <ThemeProvider theme={theme}>
            <Head title="Role Requests - Admin" />
            
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
                            Role Requests
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
                    {/* Search */}
                    <Paper sx={{ 
                        backgroundColor: '#1e293b', 
                        border: '1px solid #334155',
                        p: 3,
                        mb: 4
                    }}>
                        <TextField
                            fullWidth
                            placeholder="Search role requests by user name or email..."
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
                    </Paper>

                    {/* Tabs */}
                    <Box sx={{ borderBottom: 1, borderColor: '#334155', mb: 4 }}>
                        <Tabs 
                            value={activeTab} 
                            onChange={handleTabChange}
                            sx={{ 
                                '& .MuiTab-root': { color: '#94a3b8' },
                                '& .Mui-selected': { color: '#ffffff' },
                                '& .MuiTabs-indicator': { backgroundColor: '#8b5cf6' }
                            }}
                        >
                            <Tab label={`Pending (${requests.filter(r => r.status === 'pending').length})`} />
                            <Tab label={`Approved (${requests.filter(r => r.status === 'approved').length})`} />
                            <Tab label={`Rejected (${requests.filter(r => r.status === 'rejected').length})`} />
                        </Tabs>
                    </Box>

                    {/* Requests List */}
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                        {filteredRequests.length > 0 ? (
                            filteredRequests.map((request) => (
                                <RequestCard key={request.id} request={request} />
                            ))
                        ) : (
                            <Paper sx={{ 
                                backgroundColor: '#1e293b', 
                                border: '1px solid #334155',
                                p: 6,
                                textAlign: 'center'
                            }}>
                                <Assignment sx={{ fontSize: 64, color: '#64748b', mb: 2 }} />
                                <Typography variant="h6" sx={{ color: '#94a3b8', mb: 1 }}>
                                    No role requests found
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#64748b' }}>
                                    {searchTerm ? 'Try adjusting your search terms' : 'No requests match the current filter'}
                                </Typography>
                            </Paper>
                        )}
                    </Box>

                    {/* Reject Dialog */}
                    <Dialog open={Boolean(rejectDialog)} onClose={() => setRejectDialog(null)} maxWidth="sm" fullWidth>
                        <DialogTitle sx={{ color: '#ffffff', backgroundColor: '#1e293b' }}>
                            Reject Role Request
                        </DialogTitle>
                        <DialogContent sx={{ backgroundColor: '#1e293b' }}>
                            <Typography sx={{ color: '#ffffff', mb: 2 }}>
                                Reject role request from "{rejectDialog?.user?.name}" for {rejectDialog?.requested_role} role?
                            </Typography>
                            <TextField
                                fullWidth
                                multiline
                                rows={3}
                                placeholder="Optional: Add notes about why this request was rejected..."
                                value={adminNotes}
                                onChange={(e) => setAdminNotes(e.target.value)}
                                InputProps={{
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
                        </DialogContent>
                        <DialogActions sx={{ backgroundColor: '#1e293b' }}>
                            <Button 
                                onClick={() => {
                                    setRejectDialog(null);
                                    setAdminNotes('');
                                }}
                                sx={{ color: '#94a3b8' }}
                            >
                                Cancel
                            </Button>
                            <Button 
                                onClick={handleRejectRequest}
                                variant="contained"
                                sx={{ 
                                    backgroundColor: '#ef4444',
                                    '&:hover': { backgroundColor: '#dc2626' }
                                }}
                            >
                                Reject Request
                            </Button>
                        </DialogActions>
                    </Dialog>
                </Container>
            </Box>
        </ThemeProvider>
    );
};

export default AdminRoleRequests;
