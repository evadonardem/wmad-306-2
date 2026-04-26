import { Box, Button, Fade, Stack, TextField, Typography } from '@mui/material';
import { useForm } from '@inertiajs/react';
import { useRef } from 'react';

export default function UpdatePasswordForm() {
    const passwordInput = useRef();
    const currentPasswordInput = useRef();

    const {
        data,
        setData,
        errors,
        put,
        reset,
        processing,
        recentlySuccessful,
    } = useForm({
        current_password: '',
        password: '',
        password_confirmation: '',
    });

    const updatePassword = (e) => {
        e.preventDefault();

        put(route('password.update'), {
            preserveScroll: true,
            onSuccess: () => reset(),
            onError: (errors) => {
                if (errors.password) {
                    reset('password', 'password_confirmation');
                    passwordInput.current.focus();
                }

                if (errors.current_password) {
                    reset('current_password');
                    currentPasswordInput.current.focus();
                }
            },
        });
    };

    return (
        <Box component="section">
            <Box sx={{ mb: 3 }}>
                <Typography variant="h6" sx={{ fontWeight: 700, color: 'text.primary', mb: 0.5 }}>
                    Update Password
                </Typography>

                <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                    Ensure your account is using a long, random password to stay
                    secure.
                </Typography>
            </Box>

            <Box component="form" onSubmit={updatePassword}>
                <Stack spacing={2.5} sx={{ maxWidth: 560 }}>
                    <TextField
                        id="current_password"
                        name="current_password"
                        type="password"
                        label="Current Password"
                        fullWidth
                        inputRef={currentPasswordInput}
                        value={data.current_password}
                        onChange={(e) =>
                            setData('current_password', e.target.value)
                        }
                        autoComplete="current-password"
                        error={!!errors.current_password}
                        helperText={errors.current_password}
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                bgcolor: '#FFFFFF',
                            },
                        }}
                    />

                    <TextField
                        id="password"
                        name="password"
                        type="password"
                        label="New Password"
                        fullWidth
                        inputRef={passwordInput}
                        value={data.password}
                        onChange={(e) => setData('password', e.target.value)}
                        autoComplete="new-password"
                        error={!!errors.password}
                        helperText={errors.password}
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                bgcolor: '#FFFFFF',
                            },
                        }}
                    />

                    <TextField
                        id="password_confirmation"
                        name="password_confirmation"
                        type="password"
                        label="Confirm Password"
                        fullWidth
                        value={data.password_confirmation}
                        onChange={(e) =>
                            setData('password_confirmation', e.target.value)
                        }
                        autoComplete="new-password"
                        error={!!errors.password_confirmation}
                        helperText={errors.password_confirmation}
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                bgcolor: '#FFFFFF',
                            },
                        }}
                    />

                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                        <Button
                            type="submit"
                            variant="contained"
                            disabled={processing}
                            sx={{
                                px: 3,
                                py: 1,
                                fontWeight: 700,
                                bgcolor: 'primary.main',
                                '&:hover': { bgcolor: 'primary.dark' },
                            }}
                        >
                            Save
                        </Button>

                        <Fade in={recentlySuccessful} timeout={250}>
                            <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                            Saved.
                            </Typography>
                        </Fade>
                    </Box>
                </Stack>
            </Box>
        </Box>
    );
}
