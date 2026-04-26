import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';
import { Alert, Box, Button, Stack, Typography } from '@mui/material';

export default function VerifyEmail({ status }) {
    const { post, processing } = useForm({});

    const submit = (event) => {
        event.preventDefault();
        post(route('verification.send'));
    };

    return (
        <GuestLayout>
            <Head title="Email Verification" />
            <Stack spacing={2.25} component="form" onSubmit={submit}>
                <Box>
                    <Typography variant="h4">Verify your email</Typography>
                    <Typography color="text.secondary">
                        Check your inbox and click the verification link before you continue.
                    </Typography>
                </Box>

                {status === 'verification-link-sent' && (
                    <Alert severity="success">A new verification link has been sent to your email address.</Alert>
                )}

                <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1.25}>
                    <Button
                        type="submit"
                        variant="contained"
                        disabled={processing}
                        sx={{ borderRadius: '0.9rem', py: 1.15, fontWeight: 700, textTransform: 'none', bgcolor: '#2f6fdb', '&:hover': { bgcolor: '#2157b4' } }}
                    >
                        Resend Verification Email
                    </Button>
                    <Button
                        component={Link}
                        href={route('logout')}
                        method="post"
                        as="button"
                        variant="outlined"
                        sx={{ borderRadius: '0.9rem', py: 1.15, fontWeight: 700, textTransform: 'none' }}
                    >
                        Log Out
                    </Button>
                </Stack>
            </Stack>
        </GuestLayout>
    );
}
