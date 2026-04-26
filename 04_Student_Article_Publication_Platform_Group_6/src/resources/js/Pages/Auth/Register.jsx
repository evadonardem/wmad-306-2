import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';
import { Box, Button, Stack, TextField, Typography } from '@mui/material';

const authAnimations = `
    @keyframes auth-container-enter {
        0% { opacity: 0; transform: scale(0.94) translateY(24px); }
        100% { opacity: 1; transform: scale(1) translateY(0); }
    }
    @keyframes auth-reveal-up {
        0% { transform: translateY(80px); opacity: 0; filter: blur(8px); }
        100% { transform: translateY(0); opacity: 1; filter: blur(0); }
    }
    @keyframes auth-float-blob {
        0% { transform: translate(0px, 0px) scale(1); }
        33% { transform: translate(30px, -50px) scale(1.1); }
        66% { transform: translate(-20px, 20px) scale(0.9); }
        100% { transform: translate(0px, 0px) scale(1); }
    }
    .auth-animate-reveal-0 { animation: auth-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
    .auth-animate-reveal-1 { animation: auth-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
    .auth-animate-reveal-2 { animation: auth-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
    .auth-animate-reveal-3 { animation: auth-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both; }
    .auth-animate-reveal-4 { animation: auth-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.5s both; }
    .auth-animate-blob { animation: auth-float-blob 8s infinite ease-in-out; }
    .auth-animation-delay-2000 { animation-delay: 2s; }
    .auth-animation-delay-4000 { animation-delay: 4s; }
    .auth-container-enter { animation: auth-container-enter 0.7s cubic-bezier(0.16, 1, 0.3, 1) both; }
`;

