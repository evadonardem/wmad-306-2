import { useForm, usePage, Link } from '@inertiajs/react';
import { 
    Paper, Typography, Box, TextField, Button, Alert, Fade 
} from '@mui/material';
import { Save as SaveIcon } from '@mui/icons-material';

export default function UpdateProfileInformation({ mustVerifyEmail, status, className = '' }) {
    const user = usePage().props.auth.user;

    const { data, setData, patch, errors, processing, recentlySuccessful } = useForm({
        name: user.name,
        email: user.email,
    });

    const submit = (e) => {
        e.preventDefault();
        patch(route('profile.update'));
    };

    // --- Glass Card Style ---
    const glassStyle = {
        p: 4,
        borderRadius: '24px',
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        backdropFilter: 'blur(20px)',
        border: '1px solid rgba(255, 255, 255, 0.6)',
        boxShadow: '0 8px 32px rgba(0, 0, 0, 0.04)',
    };

    return (
        <Paper sx={glassStyle} elevation={0}>
            <header>
                <Typography variant="h6" fontWeight="700" gutterBottom>
                    Profile Information
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                    Update your account's profile information and email address.
                </Typography>
            </header>

            <Box component="form" onSubmit={submit} noValidate>
                
                <TextField
                    id="name"
                    label="Name"
                    value={data.name}
                    onChange={(e) => setData('name', e.target.value)}
                    required
                    fullWidth
                    margin="normal"
                    error={Boolean(errors.name)}
                    helperText={errors.name}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    id="email"
                    label="Email"
                    type="email"
                    value={data.email}
                    onChange={(e) => setData('email', e.target.value)}
                    required
                    fullWidth
                    margin="normal"
                    error={Boolean(errors.email)}
                    helperText={errors.email}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                {mustVerifyEmail && user.email_verified_at === null && (
                    <Alert severity="warning" sx={{ mt: 2, borderRadius: '12px' }}>
                        Your email address is unverified.
                        <Link
                            href={route('verification.send')}
                            method="post"
                            as="button"
                            style={{ 
                                background: 'none', border: 'none', color: '#ed6c02', 
                                textDecoration: 'underline', cursor: 'pointer', fontWeight: 600, marginLeft: '5px'
                            }}
                        >
                            Click here to re-send the verification email.
                        </Link>
                    </Alert>
                )}

                {status === 'verification-link-sent' && (
                    <Alert severity="success" sx={{ mt: 2, borderRadius: '12px' }}>
                        A new verification link has been sent to your email address.
                    </Alert>
                )}

                <Box display="flex" alignItems="center" gap={2} mt={3}>
                    <Button 
                        type="submit" 
                        variant="contained" 
                        disabled={processing}
                        startIcon={<SaveIcon />}
                        sx={{
                            borderRadius: '12px',
                            textTransform: 'none',
                            fontWeight: 600,
                            backgroundColor: '#0071e3',
                            boxShadow: '0 4px 14px rgba(0, 113, 227, 0.3)',
                        }}
                    >
                        Save Changes
                    </Button>

                    <Fade in={recentlySuccessful}>
                        <Typography variant="body2" color="success.main" fontWeight="600">
                            Saved.
                        </Typography>
                    </Fade>
                </Box>
            </Box>
        </Paper>
    );
}