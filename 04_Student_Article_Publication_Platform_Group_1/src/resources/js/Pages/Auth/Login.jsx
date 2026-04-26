import { useState } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import {
    Box,
    TextField,
    Button,
    Checkbox,
    Typography,
    Alert,
    FormControlLabel,
} from '@mui/material';
import {
    Eye,
    EyeOff,
    Zap,
    AlertCircle,
    ArrowRight
} from 'lucide-react';
import GuestLayout from '@/Layouts/GuestLayout';

export default function Login({ status, canResetPassword }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    const [showPassword, setShowPassword] = useState(false);

    const submit = (e) => {
        e.preventDefault();
        post(route('login'), {
            onFinish: () => reset('password'),
        });
    };

    return (
        <GuestLayout>
            <Head title="Log in" />

            <Box
                component="form"
                onSubmit={submit}
                sx={{
                    position: 'relative',
                    p: 4,
                    maxWidth: '500px',
                    background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.95) 0%, rgba(15, 23, 42, 0.98) 100%)',
                    backdropFilter: 'blur(30px)',
                    borderRadius: '30px',
                    border: '2px solid rgba(59, 130, 246, 0.3)',
                    boxShadow: '0 0 40px rgba(59, 130, 246, 0.2), inset 0 0 20px rgba(59, 130, 246, 0.1)',
                    animation: 'slideInBounce 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) both',
                    '&::before': {
                        content: '""',
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        right: 0,
                        height: '1px',
                        background: 'linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.5), transparent)',
                        borderRadius: '30px 30px 0 0',
                    },
                    '&:hover': {
                        boxShadow: '0 0 60px rgba(59, 130, 246, 0.4), inset 0 0 30px rgba(59, 130, 246, 0.2)',
                    }
                }}
            >
                <Box sx={{
                    position: 'absolute',
                    top: '-50px',
                    right: '-50px',
                    width: '200px',
                    height: '200px',
                    background: 'radial-gradient(circle, rgba(59, 130, 246, 0.2), transparent)',
                    borderRadius: '50%',
                    animation: 'float 8s ease-in-out infinite',
                    pointerEvents: 'none',
                }} />

                <Box sx={{
                    display: 'flex',
                    justifyContent: 'center',
                    mb: 3,
                    animation: 'extremeBounce 1.5s ease-in-out infinite',
                }}>
                    <Box sx={{
                        width: '80px',
                        height: '80px',
                        background: 'linear-gradient(135deg, #3B82F6, #0EA5E9)',
                        borderRadius: '20px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        boxShadow: '0 0 30px rgba(59, 130, 246, 0.6), inset 0 0 15px rgba(255, 255, 255, 0.1)',
                        animation: 'neonGlow 2s ease-in-out infinite',
                    }}>
                        <Zap size={40} color="white" strokeWidth={3} />
                    </Box>
                </Box>

                <Typography
                    variant="h4"
                    sx={{
                        textAlign: 'center',
                        mb: 1,
                        fontWeight: 900,
                        background: 'linear-gradient(90deg, #3B82F6, #0EA5E9, #059669, #F59E0B, #3B82F6)',
                        backgroundSize: '200% auto',
                        WebkitBackgroundClip: 'text',
                        WebkitTextFillColor: 'transparent',
                        animation: 'gradientShift 3s ease infinite',
                    }}
                >
                    WELCOME BACK
                </Typography>

                <Typography
                    variant="body2"
                    sx={{
                        textAlign: 'center',
                        color: '#CBD5E1',
                        mb: 3,
                        fontWeight: 500,
                        textTransform: 'uppercase',
                        letterSpacing: '2px',
                        animation: 'fadeInUp 0.8s ease 0.2s both',
                    }}
                >
                    Sign in to your account
                </Typography>

                {status && (
                    <Alert variant="filled" severity="success" sx={{
                        mb: 2,
                        background: 'linear-gradient(135deg, #059669, #10B981)',
                        animation: 'slideInBounce 0.6s cubic-bezier(0.34, 1.56, 0.64, 1)',
                    }}>
                        {status}
                    </Alert>
                )}

                <Box sx={{ mb: 2.5, animation: 'fadeInUp 0.8s ease 0.3s both' }}>
                    <TextField
                        type="email"
                        fullWidth
                        placeholder="Enter your email"
                        value={data.email}
                        onChange={(e) => setData('email', e.target.value)}
                        error={!!errors.email}
                        disabled={processing}
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                color: '#F1F5F9',
                                background: 'rgba(30, 41, 59, 0.6)',
                                backdropFilter: 'blur(10px)',
                                border: '2px solid rgba(148, 163, 184, 0.2)',
                                borderRadius: '15px',
                                transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                                '&:hover': {
                                    background: 'rgba(30, 41, 59, 0.8)',
                                    border: '2px solid rgba(59, 130, 246, 0.4)',
                                    boxShadow: '0 0 20px rgba(59, 130, 246, 0.2)',
                                },
                                '&.Mui-focused': {
                                    background: 'rgba(30, 41, 59, 0.95)',
                                    border: '2px solid rgba(59, 130, 246, 0.7)',
                                    boxShadow: '0 0 30px rgba(59, 130, 246, 0.4), inset 0 0 10px rgba(59, 130, 246, 0.1)',
                                    animation: 'extremeBounce 0.6s ease',
                                },
                                '& fieldset': { border: 'none' },
                            },
                            '& .MuiOutlinedInput-input::placeholder': {
                                color: '#94A3B8',
                                opacity: 0.7,
                            },
                        }}
                    />
                    {errors.email && (
                        <Box sx={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 0.5,
                            mt: 1,
                            color: '#F87171',
                            fontSize: '0.85rem',
                            animation: 'shake 0.5s ease',
                        }}>
                            <AlertCircle size={14} />
                            {errors.email}
                        </Box>
                    )}
                </Box>

                <Box sx={{ mb: 2.5, animation: 'fadeInUp 0.8s ease 0.4s both' }}>
                    <TextField
                        type={showPassword ? 'text' : 'password'}
                        fullWidth
                        placeholder="Enter your password"
                        value={data.password}
                        onChange={(e) => setData('password', e.target.value)}
                        error={!!errors.password}
                        disabled={processing}
                        InputProps={{
                            endAdornment: (
                                <Box
                                    onClick={() => setShowPassword(!showPassword)}
                                    sx={{
                                        cursor: 'pointer',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        width: '40px',
                                        height: '40px',
                                        transition: 'all 0.3s ease',
                                        '&:hover': {
                                            color: '#3B82F6',
                                            textShadow: '0 0 10px rgba(59, 130, 246, 0.5)',
                                        }
                                    }}
                                >
                                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                </Box>
                            ),
                        }}
                        sx={{
                            '& .MuiOutlinedInput-root': {
                                color: '#F1F5F9',
                                background: 'rgba(30, 41, 59, 0.6)',
                                backdropFilter: 'blur(10px)',
                                border: '2px solid rgba(148, 163, 184, 0.2)',
                                borderRadius: '15px',
                                transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                                '&:hover': {
                                    background: 'rgba(30, 41, 59, 0.8)',
                                    border: '2px solid rgba(59, 130, 246, 0.4)',
                                    boxShadow: '0 0 20px rgba(59, 130, 246, 0.2)',
                                },
                                '&.Mui-focused': {
                                    background: 'rgba(30, 41, 59, 0.95)',
                                    border: '2px solid rgba(59, 130, 246, 0.7)',
                                    boxShadow: '0 0 30px rgba(59, 130, 246, 0.4), inset 0 0 10px rgba(59, 130, 246, 0.1)',
                                    animation: 'extremeBounce 0.6s ease',
                                },
                                '& fieldset': { border: 'none' },
                            },
                            '& .MuiOutlinedInput-input::placeholder': {
                                color: '#94A3B8',
                                opacity: 0.7,
                            },
                        }}
                    />
                    {errors.password && (
                        <Box sx={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 0.5,
                            mt: 1,
                            color: '#F87171',
                            fontSize: '0.85rem',
                            animation: 'shake 0.5s ease',
                        }}>
                            <AlertCircle size={14} />
                            {errors.password}
                        </Box>
                    )}
                </Box>

                <Box sx={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    mb: 3,
                    animation: 'fadeInUp 0.8s ease 0.5s both',
                }}>
                    <FormControlLabel
                        control={
                            <Checkbox
                                checked={data.remember}
                                onChange={(e) => setData('remember', e.target.checked)}
                                disabled={processing}
                            />
                        }
                        label="Remember me"
                        sx={{ color: '#CBD5E1' }}
                    />
                    {canResetPassword && (
                        <Link href={route('password.request')} style={{color: '#3B82F6'}}>
                            Forgot password?
                        </Link>
                    )}
                </Box>

                <Button
                    type="submit"
                    fullWidth
                    disabled={processing}
                    variant="contained"
                    sx={{
                        background: 'linear-gradient(135deg, #3B82F6 0%, #0EA5E9 100%)',
                        color: 'white',
                        fontWeight: 900,
                        fontSize: '1rem',
                        py: 1.8,
                        borderRadius: '15px',
                        textTransform: 'uppercase',
                        letterSpacing: '2px',
                        border: '2px solid rgba(59, 130, 246, 0.5)',
                        position: 'relative',
                        overflow: 'hidden',
                        transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
                        animation: 'fadeInUp 0.8s ease 0.6s both',
                        '&::before': {
                            content: '""',
                            position: 'absolute',
                            top: 0,
                            left: '-100%',
                            width: '100%',
                            height: '100%',
                            background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent)',
                        },
                        '&:hover': {
                            boxShadow: '0 0 40px rgba(59, 130, 246, 0.5), 0 0 80px rgba(14, 165, 233, 0.3)',
                            transform: 'translateY(-3px) scale(1.02)',
                        },
                        '&:active': {
                            transform: 'translateY(-1px) scale(0.98)',
                        },
                        '&.Mui-disabled': {
                            opacity: 0.6,
                        }
                    }}
                >
                    {processing ? 'Signing in...' : 'Sign In'}
                </Button>

                <Typography sx={{
                    textAlign: 'center',
                    mt: 3,
                    color: '#CBD5E1',
                    animation: 'fadeInUp 0.8s ease 0.7s both',
                }}>
                    Don't have an account?{' '}
                    <Link href={route('register')} style={{color: '#3B82F6', fontWeight: 900}}>
                        Create one now
                    </Link>
                </Typography>
            </Box>
        </GuestLayout>
    );
}
