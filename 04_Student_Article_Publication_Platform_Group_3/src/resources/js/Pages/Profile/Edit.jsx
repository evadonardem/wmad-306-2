import { Head, Link } from '@inertiajs/react';
import {
    Box,
    Container,
    Button,
    Typography,
    Card,
    CardContent,
    Grid,
    TextField,
    AppBar,
    Toolbar,
    Alert,
    Snackbar,
    Paper,
    Divider,
    Avatar,
    IconButton,
    Chip,
    Fade,
    Zoom,
    alpha,
    Tooltip
} from '@mui/material';
import {
    AutoStories,
    Edit,
    Lock,
    Delete,
    ArrowBack,
    Save,
    Person,
    Mail,
    Visibility,
    VisibilityOff,
    EmojiEmotions,
    Brush,
    RocketLaunch,
    Cloud,
    WbSunny,
    Nightlight,
    Forest,
    Waves,
    Whatshot,
    EmojiEvents,
    CheckCircle,
    Cancel
} from '@mui/icons-material';
import { useState, useEffect } from 'react';
import { useForm, router } from '@inertiajs/react';

// Playful theme for profile page
const THEME = {
    primary: '#00b4d8',
    primaryDark: '#0077b6',
    secondary: '#ffb703',
    accent: '#fb8500',
    background: {
        default: '#f8f9fa',
        paper: '#ffffff',
        gradient: 'linear-gradient(135deg, #00b4d8 0%, #0077b6 100%)',
        playful: 'radial-gradient(circle at 10% 20%, #ffb70320 0%, transparent 20%), radial-gradient(circle at 90% 80%, #00b4d820 0%, transparent 20%)'
    },
    text: {
        primary: '#023047',
        secondary: '#5a6b7a',
        light: '#8d9aa9'
    },
    shadows: {
        small: '2px 2px 0 rgba(0,0,0,0.1)',
        medium: '4px 4px 0 rgba(0,0,0,0.1)',
        large: '8px 8px 0 rgba(0,0,0,0.1)',
        hover: '12px 12px 0 rgba(0,0,0,0.1)'
    }
};

