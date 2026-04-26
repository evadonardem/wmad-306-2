import { Head, Link, useForm } from '@inertiajs/react';
import {
    Container, Card, CardContent, TextField, Button, Box,
    Typography, Alert, FormControlLabel, Checkbox, CircularProgress
} from '@mui/material';
import { Lock, Email } from '@mui/icons-material';
import GuestLayout from '@/Layouts/GuestLayout';

export default function Login({ status, canResetPassword }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '', password: '', remember: false,
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('login'), { onFinish: () => reset('password') });
    };

    const inputStyle = {
        bgcolor: '#222', borderRadius: 1, mb: 2,
        '& .MuiFilledInput-root': { color: '#FFF' },
        '& .MuiInputLabel-root': { color: '#777', fontWeight: 'bold',  }
    };

    return (
        <GuestLayout>
            
            <Head title="Login" />
            <Container maxWidth="sm">
                <Box sx={{position: 'absolute', top: '5%', left: '0%', width: '100%', height: '20%', bgcolor: '#131212', opacity: 1, zIndex: 0}}> </Box>
                <Card sx={{ mt: 4, mb: 4, bgcolor: '#171717', borderRadius: 4, border: '2px solid #333' }}>
                    <CardContent sx={{ p: { xs: 3, md: 5 } }}>
                        <Box sx={{ textAlign: 'center', mb: 4 }}>
                            <Typography variant="h4" sx={{ fontWeight: 900, color: '#DA0037', letterSpacing: 1, mb:2}}>
                                Login
                            </Typography>
                            <Typography variant="body2" sx={{ color: '#777', fontWeight: 'bold',}}>
                                Enter credentials to access project tracker
                            </Typography>
                        </Box>

                        {status && <Alert severity="success" sx={{ mb: 3, bgcolor: '#4CAF50', color: '#000' }}>{status}</Alert>}

                        <form onSubmit={submit}>
                            <TextField
                                fullWidth variant="filled" id="email" type="email" label="Operator Email"
                                value={data.email} autoFocus error={!!errors.email} helperText={errors.email}
                                onChange={(e) => setData('email', e.target.value)}
                                sx={inputStyle}
                                InputProps={{ startAdornment: <Email sx={{ mr: 1, color: '#DA0037' , mt: 2.5 ,}} /> }}
                            />

                            <TextField
                                fullWidth variant="filled" id="password" type="password" label="Passcode"
                                value={data.password} error={!!errors.password} helperText={errors.password}
                                onChange={(e) => setData('password', e.target.value)}
                                sx={inputStyle}
                                InputProps={{ startAdornment: <Lock sx={{ mr: 1, color: '#DA0037' , mt: 2.5 ,}} /> }}
                            />

                            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', mt: 1, mb: 3 }}>
                                {canResetPassword && (
                                    <Link href={route('password.request')} style={{ color: '#DA0037', textDecoration: 'none', fontWeight: 'bold', fontSize: '0.85rem' }}>
                                        FORGOT PASSWORD?
                                    </Link>
                                )}
                            </Box>
                            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'align-items', mt: 1, mb: 2 }}>
                                <FormControlLabel
                                    control={<Checkbox checked={data.remember} onChange={(e) => setData('remember', e.target.checked)} sx={{ color: '#777', '&.Mui-checked': { color: '#DA0037' } }} />}
                                    label={<Typography sx={{ color: '#AAA', fontWeight: 'bold', fontSize: '0.85rem' }}>REMEMBER ME</Typography>}
                                />
                            </Box>
                            

                            <Button
                                type="submit" fullWidth disabled={processing}
                                sx={{
                                    bgcolor: '#DA0037', color: '#FFF', fontWeight: '900', borderRadius: 10,
                                    py: 1.5, letterSpacing: 2, border: '2px solid rgba(255,255,255,0.2)',
                                    '&:hover': { bgcolor: '#ff1744', transform: 'scale(1.02)' }, transition: '0.2s'
                                }}
                            >
                                {processing ? <CircularProgress size={24} sx={{ color: '#FFF' }} /> : 'Initialize Login'}
                            </Button>

                            <Box sx={{ textAlign: 'center', mt: 4 }}>
                                <Typography variant="caption" sx={{ color: '#777', fontWeight: 'bold' }}>
                                    <Link href={route('register')} style={{ color: '#FFF', textDecoration: 'underline' }}>
                                        REGISTER HERE
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