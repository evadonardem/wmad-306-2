import CoolButton from '@/Components/CoolButton';
import { useForm } from '@inertiajs/react';
import { Box, Button, Dialog, DialogActions, DialogContent, DialogTitle, Stack, TextField, Typography, Divider } from '@mui/material';
import { useState } from 'react';

export default function DeleteUserForm() {
    const [confirmingUserDeletion, setConfirmingUserDeletion] = useState(false);
    const { data, setData, delete: destroy, processing, reset, errors, clearErrors } = useForm({ password: '' });

    const closeModal = () => { setConfirmingUserDeletion(false); clearErrors(); reset(); };
    const deleteUser = (e) => { e.preventDefault(); destroy(route('profile.destroy'), { onSuccess: () => closeModal() }); };

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
                <span>⚠️</span> Danger Zone
            </Typography>
            <Typography color="text.secondary" sx={{ mb: 4 }}>
                Permanently delete your account. This action cannot be undone.
            </Typography>

            <CoolButton tone="outline" color="error" onClick={() => setConfirmingUserDeletion(true)}>
                Delete Account
            </CoolButton>

            <Dialog open={confirmingUserDeletion} onClose={closeModal} PaperProps={{ sx: { borderRadius: 4, p: 1 } }}>
                <DialogTitle sx={{ fontWeight: 800 }}>Are you absolutely sure?</DialogTitle>
                <DialogContent>
                    <Typography color="text.secondary" sx={{ mb: 3 }}>
                        Please enter your password to confirm you would like to permanently delete your account.
                    </Typography>
                    <TextField type="password" label="Confirm Password" value={data.password} 
                        onChange={(e) => setData('password', e.target.value)} error={Boolean(errors.password)}
                        helperText={errors.password} fullWidth autoFocus sx={{ '& .MuiOutlinedInput-root': { borderRadius: 3 } }} />
                </DialogContent>
                <DialogActions sx={{ p: 3 }}>
                    <Button onClick={closeModal} sx={{ fontWeight: 'bold' }}>Cancel</Button>
                    <Button color="error" variant="contained" onClick={deleteUser} disabled={processing} 
                        sx={{ borderRadius: 2, px: 3, fontWeight: 'bold', boxShadow: 'none' }}>
                        Permanently Delete
                    </Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
}