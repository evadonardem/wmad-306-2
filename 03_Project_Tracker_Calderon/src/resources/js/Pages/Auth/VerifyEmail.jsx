import { Head, Link, useForm } from '@inertiajs/react';
import { Container, Card, CardContent, Button, Box, Typography, Alert } from '@mui/material';
import GuestLayout from '@/Layouts/GuestLayout';

export default function VerifyEmail({ status }) {
    const { post, processing } = useForm({});

    const submit = (e) => {
        e.preventDefault();
        post(route('verification.send'));
    };

    return (
        <GuestLayout>
            <Head title="Awaiting Clearance" />
            <Container maxWidth="sm">
                <Card sx={{ mt: 8, bgcolor: '#171717', borderRadius: 4, border: '2px solid #333' }}>
                    <CardContent sx={{ p: { xs: 3, md: 5 } }}>
                        <Typography variant="h5" sx={{ fontWeight: 900, color: '#FFD700', textTransform: 'uppercase', mb: 2 }}>
                            Clearance Pending
                        </Typography>
                        <Typography variant="body1" sx={{ color: '#AAA', mb: 4, lineHeight: 1.6 }}>
                            Registration logged. Before deployment, you must verify your comms channel. Check your inbox for the activation link. If the transmission failed, request a new one below.
                        </Typography>

                        {status === 'verification-link-sent' && (
                            <Alert severity="success" sx={{ mb: 4, bgcolor: '#4CAF50', color: '#000', fontWeight: 'bold' }}>
                                NEW VERIFICATION TRANSMITTED.
                            </Alert>
                        )}

                        <form onSubmit={submit}>
                            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                                <Button
                                    type="submit" fullWidth disabled={processing}
                                    sx={{
                                        bgcolor: '#DA0037', color: '#FFF', fontWeight: '900', borderRadius: 10,
                                        py: 1.5, textTransform: 'uppercase', letterSpacing: 1,
                                        '&:hover': { bgcolor: '#ff1744' }
                                    }}
                                >
                                    Resend Clearance Link
                                </Button>
                                
                                <Button
                                    component={Link} href={route('logout')} method="post" as="button"
                                    fullWidth variant="outlined"
                                    sx={{
                                        color: '#777', borderColor: '#444', fontWeight: 'bold', borderRadius: 10, py: 1.5,
                                        '&:hover': { color: '#FFF', borderColor: '#777' }
                                    }}
                                >
                                    Abort & Logout
                                </Button>
                            </Box>
                        </form>
                    </CardContent>
                </Card>
            </Container>
        </GuestLayout>
    );
}