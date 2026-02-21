import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

import {
  Alert,
  Box,
  Button,
  Checkbox,
  Divider,
  FormControlLabel,
  Paper,
  Stack,
  TextField,
  Typography,
} from '@mui/material';

import BoltIcon from '@mui/icons-material/Bolt';

export default function Login({ status, canResetPassword }) {
  const { data, setData, post, processing, errors, reset } = useForm({
    email: '',
    password: '',
    remember: false,
  });

  const submit = (e) => {
    e.preventDefault();

    post(route('login'), {
      onFinish: () => reset('password'),
    });
  };

  // UI-only: shared styles for inputs (minimal, no blue outline)
  const fieldSx = (hasError) => ({
    '& .MuiInputLabel-root': {
      color: 'rgba(255,255,255,0.60)',
    },
    '& .MuiInputLabel-root.Mui-focused': {
      color: 'rgba(255,255,255,0.75)',
    },

    '& .MuiFilledInput-root': {
      borderRadius: 2,
      backgroundColor: 'rgba(255,255,255,0.07)',
      color: 'rgba(255,255,255,0.92)',
      border: hasError
        ? '1px solid rgba(255, 107, 107, 0.70)'
        : '1px solid rgba(255,255,255,0.10)',
      transition: '0.15s ease',
      overflow: 'hidden', // keeps autofill overlay from looking “boxed”
    },
    '& .MuiFilledInput-root:hover': {
      backgroundColor: 'rgba(255,255,255,0.09)',
      borderColor: hasError
        ? 'rgba(255, 107, 107, 0.85)'
        : 'rgba(255,255,255,0.16)',
    },
    '& .MuiFilledInput-root.Mui-focused': {
      backgroundColor: 'rgba(255,255,255,0.09)',
      borderColor: hasError
        ? 'rgba(255, 107, 107, 0.95)'
        : 'rgba(255,255,255,0.22)',
      boxShadow: 'none',
      outline: 'none',
    },

    // ✅ FIX: Chrome autofill (suggested email) forces bright background — override it
    '& input:-webkit-autofill': {
      WebkitBoxShadow: '0 0 0 1000px rgba(255,255,255,0.07) inset',
      WebkitTextFillColor: 'rgba(255,255,255,0.92)',
      caretColor: 'rgba(255,255,255,0.92)',
      borderRadius: 8,
      transition: 'background-color 9999s ease-out 0s',
    },
    '& input:-webkit-autofill:hover': {
      WebkitBoxShadow: '0 0 0 1000px rgba(255,255,255,0.09) inset',
      WebkitTextFillColor: 'rgba(255,255,255,0.92)',
    },
    '& input:-webkit-autofill:focus': {
      WebkitBoxShadow: '0 0 0 1000px rgba(255,255,255,0.09) inset',
      WebkitTextFillColor: 'rgba(255,255,255,0.92)',
    },

    '& .MuiFormHelperText-root': {
      color: hasError ? '#ff6b6b' : 'rgba(255,255,255,0.40)',
      marginLeft: 0,
    },
  });

  return (
    <GuestLayout>
      <Head title="Log in" />

      {/* Page wrapper (footer stays bottom) */}
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          background:
            'radial-gradient(900px 520px at 20% 10%, rgba(255,255,255,0.08), transparent 60%), #141821',
        }}
      >
        {/* Center content */}
        <Box
          sx={{
            flex: 1,
            display: 'grid',
            placeItems: 'center',
            px: 2,
            py: { xs: 3, sm: 5 },
          }}
        >
          {/* Two-column container */}
          <Box
            sx={{
              width: '100%',
              maxWidth: 980,
              display: 'grid',
              gridTemplateColumns: { xs: '1fr', md: '1.05fr 0.95fr' },
              gap: 2,
            }}
          >
            {/* LEFT: Brand panel */}
            <Paper
              elevation={0}
              sx={{
                borderRadius: 4,
                p: { xs: 3, sm: 4 },
                border: '1px solid rgba(255,255,255,0.10)',
                background:
                  'linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.03))',
                backdropFilter: 'blur(12px)',
                overflow: 'hidden',
                position: 'relative',
                minHeight: { xs: 220, md: 420 },
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'space-between',
              }}
            >
              {/* subtle glow */}
              <Box
                sx={{
                  position: 'absolute',
                  inset: -100,
                  background:
                    'radial-gradient(circle at 30% 20%, rgba(255,255,255,0.10), transparent 55%)',
                  pointerEvents: 'none',
                }}
              />

              <Box sx={{ position: 'relative' }}>
                <Stack direction="row" spacing={1.5} alignItems="center">
                  <Box
                    sx={{
                      width: 46,
                      height: 46,
                      borderRadius: 3,
                      display: 'grid',
                      placeItems: 'center',
                      backgroundColor: 'rgba(255,255,255,0.07)',
                      border: '1px solid rgba(255,255,255,0.10)',
                    }}
                  >
                    <BoltIcon sx={{ fontSize: 24, color: 'rgba(255,255,255,0.92)' }} />
                  </Box>

                  <Box>
                    <Typography
                      fontWeight={900}
                      sx={{ color: 'rgba(255,255,255,0.92)', lineHeight: 1.1 }}
                    >
                      Project Tracker
                    </Typography>
                    <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.55)' }}>
                      Laravel • Inertia • React • MUI
                    </Typography>
                  </Box>
                </Stack>

                <Typography
                  variant="h4"
                  fontWeight={900}
                  sx={{
                    mt: 3,
                    color: 'rgba(255,255,255,0.94)',
                    lineHeight: 1.15,
                    letterSpacing: -0.4,
                  }}
                >
                  Keep your projects organized.
                </Typography>

                <Typography
                  variant="body2"
                  sx={{ mt: 1.25, color: 'rgba(255,255,255,0.62)', maxWidth: 420 }}
                >
                Call me the tracker ’cause I’m stackin’ the tasks, priorities set so I’m movin’ up fast, update the status while I stick to the path, productive all day — no time to relax. 🔥
                </Typography>
              </Box>

              <Box sx={{ position: 'relative' }}>
                <Stack spacing={1}>
                  <Stack direction="row" spacing={1} alignItems="center">
                    <Box
                      sx={{
                        width: 6,
                        height: 6,
                        borderRadius: 99,
                        backgroundColor: 'rgba(255,255,255,0.75)',
                      }}
                    />
                    <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.70)' }}>
                      Fast, minimal UI
                    </Typography>
                  </Stack>
                  <Stack direction="row" spacing={1} alignItems="center">
                    <Box
                      sx={{
                        width: 6,
                        height: 6,
                        borderRadius: 99,
                        backgroundColor: 'rgba(255,255,255,0.75)',
                      }}
                    />
                    <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.70)' }}>
                      Projects → Tasks hierarchy
                    </Typography>
                  </Stack>
                  <Stack direction="row" spacing={1} alignItems="center">
                    <Box
                      sx={{
                        width: 6,
                        height: 6,
                        borderRadius: 99,
                        backgroundColor: 'rgba(255,255,255,0.75)',
                      }}
                    />
                    <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.70)' }}>
                      Priority + status toggling
                    </Typography>
                  </Stack>
                </Stack>
              </Box>
            </Paper>

            {/* RIGHT: Login form */}
            <Paper
              elevation={0}
              sx={{
                borderRadius: 4,
                p: { xs: 3, sm: 4 },
                border: '1px solid rgba(255,255,255,0.10)',
                backgroundColor: 'rgba(255,255,255,0.06)',
                backdropFilter: 'blur(12px)',
              }}
            >
              <Stack spacing={2.25}>
                <Box>
                  <Typography
                    variant="h5"
                    fontWeight={900}
                    sx={{ color: 'rgba(255,255,255,0.92)', lineHeight: 1.2 }}
                  >
                    Welcome back
                  </Typography>
                  <Typography
                    variant="body2"
                    sx={{ mt: 0.5, color: 'rgba(255,255,255,0.62)' }}
                  >
                    Sign in to continue.
                  </Typography>
                </Box>

                {status && (
                  <Alert
                    severity="success"
                    sx={{
                      borderRadius: 2,
                      backgroundColor: 'rgba(46,125,50,0.18)',
                      color: 'rgba(255,255,255,0.90)',
                      '& .MuiAlert-icon': { color: 'rgba(255,255,255,0.90)' },
                    }}
                  >
                    {status}
                  </Alert>
                )}

                <Divider sx={{ borderColor: 'rgba(255,255,255,0.10)' }} />

                {/* Form (logic unchanged) */}
                <Box component="form" onSubmit={submit} noValidate>
                  <Stack spacing={1.5}>
                    <TextField
                      id="email"
                      type="email"
                      name="email"
                      label="Email"
                      variant="filled"
                      value={data.email}
                      onChange={(e) => setData('email', e.target.value)}
                      autoComplete="username"
                      autoFocus
                      fullWidth
                      disabled={processing}
                      error={Boolean(errors.email)}
                      helperText={errors.email || ' '}
                      InputProps={{ disableUnderline: true }}
                      sx={fieldSx(Boolean(errors.email))}
                    />

                    <TextField
                      id="password"
                      type="password"
                      name="password"
                      label="Password"
                      variant="filled"
                      value={data.password}
                      onChange={(e) => setData('password', e.target.value)}
                      autoComplete="current-password"
                      fullWidth
                      disabled={processing}
                      error={Boolean(errors.password)}
                      helperText={errors.password || ' '}
                      InputProps={{ disableUnderline: true }}
                      sx={fieldSx(Boolean(errors.password))}
                    />

                    <Stack
                      direction={{ xs: 'column', sm: 'row' }}
                      alignItems={{ xs: 'flex-start', sm: 'center' }}
                      justifyContent="space-between"
                      spacing={0.5}
                      sx={{ mt: 0.25 }}
                    >
                      <FormControlLabel
                        control={
                          <Checkbox
                            checked={data.remember}
                            onChange={(e) => setData('remember', e.target.checked)}
                            sx={{
                              color: 'rgba(255,255,255,0.55)',
                              '&.Mui-checked': { color: 'rgba(255,255,255,0.88)' },
                            }}
                          />
                        }
                        label={
                          <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.62)' }}>
                            Remember me
                          </Typography>
                        }
                        sx={{ m: 0 }}
                      />

                      {canResetPassword && (
                        <Button
                          component={Link}
                          href={route('password.request')}
                          variant="text"
                          size="small"
                          disabled={processing}
                          sx={{
                            textTransform: 'none',
                            borderRadius: 2,
                            color: 'rgba(255,255,255,0.70)',
                            '&:hover': { backgroundColor: 'rgba(255,255,255,0.08)' },
                            px: 1,
                          }}
                        >
                          Forgot password?
                        </Button>
                      )}
                    </Stack>

                    <Button
                      type="submit"
                      fullWidth
                      disabled={processing}
                      sx={{
                        mt: 0.5,
                        borderRadius: 2.5,
                        textTransform: 'none',
                        fontWeight: 900,
                        py: 1.15,
                        color: '#0b1220',
                        backgroundColor: 'rgba(255,255,255,0.92)',
                        '&:hover': { backgroundColor: 'rgba(255,255,255,0.98)' },
                      }}
                    >
                      Log in
                    </Button>

                    {/* ✅ NEW: Register link (UI-only, very basic) */}
                    <Typography
                      variant="body2"
                      sx={{
                        textAlign: 'center',
                        color: 'rgba(255,255,255,0.60)',
                        mt: 0.5,
                      }}
                    >
                      Don’t have an account?{' '}
                      <Box
                        component={Link}
                        href={route('register')}
                        sx={{
                          color: 'rgba(255,255,255,0.92)',
                          fontWeight: 800,
                          textDecoration: 'none',
                          '&:hover': { textDecoration: 'underline' },
                        }}
                      >
                        Register
                      </Box>
                    </Typography>
                  </Stack>
                </Box>
              </Stack>
            </Paper>
          </Box>
        </Box>

        <Box
          component="footer"
          sx={{
            px: 2,
            py: 1.25,
            textAlign: 'center',
            color: 'rgba(255,255,255,0.55)',
            fontSize: 12,
          }}
        >
          @ Sana all goods po eto sir haha.
        </Box>
      </Box>
    </GuestLayout>
  );
}