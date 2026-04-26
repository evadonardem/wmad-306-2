import { useEffect } from 'react';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';
import { TextField, Button, FormControlLabel, Checkbox, Box, Typography, Alert } from '@mui/material';
import { EmojiEvents as CrownIcon } from '@mui/icons-material';

export default function Login({ status, canResetPassword }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    useEffect(() => {
        return () => {
            reset('password');
        };
    }, []);

    const submit = (e) => {
        e.preventDefault();
        post(route('login'));
    };

    return (
        <GuestLayout>
            <Head title="Log in" />

            <Box display="flex" flexDirection="column" alignItems="center" mb={3}>
                {/* --- DUPLICATE REMOVED FROM HERE --- */}
                
                <Box 
                    sx={{ 
                        width: 64, 
                        height: 64, 
                        borderRadius: '20px', 
                        backgroundColor: '#c2e4f1',
                        display: 'flex', 
                        alignItems: 'center', 
                        justifyContent: 'center',
                        mb: 2,
                        boxShadow: '0 4px 12px rgba(0,0,0,0.05)'
                    }}
                >
                    <CrownIcon sx={{ color: '#0071e3', fontSize: '2.2rem' }} />
                </Box>
                
                <Typography variant="h5" fontWeight="700" textAlign="center">
                    Sign in to RHJE
                </Typography>
                <Typography variant="body2" color="text.secondary" textAlign="center">
                    Welcome back! Please enter your details.
                </Typography>
            </Box>

            {status && <Alert severity="success" sx={{ mb: 3 }}>{status}</Alert>}

            <Box component="form" onSubmit={submit} noValidate>
                <TextField
                    margin="normal"
                    required
                    fullWidth
                    id="email"
                    label="Email Address"
                    name="email"
                    autoComplete="email"
                    autoFocus
                    value={data.email}
                    onChange={(e) => setData('email', e.target.value)}
                    error={Boolean(errors.email)}
                    helperText={errors.email}
                    sx={{
                        '& .MuiOutlinedInput-root': { borderRadius: '12px' }
                    }}
                />

                <TextField
                    margin="normal"
                    required
                    fullWidth
                    name="password"
                    label="Password"
                    type="password"
                    id="password"
                    autoComplete="current-password"
                    value={data.password}
                    onChange={(e) => setData('password', e.target.value)}
                    error={Boolean(errors.password)}
                    helperText={errors.password}
                    sx={{
                        '& .MuiOutlinedInput-root': { borderRadius: '12px' }
                    }}
                />

                <Box display="flex" justifyContent="space-between" alignItems="center" mt={1}>
                    <FormControlLabel
                        control={
                            <Checkbox 
                                value="remember" 
                                color="primary" 
                                checked={data.remember}
                                onChange={(e) => setData('remember', e.target.checked)}
                            />
                        }
                        label={<Typography variant="body2" color="text.secondary">Remember me</Typography>}
                    />
                    
                    {canResetPassword && (
                        <Link 
                            href={route('password.request')}
                            style={{ textDecoration: 'none', color: '#0071e3', fontSize: '0.875rem', fontWeight: 500 }}
                        >
                            Forgot password?
                        </Link>
                    )}
                </Box>

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
                        boxShadow: '0 8px 20px rgba(0, 113, 227, 0.25)',
                        '&:hover': { backgroundColor: '#005bb5' }
                    }}
                >
                    Sign In
                </Button>

                <Box textAlign="center" mt={2}>
                    <Typography variant="body2" color="text.secondary">
                        Don't have an account?{' '}
                        <Link 
                            href={route('register')} 
                            style={{ textDecoration: 'none', color: '#0071e3', fontWeight: 600 }}
                        >
                            Sign up
                        </Link>
                    </Typography>
                </Box>
            </Box>
        </GuestLayout>
    );
}