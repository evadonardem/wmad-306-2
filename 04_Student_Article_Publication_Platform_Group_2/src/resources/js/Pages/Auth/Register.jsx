import React from 'react';
import {
    Container, TextField, Button, Typography, Paper, Box, Stack,
    Link as MuiLink,
} from '@mui/material';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('register'), {
            onFinish: () => reset('password', 'password_confirmation'),
        });
    };

    return (
        <GuestLayout>
            <Head title="Register" />
            <Container maxWidth="xs">
                <Paper sx={{ p: 4, mt: 8 }}>
                    <Typography variant="h5" align="center" gutterBottom>Register</Typography>

                    <form onSubmit={submit}>
                        <Stack spacing={2}>
                            <TextField
                                label="Name"
                                value={data.name}
                                onChange={(e) => setData('name', e.target.value)}
                                error={!!errors.name}
                                helperText={errors.name}
                                fullWidth
                                autoFocus
                                required
                            />
                            <TextField
                                label="Email"
                                type="email"
                                value={data.email}
                                onChange={(e) => setData('email', e.target.value)}
                                error={!!errors.email}
                                helperText={errors.email}
                                fullWidth
                                required
                            />
                            <TextField
                                label="Password"
                                type="password"
                                value={data.password}
                                onChange={(e) => setData('password', e.target.value)}
                                error={!!errors.password}
                                helperText={errors.password}
                                fullWidth
                                required
                            />
                            <TextField
                                label="Confirm Password"
                                type="password"
                                value={data.password_confirmation}
                                onChange={(e) => setData('password_confirmation', e.target.value)}
                                error={!!errors.password_confirmation}
                                helperText={errors.password_confirmation}
                                fullWidth
                                required
                            />
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <MuiLink component={Link} href={route('login')} variant="body2">
                                    Already registered?
                                </MuiLink>
                                <Button type="submit" variant="contained" disabled={processing}>
                                    Register
                                </Button>
                            </Box>
                        </Stack>
                    </form>
                </Paper>
            </Container>
        </GuestLayout>
    );
}