export default function Profile({ auth, mustVerifyEmail, status }) {
    const [showPassword, setShowPassword] = useState(false);
    const [showCurrentPassword, setShowCurrentPassword] = useState(false);
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
    const [floatingIcons, setFloatingIcons] = useState([]);
    const [profileEmoji, setProfileEmoji] = useState('👤');

    const profileForm = useForm({
        name: auth.user.name,
        email: auth.user.email,
    });

    const passwordForm = useForm({
        current_password: '',
        password: '',
        password_confirmation: '',
    });

    useEffect(() => {
        generateFloatingIcons();
        setProfileEmoji(getRandomEmoji());
    }, []);

    const generateFloatingIcons = () => {
        const icons = [
            <EmojiEmotions />, <Brush />, <RocketLaunch />, <Cloud />, 
            <WbSunny />, <Nightlight />, <Forest />, <Waves />, <Whatshot />
        ];
        const positions = [];
        for (let i = 0; i < 10; i++) {
            positions.push({
                icon: icons[Math.floor(Math.random() * icons.length)],
                left: Math.random() * 100,
                top: Math.random() * 100,
                delay: Math.random() * 5,
                duration: 10 + Math.random() * 20,
                size: 20 + Math.random() * 30
            });
        }
        setFloatingIcons(positions);
    };

    const getRandomEmoji = () => {
        const emojis = ['😊', '🌟', '✨', '🎨', '🚀', '🌈', '🎭', '🎪'];
        return emojis[Math.floor(Math.random() * emojis.length)];
    };

    const updateProfile = (e) => {
        e.preventDefault();
        profileForm.patch(route('profile.update'), {
            onSuccess: () => {
                setSnackbar({ open: true, message: 'Profile updated successfully! ✨', severity: 'success' });
                setProfileEmoji(getRandomEmoji());
            },
            onError: () => setSnackbar({ open: true, message: 'Error updating profile', severity: 'error' })
        });
    };

    const updatePassword = (e) => {
        e.preventDefault();
        passwordForm.post(route('password.update'), {
            onSuccess: () => {
                passwordForm.reset();
                setSnackbar({ open: true, message: 'Password updated successfully! 🔐', severity: 'success' });
            },
            onError: () => setSnackbar({ open: true, message: 'Error updating password', severity: 'error' })
        });
    };

    return (
        <>
            <Head title="Profile" />

            {/* Floating Background Icons */}
            <Box sx={{
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                pointerEvents: 'none',
                zIndex: 0,
                overflow: 'hidden'
            }}>
                {floatingIcons.map((item, index) => (
                    <Box
                        key={index}
                        sx={{
                            position: 'absolute',
                            left: `${item.left}%`,
                            top: `${item.top}%`,
                            color: [THEME.primary, THEME.secondary, THEME.accent][Math.floor(Math.random() * 3)],
                            opacity: 0.1,
                            fontSize: item.size,
                            animation: `float ${item.duration}s infinite ease-in-out`,
                            animationDelay: `${item.delay}s`,
                            '@keyframes float': {
                                '0%': { transform: 'translateY(0px) rotate(0deg)' },
                                '50%': { transform: 'translateY(-20px) rotate(10deg)' },
                                '100%': { transform: 'translateY(0px) rotate(0deg)' }
                            }
                        }}
                    >
                        {item.icon}
                    </Box>
                ))}
            </Box>

            {/* Navigation Bar - Playful Design */}
            <AppBar 
                position="sticky" 
                elevation={4}
                sx={{ 
                    background: THEME.background.gradient,
                    borderBottom: `4px solid ${THEME.secondary}`,
                    zIndex: 10,
                    boxShadow: THEME.shadows.medium
                }}
            >
                <Toolbar sx={{ display: 'flex', justifyContent: 'space-between', minHeight: 80 }}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Button
                            component={Link}
                            href={route('dashboard')}
                            variant="text"
                            size="large"
                            sx={{ 
                                color: 'white', 
                                minWidth: 'auto', 
                                fontSize: '1rem', 
                                py: 1,
                                borderRadius: '30px',
                                '&:hover': {
                                    backgroundColor: 'rgba(255,255,255,0.1)',
                                    transform: 'scale(1.05)'
                                },
                                transition: 'all 0.3s ease'
                            }}
                        >
                            <ArrowBack sx={{ mr: 1, fontSize: 24 }} />
                            Back
                        </Button>
                        <Box
                            sx={{
                                bgcolor: THEME.secondary,
                                borderRadius: '50%',
                                width: 50,
                                height: 50,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                transform: 'rotate(-5deg)',
                                boxShadow: `4px 4px 0 rgba(0,0,0,0.1)`,
                                animation: 'bounce 2s infinite',
                                '@keyframes bounce': {
                                    '0%, 100%': { transform: 'rotate(-5deg) translateY(0)' },
                                    '50%': { transform: 'rotate(-5deg) translateY(-5px)' }
                                }
                            }}
                        >
                            <AutoStories sx={{ fontSize: 30, color: THEME.primaryDark }} />
                        </Box>
                        <Box>
                            <Typography 
                                variant="h5" 
                                sx={{ 
                                    fontWeight: 'bold', 
                                    color: 'white',
                                    textShadow: '2px 2px 0 rgba(0,0,0,0.1)',
                                    letterSpacing: '1px'
                                }}
                            >
                                Profile Settings
                            </Typography>
                            <Typography variant="caption" sx={{ color: THEME.secondary }}>
                                Manage your account {profileEmoji}
                            </Typography>
                        </Box>
                    </Box>
                    <Box sx={{ display: 'flex', gap: 2 }}>
                        <Button
                            component={Link}
                            href={route('dashboard')}
                            variant="outlined"
                            size="large"
                            sx={{ 
                                color: 'white', 
                                borderColor: 'white',
                                borderWidth: 2,
                                fontSize: '1rem',
                                py: 1,
                                px: 3,
                                borderRadius: '30px',
                                '&:hover': {
                                    backgroundColor: 'rgba(255,255,255,0.1)',
                                    transform: 'scale(1.05)'
                                }
                            }}
                        >
                            Dashboard 📊
                        </Button>
                        <Tooltip title="Logout">
                            <Button
                                component="button"
                                onClick={() => router.post(route('logout'))}
                                variant="text"
                                size="large"
                                sx={{ 
                                    color: 'white',
                                    fontSize: '1rem',
                                    py: 1,
                                    px: 3,
                                    borderRadius: '30px',
                                    '&:hover': {
                                        backgroundColor: 'rgba(255,255,255,0.1)',
                                        transform: 'scale(1.05)'
                                    }
                                }}
                            >
                                Logout 👋
                            </Button>
                        </Tooltip>
                    </Box>
                </Toolbar>
            </AppBar>

            {/* Main Content */}
            <Box sx={{ 
                minHeight: '100vh', 
                backgroundColor: THEME.background.default,
                pt: 10,
                pb: 4,
                position: 'relative',
                zIndex: 1,
                '&::before': {
                    content: '""',
                    position: 'fixed',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    background: THEME.background.playful,
                    pointerEvents: 'none',
                    zIndex: 0
                }
            }}>
                <Container maxWidth="md" sx={{ position: 'relative', zIndex: 2 }}>
                    {/* Profile Header with Playful Elements */}
                    <Fade in timeout={1000}>
                        <Paper
                            elevation={0}
                            sx={{
                                p: 4,
                                mb: 6,
                                textAlign: 'center',
                                background: THEME.background.gradient,
                                borderRadius: '24px',
                                border: `4px solid ${THEME.secondary}`,
                                boxShadow: THEME.shadows.large,
                                position: 'relative',
                                overflow: 'hidden',
                                transform: 'rotate(-0.5deg)',
                                '&:hover': {
                                    transform: 'rotate(0deg) scale(1.01)',
                                    boxShadow: THEME.shadows.hover
                                },
                                transition: 'all 0.3s ease'
                            }}
                        >
                            {/* Floating decorative elements */}
                            <Box sx={{
                                position: 'absolute',
                                top: 20,
                                left: 20,
                                animation: 'float 6s infinite ease-in-out'
                            }}>
                                <WbSunny sx={{ fontSize: 40, color: 'rgba(255,255,255,0.2)' }} />
                            </Box>
                            <Box sx={{
                                position: 'absolute',
                                bottom: 20,
                                right: 20,
                                animation: 'float 8s infinite ease-in-out',
                                animationDelay: '1s'
                            }}>
                                <Waves sx={{ fontSize: 40, color: 'rgba(255,255,255,0.2)' }} />
                            </Box>

                            <Avatar
                                sx={{ 
                                    width: 120, 
                                    height: 120, 
                                    mx: 'auto', 
                                    mb: 2,
                                    background: THEME.background.gradient,
                                    border: `4px solid ${THEME.secondary}`,
                                    boxShadow: `4px 4px 0 rgba(0,0,0,0.1)`,
                                    fontSize: '3rem',
                                    animation: 'float 4s infinite ease-in-out'
                                }}
                            >
                                {auth.user.name.charAt(0).toUpperCase()}
                            </Avatar>
                            
                            <Chip
                                icon={<EmojiEvents />}
                                label="Profile Active"
                                sx={{
                                    mb: 2,
                                    bgcolor: 'rgba(255,255,255,0.2)',
                                    color: 'white',
                                    border: '2px solid white',
                                    fontSize: '1rem',
                                    borderRadius: '30px'
                                }}
                            />
                            
                            <Typography variant="h3" sx={{ 
                                fontWeight: 'bold', 
                                mb: 1,
                                color: 'white',
                                textShadow: '3px 3px 0 rgba(0,0,0,0.1)'
                            }}>
                                {auth.user.name}
                                <Box component="span" sx={{ ml: 1, animation: 'wave 2s infinite' }}>
                                    {profileEmoji}
                                </Box>
                            </Typography>
                            
                            <Typography variant="h6" sx={{ color: 'white', opacity: 0.9, mb: 1 }}>
                                {auth.user.email}
                            </Typography>
                            
                            <Chip
                                label={`Role: ${auth.user.role || 'User'} 👤`}
                                sx={{
                                    bgcolor: THEME.secondary,
                                    color: THEME.text.primary,
                                    fontWeight: 'bold',
                                    fontSize: '1rem',
                                    border: '2px solid white'
                                }}
                            />
                        </Paper>
                    </Fade>

                    <Grid container spacing={4}>
                        {/* Update Profile Information */}
                        <Grid item xs={12}>
                            <Zoom in timeout={500}>
                                <Card sx={{ 
                                    boxShadow: THEME.shadows.medium,
                                    borderRadius: '20px',
                                    border: `3px solid ${THEME.primary}`,
                                    transition: 'all 0.3s ease',
                                    '&:hover': {
                                        transform: 'translateY(-4px)',
                                        boxShadow: THEME.shadows.hover
                                    }
                                }}>
                                    <CardContent sx={{ p: 4 }}>
                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                                            <Box
                                                sx={{
                                                    width: 40,
                                                    height: 40,
                                                    borderRadius: '12px',
                                                    background: THEME.background.gradient,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    mr: 2,
                                                    transform: 'rotate(-5deg)',
                                                    boxShadow: `2px 2px 0 rgba(0,0,0,0.1)`
                                                }}
                                            >
                                                <Person sx={{ color: 'white' }} />
                                            </Box>
                                            <Typography variant="h5" sx={{ fontWeight: '600', color: THEME.text.primary }}>
                                                Profile Information 📝
                                            </Typography>
                                        </Box>
                                        
                                        {status && (
                                            <Alert 
                                                severity="info" 
                                                sx={{ 
                                                    mb: 3,
                                                    borderRadius: '12px',
                                                    border: `2px solid ${alpha(THEME.primary, 0.2)}`
                                                }}
                                            >
                                                {status}
                                            </Alert>
                                        )}

                                        <form onSubmit={updateProfile}>
                                            <Grid container spacing={3}>
                                                <Grid item xs={12}>
                                                    <TextField
                                                        fullWidth
                                                        label="Name"
                                                        value={profileForm.data.name}
                                                        onChange={(e) => profileForm.setData('name', e.target.value)}
                                                        error={!!profileForm.errors.name}
                                                        helperText={profileForm.errors.name}
                                                        disabled={profileForm.processing}
                                                        sx={{
                                                            '& .MuiOutlinedInput-root': {
                                                                borderRadius: '12px',
                                                                '&:hover fieldset': { borderColor: THEME.primary, borderWidth: 2 },
                                                                '&.Mui-focused fieldset': { borderColor: THEME.primary, borderWidth: 2 }
                                                            }
                                                        }}
                                                        InputProps={{
                                                            startAdornment: <Person sx={{ mr: 1, color: THEME.primary }} />
                                                        }}
                                                    />
                                                </Grid>
                                                <Grid item xs={12}>
                                                    <TextField
                                                        fullWidth
                                                        label="Email"
                                                        type="email"
                                                        value={profileForm.data.email}
                                                        onChange={(e) => profileForm.setData('email', e.target.value)}
                                                        error={!!profileForm.errors.email}
                                                        helperText={profileForm.errors.email}
                                                        disabled={profileForm.processing}
                                                        sx={{
                                                            '& .MuiOutlinedInput-root': {
                                                                borderRadius: '12px',
                                                                '&:hover fieldset': { borderColor: THEME.primary, borderWidth: 2 },
                                                                '&.Mui-focused fieldset': { borderColor: THEME.primary, borderWidth: 2 }
                                                            }
                                                        }}
                                                        InputProps={{
                                                            startAdornment: <Mail sx={{ mr: 1, color: THEME.primary }} />
                                                        }}
                                                    />
                                                </Grid>
                                                <Grid item xs={12}>
                                                    <Button
                                                        type="submit"
                                                        variant="contained"
                                                        disabled={profileForm.processing}
                                                        startIcon={<Save />}
                                                        sx={{
                                                            background: THEME.background.gradient,
                                                            color: 'white',
                                                            borderRadius: '30px',
                                                            py: 1.5,
                                                            px: 4,
                                                            border: '2px solid white',
                                                            boxShadow: THEME.shadows.small,
                                                            '&:hover': {
                                                                transform: 'scale(1.05)',
                                                                boxShadow: THEME.shadows.medium
                                                            }
                                                        }}
                                                    >
                                                        {profileForm.processing ? 'Saving... ✨' : 'Save Changes'}
                                                    </Button>
                                                </Grid>
                                            </Grid>
                                        </form>
                                    </CardContent>
                                </Card>
                            </Zoom>
                        </Grid>

                        {/* Update Password */}
                        <Grid item xs={12}>
                            <Zoom in timeout={600}>
                                <Card sx={{ 
                                    boxShadow: THEME.shadows.medium,
                                    borderRadius: '20px',
                                    border: `3px solid ${THEME.accent}`,
                                    transition: 'all 0.3s ease',
                                    '&:hover': {
                                        transform: 'translateY(-4px)',
                                        boxShadow: THEME.shadows.hover
                                    }
                                }}>
                                    <CardContent sx={{ p: 4 }}>
                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                                            <Box
                                                sx={{
                                                    width: 40,
                                                    height: 40,
                                                    borderRadius: '12px',
                                                    background: `linear-gradient(135deg, ${THEME.accent} 0%, ${THEME.secondary} 100%)`,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    mr: 2,
                                                    transform: 'rotate(-5deg)',
                                                    boxShadow: `2px 2px 0 rgba(0,0,0,0.1)`
                                                }}
                                            >
                                                <Lock sx={{ color: 'white' }} />
                                            </Box>
                                            <Typography variant="h5" sx={{ fontWeight: '600', color: THEME.text.primary }}>
                                                Update Password 🔒
                                            </Typography>
                                        </Box>

                                        <form onSubmit={updatePassword}>
                                            <Grid container spacing={3}>
                                                <Grid item xs={12}>
                                                    <TextField
                                                        fullWidth
                                                        label="Current Password"
                                                        type={showCurrentPassword ? 'text' : 'password'}
                                                        value={passwordForm.data.current_password}
                                                        onChange={(e) => passwordForm.setData('current_password', e.target.value)}
                                                        error={!!passwordForm.errors.current_password}
                                                        helperText={passwordForm.errors.current_password}
                                                        disabled={passwordForm.processing}
                                                        sx={{
                                                            '& .MuiOutlinedInput-root': {
                                                                borderRadius: '12px',
                                                                '&:hover fieldset': { borderColor: THEME.accent, borderWidth: 2 },
                                                                '&.Mui-focused fieldset': { borderColor: THEME.accent, borderWidth: 2 }
                                                            }
                                                        }}
                                                        InputProps={{
                                                            endAdornment: (
                                                                <IconButton
                                                                    onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                                                                    edge="end"
                                                                >
                                                                    {showCurrentPassword ? <VisibilityOff /> : <Visibility />}
                                                                </IconButton>
                                                            )
                                                        }}
                                                    />
                                                </Grid>
                                                <Grid item xs={12} md={6}>
                                                    <TextField
                                                        fullWidth
                                                        label="New Password"
                                                        type={showPassword ? 'text' : 'password'}
                                                        value={passwordForm.data.password}
                                                        onChange={(e) => passwordForm.setData('password', e.target.value)}
                                                        error={!!passwordForm.errors.password}
                                                        helperText={passwordForm.errors.password}
                                                        disabled={passwordForm.processing}
                                                        sx={{
                                                            '& .MuiOutlinedInput-root': {
                                                                borderRadius: '12px',
                                                                '&:hover fieldset': { borderColor: THEME.accent, borderWidth: 2 },
                                                                '&.Mui-focused fieldset': { borderColor: THEME.accent, borderWidth: 2 }
                                                            }
                                                        }}
                                                        InputProps={{
                                                            endAdornment: (
                                                                <IconButton
                                                                    onClick={() => setShowPassword(!showPassword)}
                                                                    edge="end"
                                                                >
                                                                    {showPassword ? <VisibilityOff /> : <Visibility />}
                                                                </IconButton>
                                                            )
                                                        }}
                                                    />
                                                </Grid>
                                                <Grid item xs={12} md={6}>
                                                    <TextField
                                                        fullWidth
                                                        label="Confirm Password"
                                                        type={showPassword ? 'text' : 'password'}
                                                        value={passwordForm.data.password_confirmation}
                                                        onChange={(e) => passwordForm.setData('password_confirmation', e.target.value)}
                                                        error={!!passwordForm.errors.password_confirmation}
                                                        helperText={passwordForm.errors.password_confirmation}
                                                        disabled={passwordForm.processing}
                                                        sx={{
                                                            '& .MuiOutlinedInput-root': {
                                                                borderRadius: '12px',
                                                                '&:hover fieldset': { borderColor: THEME.accent, borderWidth: 2 },
                                                                '&.Mui-focused fieldset': { borderColor: THEME.accent, borderWidth: 2 }
                                                            }
                                                        }}
                                                    />
                                                </Grid>
                                                <Grid item xs={12}>
                                                    <Button
                                                        type="submit"
                                                        variant="contained"
                                                        disabled={passwordForm.processing}
                                                        startIcon={<Save />}
                                                        sx={{
                                                            background: `linear-gradient(135deg, ${THEME.accent} 0%, ${THEME.secondary} 100%)`,
                                                            color: 'white',
                                                            borderRadius: '30px',
                                                            py: 1.5,
                                                            px: 4,
                                                            border: '2px solid white',
                                                            boxShadow: THEME.shadows.small,
                                                            '&:hover': {
                                                                transform: 'scale(1.05)',
                                                                boxShadow: THEME.shadows.medium
                                                            }
                                                        }}
                                                    >
                                                        {passwordForm.processing ? 'Updating... 🔐' : 'Update Password'}
                                                    </Button>
                                                </Grid>
                                            </Grid>
                                        </form>
                                    </CardContent>
                                </Card>
                            </Zoom>
                        </Grid>

                        {/* Delete Account */}
                        <Grid item xs={12}>
                            <Zoom in timeout={700}>
                                <Card sx={{ 
                                    boxShadow: THEME.shadows.medium,
                                    borderRadius: '20px',
                                    border: '3px solid',
                                    borderColor: 'error.main',
                                    transition: 'all 0.3s ease',
                                    '&:hover': {
                                        transform: 'translateY(-4px)',
                                        boxShadow: THEME.shadows.hover
                                    }
                                }}>
                                    <CardContent sx={{ p: 4 }}>
                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                                            <Box
                                                sx={{
                                                    width: 40,
                                                    height: 40,
                                                    borderRadius: '12px',
                                                    background: 'linear-gradient(135deg, #ef4444 0%, #dc2626 100%)',
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                    justifyContent: 'center',
                                                    mr: 2,
                                                    transform: 'rotate(-5deg)',
                                                    boxShadow: `2px 2px 0 rgba(0,0,0,0.1)`
                                                }}
                                            >
                                                <Delete sx={{ color: 'white' }} />
                                            </Box>
                                            <Typography variant="h5" sx={{ fontWeight: '600', color: 'error.main' }}>
                                                Delete Account ⚠️
                                            </Typography>
                                        </Box>
                                        
                                        <Paper
                                            sx={{
                                                p: 3,
                                                mb: 3,
                                                borderRadius: '12px',
                                                bgcolor: alpha('#ef4444', 0.05),
                                                border: `2px dashed ${alpha('#ef4444', 0.3)}`
                                            }}
                                        >
                                            <Typography variant="body2" color="text.secondary" sx={{ lineHeight: 1.8 }}>
                                                ⚠️ <strong>Warning:</strong> Once your account is deleted, all of its resources and data will be permanently deleted. 
                                                Before deleting your account, please download any data or information that you wish to retain.
                                            </Typography>
                                        </Paper>

                                        <Button
                                            variant="outlined"
                                            color="error"
                                            startIcon={<Delete />}
                                            component={Link}
                                            href={route('profile.destroy')}
                                            method="delete"
                                            as="button"
                                            sx={{
                                                borderRadius: '30px',
                                                py: 1.5,
                                                px: 4,
                                                borderWidth: 2,
                                                '&:hover': {
                                                    transform: 'scale(1.05)',
                                                    borderWidth: 2
                                                }
                                            }}
                                        >
                                            Delete Account
                                        </Button>
                                    </CardContent>
                                </Card>
                            </Zoom>
                        </Grid>
                    </Grid>
                </Container>
            </Box>

            {/* Snackbar with Playful Design */}
            <Snackbar
                open={snackbar.open}
                autoHideDuration={6000}
                onClose={() => setSnackbar({ ...snackbar, open: false })}
                anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
                TransitionComponent={Zoom}
            >
                <Alert 
                    onClose={() => setSnackbar({ ...snackbar, open: false })} 
                    severity={snackbar.severity}
                    icon={snackbar.severity === 'success' ? <CheckCircle /> : <Cancel />}
                    sx={{ 
                        width: '100%',
                        borderRadius: '12px',
                        border: `2px solid ${snackbar.severity === 'success' ? '#10b981' : '#ef4444'}`,
                        boxShadow: `4px 4px 0 ${alpha(snackbar.severity === 'success' ? '#10b981' : '#ef4444', 0.2)}`,
                        '& .MuiAlert-message': {
                            fontWeight: 600
                        }
                    }}
                >
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </>
    );
}