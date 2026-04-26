import { Head, useForm } from '@inertiajs/react';
import { Container, Card, CardContent, TextField, Button, Box, Typography } from '@mui/material';
import GuestLayout from '@/Layouts/GuestLayout';

export default function ResetPassword({ token, email }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        token: token, email: email, password: '', password_confirmation: '',
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('password.store'), { onFinish: () => reset('password', 'password_confirmation') });
    };

    const inputStyle = {
        bgcolor: '#222', borderRadius: 1, mb: 3,
        '& .MuiFilledInput-root': { color: '#FFF' },
        '& .MuiInputLabel-root': { color: '#777', fontWeight: 'bold', textTransform: 'uppercase' }
    };

    return (
        <GuestLayout>
            <Head title="Reset Password" />
            <Container maxWidth="sm">
                <Card sx={{ mt: 8, bgcolor: '#171717', borderRadius: 4, border: '2px solid #333' }}>
                    <CardContent sx={{ p: { xs: 3, md: 5 } }}>
                        <Typography variant="h5" sx={{ fontWeight: 900, color: '#DA0037', textTransform: 'uppercase', mb: 4 }}>
                            Execute Password Reset
                        </Typography>

                        <form onSubmit={submit}>
                            <TextField
                                fullWidth variant="filled" id="email" type="email" label="Confirm Email"
                                value={data.email} error={!!errors.email} helperText={errors.email}
                                onChange={(e) => setData('email', e.target.value)} sx={inputStyle}
                            />
                            <TextField
                                fullWidth variant="filled" id="password" type="password" label="New Passcode"
                                value={data.password} autoFocus error={!!errors.password} helperText={errors.password}
                                onChange={(e) => setData('password', e.target.value)} sx={inputStyle}
                            />
                            <TextField
                                fullWidth variant="filled" id="password_confirmation" type="password" label="Verify New Passcode"
                                value={data.password_confirmation} error={!!errors.password_confirmation} helperText={errors.password_confirmation}
                                onChange={(e) => setData('password_confirmation', e.target.value)} sx={inputStyle}
                            />

                            <Button
                                type="submit" fullWidth disabled={processing}
                                sx={{
                                    bgcolor: '#DA0037', color: '#FFF', fontWeight: '900', borderRadius: 10,
                                    py: 1.5, textTransform: 'uppercase', letterSpacing: 2, mt: 2,
                                    '&:hover': { bgcolor: '#ff1744' }
                                }}
                            >
                                Confirm Override
                            </Button>
                        </form>
                    </CardContent>
                </Card>
            </Container>
        </GuestLayout>
    );
}