const textFieldSx = {
    '& .MuiOutlinedInput-root': { 
        borderRadius: '0.75rem', 
        fontWeight: 500,
        backgroundColor: '#fff',
        color: '#0f172a',
        transition: 'all 0.2s ease',
        '&:hover fieldset': { borderColor: 'rgba(47, 111, 219, 0.4)' },
        '&.Mui-focused fieldset': { borderColor: '#2f6fdb', borderWidth: '2px' }
    },
    '& .MuiInputBase-input': { color: '#0f172a' },
    '& .MuiInputLabel-root': { fontWeight: 600, color: 'rgba(15, 23, 42, 0.7)' },
    '& .MuiInputLabel-root.Mui-focused': { color: '#2f6fdb' },
};

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        password: '',
        password_confirmation: '',
        role: 'student', // Silently defaults to student
    });

    const submit = (event) => {
        event.preventDefault();
        post(route('register'), { onFinish: () => reset('password', 'password_confirmation') });
    };

    return (
        <GuestLayout>
            <Head title="Register" />
            <style>{authAnimations}</style>
            
            <Box 
                className="auth-container-enter" 
                sx={{ 
                    display: 'flex',
                    width: '100%',
                    maxWidth: 1000,
                    margin: '0 auto',
                    minHeight: { xs: 'auto', md: 650 },
                    bgcolor: 'background.paper',
                    borderRadius: '1.5rem',
                    boxShadow: '0 24px 50px rgba(0, 0, 0, 0.06), 0 4px 10px rgba(0, 0, 0, 0.03)',
                    overflow: 'hidden'
                }}
            >
                {/* Left Side: Clean Form Panel */}
                <Box 
                    sx={{ 
                        flex: { xs: '1 1 100%', md: '1 1 50%' }, 
                        p: { xs: 4, sm: 6, md: 8 }, 
                        display: 'flex', 
                        flexDirection: 'column', 
                        justifyContent: 'center' 
                    }}
                >
                    <Box className="auth-animate-reveal-0" sx={{ mb: 4 }}>
                        <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.02em', color: 'text.primary' }}>
                            Create account
                        </Typography>
                        <Typography color="text.secondary" sx={{ mt: 1, fontWeight: 500 }}>
                            Already have an account?{' '}
                            <Link href={route('login')} style={{ color: '#2f6fdb', textDecoration: 'none', fontWeight: 700 }}>
                                Sign in
                            </Link>
                        </Typography>
                    </Box>

                    <Stack spacing={2.25} component="form" onSubmit={submit}>
                        <TextField
                            className="auth-animate-reveal-1"
                            label="Full Name"
                            value={data.name}
                            onChange={(event) => setData('name', event.target.value)}
                            error={Boolean(errors.name)}
                            helperText={errors.name}
                            fullWidth
                            required
                            sx={textFieldSx}
                        />

                        <TextField
                            className="auth-animate-reveal-1"
                            label="Email"
                            type="email"
                            value={data.email}
                            onChange={(event) => setData('email', event.target.value)}
                            error={Boolean(errors.email)}
                            helperText={errors.email}
                            fullWidth
                            required
                            sx={textFieldSx}
                        />

                        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2.25} className="auth-animate-reveal-2">
                            <TextField
                                label="Password"
                                type="password"
                                value={data.password}
                                onChange={(event) => setData('password', event.target.value)}
                                error={Boolean(errors.password)}
                                helperText={errors.password}
                                fullWidth
                                required
                                sx={textFieldSx}
                            />

                            <TextField
                                label="Confirm"
                                type="password"
                                value={data.password_confirmation}
                                onChange={(event) => setData('password_confirmation', event.target.value)}
                                error={Boolean(errors.password_confirmation)}
                                helperText={errors.password_confirmation}
                                fullWidth
                                required
                                sx={textFieldSx}
                            />
                        </Stack>

                        {/* Hidden role input - ensures the backend receives the 'student' default if required */}
                        <input type="hidden" name="role" value="student" />

                        <Button
                            className="auth-animate-reveal-3"
                            type="submit"
                            variant="contained"
                            disabled={processing}
                            fullWidth
                            sx={{ 
                                mt: 2,
                                borderRadius: '0.75rem', 
                                py: 1.5, 
                                fontSize: '1rem',
                                fontWeight: 700, 
                                textTransform: 'none', 
                                bgcolor: '#2f6fdb', 
                                boxShadow: 'none',
                                '&:hover': { bgcolor: '#2157b4', boxShadow: '0 4px 12px rgba(47, 111, 219, 0.25)' } 
                            }}
                        >
                            Complete Registration
                        </Button>
                    </Stack>
                </Box>

                {/* Right Side: Animated Branding Panel */}
                <Box 
                    sx={{ 
                        flex: '1 1 50%', 
                        display: { xs: 'none', md: 'flex' }, 
                        position: 'relative', 
                        background: 'linear-gradient(135deg, #f0f4fd 0%, #e2ebfa 100%)',
                        alignItems: 'center', 
                        justifyContent: 'center',
                        flexDirection: 'column',
                        p: 6,
                        overflow: 'hidden'
                    }}
                >
                    {/* Floating blobs */}
                    <Box sx={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
                        <Box
                            className="auth-animate-blob"
                            sx={{
                                position: 'absolute', top: '15%', right: '10%',
                                width: 240, height: 240, borderRadius: '50%',
                                bgcolor: '#2f6fdb', opacity: 0.15, mixBlendMode: 'multiply',
                            }}
                        />
                        <Box
                            className="auth-animate-blob auth-animation-delay-2000"
                            sx={{
                                position: 'absolute', bottom: '20%', left: '5%',
                                width: 200, height: 200, borderRadius: '50%',
                                bgcolor: '#7ea5ea', opacity: 0.15, mixBlendMode: 'multiply',
                            }}
                        />
                        <Box
                            className="auth-animate-blob auth-animation-delay-4000"
                            sx={{
                                position: 'absolute', top: '45%', left: '30%',
                                width: 180, height: 180, borderRadius: '50%',
                                bgcolor: '#1e4b9b', opacity: 0.12, mixBlendMode: 'multiply',
                            }}
                        />
                    </Box>

                    {/* Branding Text */}
                    <Box sx={{ position: 'relative', zIndex: 1, textAlign: 'center', maxWidth: 360 }} className="auth-animate-reveal-3">
                        <Typography variant="h4" sx={{ fontWeight: 800, color: '#1e4b9b', mb: 2, lineHeight: 1.2 }}>
                            Shape the Narrative.
                        </Typography>
                        <Typography variant="body1" sx={{ color: '#2f6fdb', opacity: 0.85, fontWeight: 500 }}>
                            Create your account today to read the latest publications and join the campus conversation.
                        </Typography>
                    </Box>
                </Box>
            </Box>
        </GuestLayout>
    );
}
