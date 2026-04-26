import { useState } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import {
    Box,
    TextField,
    Button,
    Card,
    CardContent,
    Typography,
    Alert,
    LinearProgress,
    Container,
    Grid,
    Card as MuiCard,
} from '@mui/material';
import {
    Eye,
    EyeOff,
    UserPlus,
    CheckCircle2,
    Zap,
    AlertCircle,
    Sparkles,
} from 'lucide-react';
import GuestLayout from '@/Layouts/GuestLayout';

const roles = [
    { id: 'writer', name: 'Writer', color: '#3B82F6', icon: '✍️', desc: 'Create & submit articles' },
    { id: 'editor', name: 'Editor', color: '#059669', icon: '✓', desc: 'Review & approve content' },
    { id: 'student', name: 'Student', color: '#0EA5E9', icon: '📚', desc: 'Discover & read content' }
];

export default function Register() {
    const { data, setData, post, processing, errors } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
        role: '',
    });

    const [activeStep, setActiveStep] = useState(0);
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirm, setShowConfirm] = useState(false);

    const steps = ['Account Info', 'Password', 'Choose Role'];

    const canProceed = () => {
        if (activeStep === 0) return data.name && data.email;
        if (activeStep === 1) return data.password && data.password_confirmation && data.password === data.password_confirmation;
        if (activeStep === 2) return data.role;
        return false;
    };

    const handleNext = () => {
        if (canProceed() && activeStep < steps.length - 1) {
            setActiveStep(activeStep + 1);
        }
    };

    const handleBack = () => {
        if (activeStep > 0) setActiveStep(activeStep - 1);
    };

    const submit = (e) => {
        e.preventDefault();
        post(route('register'));
    };

    return (
        <GuestLayout>
            <Head title="Register" />

            <Container maxWidth="sm">
                <Box
                    sx={{
                        position: 'relative',
                        p: 4,
                        background: 'linear-gradient(135deg, rgba(30, 41, 59, 0.95) 0%, rgba(15, 23, 42, 0.98) 100%)',
                        backdropFilter: 'blur(30px)',
                        borderRadius: '30px',
                        border: '2px solid rgba(5, 150, 105, 0.3)',
                        boxShadow: '0 0 50px rgba(5, 150, 105, 0.15), inset 0 0 20px rgba(5, 150, 105, 0.1)',
                        animation: 'slideInBounce 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) both',
                        '&::before': {
                            content: '""',
                            position: 'absolute',
                            top: 0,
                            left: 0,
                            right: 0,
                            height: '1px',
                            background: 'linear-gradient(90deg, transparent, rgba(5, 150, 105, 0.5), transparent)',
                        },
                        '&:hover': {
                            boxShadow: '0 0 70px rgba(5, 150, 105, 0.25), inset 0 0 30px rgba(5, 150, 105, 0.15)',
                        }
                    }}
                >
                    {/* Header with Icon */}
                    <Box sx={{
                        display: 'flex',
                        justifyContent: 'center',
                        mb: 3,
                        animation: 'extremeBounce 1.5s ease-in-out infinite',
                    }}>
                        <Box sx={{
                            width: '80px',
                            height: '80px',
                            background: 'linear-gradient(135deg, #059669, #10B981)',
                            borderRadius: '20px',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            boxShadow: '0 0 30px rgba(5, 150, 105, 0.6), inset 0 0 15px rgba(255, 255, 255, 0.1)',
                            animation: 'neonGlowGreen 2s ease-in-out infinite',
                        }}>
                            <UserPlus size={40} color="white" strokeWidth={2.5} />
                        </Box>
                    </Box>

                    <Typography
                        variant="h4"
                        sx={{
                            textAlign: 'center',
                            mb: 2,
                            fontWeight: 900,
                            background: 'linear-gradient(90deg, #059669, #10B981, #34D399, #059669)',
                            backgroundSize: '200% auto',
                            WebkitBackgroundClip: 'text',
                            WebkitTextFillColor: 'transparent',
                            animation: 'gradientShift 3s ease infinite',
                        }}
                    >
                        CREATE ACCOUNT
                    </Typography>

                    <Typography
                        variant="body2"
                        sx={{
                            textAlign: 'center',
                            color: '#CBD5E1',
                            mb: 3,
                            fontWeight: 500,
                            animation: 'fadeInUp 0.8s ease 0.2s both',
                        }}
                    >
                        Step {activeStep + 1} of {steps.length} - {steps[activeStep]}
                    </Typography>

                    {/* Progress Bar with glow */}
                    <Box sx={{
                        mb: 3,
                        animation: 'fadeInUp 0.8s ease 0.3s both',
                    }}>
                        <LinearProgress
                            variant="determinate"
                            value={((activeStep + 1) / steps.length) * 100}
                            sx={{
                                height: '8px',
                                borderRadius: '10px',
                                background: 'rgba(5, 150, 105, 0.1)',
                                '& .MuiLinearProgress-bar': {
                                    background: 'linear-gradient(90deg, #059669, #10B981, #34D399)',
                                    borderRadius: '10px',
                                    boxShadow: '0 0 20px rgba(5, 150, 105, 0.6)',
                                }
                            }}
                        />
                    </Box>

                    {/* Step Indicators */}
                    <Box sx={{
                        display: 'flex',
                        justifyContent: 'space-around',
                        mb: 4,
                        animation: 'fadeInUp 0.8s ease 0.4s both',
                    }}>
                        {steps.map((label, index) => (
                            <Box key={index} sx={{ textAlign: 'center' }}>
                                <Box sx={{
                                    width: '48px',
                                    height: '48px',
                                    borderRadius: '50%',
                                    background: index <= activeStep
                                        ? (index === activeStep ? 'linear-gradient(135deg, #059669, #10B981)' : 'linear-gradient(135deg, #059669, #10B981)')
                                        : 'rgba(148, 163, 184, 0.2)',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    color: index <= activeStep ? 'white' : '#94A3B8',
                                    fontWeight: 700,
                                    fontSize: '0.875rem',
                                    mx: 'auto',
                                    mb: 1,
                                    transition: 'all 0.3s ease',
                                    boxShadow: index <= activeStep ? '0 0 15px rgba(5, 150, 105, 0.4)' : 'none',
                                    animation: index === activeStep ? 'spinPulse 1s ease infinite' : 'none',
                                }}>
                                    {index < activeStep ? <CheckCircle2 size={24} /> : index + 1}
                                </Box>
                                <Typography variant="caption" sx={{ color: index <= activeStep ? '#10B981' : '#94A3B8', fontWeight: 600 }}>
                                    {label}
                                </Typography>
                            </Box>
                        ))}
                    </Box>

                    {/* Form */}
                    <Box component="form" onSubmit={submit} noValidate>
                        {/* Step 0: Account Info */}
                        {activeStep === 0 && (
                            <Box sx={{ animation: 'slideInBounce 0.6s ease-out' }}>
                                <Box sx={{ mb: 2.5, animation: 'fadeInUp 0.8s ease 0.1s both' }}>
                                    <TextField
                                        fullWidth
                                        type="text"
                                        placeholder="Full Name"
                                        value={data.name}
                                        onChange={(e) => setData('name', e.target.value)}
                                        error={!!errors.name}
                                        disabled={processing}
                                        sx={{
                                            '& .MuiOutlinedInput-root': {
                                                color: '#F1F5F9',
                                                background: 'rgba(30, 41, 59, 0.6)',
                                                border: '2px solid rgba(5, 150, 105, 0.2)',
                                                borderRadius: '15px',
                                                transition: 'all 0.3s ease',
                                                '&:hover': {
                                                    border: '2px solid rgba(5, 150, 105, 0.4)',
                                                    boxShadow: '0 0 20px rgba(5, 150, 105, 0.2)',
                                                },
                                                '&.Mui-focused': {
                                                    border: '2px solid rgba(5, 150, 105, 0.7)',
                                                    boxShadow: '0 0 30px rgba(5, 150, 105, 0.4)',
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
                                    {errors.name && (
                                        <Box sx={{ color: '#F87171', fontSize: '0.85rem', mt: 1, animation: 'shake 0.5s ease' }}>
                                            <AlertCircle size={14} />{errors.name}
                                        </Box>
                                    )}
                                </Box>

                                <Box sx={{ mb: 2.5, animation: 'fadeInUp 0.8s ease 0.2s both' }}>
                                    <TextField
                                        fullWidth
                                        type="email"
                                        placeholder="Email Address"
                                        value={data.email}
                                        onChange={(e) => setData('email', e.target.value)}
                                        error={!!errors.email}
                                        disabled={processing}
                                        sx={{
                                            '& .MuiOutlinedInput-root': {
                                                color: '#F1F5F9',
                                                background: 'rgba(30, 41, 59, 0.6)',
                                                border: '2px solid rgba(5, 150, 105, 0.2)',
                                                borderRadius: '15px',
                                                transition: 'all 0.3s ease',
                                                '&:hover': {
                                                    border: '2px solid rgba(5, 150, 105, 0.4)',
                                                    boxShadow: '0 0 20px rgba(5, 150, 105, 0.2)',
                                                },
                                                '&.Mui-focused': {
                                                    border: '2px solid rgba(5, 150, 105, 0.7)',
                                                    boxShadow: '0 0 30px rgba(5, 150, 105, 0.4)',
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
                                        <Box sx={{ color: '#F87171', fontSize: '0.85rem', mt: 1, animation: 'shake 0.5s ease' }}>
                                            <AlertCircle size={14} />{errors.email}
                                        </Box>
                                    )}
                                </Box>
                            </Box>
                        )}

                        {/* Step 1: Password */}
                        {activeStep === 1 && (
                            <Box sx={{ animation: 'slideInBounce 0.6s ease-out' }}>
                                <Box sx={{ mb: 2.5, animation: 'fadeInUp 0.8s ease 0.1s both' }}>
                                    <TextField
                                        fullWidth
                                        type={showPassword ? 'text' : 'password'}
                                        placeholder="Password"
                                        value={data.password}
                                        onChange={(e) => setData('password', e.target.value)}
                                        error={!!errors.password}
                                        disabled={processing}
                                        InputProps={{
                                            endAdornment: (
                                                <Box onClick={() => setShowPassword(!showPassword)} sx={{ cursor: 'pointer', mr: 1 }}>
                                                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                                </Box>
                                            ),
                                        }}
                                        sx={{
                                            '& .MuiOutlinedInput-root': {
                                                color: '#F1F5F9',
                                                background: 'rgba(30, 41, 59, 0.6)',
                                                border: '2px solid rgba(5, 150, 105, 0.2)',
                                                borderRadius: '15px',
                                                transition: 'all 0.3s ease',
                                                '&:hover': {
                                                    border: '2px solid rgba(5, 150, 105, 0.4)',
                                                    boxShadow: '0 0 20px rgba(5, 150, 105, 0.2)',
                                                },
                                                '&.Mui-focused': {
                                                    border: '2px solid rgba(5, 150, 105, 0.7)',
                                                    boxShadow: '0 0 30px rgba(5, 150, 105, 0.4)',
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
                                </Box>

                                <Box sx={{ mb: 2.5, animation: 'fadeInUp 0.8s ease 0.2s both' }}>
                                    <TextField
                                        fullWidth
                                        type={showConfirm ? 'text' : 'password'}
                                        placeholder="Confirm Password"
                                        value={data.password_confirmation}
                                        onChange={(e) => setData('password_confirmation', e.target.value)}
                                        error={!!errors.password_confirmation}
                                        disabled={processing}
                                        InputProps={{
                                            endAdornment: (
                                                <Box onClick={() => setShowConfirm(!showConfirm)} sx={{ cursor: 'pointer', mr: 1 }}>
                                                    {showConfirm ? <EyeOff size={20} /> : <Eye size={20} />}
                                                </Box>
                                            ),
                                        }}
                                        sx={{
                                            '& .MuiOutlinedInput-root': {
                                                color: '#F1F5F9',
                                                background: 'rgba(30, 41, 59, 0.6)',
                                                border: '2px solid rgba(5, 150, 105, 0.2)',
                                                borderRadius: '15px',
                                                transition: 'all 0.3s ease',
                                                '&:hover': {
                                                    border: '2px solid rgba(5, 150, 105, 0.4)',
                                                    boxShadow: '0 0 20px rgba(5, 150, 105, 0.2)',
                                                },
                                                '&.Mui-focused': {
                                                    border: '2px solid rgba(5, 150, 105, 0.7)',
                                                    boxShadow: '0 0 30px rgba(5, 150, 105, 0.4)',
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
                                </Box>
                            </Box>
                        )}

                        {/* Step 2: Role Selection */}
                        {activeStep === 2 && (
                            <Grid container spacing={2} sx={{ animation: 'slideInBounce 0.6s ease-out' }}>
                                {roles.map((role)=> (
                                    <Grid item xs={12} key={role.id}>
                                        <Card
                                            onClick={() => setData('role', role.id)}
                                            sx={{
                                                background: data.role === role.id
                                                    ? `linear-gradient(135deg, ${role.color}20, ${role.color}10)`
                                                    : 'rgba(30, 41, 59, 0.6)',
                                                border: `2px solid ${data.role === role.id ? role.color : 'rgba(148, 163, 184, 0.2)'}`,
                                                cursor: 'pointer',
                                                transition: 'all 0.3s ease',
                                                animation: data.role === role.id ? 'neonGlow 2s ease infinite' : 'none',
                                                '&:hover': {
                                                    border: `2px solid ${role.color}`,
                                                    transform: 'translateY(-5px)',
                                                    boxShadow: `0 0 20px ${role.color}40`,
                                                }
                                            }}
                                        >
                                            <CardContent sx={{ textAlign: 'center', p: 2 }}>
                                                <Box sx={{ fontSize: '2rem', mb: 1 }}>{role.icon}</Box>
                                                <Typography variant="h6" sx={{ color: '#F1F5F9', fontWeight: 700 }}>
                                                    {role.name}
                                                </Typography>
                                                <Typography variant="body2" sx={{ color: '#CBD5E1', mt: 1 }}>
                                                    {role.desc}
                                                </Typography>
                                            </CardContent>
                                        </Card>
                                    </Grid>
                                ))}
                            </Grid>
                        )}

                        {/* Action Buttons */}
                        <Box sx={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            gap: 2,
                            mt: 4,
                            animation: 'fadeInUp 0.8s ease 0.5s both',
                        }}>
                            <Button
                                onClick={handleBack}
                                disabled={activeStep === 0 || processing}
                                variant="outlined"
                                sx={{
                                    flex: 1,
                                    color: '#059669',
                                    borderColor: 'rgba(5, 150, 105, 0.3)',
                                    '&:hover': {
                                        borderColor: '#059669',
                                        background: 'rgba(5, 150, 105, 0.1)',
                                    },
                                    '&:disabled': { opacity: 0.5 },
                                }}
                            >
                                Back
                            </Button>

                            {activeStep === steps.length - 1 ? (
                                <Button
                                    type="submit"
                                    disabled={processing || !data.role}
                                    variant="contained"
                                    sx={{
                                        flex: 1,
                                        background: 'linear-gradient(135deg, #059669, #10B981)',
                                        fontWeight: 900,
                                        textTransform: 'uppercase',
                                        letterSpacing: '2px',
                                        '&:hover': {
                                            boxShadow: '0 0 30px rgba(5, 150, 105, 0.5)',
                                            transform: 'translateY(-2px)',
                                        }
                                    }}
                                >
                                    {processing ? 'Creating...' : 'Create Account'}
                                </Button>
                            ) : (
                                <Button
                                    onClick={handleNext}
                                    disabled={!canProceed() || processing}
                                    variant="contained"
                                    sx={{
                                        flex: 1,
                                        background: 'linear-gradient(135deg, #059669, #10B981)',
                                        fontWeight: 900,
                                        textTransform: 'uppercase',
                                        letterSpacing: '2px',
                                        '&:hover': {
                                            boxShadow: '0 0 30px rgba(5, 150, 105, 0.5)',
                                            transform: 'translateY(-2px)',
                                        }
                                    }}
                                >
                                    Next
                                </Button>
                            )}
                        </Box>

                        {/* Sign In Link */}
                        <Typography sx={{
                            textAlign: 'center',
                            mt: 3,
                            color: '#CBD5E1',
                            animation: 'fadeInUp 0.8s ease 0.6s both',
                        }}>
                            Already have an account?{' '}
                            <Link href={route('login')} style={{color: '#059669', fontWeight: 900}}>
                                Sign in
                            </Link>
                        </Typography>
                    </Box>
                </Box>
            </Container>
        </GuestLayout>
    );
}
