import GuestLayout from '@/Layouts/GuestLayout';
import { Head, Link, useForm } from '@inertiajs/react';

import {
    Alert,
    Box,
    Button,
    Divider,
    Paper,
    Stack,
    TextField,
    Typography,
} from '@mui/material';

import BoltIcon from '@mui/icons-material/Bolt';

export default function Register() {
  const { data, setData, post, processing, errors, reset } = useForm({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
  });

  const submit = (e) => {
    e.preventDefault();

    post(route('register'), {
      onFinish: () => reset('password', 'password_confirmation'),
    });
  };

  // UI-only: shared styles for inputs (minimal, no blue outline)
  const fieldSx = (hasError) => ({
    '& .MuiInputLabel-root': {
      color: 'rgba(255,255,255,0.60)',
      fontSize: 13,
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
      overflow: 'hidden',
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

    // UI-only: Chrome autofill fix
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
      fontSize: 12,
    },
  });

  return (
    <GuestLayout>
      <Head title="Register" />

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
          <Paper
            elevation={0}
            sx={{
              width: '100%',
              maxWidth: 460, // ✅ smaller, 1-column
              borderRadius: 4,
              p: { xs: 3, sm: 3.5 },
              border: '1px solid rgba(255,255,255,0.10)',
              backgroundColor: 'rgba(255,255,255,0.06)',
              backdropFilter: 'blur(12px)',
            }}
          >
            <Stack spacing={2}>
              {/* Small header */}
              <Stack spacing={1} alignItems="center">
                <Box
                  sx={{
                    width: 44,
                    height: 44,
                    borderRadius: 3,
                    display: 'grid',
                    placeItems: 'center',
                    backgroundColor: 'rgba(255,255,255,0.07)',
                    border: '1px solid rgba(255,255,255,0.10)',
                  }}
                >
                  <BoltIcon sx={{ fontSize: 22, color: 'rgba(255,255,255,0.92)' }} />
                </Box>

                <Box sx={{ textAlign: 'center' }}>
                  <Typography
                    variant="h6"
                    fontWeight={900}
                    sx={{ color: 'rgba(255,255,255,0.92)', lineHeight: 1.15 }}
                  >
                    Create account
                  </Typography>
                  <Typography
                    variant="body2"
                    sx={{ mt: 0.25, color: 'rgba(255,255,255,0.60)', fontSize: 13 }}
                  >
                    Create account to make your day the smarter, simpler way.
                  </Typography>
                </Box>
              </Stack>

              {/* (Optional) small error alert */}
              {errors?.email && (
                <Alert
                  severity="error"
                  sx={{
                    borderRadius: 2,
                    backgroundColor: 'rgba(211,47,47,0.16)',
                    color: 'rgba(255,255,255,0.90)',
                    '& .MuiAlert-icon': { color: 'rgba(255,255,255,0.90)' },
                    fontSize: 13,
                  }}
                >
                  {errors.email}
                </Alert>
              )}

              <Divider sx={{ borderColor: 'rgba(255,255,255,0.10)' }} />

              {/* Form (logic unchanged) */}
              <Box component="form" onSubmit={submit} noValidate>
                <Stack spacing={1.4}>
                  <TextField
                    id="name"
                    name="name"
                    label="Name"
                    variant="filled"
                    value={data.name}
                    onChange={(e) => setData('name', e.target.value)}
                    autoComplete="name"
                    fullWidth
                    disabled={processing}
                    error={Boolean(errors.name)}
                    helperText={errors.name || ' '}
                    InputProps={{ disableUnderline: true }}
                    sx={fieldSx(Boolean(errors.name))}
                    required
                    size="small"
                  />

                  <TextField
                    id="email"
                    type="email"
                    name="email"
                    label="Email"
                    variant="filled"
                    value={data.email}
                    onChange={(e) => setData('email', e.target.value)}
                    autoComplete="username"
                    fullWidth
                    disabled={processing}
                    error={Boolean(errors.email)}
                    helperText={errors.email || ' '}
                    InputProps={{ disableUnderline: true }}
                    sx={fieldSx(Boolean(errors.email))}
                    required
                    size="small"
                  />

                  <TextField
                    id="password"
                    type="password"
                    name="password"
                    label="Password"
                    variant="filled"
                    value={data.password}
                    onChange={(e) => setData('password', e.target.value)}
                    autoComplete="new-password"
                    fullWidth
                    disabled={processing}
                    error={Boolean(errors.password)}
                    helperText={errors.password || ' '}
                    InputProps={{ disableUnderline: true }}
                    sx={fieldSx(Boolean(errors.password))}
                    required
                    size="small"
                  />

                  <TextField
                    id="password_confirmation"
                    type="password"
                    name="password_confirmation"
                    label="Confirm Password"
                    variant="filled"
                    value={data.password_confirmation}
                    onChange={(e) => setData('password_confirmation', e.target.value)}
                    autoComplete="new-password"
                    fullWidth
                    disabled={processing}
                    error={Boolean(errors.password_confirmation)}
                    helperText={errors.password_confirmation || ' '}
                    InputProps={{ disableUnderline: true }}
                    sx={fieldSx(Boolean(errors.password_confirmation))}
                    required
                    size="small"
                  />

                  <Button
                    type="submit"
                    fullWidth
                    disabled={processing}
                    sx={{
                      mt: 0.25,
                      borderRadius: 2.5,
                      textTransform: 'none',
                      fontWeight: 900,
                      py: 1.05,
                      color: '#0b1220',
                      backgroundColor: 'rgba(255,255,255,0.92)',
                      '&:hover': { backgroundColor: 'rgba(255,255,255,0.98)' },
                    }}
                  >
                    Register
                  </Button>

                  <Button
                    component={Link}
                    href={route('login')}
                    variant="text"
                    size="small"
                    disabled={processing}
                    sx={{
                      textTransform: 'none',
                      borderRadius: 2,
                      color: 'rgba(255,255,255,0.70)',
                      '&:hover': { backgroundColor: 'rgba(255,255,255,0.08)' },
                      alignSelf: 'center',
                    }}
                  >
                    Already registered? Log in
                  </Button>
                </Stack>
              </Box>
            </Stack>
          </Paper>
        </Box>

        {/* Footer (bottom) */}
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