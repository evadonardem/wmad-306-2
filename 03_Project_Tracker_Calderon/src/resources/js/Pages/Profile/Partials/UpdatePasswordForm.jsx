import { useForm, router } from '@inertiajs/react';
import { useState } from 'react';
import {
    TextField,
    Button,
    Box,
    Typography,
    Alert,
    Snackbar,
    IconButton,
    Paper,
} from '@mui/material';
import { Lock, Visibility, VisibilityOff } from '@mui/icons-material';
import { useThemeContext } from '@/Components/ThemeProvider';

export default function UpdatePasswordForm({ className = '' }) {
    const { theme } = useThemeContext();
    const [showPasswords, setShowPasswords] = useState({
        new: false,
        confirm: false
    });
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    const { data, setData, patch, processing, errors, reset } = useForm({
        password: '',
        password_confirmation: '',
    });

    const submit = (e) => {
        e.preventDefault();
        patch(route('profile.password.update'), {
            onSuccess: () => {
                setSnackbar({
                    open: true,
                    message: 'Password updated successfully!',
                    severity: 'success'
                });
                reset();
                setShowPasswords({ new: false, confirm: false });
            },
            onError: () => {
                setSnackbar({
                    open: true,
                    message: 'Error updating password. Please check form.',
                    severity: 'error'
                });
            }
        });
    };

    const handleCloseSnackbar = () => {
        setSnackbar(prev => ({ ...prev, open: false }));
    };

    const togglePasswordVisibility = (field) => {
        setShowPasswords(prev => ({ ...prev, [field]: !prev[field] }));
    };

    const PasswordField = ({ label, field, value, onChange, error, helperText }) => (
        <TextField
            fullWidth
            label={label}
            type={showPasswords[field] ? 'text' : 'password'}
            value={value}
            onChange={onChange}
            error={!!error}
            helperText={error}
            required
            size="small"
            InputProps={{
                endAdornment: (
                    <IconButton
                        onClick={() => togglePasswordVisibility(field)}
                        edge="end"
                        sx={{ p: 1 }}
                    >
                        {showPasswords[field] ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                ),
            }}
        />
    );

    return (
        <Box className={className}>
            <Box component="form" onSubmit={submit} sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>

                <Box>
                    <TextField
                        fullWidth
                        label="New Password"
                        type={showPasswords.new ? 'text' : 'password'}
                        value={data.password}
                        onChange={(e) => setData('password', e.target.value)}
                        error={!!errors.password}
                        helperText={errors.password}
                        required
                        autoComplete="new-password"
                        InputProps={{
                            endAdornment: (
                                <IconButton
                                    onClick={() => setShowPasswords(prev => ({ ...prev, new: !prev.new }))}
                                    edge="end"
                                >
                                    {showPasswords.new ? <VisibilityOff /> : <Visibility />}
                                </IconButton>
                            ),
                        }}
                    />
                </Box>

                <Box>
                    <TextField
                        fullWidth
                        label="Confirm Password"
                        type={showPasswords.confirm ? 'text' : 'password'}
                        value={data.password_confirmation}
                        onChange={(e) => setData('password_confirmation', e.target.value)}
                        error={!!errors.password_confirmation}
                        helperText={errors.password_confirmation}
                        required
                        autoComplete="new-password"
                        InputProps={{
                            endAdornment: (
                                <IconButton
                                    onClick={() => setShowPasswords(prev => ({ ...prev, confirm: !prev.confirm }))}
                                    edge="end"
                                >
                                    {showPasswords.confirm ? <VisibilityOff /> : <Visibility />}
                                </IconButton>
                            ),
                        }}
                    />
                </Box>

                <Box sx={{ display: 'flex', gap: 2, mt: 2, justifyContent: 'center' }}>
                    <Button
                        type="submit"
                        variant="contained"
                        disabled={processing}
                        sx={{
                            background: theme.palette.primary.main,
                            color: theme.palette.primary.contrastText,
                            borderRadius: 1,
                            textTransform: 'none',
                            '&:hover': {
                                background: theme.palette.primary.dark,
                            }
                        }}
                    >
                        {processing ? 'Updating...' : 'Update Password'}
                    </Button>
                    <Button
                        onClick={() => reset()}
                        variant="outlined"
                        sx={{
                            borderRadius: 2,
                            textTransform: 'none',
                        }}
                    >
                        Cancel
                    </Button>
                </Box>
            </Box>

            <Snackbar
                open={snackbar.open}
                autoHideDuration={4000}
                onClose={handleCloseSnackbar}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
            >
                <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: '100%' }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </Box>
    );
}
