import CoolButton from '@/Components/CoolButton';
import { useForm } from '@inertiajs/react';
import { Box, Stack, TextField, Typography, Divider } from '@mui/material';

export default function UpdatePasswordForm() {
    const { data, setData, errors, put, reset, processing, recentlySuccessful } = useForm({
        current_password: '', password: '', password_confirmation: '',
    });

    const updatePassword = (e) => { e.preventDefault(); put(route('password.update'), { onSuccess: () => reset() }); };

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
                <span>🔒</span> Security
            </Typography>
            <Typography color="text.secondary" sx={{ mb: 4 }}>Ensure your account is using a long, random password to stay secure.</Typography>

            <Stack component="form" onSubmit={updatePassword} spacing={3}>
                <TextField label="Current Password" type="password" value={data.current_password}
                    onChange={(e) => setData('current_password', e.target.value)} error={Boolean(errors.current_password)}
                    helperText={errors.current_password} fullWidth sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }} />
                
                <Divider />

                <TextField label="New Password" type="password" value={data.password}
                    onChange={(e) => setData('password', e.target.value)} error={Boolean(errors.password)}
                    helperText={errors.password} fullWidth sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }} />

                <TextField label="Confirm New Password" type="password" value={data.password_confirmation}
                    onChange={(e) => setData('password_confirmation', e.target.value)} error={Boolean(errors.password_confirmation)}
                    helperText={errors.password_confirmation} fullWidth sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }} />

                <Stack direction="row" spacing={2} alignItems="center">
                    <CoolButton type="submit" disabled={processing}>Update Password</CoolButton>
                    {recentlySuccessful && <Typography color="success.main" sx={{ fontWeight: 600 }}>✨ Updated</Typography>}
                </Stack>
            </Stack>
        </Box>
    );
}