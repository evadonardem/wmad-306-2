import GuestLayout from '@/Layouts/GuestLayout';
import { Head, useForm } from '@inertiajs/react';

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

export default function ForgotPassword({ status }) {
  const { data, setData, post, processing, errors } = useForm({
    email: '',
  });

  const submit = (e) => {
    e.preventDefault();
    post(route('password.email'));
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

    // UI-only: Chrome autofill fix (suggested email)
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
      <Head title="Forgot Password" />

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
              maxWidth: 460,
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
                    Reset your password
                  </Typography>

                  <Typography
                    variant="body2"
                    sx={{ mt: 0.25, color: 'rgba(255,255,255,0.60)', fontSize: 13 }}
                  >
                    Enter your email and we’ll send a reset link.
                  </Typography>
                </Box>
              </Stack>

              {/* Status message (same functionality) */}
              {status && (
                <Alert
                  severity="success"
                  sx={{
                    borderRadius: 2,
                    backgroundColor: 'rgba(46,125,50,0.18)',
                    color: 'rgba(255,255,255,0.90)',
                    '& .MuiAlert-icon': { color: 'rgba(255,255,255,0.90)' },
                    fontSize: 13,
                  }}
                >
                  {status}
                </Alert>
              )}

              <Divider sx={{ borderColor: 'rgba(255,255,255,0.10)' }} />

              {/* Form (logic unchanged) */}
              <Box component="form" onSubmit={submit} noValidate>
                <Stack spacing={1.4}>
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
                    size="small"
                    required
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
                    Email Password Reset Link
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