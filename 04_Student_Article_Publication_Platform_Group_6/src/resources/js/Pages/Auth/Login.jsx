import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';
import {
    Alert,
    Box,
    Button,
    Checkbox,
    FormControlLabel,
    Stack,
    TextField,
    Typography,
} from '@mui/material';

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
    .auth-animate-reveal-5 { animation: auth-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.6s both; }
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

export default function Login({ status, canResetPassword }) {
    const { data, setData, post, processing, errors, reset } = useForm({
        email: '',
        password: '',
        remember: false,
    });

    const submit = (event) => {
        event.preventDefault();
        post(route('login'), { onFinish: () => reset('password') });
    };

    return (
        <GuestLayout>
            <Head title="Log in" />
            <style>{authAnimations}</style>
            
            <Box 
                className="auth-container-enter" 
                sx={{ 
                    display: 'flex',
                    width: '100%',
                    maxWidth: 1000, // Wide layout for Jeton's split-screen look
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
                            Sign in
                        </Typography>
                        <Typography color="text.secondary" sx={{ mt: 1, fontWeight: 500 }}>
                            Don't have an account?{' '}
                            <Link href={route('register')} style={{ color: '#2f6fdb', textDecoration: 'none', fontWeight: 700 }}>
                                Sign up now
                            </Link>
                        </Typography>
                    </Box>

                    {status && <Alert severity="success" className="auth-animate-reveal-1" sx={{ mb: 3, borderRadius: '0.75rem' }}>{status}</Alert>}

                    <Stack spacing={2.5} component="form" onSubmit={submit}>
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

                        <TextField
                            className="auth-animate-reveal-2"
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

                        <Box className="auth-animate-reveal-3" sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                            <FormControlLabel
                                control={
                                    <Checkbox
                                        checked={data.remember}
                                        onChange={(event) => setData('remember', event.target.checked)}
                                        sx={{ '&.Mui-checked': { color: '#2f6fdb' } }}
                                    />
                                }
                                label={<Typography sx={{ fontWeight: 600, fontSize: '0.875rem' }}>Remember me</Typography>}
                            />
                            {canResetPassword && (
                                <Link href={route('password.request')} style={{ color: '#2f6fdb', textDecoration: 'none', fontWeight: 600, fontSize: '0.875rem' }}>
                                    Forgot password?
                                </Link>
                            )}
                        </Box>

                        <Button
                            className="auth-animate-reveal-4"
                            type="submit"
                            variant="contained"
                            disabled={processing}
                            fullWidth
                            sx={{ 
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
                            Log in
                        </Button>

                        <Box
                            className="auth-animate-reveal-5"
                            sx={{
                                mt: 2,
                                borderRadius: '0.75rem',
                                p: 2,
                                bgcolor: 'rgba(47,111,219,0.04)',
                                border: '1px solid rgba(47,111,219,0.1)',
                            }}
                        >
                            <Typography variant="body2" sx={{ fontWeight: 700, color: '#2f6fdb', mb: 0.5 }}>
                                Seeded role accounts
                            </Typography>
                            <Typography variant="caption" color="text.secondary" sx={{ display: 'block', lineHeight: 1.5 }}>
                                Use the seeded writer/editor/student emails from your seeder. Password is your seeded default (often <code style={{ backgroundColor: '#fff', color: '#0f172a', padding: '2px 4px', borderRadius: '4px' }}>password</code>).
                            </Typography>
                        </Box>
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
                    {/* Floating blobs contained as artwork */}
                    <Box sx={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
                        <Box
                            className="auth-animate-blob"
                            sx={{
                                position: 'absolute', top: '10%', left: '10%',
                                width: 250, height: 250, borderRadius: '50%',
                                bgcolor: '#2f6fdb', opacity: 0.15, mixBlendMode: 'multiply',
                            }}
                        />
                        <Box
                            className="auth-animate-blob auth-animation-delay-2000"
                            sx={{
                                position: 'absolute', top: '40%', right: '5%',
                                width: 220, height: 220, borderRadius: '50%',
                                bgcolor: '#7ea5ea', opacity: 0.15, mixBlendMode: 'multiply',
                            }}
                        />
                        <Box
                            className="auth-animate-blob auth-animation-delay-4000"
                            sx={{
                                position: 'absolute', bottom: '15%', left: '20%',
                                width: 200, height: 200, borderRadius: '50%',
                                bgcolor: '#1e4b9b', opacity: 0.12, mixBlendMode: 'multiply',
                            }}
                        />
                    </Box>

                    {/* Branding Text overlaying blobs */}
                    <Box sx={{ position: 'relative', zIndex: 1, textAlign: 'center', maxWidth: 320 }} className="auth-animate-reveal-3">
                        <Typography variant="h4" sx={{ fontWeight: 800, color: '#1e4b9b', mb: 2, lineHeight: 1.2 }}>
                            Welcome to Campus Press.
                        </Typography>
                        <Typography variant="body1" sx={{ color: '#2f6fdb', opacity: 0.85, fontWeight: 500 }}>
                            Your central hub for campus journalism, real-time collaboration, and editorial workflows.
                        </Typography>
                    </Box>
                </Box>
            </Box>
        </GuestLayout>
    );
}
