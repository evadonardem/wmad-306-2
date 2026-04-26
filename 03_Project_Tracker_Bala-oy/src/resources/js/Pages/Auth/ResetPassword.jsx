import { useEffect } from 'react';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, useForm } from '@inertiajs/react';
import { TextField, Button, Box, Typography } from '@mui/material';

export default function ResetPassword({ token, email }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        token: token,
        email: email,
        password: '',
        password_confirmation: '',
    });

    useEffect(() => {
        return () => {
            reset('password', 'password_confirmation');
        };
    }, []);

    const submit = (e) => {
        e.preventDefault();
        post(route('password.store'));
    };

    return (
        <GuestLayout>
            <Head title="Reset Password" />

            <Typography variant="h5" fontWeight="700" textAlign="center" gutterBottom>
                Set New Password
            </Typography>
            <Typography variant="body2" color="text.secondary" textAlign="center" mb={4}>
                Please enter your new password below.
            </Typography>

            <Box component="form" onSubmit={submit} noValidate>
                <TextField
                    id="email"
                    type="email"
                    name="email"
                    value={data.email}
                    label="Email Address"
                    margin="normal"
                    required
                    fullWidth
                    autoFocus
                    onChange={(e) => setData('email', e.target.value)}
                    error={Boolean(errors.email)}
                    helperText={errors.email}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    id="password"
                    type="password"
                    name="password"
                    value={data.password}
                    label="New Password"
                    margin="normal"
                    required
                    fullWidth
                    autoComplete="new-password"
                    onChange={(e) => setData('password', e.target.value)}
                    error={Boolean(errors.password)}
                    helperText={errors.password}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    id="password_confirmation"
                    type="password"
                    name="password_confirmation"
                    value={data.password_confirmation}
                    label="Confirm New Password"
                    margin="normal"
                    required
                    fullWidth
                    autoComplete="new-password"
                    onChange={(e) => setData('password_confirmation', e.target.value)}
                    error={Boolean(errors.password_confirmation)}
                    helperText={errors.password_confirmation}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <Button
                    type="submit"
                    fullWidth
                    variant="contained"
                    disabled={processing}
                    sx={{
                        mt: 4,
                        mb: 2,
                        py: 1.5,
                        borderRadius: '12px',
                        textTransform: 'none',
                        fontSize: '1rem',
                        fontWeight: 600,
                        backgroundColor: '#0071e3',
                        boxShadow: '0 4px 14px rgba(0, 113, 227, 0.3)',
                        '&:hover': { backgroundColor: '#005bb5' }
                    }}
                >
                    Reset Password
                </Button>
            </Box>
        </GuestLayout>
    );
}