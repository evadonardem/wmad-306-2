import React, { useState } from 'react';
import { Head, router, usePage } from '@inertiajs/react';
import {
    Typography,
    Box,
    Button,
    Paper,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    ThemeProvider,
    createTheme,
    Alert,
    CircularProgress,
    Grid,
    Chip
} from '@mui/material';
import {
    ArrowBack,
    Send,
    Edit,
    RateReview,
    Assignment
} from '@mui/icons-material';

const RoleRequest = ({ existingRequests }) => {
    const [openDialog, setOpenDialog] = useState(false);
    const [selectedRole, setSelectedRole] = useState('');
    const [reason, setReason] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

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

    const handleBackToDashboard = () => {
        router.get('/student/dashboard');
    };

    const handleOpenDialog = (role) => {
        setSelectedRole(role);
        setOpenDialog(true);
    };

    const handleCloseDialog = () => {
        setOpenDialog(false);
        setSelectedRole('');
        setReason('');
    };

    const handleSubmitRequest = () => {
        if (!reason.trim()) {
            alert('Please provide a reason for your role request.');
            return;
        }

        setIsSubmitting(true);

        router.post('/role-requests', {
            requested_role: selectedRole,
            reason: reason.trim()
        }, {
            onSuccess: () => {
                handleCloseDialog();
                setIsSubmitting(false);
            },
            onError: (errors) => {
                setIsSubmitting(false);
                console.error('Error submitting role request:', errors);
            }
        });
    };

    const hasPendingRequest = (role) => {
        return existingRequests.some(req => 
            req.requested_role === role && req.status === 'pending'
        );
    };

    const hasApprovedRequest = (role) => {
        return existingRequests.some(req => 
            req.requested_role === role && req.status === 'approved'
        );
    };

    const RoleCard = ({ role, title, description, icon, color }) => {
        const isPending = hasPendingRequest(role);
        const isApproved = hasApprovedRequest(role);

        return (
            <Paper sx={{ 
                backgroundColor: '#1e293b', 
                border: '1px solid #334155',
                p: 4,
                textAlign: 'center',
                position: 'relative',
                '&:hover': { border: '2px solid ' + color }
            }}>
                {isApproved && (
                    <Chip 
                        label="Approved" 
                        size="small" 
                        sx={{ 
                            position: 'absolute',
                            top: 16,
                            right: 16,
                            backgroundColor: '#10b981',
                            color: '#ffffff'
                        }} 
                    />
                )}
                <Box sx={{ mb: 3 }}>
                    <Box sx={{ 
                        display: 'inline-flex',
                        p: 2,
                        borderRadius: '50%',
                        backgroundColor: color + '20',
                        mb: 2
                    }}>
                        {React.createElement(icon, { sx: { fontSize: 48, color } })}
                    </Box>
                    <Typography variant="h5" sx={{ color: '#ffffff', fontWeight: 'bold', mb: 2 }}>
                        {title}
                    </Typography>
                    <Typography variant="body2" sx={{ color: '#94a3b8', mb: 3, minHeight: 60 }}>
                        {description}
                    </Typography>
                </Box>
                
                {isApproved ? (
                    <Button 
                        variant="outlined" 
                        disabled
                        sx={{ 
                            borderColor: '#10b981',
                            color: '#10b981',
                            cursor: 'not-allowed'
                        }}
                    >
                        Role Granted
                    </Button>
                ) : isPending ? (
                    <Button 
                        variant="outlined" 
                        disabled
                        sx={{ 
                            borderColor: '#f59e0b',
                            color: '#f59e0b',
                            cursor: 'not-allowed'
                        }}
                    >
                        Request Pending
                    </Button>
                ) : (
                    <Button 
                        variant="contained"
                        onClick={() => handleOpenDialog(role)}
                        sx={{ 
                            backgroundColor: color,
                            '&:hover': { backgroundColor: color + 'dd' }
                        }}
                    >
                        Request {title} Role
                    </Button>
                )}
            </Paper>
        );
    };

    return (
        <ThemeProvider theme={theme}>
            <Head title="Request Role - Student" />
            
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
                            Request New Role
                        </Typography>
                    </Box>
                </Box>

                {/* Main Content */}
                <Box sx={{ flexGrow: 1, py: 4, px: 3 }}>
                    <Box sx={{ maxWidth: '1200px', mx: 'auto' }}>
                        {/* Hero Section */}
                        <Box sx={{ textAlign: 'center', mb: 6 }}>
                            <Typography variant="h2" sx={{ color: '#ffffff', fontWeight: 700, mb: 2 }}>
                                Expand Your Contribution
                            </Typography>
                            <Typography variant="h6" sx={{ color: '#94a3b8', mb: 4 }}>
                                Apply for additional roles to contribute more to the platform
                            </Typography>
                        </Box>

                        {/* Existing Requests Alert */}
                        {existingRequests.some(req => req.status === 'pending') && (
                            <Alert severity="warning" sx={{ mb: 4, backgroundColor: '#fef3c7', color: '#92400e' }}>
                                You have pending role requests. Please wait for admin approval before submitting new requests.
                            </Alert>
                        )}

                        {/* Role Cards */}
                        <Grid container spacing={4}>
                            <Grid item xs={12} md={6}>
                                <RoleCard
                                    role="writer"
                                    title="Writer"
                                    description="Create and publish articles, share your knowledge and creativity with the community"
                                    icon={Edit}
                                    color="#10b981"
                                />
                            </Grid>
                            <Grid item xs={12} md={6}>
                                <RoleCard
                                    role="editor"
                                    title="Editor"
                                    description="Review and edit articles, ensure content quality and help writers improve their work"
                                    icon={RateReview}
                                    color="#f59e0b"
                                />
                            </Grid>
                        </Grid>
                    </Box>
                </Box>

                {/* Role Request Dialog */}
                <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
                    <DialogTitle sx={{ color: '#ffffff', backgroundColor: '#1e293b' }}>
                        Request {selectedRole === 'writer' ? 'Writer' : 'Editor'} Role
                    </DialogTitle>
                    <DialogContent sx={{ backgroundColor: '#1e293b' }}>
                        <Typography sx={{ color: '#94a3b8', mb: 3 }}>
                            Please tell us why you want to become a {selectedRole}. This helps us understand your motivations and ensure you're a good fit for the role.
                        </Typography>
                        <TextField
                            fullWidth
                            multiline
                            rows={4}
                            placeholder={`Explain why you want to be a ${selectedRole}...`}
                            value={reason}
                            onChange={(e) => setReason(e.target.value)}
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
                            onClick={handleCloseDialog}
                            sx={{ color: '#94a3b8' }}
                            disabled={isSubmitting}
                        >
                            Cancel
                        </Button>
                        <Button 
                            onClick={handleSubmitRequest}
                            variant="contained"
                            disabled={isSubmitting || !reason.trim()}
                            sx={{ 
                                backgroundColor: '#8b5cf6',
                                '&:hover': { backgroundColor: '#7c3aed' }
                            }}
                        >
                            {isSubmitting ? (
                                <CircularProgress size={20} sx={{ color: '#ffffff' }} />
                            ) : (
                                'Submit Request'
                            )}
                        </Button>
                    </DialogActions>
                </Dialog>
            </Box>
        </ThemeProvider>
    );
};

export default RoleRequest;
