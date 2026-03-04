import React from 'react';
import {
    Container, TextField, Button, Typography, Paper, Box, Checkbox,
    FormControlLabel, Alert, Link as MuiLink, Stack,
} from '@mui/material';
import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

export default function Login({ status, canResetPassword }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('login'), {
            onFinish: () => reset('password'),
        });
    };

    return (
        <GuestLayout>
            <Head title="Log in" />
            <Container maxWidth="xs">
                <Paper sx={{ p: 4, mt: 8 }}>
                    <Typography variant="h5" align="center" gutterBottom>Log In</Typography>

                    {status && <Alert severity="success" sx={{ mb: 2 }}>{status}</Alert>}

                    <form onSubmit={submit}>
                        <Stack spacing={2}>
                            <TextField
                                label="Email"
                                type="email"
                                value={data.email}
                                onChange={(e) => setData('email', e.target.value)}
                                error={!!errors.email}
                                helperText={errors.email}
                                fullWidth
                                autoFocus
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
                            <FormControlLabel
                                control={
                                    <Checkbox
                                        checked={data.remember}
                                        onChange={(e) => setData('remember', e.target.checked)}
                                    />
                                }
                                label="Remember me"
                            />
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                {canResetPassword && (
                                    <MuiLink component={Link} href={route('password.request')} variant="body2">
                                        Forgot your password?
                                    </MuiLink>
                                )}
                                <Button type="submit" variant="contained" disabled={processing}>
                                    Log in
                                </Button>
                            </Box>
                        </Stack>
                    </form>
                </Paper>
            </Container>
        </GuestLayout>
    );
}
