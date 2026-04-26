import CoolButton from '@/Components/CoolButton';
import { Link, useForm, usePage } from '@inertiajs/react';
import { Alert, Avatar, Box, Button, Stack, TextField, Typography } from '@mui/material';
import { useEffect, useMemo, useState } from 'react';

export default function UpdateProfileInformationForm({ mustVerifyEmail, status }) {
    const user = usePage().props.auth.user;
    const { data, setData, patch, errors, processing, recentlySuccessful } = useForm({
        name: user.name,
        email: user.email,
        avatar: null,
        remove_avatar: false,
    });
    const [localPreview, setLocalPreview] = useState(null);
    const previewSrc = useMemo(() => localPreview ?? user.avatar_url ?? null, [localPreview, user.avatar_url]);

    useEffect(() => () => {
        if (localPreview) {
            URL.revokeObjectURL(localPreview);
        }
    }, [localPreview]);

    const submit = (e) => {
        e.preventDefault();
        patch(route('profile.update'), {
            forceFormData: true,
        });
    };

    // Unified card styling - matching UpdateAppearancePreferencesForm
    const cardStyles = {
        bgcolor: 'background.paper',
        borderRadius: '2rem',
        p: { xs: 3, sm: 4 },
        boxShadow: 'none',
        border: '1px solid',
        borderColor: 'divider',
        overflow: 'hidden',
    };

    return (
        <Box sx={cardStyles}>
            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1, display: 'flex', alignItems: 'center', gap: 1.5 }}>
                <span>👤</span> Profile Information
            </Typography>
            <Typography color="text.secondary" sx={{ mb: 4 }}>
                Update your account identity used for submissions and comments.
            </Typography>

            <Stack component="form" onSubmit={submit} spacing={3}>
                <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems={{ xs: 'flex-start', sm: 'center' }}>
                    <Avatar
                        src={previewSrc ?? undefined}
                        alt={user.name}
                        sx={{ width: 74, height: 74, bgcolor: '#2f6fdb', fontWeight: 700, fontSize: '1.2rem' }}
                    >
                        {!previewSrc ? (user.name?.[0] ?? 'U') : null}
                    </Avatar>
                    <Stack spacing={1} sx={{ width: '100%' }}>
                        <Button variant="outlined" component="label" sx={{ borderRadius: '0.85rem', fontWeight: 700, width: { xs: '100%', sm: 'fit-content' } }}>
                            Upload profile picture
                            <input
                                type="file"
                                hidden
                                accept="image/*"
                                onChange={(e) => {
                                    const file = e.target.files?.[0] ?? null;
                                    if (localPreview) {
                                        URL.revokeObjectURL(localPreview);
                                    }
                                    setData('avatar', file);
                                    setData('remove_avatar', false);
                                    setLocalPreview(file ? URL.createObjectURL(file) : null);
                                }}
                            />
                        </Button>
                        <Button
                            variant="text"
                            color="inherit"
                            sx={{ fontWeight: 600, width: { xs: '100%', sm: 'fit-content' } }}
                            onClick={() => {
                                if (localPreview) {
                                    URL.revokeObjectURL(localPreview);
                                }
                                setLocalPreview(null);
                                setData('avatar', null);
                                setData('remove_avatar', true);
                            }}
                        >
                            Remove picture
                        </Button>
                        {errors.avatar && <Typography color="error.main" variant="caption">{errors.avatar}</Typography>}
                    </Stack>
                </Stack>

                <TextField label="Name" value={data.name} onChange={(e) => setData('name', e.target.value)}
                    error={Boolean(errors.name)} helperText={errors.name} required fullWidth
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }} />

                <TextField label="Email" type="email" value={data.email} onChange={(e) => setData('email', e.target.value)}
                    error={Boolean(errors.email)} helperText={errors.email} required fullWidth
                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }} />

                {mustVerifyEmail && user.email_verified_at === null && (
                    <Alert severity="warning" sx={{ borderRadius: 3 }}>
                        Your email is unverified. <Button component={Link} href={route('verification.send')} method="post">Resend</Button>
                    </Alert>
                )}

                <Stack direction="row" spacing={2} alignItems="center">
                    <CoolButton type="submit" disabled={processing}>Save Changes</CoolButton>
                    {recentlySuccessful && <Typography color="success.main" sx={{ fontWeight: 600 }}>✨ Saved</Typography>}
                </Stack>
            </Stack>
        </Box>
    );
}
