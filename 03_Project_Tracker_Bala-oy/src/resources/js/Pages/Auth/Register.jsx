import { useEffect } from 'react';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';
import { TextField, Button, Box, Typography } from '@mui/material';
import { EmojiEvents as CrownIcon } from '@mui/icons-material';

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
    });

    useEffect(() => {
        return () => {
            reset('password', 'password_confirmation');
        };
    }, []);

    const submit = (e) => {
        e.preventDefault();
        post(route('register'));
    };

    return (
        <GuestLayout>
            <Head title="Register" />

            {/* RHJE Branding Section */}
            <Box display="flex" flexDirection="column" alignItems="center" mb={3}>
                <Box 
                    sx={{ 
                        width: 64, 
                        height: 64, 
                        borderRadius: '20px', 
                        backgroundColor: '#f5f5f7', 
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
                    Join RHJE
                </Typography>
                <Typography variant="body2" color="text.secondary" textAlign="center">
                    Start organizing your projects today.
                </Typography>
            </Box>

            <Box component="form" onSubmit={submit} noValidate>
                <TextField
                    margin="normal"
                    required
                    fullWidth
                    id="name"
                    label="Full Name"
                    name="name"
                    autoComplete="name"
                    autoFocus
                    value={data.name}
                    onChange={(e) => setData('name', e.target.value)}
                    error={Boolean(errors.name)}
                    helperText={errors.name}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    margin="normal"
                    required
                    fullWidth
                    id="email"
                    label="Email Address"
                    name="email"
                    autoComplete="email"
                    value={data.email}
                    onChange={(e) => setData('email', e.target.value)}
                    error={Boolean(errors.email)}
                    helperText={errors.email}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    margin="normal"
                    required
                    fullWidth
                    name="password"
                    label="Password"
                    type="password"
                    id="password"
                    autoComplete="new-password"
                    value={data.password}
                    onChange={(e) => setData('password', e.target.value)}
                    error={Boolean(errors.password)}
                    helperText={errors.password}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

                <TextField
                    margin="normal"
                    required
                    fullWidth
                    name="password_confirmation"
                    label="Confirm Password"
                    type="password"
                    id="password_confirmation"
                    autoComplete="new-password"
                    value={data.password_confirmation}
                    onChange={(e) => setData('password_confirmation', e.target.value)}
                    error={Boolean(errors.password_confirmation)}
                    helperText={errors.password_confirmation}
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                />

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
                    Get Started
                </Button>

                <Box textAlign="center" mt={2}>
                    <Typography variant="body2" color="text.secondary">
                        Already have an account?{' '}
                        <Link 
                            href={route('login')} 
                            style={{ textDecoration: 'none', color: '#0071e3', fontWeight: 600 }}
                        >
                            Log in
                        </Link>
                    </Typography>
                </Box>
            </Box>
        </GuestLayout>
    );
}