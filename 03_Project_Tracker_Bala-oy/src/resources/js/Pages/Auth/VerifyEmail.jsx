import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';
import { Button, Box, Typography, Alert, Stack } from '@mui/material';
import { MarkEmailRead as EmailIcon } from '@mui/icons-material';

export default function VerifyEmail({ status }) {
    const { post, processing } = useForm({});

    const submit = (e) => {
        e.preventDefault();
        post(route('verification.send'));
    };

    return (
        <GuestLayout>
            <Head title="Email Verification" />

            <Box display="flex" flexDirection="column" alignItems="center" mb={2}>
                <Box 
                    sx={{ 
                        width: 48, height: 48, borderRadius: '50%', 
                        bgcolor: 'rgba(52, 199, 89, 0.1)', // Light green bg
                        display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 2 
                    }}
                >
                    <EmailIcon sx={{ color: '#34C759' }} />
                </Box>
                <Typography variant="h5" fontWeight="700" textAlign="center">
                    Check your inbox
                </Typography>
            </Box>

            <Typography variant="body2" color="text.secondary" textAlign="center" mb={3} sx={{ lineHeight: 1.6 }}>
                Thanks for signing up! Before getting started, could you verify your email address by clicking on the link we just emailed to you?
            </Typography>

            {status === 'verification-link-sent' && (
                <Alert severity="success" sx={{ mb: 4, borderRadius: '12px' }}>
                    A new verification link has been sent to the email address you provided during registration.
                </Alert>
            )}

            <Box component="form" onSubmit={submit}>
                <Stack spacing={2}>
                    <Button
                        type="submit"
                        fullWidth
                        variant="contained"
                        disabled={processing}
                        sx={{
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
                        Resend Verification Email
                    </Button>

                    <Box textAlign="center">
                        <Link
                            href={route('logout')}
                            method="post"
                            as="button"
                            style={{ 
                                background: 'none', 
                                border: 'none', 
                                color: '#6e6e73', 
                                textDecoration: 'underline', 
                                cursor: 'pointer',
                                fontSize: '0.875rem',
                                fontWeight: 500
                            }}
                        >
                            Log Out
                        </Link>
                    </Box>
                </Stack>
            </Box>
        </GuestLayout>
    );
}