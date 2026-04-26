import { useState } from 'react';
import { Head } from '@inertiajs/react';
import {
    Box,
    Container,
    Card,
    CardContent,
    Typography,
    Button,
    TextField,
    Grid,
    Avatar,
    Divider,
} from '@mui/material';
import { Mail, User, Shield, Lock } from 'lucide-react';
import GuestLayout from '@/Layouts/GuestLayout';

export default function EditProfile({ auth }) {
    const [formData, setFormData] = useState({
        name: auth?.user?.name || '',
        email: auth?.user?.email || '',
    });
    const [passwordData, setPasswordData] = useState({
        current_password: '',
        password: '',
        password_confirmation: '',
    });
    const [saveSuccess, setSaveSuccess] = useState(false);

    const getRoleColor = (role) => {
        const colors = {
            writer: { bg: '#3B82F6', border: '#3B82F650', text: '#3B82F6', icon: '✍️' },
            editor: { bg: '#059669', border: '#05966950', text: '#059669', icon: '👁️' },
            student: { bg: '#0EA5E9', border: '#0EA5E950', text: '#0EA5E9', icon: '📚' },
            admin: { bg: '#F59E0B', border: '#F59E0B50', text: '#F59E0B', icon: '🛡️' }
        };
        return colors[role] || colors.student;
    };

    const userRole = (auth?.user?.roles?.[0]?.name || auth?.user?.role || 'student').toLowerCase();
    const roleInfo = getRoleColor(userRole);

    const handleProfileChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value
        });
    };

    const handlePasswordChange = (e) => {
        setPasswordData({
            ...passwordData,
            [e.target.name]: e.target.value
        });
    };

    return (
        <>
            <Head title="Edit Profile" />
            <Box sx={{
                display: 'flex',
                minHeight: '100vh',
                background: 'linear-gradient(135deg, #0F172A 0%, #1E293B 50%, #0F172A 100%)',
                backgroundAttachment: 'fixed',
                pt: 8,
                pb: 4
            }}>
                <Container maxWidth="md">
                    {/* Header */}
                    <Box sx={{ mb: 4, textAlign: 'center', animation: 'slideInDown 0.6s ease-out' }}>
                        <Typography variant="h3" sx={{
                            fontWeight: 900,
                            background: 'linear-gradient(90deg, #3B82F6, #0EA5E9, #059669)',
                            backgroundSize: '200% auto',
                            WebkitBackgroundClip: 'text',
                            WebkitTextFillColor: 'transparent',
                            animation: 'gradientShift 3s ease infinite',
                            mb: 1
                        }}>
                            MY PROFILE
                        </Typography>
                        <Typography sx={{ color: '#CBD5E1', fontSize: '1rem' }}>
                            Manage your account settings and personal information
                        </Typography>
                    </Box>

                    {/* Profile Overview Card */}
                    <Card sx={{
                        background: 'linear-gradient(135deg, rgba(59, 130, 246, 0.1) 0%, rgba(5, 150, 105, 0.1) 100%)',
                        backdropFilter: 'blur(20px)',
                        border: '2px solid rgba(59, 130, 246, 0.3)',
                        borderRadius: '20px',
                        p: 3,
                        mb: 3,
                        animation: 'slideInBounce 0.8s ease',
                    }}>
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 3, mb: 2 }}>
                            <Avatar sx={{
                                width: 100,
                                height: 100,
                                background: `linear-gradient(135deg, ${roleInfo.bg}, ${roleInfo.bg}CC)`,
                                fontSize: '2.5rem',
                                boxShadow: `0 0 30px ${roleInfo.bg}80`,
                            }}>
                                {auth?.user?.name?.charAt(0).toUpperCase()}
                            </Avatar>
                            <Box sx={{ flex: 1 }}>
                                <Typography variant="h5" sx={{ fontWeight: 800, mb: 0.5 }}>
                                    {auth?.user?.name}
                                </Typography>
                                <Typography sx={{ color: '#CBD5E1', fontSize: '0.95rem', mb: 1.5 }}>
                                    {auth?.user?.email}
                                </Typography>
                                <Box sx={{
                                    display: 'inline-flex',
                                    alignItems: 'center',
                                    gap: 1,
                                    px: 2,
                                    py: 0.8,
                                    background: `${roleInfo.bg}20`,
                                    border: `2px solid ${roleInfo.bg}60`,
                                    borderRadius: '12px',
                                }}>
                                    <Typography sx={{ fontSize: '1.2rem' }}>{roleInfo.icon}</Typography>
                                    <Typography sx={{
                                        fontWeight: 700,
                                        color: roleInfo.text,
                                        textTransform: 'uppercase',
                                        fontSize: '0.85rem',
                                        letterSpacing: '0.5px'
                                    }}>
                                        {userRole}
                                    </Typography>
                                    <Shield size={16} color={roleInfo.text} style={{ marginLeft: '4px' }} />
                                </Box>
                            </Box>
                        </Box>
                    </Card>

                    {/* Profile Information Section */}
                    <Card sx={{
                        background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(15, 23, 42, 0.95) 100%)',
                        backdropFilter: 'blur(20px)',
                        border: '2px solid rgba(148, 163, 184, 0.2)',
                        borderRadius: '18px',
                        mb: 3,
                        animation: 'fadeInUp 0.8s ease 0.1s both',
                        overflow: 'hidden'
                    }}>
                        <CardContent sx={{ p: 3 }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2.5 }}>
                                <User size={20} color="#3B82F6" style={{ marginRight: '12px' }} />
                                <Typography variant="h6" sx={{ fontWeight: 800 }}>
                                    Profile Information
                                </Typography>
                            </Box>
                            <Divider sx={{ borderColor: 'rgba(148, 163, 184, 0.1)', mb: 2.5 }} />

                            <Grid container spacing={2.5}>
                                <Grid item xs={12} md={6}>
                                    <Box>
                                        <Typography sx={{ color: '#94A3B8', fontSize: '0.85rem', mb: 0.5, fontWeight: 700 }}>
                                            FULL NAME
                                        </Typography>
                                        <TextField
                                            fullWidth
                                            name="name"
                                            value={formData.name}
                                            onChange={handleProfileChange}
                                            placeholder="Your full name"
                                            sx={{
                                                '& .MuiOutlinedInput-root': {
                                                    background: 'rgba(30, 41, 59, 0.6)',
                                                    border: '2px solid rgba(59, 130, 246, 0.2)',
                                                    borderRadius: '12px',
                                                    transition: 'all 0.3s ease',
                                                    '&:hover': { border: '2px solid rgba(59, 130, 246, 0.4)' },
                                                    '&.Mui-focused': {
                                                        border: '2px solid rgba(59, 130, 246, 0.7)',
                                                        boxShadow: '0 0 20px rgba(59, 130, 246, 0.3)',
                                                    }
                                                },
                                                '& .MuiOutlinedInput-input::placeholder': { color: '#94A3B8' }
                                            }}
                                        />
                                    </Box>
                                </Grid>
                                <Grid item xs={12} md={6}>
                                    <Box>
                                        <Typography sx={{ color: '#94A3B8', fontSize: '0.85rem', mb: 0.5, fontWeight: 700 }}>
                                            EMAIL ADDRESS
                                        </Typography>
                                        <TextField
                                            fullWidth
                                            type="email"
                                            name="email"
                                            value={formData.email}
                                            onChange={handleProfileChange}
                                            placeholder="your.email@example.com"
                                            sx={{
                                                '& .MuiOutlinedInput-root': {
                                                    background: 'rgba(30, 41, 59, 0.6)',
                                                    border: '2px solid rgba(59, 130, 246, 0.2)',
                                                    borderRadius: '12px',
                                                    transition: 'all 0.3s ease',
                                                    '&:hover': { border: '2px solid rgba(59, 130, 246, 0.4)' },
                                                    '&.Mui-focused': {
                                                        border: '2px solid rgba(59, 130, 246, 0.7)',
                                                        boxShadow: '0 0 20px rgba(59, 130, 246, 0.3)',
                                                    }
                                                },
                                                '& .MuiOutlinedInput-input::placeholder': { color: '#94A3B8' }
                                            }}
                                        />
                                    </Box>
                                </Grid>
                                <Grid item xs={12}>
                                    <Button variant="contained" sx={{
                                        background: 'linear-gradient(135deg, #3B82F6, #0EA5E9)',
                                        fontWeight: 700,
                                        py: 1.2,
                                        borderRadius: '12px',
                                        transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                                        '&:hover': {
                                            transform: 'translateY(-3px)',
                                            boxShadow: '0 0 30px rgba(59, 130, 246, 0.5)',
                                        }
                                    }} onClick={() => setSaveSuccess(true)}>
                                        💾 Save Changes
                                    </Button>
                                    {saveSuccess && (
                                        <Typography sx={{
                                            color: '#10B981',
                                            fontSize: '0.9rem',
                                            mt: 1,
                                            animation: 'slideInUp 0.3s ease',
                                            fontWeight: 600
                                        }}>
                                            ✅ Profile updated successfully!
                                        </Typography>
                                    )}
                                </Grid>
                            </Grid>
                        </CardContent>
                    </Card>

                    {/* Password Section */}
                    <Card sx={{
                        background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.85) 0%, rgba(15, 23, 42, 0.95) 100%)',
                        backdropFilter: 'blur(20px)',
                        border: '2px solid rgba(148, 163, 184, 0.2)',
                        borderRadius: '18px',
                        animation: 'fadeInUp 0.8s ease 0.2s both',
                        overflow: 'hidden'
                    }}>
                        <CardContent sx={{ p: 3 }}>
                            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2.5 }}>
                                <Lock size={20} color="#EF4444" style={{ marginRight: '12px' }} />
                                <Typography variant="h6" sx={{ fontWeight: 800 }}>
                                    Change Password
                                </Typography>
                            </Box>
                            <Divider sx={{ borderColor: 'rgba(148, 163, 184, 0.1)', mb: 2.5 }} />

                            <Grid container spacing={2.5}>
                                <Grid item xs={12}>
                                    <Box>
                                        <Typography sx={{ color: '#94A3B8', fontSize: '0.85rem', mb: 0.5, fontWeight: 700 }}>
                                            CURRENT PASSWORD
                                        </Typography>
                                        <TextField
                                            fullWidth
                                            type="password"
                                            name="current_password"
                                            value={passwordData.current_password}
                                            onChange={handlePasswordChange}
                                            placeholder="Enter your current password"
                                            sx={{
                                                '& .MuiOutlinedInput-root': {
                                                    background: 'rgba(30, 41, 59, 0.6)',
                                                    border: '2px solid rgba(239, 68, 68, 0.2)',
                                                    borderRadius: '12px',
                                                    transition: 'all 0.3s ease',
                                                    '&:hover': { border: '2px solid rgba(239, 68, 68, 0.4)' },
                                                    '&.Mui-focused': {
                                                        border: '2px solid rgba(239, 68, 68, 0.7)',
                                                        boxShadow: '0 0 20px rgba(239, 68, 68, 0.2)',
                                                    }
                                                },
                                                '& .MuiOutlinedInput-input::placeholder': { color: '#94A3B8' }
                                            }}
                                        />
                                    </Box>
                                </Grid>
                                <Grid item xs={12} md={6}>
                                    <Box>
                                        <Typography sx={{ color: '#94A3B8', fontSize: '0.85rem', mb: 0.5, fontWeight: 700 }}>
                                            NEW PASSWORD
                                        </Typography>
                                        <TextField
                                            fullWidth
                                            type="password"
                                            name="password"
                                            value={passwordData.password}
                                            onChange={handlePasswordChange}
                                            placeholder="Enter new password"
                                            sx={{
                                                '& .MuiOutlinedInput-root': {
                                                    background: 'rgba(30, 41, 59, 0.6)',
                                                    border: '2px solid rgba(239, 68, 68, 0.2)',
                                                    borderRadius: '12px',
                                                    transition: 'all 0.3s ease',
                                                    '&:hover': { border: '2px solid rgba(239, 68, 68, 0.4)' },
                                                    '&.Mui-focused': {
                                                        border: '2px solid rgba(239, 68, 68, 0.7)',
                                                        boxShadow: '0 0 20px rgba(239, 68, 68, 0.2)',
                                                    }
                                                },
                                                '& .MuiOutlinedInput-input::placeholder': { color: '#94A3B8' }
                                            }}
                                        />
                                    </Box>
                                </Grid>
                                <Grid item xs={12} md={6}>
                                    <Box>
                                        <Typography sx={{ color: '#94A3B8', fontSize: '0.85rem', mb: 0.5, fontWeight: 700 }}>
                                            CONFIRM PASSWORD
                                        </Typography>
                                        <TextField
                                            fullWidth
                                            type="password"
                                            name="password_confirmation"
                                            value={passwordData.password_confirmation}
                                            onChange={handlePasswordChange}
                                            placeholder="Confirm new password"
                                            sx={{
                                                '& .MuiOutlinedInput-root': {
                                                    background: 'rgba(30, 41, 59, 0.6)',
                                                    border: '2px solid rgba(239, 68, 68, 0.2)',
                                                    borderRadius: '12px',
                                                    transition: 'all 0.3s ease',
                                                    '&:hover': { border: '2px solid rgba(239, 68, 68, 0.4)' },
                                                    '&.Mui-focused': {
                                                        border: '2px solid rgba(239, 68, 68, 0.7)',
                                                        boxShadow: '0 0 20px rgba(239, 68, 68, 0.2)',
                                                    }
                                                },
                                                '& .MuiOutlinedInput-input::placeholder': { color: '#94A3B8' }
                                            }}
                                        />
                                    </Box>
                                </Grid>
                                <Grid item xs={12}>
                                    <Button variant="contained" sx={{
                                        background: '#EF4444',
                                        fontWeight: 700,
                                        py: 1.2,
                                        borderRadius: '12px',
                                        transition: 'all 0.3s ease',
                                        '&:hover': {
                                            transform: 'translateY(-3px)',
                                            boxShadow: '0 0 30px rgba(239, 68, 68, 0.4)',
                                        }
                                    }}>
                                        🔐 Update Password
                                    </Button>
                                </Grid>
                            </Grid>
                        </CardContent>
                    </Card>
                </Container>
            </Box>
        </>
    );
}
