import InputLabel from '@/Components/InputLabel';
import PrimaryButton from '@/Components/PrimaryButton';
import TextInput from '@/Components/TextInput';
import { useForm, router } from '@inertiajs/react'; 
import {
    Box,
    Typography,
    Snackbar,
    Alert,
    Container,
    Button,
    Paper,
    Stack,
} from '@mui/material';
import { ArrowBack } from '@mui/icons-material'; 
import { useThemeContext } from '@/Components/ThemeProvider';
import { useState } from 'react';

export default function UpdateProfileInformation({
    auth,
    mustVerifyEmail,
    status,
    className = '',
}) {
    const { theme } = useThemeContext();
    const user = auth?.user || { name: '', email: '' };
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    const { data, setData, patch, errors, processing, recentlySuccessful } =
        useForm({
            name: user.name,
            email: user.email,
        });

    const submit = (e) => {
        e.preventDefault();
        patch(route('profile.update'), {
            preserveScroll: true,
            onSuccess: () => {
                setSnackbar({
                    open: true,
                    message: 'Profile updated successfully!',
                    severity: 'success'
                });
            },
            onError: () => {
                setSnackbar({
                    open: true,
                    message: 'Error updating profile. Please check form.',
                    severity: 'error'
                });
            }
        });
    };

    const handleCloseSnackbar = () => {
        setSnackbar({ ...snackbar, open: false });
    };

    return (
        <Container maxWidth="lg" className={className}>
            <Box sx={{ mb: 3 }}>
                <Button
                    onClick={() => router.visit(route('dashboard'))}
                    startIcon={<ArrowBack />}
                    sx={{ textTransform: 'none' }}
                >
                    Back to Dashboard
                </Button>
            </Box>

            <Paper elevation={0} sx={{ p: 4, border: 1, borderColor: 'divider', borderRadius: 2 }}>
                <Box component="form" onSubmit={submit}>
                    <Stack spacing={3}>
                        {/* Name Field */}
                        <Box>
                            <InputLabel htmlFor="name" value="Name" />
                            <TextInput
                                id="name"
                                value={data.name}
                                onChange={(e) => setData('name', e.target.value)}
                                error={errors.name}
                                autoComplete="name"
                                isFocused
                                required
                            />
                            {errors.name && (
                                <Typography variant="caption" color="error" sx={{ mt: 0.5, display: 'block' }}>
                                    {errors.name}
                                </Typography>
                            )}
                        </Box>

                        {/* Email Field */}
                        <Box>
                            <InputLabel htmlFor="email" value="Email" />
                            <TextInput
                                id="email"
                                type="email"
                                value={data.email}
                                onChange={(e) => setData('email', e.target.value)}
                                error={errors.email}
                                autoComplete="username"
                                required
                            />
                            {errors.email && (
                                <Typography variant="caption" color="error" sx={{ mt: 0.5, display: 'block' }}>
                                    {errors.email}
                                </Typography>
                            )}
                        </Box>

                        {/* Email Verification Section */}
                        {mustVerifyEmail && user.email_verified_at === null && (
                            <Box sx={{ 
                                p: 2, 
                                backgroundColor: theme.palette.warning.light,
                                borderRadius: 2,
                                border: `1px solid ${theme.palette.warning.main}`
                            }}>
                                <Typography variant="body2" sx={{ color: theme.palette.warning.dark, mb: 1 }}>
                                    Your email address is unverified.
                                </Typography>
                                <Button
                                    onClick={() => router.post(route('verification.send'))}
                                    sx={{ 
                                        p: 0,
                                        minWidth: 0,
                                        textTransform: 'none',
                                        color: theme.palette.warning.dark, 
                                        textDecoration: 'underline',
                                        fontWeight: 'bold',
                                        '&:hover': { backgroundColor: 'transparent', textDecoration: 'none' }
                                    }}
                                >
                                    Click here to re-send verification email.
                                </Button>
                            </Box>
                        )}

                        {/* Status Message */}
                        {status === 'verification-link-sent' && (
                            <Alert severity="success" sx={{ 
                                backgroundColor: theme.palette.success.light,
                                color: theme.palette.success.dark,
                                border: `1px solid ${theme.palette.success.main}`
                            }}>
                                A new verification link has been sent to your email address.
                            </Alert>
                        )}

                        {/* Action Buttons */}
                        <Box sx={{ width: '100%',   display: 'flex', alignItems: 'center', gap: 2, pt: 1 }}>
                            <Button 
                                type="submit"
                                disabled={processing} 
                                sx={{ 
                                    pt: 1, 
                                    borderRadius: 1,
                                    bgcolor: theme.palette.primary.main, 
                                    color: theme.palette.text.primary,
                                    textTransform: 'none',
                                    px: 3,
                                    '&:hover': {
                                        bgcolor: theme.palette.primary.dark
                                    }
                                }}
                            >
                                Save Changes
                            </Button>

                            {recentlySuccessful && (
                                <Typography 
                                    variant="body2" 
                                    sx={{ color: theme.palette.success.main, fontWeight: 'medium' }}
                                >
                                    Saved successfully.
                                </Typography>
                            )}
                        </Box>
                    </Stack>
                </Box>
            </Paper>

            {/* Success/Error Snackbar */}
            <Snackbar
                open={snackbar.open}
                autoHideDuration={4000}
                onClose={handleCloseSnackbar}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
            >
                <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: '100%' }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </Container>
    );
}