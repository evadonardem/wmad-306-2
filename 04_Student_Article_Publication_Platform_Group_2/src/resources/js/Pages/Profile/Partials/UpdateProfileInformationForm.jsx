import {
    Alert,
    Box,
    Button,
    Fade,
    Stack,
    TextField,
    Typography,
} from '@mui/material';
import { Link as InertiaLink, useForm, usePage } from '@inertiajs/react';

export default function UpdateProfileInformation({
    mustVerifyEmail,
    status,
}) {
    const user = usePage().props.auth.user;

    const { data, setData, patch, errors, processing, recentlySuccessful } =
        useForm({
            name: user.name,
            email: user.email,
        });

    const submit = (e) => {
        e.preventDefault();

        patch(route('profile.update'));
    };

    return (
        <Box component="section">
            <Box sx={{ mb: 3 }}>
                <Typography variant="h6" sx={{ fontWeight: 700, color: 'text.primary', mb: 0.5 }}>
                    Profile Information
                </Typography>

                <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                    Update your account's profile information and email address.
                </Typography>
            </Box>

            <Box component="form" onSubmit={submit}>
                <Stack spacing={2.5} sx={{ maxWidth: 560 }}>
                    <TextField
                        id="name"
                        name="name"
                        label="Name"
                        fullWidth
                        value={data.name}
                        onChange={(e) => setData('name', e.target.value)}
                        error={!!errors.name}
                        helperText={errors.name}
                        required
                        autoComplete="name"
                        autoFocus
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                bgcolor: '#FFFFFF',
                            },
                        }}
                    />

                    <TextField
                        id="email"
                        name="email"
                        type="email"
                        label="Email"
                        fullWidth
                        value={data.email}
                        onChange={(e) => setData('email', e.target.value)}
                        error={!!errors.email}
                        helperText={errors.email}
                        required
                        autoComplete="username"
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                bgcolor: '#FFFFFF',
                            },
                        }}
                    />

                {mustVerifyEmail && user.email_verified_at === null && (
                    <Alert
                        severity="warning"
                        sx={{
                            borderRadius: 2,
                            bgcolor: '#FFF8E1',
                        }}
                    >
                        <Typography variant="body2" sx={{ mb: 1 }}>
                            Your email address is unverified.
                        </Typography>
                        <Button
                            size="small"
                            component={InertiaLink}
                            href={route('verification.send')}
                            method="post"
                            as="button"
                            sx={{ p: 0, minWidth: 0, textTransform: 'none', fontWeight: 700 }}
                        >
                            Click here to re-send the verification email.
                        </Button>

                        {status === 'verification-link-sent' && (
                            <Typography variant="body2" sx={{ mt: 1, fontWeight: 600, color: 'success.main' }}>
                                A new verification link has been sent to your
                                email address.
                            </Typography>
                        )}
                    </Alert>
                )}

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
