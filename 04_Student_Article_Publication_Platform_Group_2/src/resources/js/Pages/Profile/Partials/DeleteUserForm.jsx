import {
    Alert,
    Box,
    Button,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    Stack,
    TextField,
    Typography,
} from '@mui/material';
import { useForm } from '@inertiajs/react';
import { useRef, useState } from 'react';

export default function DeleteUserForm() {
    const [confirmingUserDeletion, setConfirmingUserDeletion] = useState(false);
    const passwordInput = useRef();

    const {
        data,
        setData,
        delete: destroy,
        processing,
        reset,
        errors,
        clearErrors,
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

        clearErrors();
        reset();
    };

    return (
        <Box component="section">
            <Stack spacing={2.5} sx={{ maxWidth: 700 }}>
                <Box>
                    <Typography variant="h6" sx={{ fontWeight: 700, color: 'text.primary', mb: 0.5 }}>
                    Delete Account
                    </Typography>

                    <Typography variant="body2" sx={{ color: 'text.secondary' }}>
                    Once your account is deleted, all of its resources and data
                    will be permanently deleted. Before deleting your account,
                    please download any data or information that you wish to
                    retain.
                    </Typography>
                </Box>

                <Alert severity="error" sx={{ borderRadius: 2 }}>
                    This action is permanent and cannot be undone.
                </Alert>

                <Box>
                    <Button variant="contained" color="error" onClick={confirmUserDeletion} sx={{ fontWeight: 700 }}>
                        Delete Account
                    </Button>
                </Box>
            </Stack>

            <Dialog open={confirmingUserDeletion} onClose={closeModal} maxWidth="sm" fullWidth>
                <Box component="form" onSubmit={deleteUser}>
                    <DialogTitle sx={{ fontWeight: 700 }}>
                        Are you sure you want to delete your account?
                    </DialogTitle>

                    <DialogContent>
                        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
                        Once your account is deleted, all of its resources and
                        data will be permanently deleted. Please enter your
                        password to confirm you would like to permanently delete
                        your account.
                        </Typography>

                        <TextField
                            id="password"
                            type="password"
                            name="password"
                            fullWidth
                            inputRef={passwordInput}
                            value={data.password}
                            onChange={(e) => setData('password', e.target.value)}
                            placeholder="Password"
                            autoFocus
                            error={!!errors.password}
                            helperText={errors.password}
                            sx={{
                                '& .MuiOutlinedInput-root': {
                                    bgcolor: '#FFFFFF',
                                },
                            }}
                        />
                    </DialogContent>

                    <DialogActions sx={{ px: 3, pb: 3 }}>
                        <Button onClick={closeModal} variant="outlined">
                            Cancel
                        </Button>
                        <Button type="submit" variant="contained" color="error" disabled={processing} sx={{ fontWeight: 700 }}>
                            Delete Account
                        </Button>
                    </DialogActions>
                </Box>
            </Dialog>
        </Box>
    );
}
