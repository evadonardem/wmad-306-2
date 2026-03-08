import GuestLayout from '@/Layouts/GuestLayout';
import { Head, useForm } from '@inertiajs/react';
import { Alert, Box, Button, Stack, TextField, Typography } from '@mui/material';

export default function ForgotPassword({ status }) {
    const { data, setData, post, processing, errors } = useForm({ email: '' });

    const submit = (event) => {
        event.preventDefault();
        post(route('password.email'));
    };

    return (
        <GuestLayout>
            <Head title="Forgot Password" />
            <Stack spacing={2.25} component="form" onSubmit={submit}>
                <Box>
                    <Typography variant="h4">Reset access</Typography>
                    <Typography color="text.secondary">
                        Enter your email and we will send a secure password reset link.
                    </Typography>
                </Box>
                {status && <Alert severity="success">{status}</Alert>}
                <TextField
                    label="Email"
                    type="email"
                    value={data.email}
                    onChange={(event) => setData('email', event.target.value)}
                    error={Boolean(errors.email)}
                    helperText={errors.email}
                    required
                    fullWidth
                />
                <Button type="submit" variant="contained" disabled={processing} sx={{ borderRadius: '0.9rem', py: 1.15, fontWeight: 700, textTransform: 'none', bgcolor: '#2f6fdb', '&:hover': { bgcolor: '#2157b4' } }}>Email Password Reset Link</Button>
            </Stack>
        </GuestLayout>
    );
}
