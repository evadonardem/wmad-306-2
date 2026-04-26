import GuestLayout from '@/Layouts/GuestLayout';
import { Head, useForm } from '@inertiajs/react';
import { TextField, Button, Box, Typography, Alert } from '@mui/material';

export default function ForgotPassword({ status }) {
    const { data, setData, post, processing, errors } = useForm({
        email: '',
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('password.email'));
    };

    return (
        <GuestLayout>
            <Head title="Forgot Password" />

            <Typography variant="h5" fontWeight="700" textAlign="center" gutterBottom>
                Reset Password
            </Typography>

            <Typography variant="body2" color="text.secondary" textAlign="center" mb={4}>
                Forgot your password? No problem. Just let us know your email address and we will email you a password reset link.
            </Typography>

            {status && <Alert severity="success" sx={{ mb: 3 }}>{status}</Alert>}

            <Box component="form" onSubmit={submit} noValidate>
                <TextField
                    id="email"
                    type="email"
                    name="email"
                    value={data.email}
                    label="Email Address"
                    margin="normal"
                    autoFocus
                    required
                    fullWidth
                    onChange={(e) => setData('email', e.target.value)}
                    error={Boolean(errors.email)}
                    helperText={errors.email}
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
                    Email Password Reset Link
                </Button>
            </Box>
        </GuestLayout>
    );
}