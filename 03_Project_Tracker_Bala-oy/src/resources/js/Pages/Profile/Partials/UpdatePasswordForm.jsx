import { useRef } from 'react';
import { useForm } from '@inertiajs/react';
import { 
    Paper, Typography, Box, TextField, Button, Fade, Alert 
} from '@mui/material';
import { LockReset as LockIcon } from '@mui/icons-material';

export default function UpdatePasswordForm({ className = '' }) {
    const passwordInput = useRef();
    const currentPasswordInput = useRef();

    const { data, setData, errors, put, reset, processing, recentlySuccessful } = useForm({
        current_password: '',
        password: '',
        password_confirmation: '',
    });

    const updatePassword = (e) => {
        e.preventDefault();

        put(route('password.update'), {
            preserveScroll: true,
            onSuccess: () => reset(),
            onError: (errors) => {
                if (errors.password) {
                    reset('password', 'password_confirmation');
                    passwordInput.current.focus();
                }

                if (errors.current_password) {
                    reset('current_password');
                    currentPasswordInput.current.focus();
                }
            },
        });
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
        <Paper sx={glassStyle} elevation={0} className={className}>
            <header>
                <Typography variant="h6" fontWeight="700" gutterBottom>
                    Update Password
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                    Ensure your account is using a long, random password to stay secure.
                </Typography>
            </header>

            <Box component="form" onSubmit={updatePassword} noValidate>
                
                <TextField
                    id="current_password"
                    label="Current Password"
                    type="password"
                    fullWidth
                    margin="normal"
                    value={data.current_password}
                    onChange={(e) => setData('current_password', e.target.value)}
                    inputRef={currentPasswordInput}
                    error={Boolean(errors.current_password)}
                    helperText={errors.current_password}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    id="password"
                    label="New Password"
                    type="password"
                    fullWidth
                    margin="normal"
                    value={data.password}
                    onChange={(e) => setData('password', e.target.value)}
                    inputRef={passwordInput}
                    error={Boolean(errors.password)}
                    helperText={errors.password}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    id="password_confirmation"
                    label="Confirm Password"
                    type="password"
                    fullWidth
                    margin="normal"
                    value={data.password_confirmation}
                    onChange={(e) => setData('password_confirmation', e.target.value)}
                    error={Boolean(errors.password_confirmation)}
                    helperText={errors.password_confirmation}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <Box display="flex" alignItems="center" gap={2} mt={3}>
                    <Button 
                        type="submit" 
                        variant="contained" 
                        disabled={processing}
                        startIcon={<LockIcon />}
                        sx={{
                            borderRadius: '12px',
                            textTransform: 'none',
                            fontWeight: 600,
                            backgroundColor: '#1d1d1f', // Darker for security actions
                            boxShadow: '0 4px 14px rgba(0, 0, 0, 0.2)',
                            '&:hover': { backgroundColor: '#000' }
                        }}
                    >
                        Update Password
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