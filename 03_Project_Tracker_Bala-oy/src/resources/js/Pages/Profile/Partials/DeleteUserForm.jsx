import { useRef, useState } from 'react';
import { useForm } from '@inertiajs/react';
import { 
    Paper, Typography, Box, Button, Dialog, DialogTitle, 
    DialogContent, DialogContentText, DialogActions, TextField 
} from '@mui/material';
import { WarningAmber as WarningIcon, DeleteForever as DeleteIcon } from '@mui/icons-material';

export default function DeleteUserForm({ className = '' }) {
    const [confirmingUserDeletion, setConfirmingUserDeletion] = useState(false);
    const passwordInput = useRef();

    const {
        data,
        setData,
        delete: destroy,
        processing,
        reset,
        errors,
    } = useForm({
        password: '',
    });

    const confirmUserDeletion = () => {
        setConfirmingUserDeletion(true);
    };

    const deleteUser = (e) => {
        e.preventDefault();

        destroy(route('profile.destroy'), {
            preserveScroll: true,
            onSuccess: () => closeModal(),
            onError: () => passwordInput.current.focus(),
            onFinish: () => reset(),
        });
    };

    const closeModal = () => {
        setConfirmingUserDeletion(false);
        reset();
    };

    // --- Danger Zone Style ---
    const dangerStyle = {
        p: 4,
        borderRadius: '24px',
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        backdropFilter: 'blur(20px)',
        border: '1px solid rgba(255, 45, 85, 0.3)', // Reddish border
        boxShadow: '0 8px 32px rgba(255, 45, 85, 0.05)',
        height: '100%' // Fill height of grid column
    };

    return (
        <Paper sx={dangerStyle} elevation={0} className={className}>
            <header>
                <Typography variant="h6" fontWeight="700" color="error" gutterBottom display="flex" alignItems="center" gap={1}>
                    <WarningIcon color="error" /> Delete Account
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                    Once your account is deleted, all of its resources and data will be permanently deleted.
                </Typography>
            </header>

            <Button 
                variant="outlined" 
                color="error"
                onClick={confirmUserDeletion}
                startIcon={<DeleteIcon />}
                sx={{
                    borderRadius: '12px',
                    textTransform: 'none',
                    fontWeight: 600,
                    borderWidth: '2px',
                    '&:hover': { borderWidth: '2px', backgroundColor: 'rgba(255, 45, 85, 0.05)' }
                }}
            >
                Delete Account
            </Button>

            {/* Confirmation Modal */}
            <Dialog
                open={confirmingUserDeletion}
                onClose={closeModal}
                PaperProps={{
                    sx: { borderRadius: '24px', p: 1, width: '100%', maxWidth: '450px' }
                }}
            >
                <DialogTitle fontWeight="700">
                    Are you sure you want to delete your account?
                </DialogTitle>
                
                <DialogContent>
                    <DialogContentText sx={{ mb: 3 }}>
                        Once your account is deleted, all of its resources and data will be permanently deleted. 
                        Please enter your password to confirm you would like to permanently delete your account.
                    </DialogContentText>

                    <TextField
                        id="password"
                        type="password"
                        name="password"
                        label="Password"
                        value={data.password}
                        onChange={(e) => setData('password', e.target.value)}
                        inputRef={passwordInput}
                        fullWidth
                        autoFocus
                        error={Boolean(errors.password)}
                        helperText={errors.password}
                        sx={{ '& .MuiOutlinedInput-root': { borderRadius: '12px' } }}
                        onKeyDown={(e) => { if(e.key === 'Enter') deleteUser(e); }}
                    />
                </DialogContent>

                <DialogActions sx={{ p: 2 }}>
                    <Button 
                        onClick={closeModal} 
                        sx={{ color: 'text.secondary', fontWeight: 600, textTransform: 'none' }}
                    >
                        Cancel
                    </Button>
                    
                    <Button 
                        onClick={deleteUser} 
                        variant="contained" 
                        color="error"
                        disabled={processing}
                        sx={{ borderRadius: '12px', textTransform: 'none', fontWeight: 600, boxShadow: 'none' }}
                    >
                        Delete Account
                    </Button>
                </DialogActions>
            </Dialog>
        </Paper>
    );
}