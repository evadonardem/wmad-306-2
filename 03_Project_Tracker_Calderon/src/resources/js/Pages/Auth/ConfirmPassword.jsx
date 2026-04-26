import { Head, useForm } from '@inertiajs/react';
import { Container, Card, CardContent, TextField, Button, Typography, Box } from '@mui/material';
import GuestLayout from '@/Layouts/GuestLayout';

export default function ConfirmPassword() {
    const { data, setData, post, processing, errors, reset } = useForm({ password: '' });

    const submit = (e) => {
        e.preventDefault();
        post(route('password.confirm'), { onFinish: () => reset('password') });
    };

    return (
        <GuestLayout>
            <Head title="Restricted Area" />
            <Container maxWidth="sm">
                <Card sx={{ mt: 8, bgcolor: '#171717', borderRadius: 4, border: '2px solid #DA0037' }}>
                    <CardContent sx={{ p: { xs: 3, md: 5 } }}>
                        <Typography variant="h5" sx={{ fontWeight: 900, color: '#DA0037', textTransform: 'uppercase', mb: 2 }}>
                            Security Checkpoint
                        </Typography>
                        <Typography variant="body2" sx={{ color: '#AAA', mb: 4 }}>
                            You are attempting to access a secure sector. Re-enter your passcode to confirm clearance.
                        </Typography>

                        <form onSubmit={submit}>
                            <TextField
                                fullWidth variant="filled" id="password" type="password" label="Passcode Required"
                                value={data.password} autoFocus error={!!errors.password} helperText={errors.password}
                                onChange={(e) => setData('password', e.target.value)}
                                sx={{
                                    bgcolor: '#222', borderRadius: 1, mb: 4,
                                    '& .MuiFilledInput-root': { color: '#FFF' },
                                    '& .MuiInputLabel-root': { color: '#777', fontWeight: 'bold', textTransform: 'uppercase' }
                                }}
                            />

                            <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
                                <Button
                                    type="submit" disabled={processing}
                                    sx={{
                                        bgcolor: '#DA0037', color: '#FFF', fontWeight: '900', borderRadius: 10,
                                        px: 4, py: 1.5, textTransform: 'uppercase', letterSpacing: 1,
                                        '&:hover': { bgcolor: '#ff1744' }
                                    }}
                                >
                                    Authorize
                                </Button>
                            </Box>
                        </form>
                    </CardContent>
                </Card>
            </Container>
        </GuestLayout>
    );
}