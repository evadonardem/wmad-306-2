import { Head, useForm } from '@inertiajs/react';
import { Container, Card, CardContent, TextField, Button, Box, Typography, Alert } from '@mui/material';
import GuestLayout from '@/Layouts/GuestLayout';

export default function ForgotPassword({ status }) {
    const { data, setData, post, processing, errors } = useForm({ email: '' });

    const submit = (e) => {
        e.preventDefault();
        post(route('password.email'));
    };

    return (
        <GuestLayout>
            <Head title="Password Recovery" />
            <Container maxWidth="sm">
                <Card sx={{ mt: 8, bgcolor: '#171717', borderRadius: 4, border: '2px solid #333' }}>
                    <CardContent sx={{ p: { xs: 3, md: 5 } }}>
                        <Typography variant="h5" sx={{ fontWeight: 900, color: '#DA0037', textTransform: 'uppercase', mb: 2 }}>
                            System Override: Recovery
                        </Typography>
                        <Typography variant="body2" sx={{ color: '#AAA', mb: 4, lineHeight: 1.6 }}>
                            Lost access? Enter your registered comms channel (email) and the system will transmit a secure reset protocol.
                        </Typography>

                        {status && <Alert severity="success" sx={{ mb: 3, bgcolor: '#4CAF50', color: '#000' }}>{status}</Alert>}

                        <form onSubmit={submit}>
                            <TextField
                                fullWidth variant="filled" id="email" type="email" label="Operator Email"
                                value={data.email} autoFocus error={!!errors.email} helperText={errors.email}
                                onChange={(e) => setData('email', e.target.value)}
                                sx={{
                                    bgcolor: '#222', borderRadius: 1, mb: 4,
                                    '& .MuiFilledInput-root': { color: '#FFF' },
                                    '& .MuiInputLabel-root': { color: '#777', fontWeight: 'bold', textTransform: 'uppercase' }
                                }}
                            />
                            <Button
                                type="submit" fullWidth disabled={processing}
                                sx={{
                                    bgcolor: '#FFF', color: '#000', fontWeight: '900', borderRadius: 10,
                                    py: 1.5, textTransform: 'uppercase', letterSpacing: 1,
                                    '&:hover': { bgcolor: '#DA0037', color: '#FFF' }
                                }}
                            >
                                Transmit Reset Link
                            </Button>
                        </form>
                    </CardContent>
                </Card>
            </Container>
        </GuestLayout>
    );
}