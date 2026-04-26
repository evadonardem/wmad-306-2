import { useEffect } from 'react';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, useForm } from '@inertiajs/react';
import { TextField, Button, Box, Typography } from '@mui/material';
import { Lock as LockIcon } from '@mui/icons-material';

export default function ConfirmPassword() {
    const { data, setData, post, processing, errors, reset } = useForm({
        password: '',
    });

    useEffect(() => {
        return () => {
            reset('password');
        };
    }, []);

    const submit = (e) => {
        e.preventDefault();
        post(route('password.confirm'));
    };

    return (
        <GuestLayout>
            <Head title="Confirm Password" />

            <Box display="flex" flexDirection="column" alignItems="center" mb={2}>
                <Box 
                    sx={{ 
                        width: 48, height: 48, borderRadius: '50%', 
                        bgcolor: 'rgba(0, 113, 227, 0.1)', 
                        display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 2 
                    }}
                >
                    <LockIcon sx={{ color: '#0071e3' }} />
                </Box>
                <Typography variant="h5" fontWeight="700" textAlign="center">
                    Secure Area
                </Typography>
            </Box>

            <Typography variant="body2" color="text.secondary" textAlign="center" mb={4}>
                This is a secure area of the application. Please confirm your password before continuing.
            </Typography>

            <Box component="form" onSubmit={submit} noValidate>
                <TextField
                    id="password"
                    type="password"
                    name="password"
                    label="Password"
                    value={data.password}
                    onChange={(e) => setData('password', e.target.value)}
                    fullWidth
                    required
                    autoFocus
                    margin="normal"
                    error={Boolean(errors.password)}
                    helperText={errors.password}
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
                        boxShadow: '0 4px 14px rgba(0, 113, 227, 0.3)',
                        '&:hover': { backgroundColor: '#005bb5' }
                    }}
                >
                    Confirm
                </Button>
            </Box>
        </GuestLayout>
    );
}