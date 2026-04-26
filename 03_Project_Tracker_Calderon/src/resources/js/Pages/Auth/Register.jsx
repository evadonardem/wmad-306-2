import { Head, Link, useForm } from '@inertiajs/react';
import { Container, Card, CardContent, TextField, Button, Box, Typography, CircularProgress } from '@mui/material';
import { Lock, Email, Person } from '@mui/icons-material';
import GuestLayout from '@/Layouts/GuestLayout';

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '', email: '', password: '', password_confirmation: '',
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('register'), { onFinish: () => reset('password', 'password_confirmation') });
    };

    const inputStyle = {
        bgcolor: '#222', borderRadius: 1, mb: 2,
        '& .MuiFilledInput-root': { color: '#FFF' },
        '& .MuiInputLabel-root': { color: '#777', fontWeight: 'bold' }
    };

    return (
        <GuestLayout>
            <Head title="New User Registration" />
            <Container maxWidth="sm">
                <Box sx={{position: 'absolute', top: '2%', left: '0%', width: '100%', height: '20%', bgcolor: '#131212', opacity: 1, zIndex: 0}}> </Box>
                <Card sx={{ mt: 4, mb: 4, bgcolor: '#171717', borderRadius: 4, border: '2px solid #333' }}>
                    <CardContent sx={{ p: { xs: 3, md: 5 } }}>
                        <Box sx={{ textAlign: 'center', mb: 4 }}>
                            <Typography variant="h4" sx={{ fontWeight: 900, color: '#DA0037', letterSpacing: 1, mb:2}}>
                                Register
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#777', fontWeight: 'bold' }}>
                                Establish your profile
                            </Typography>
                        </Box>

                        <form onSubmit={submit}>
                            <TextField
                                fullWidth variant="filled" id="name" label="Full Designation (Name)"
                                value={data.name} autoFocus error={!!errors.name} helperText={errors.name}
                                onChange={(e) => setData('name', e.target.value)} sx={inputStyle}
                                InputProps={{ startAdornment: <Person sx={{ mr: 1, color: '#DA0037', mt: 2.5 ,}} /> }}
                            />

                            <TextField
                                fullWidth variant="filled" id="email" type="email" label="Comms Channel (Email)"
                                value={data.email} error={!!errors.email} helperText={errors.email}
                                onChange={(e) => setData('email', e.target.value)} sx={inputStyle}
                                InputProps={{ startAdornment: <Email sx={{ mr: 1, color: '#DA0037', mt: 2.5 , }} /> }}
                            />

                            <TextField
                                fullWidth variant="filled" id="password" type="password" label="Passcode"
                                value={data.password} error={!!errors.password} helperText={errors.password}
                                onChange={(e) => setData('password', e.target.value)} sx={inputStyle}
                                InputProps={{ startAdornment: <Lock sx={{ mr: 1, color: '#DA0037', mt: 2.5 , }} /> }}
                            />

                            <TextField
                                fullWidth variant="filled" id="password_confirmation" type="password" label="Confirm Passcode"
                                value={data.password_confirmation} error={!!errors.password_confirmation} helperText={errors.password_confirmation}
                                onChange={(e) => setData('password_confirmation', e.target.value)} sx={inputStyle}
                                InputProps={{ startAdornment: <Lock sx={{ mr: 1, color: '#DA0037', mt: 2.5 , }} /> }}
                            />

                            <Button
                                type="submit" fullWidth disabled={processing}
                                sx={{
                                    mt: 2, bgcolor: '#DA0037', color: '#FFF', fontWeight: '900', borderRadius: 10,
                                    py: 1.5, letterSpacing: 2, border: '2px solid rgba(255,255,255,0.2)',
                                    '&:hover': { bgcolor: '#ff1744', transform: 'scale(1.02)' }, transition: '0.2s'
                                }}
                            >
                                {processing ? <CircularProgress size={24} sx={{ color: '#FFF' }} /> : 'Create Profile'}
                            </Button>

                            <Box sx={{ textAlign: 'center', mt: 4 }}>
                                <Typography variant="caption" sx={{ color: '#777', fontWeight: 'bold' }}>
                                    <Link href={route('login')} style={{ color: '#FFF', textDecoration: 'underline' }}>
                                        LOGIN HERE
                                    </Link>
                                </Typography>
                            </Box>
                        </form>
                    </CardContent>
                </Card>
                <Box sx={{position: 'absolute', top: '90%', left: '0%', width: '100%', height: '20%', bgcolor: '#131212', opacity: 1, zIndex: 0}}> </Box>
            </Container>
        </GuestLayout>
    );
}