import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';

import {
  Box,
  Chip,
  Container,
  Divider,
  Paper,
  Stack,
  Typography,
} from '@mui/material';

export default function Dashboard() {
  // ✅ Slimmer footer (not thick)
  const footerHeight = 36;

  const pageBg = {
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
    background:
      'radial-gradient(1000px 520px at 20% 10%, rgba(15, 23, 42, 0.10), transparent 60%), #EEF2F7',
  };

  const glassCard = {
    borderRadius: 4,
    backgroundColor: 'rgba(255,255,255,0.72)',
    border: '1px solid rgba(15, 23, 42, 0.10)',
    backdropFilter: 'blur(16px)',
    WebkitBackdropFilter: 'blur(16px)',
    boxShadow: '0 10px 28px rgba(15, 23, 42, 0.10)',
  };

  const hoverGlassCard = {
    ...glassCard,
    transition: 'background-color 160ms ease, box-shadow 160ms ease, transform 160ms ease',
    '&:hover': {
      backgroundColor: 'rgba(255,255,255,0.78)',
      boxShadow: '0 14px 36px rgba(15, 23, 42, 0.14)',
      transform: 'translateY(-2px)',
    },
  };

  return (
    <AuthenticatedLayout
      header={
        <Typography
          variant="h6"
          sx={{
            fontWeight: 900,
            color: 'rgba(15, 23, 42, 0.92)',
          }}
        >
          Dashboard
        </Typography>
      }
    >
      <Head title="Dashboard" />

      <Box sx={pageBg}>
        {/* Main content (padding bottom for fixed footer) */}
        <Box sx={{ flex: 1, py: { xs: 3, sm: 4 }, pb: `${footerHeight + 16}px` }}>
          <Container maxWidth="lg">
            <Stack spacing={2}>
              <Paper elevation={0} sx={{ ...glassCard, p: { xs: 2.5, sm: 3 } }}>
                <Stack spacing={1.5}>
                  <Stack
                    direction={{ xs: 'column', sm: 'row' }}
                    spacing={1.25}
                    alignItems={{ xs: 'flex-start', sm: 'center' }}
                    justifyContent="space-between"
                  >
                    <Box>
                      <Typography
                        sx={{
                          fontSize: 11,
                          fontWeight: 900,
                          letterSpacing: 0.9,
                          textTransform: 'uppercase',
                          color: 'rgba(15, 23, 42, 0.60)',
                        }}
                      >
                        Project Tracker
                      </Typography>

                      <Typography
                        sx={{
                          mt: 0.5,
                          fontSize: 16,
                          fontWeight: 900,
                          color: 'rgba(15, 23, 42, 0.92)',
                          lineHeight: 1.15,
                        }}
                      >
                        Welcome back!
                      </Typography>

                      <Typography
                        sx={{
                          mt: 0.5,
                          fontSize: 13,
                          color: 'rgba(15, 23, 42, 0.66)',
                        }}
                      >
                        My simple overview page, move smart not in a haze.
                      </Typography>
                    </Box>

                    <Chip
                      label="Active"
                      size="small"
                      sx={{
                        fontWeight: 900,
                        borderRadius: 99,
                        backgroundColor: 'rgba(16, 185, 129, 0.12)',
                        color: 'rgba(6, 95, 70, 0.95)',
                        border: '1px solid rgba(16, 185, 129, 0.22)',
                      }}
                    />
                  </Stack>

                  <Divider sx={{ borderColor: 'rgba(15, 23, 42, 0.12)' }} />

                  {/* Note */}
                  <Box
                    sx={{
                      borderRadius: 3,
                      p: 2,
                      backgroundColor: 'rgba(15, 23, 42, 0.05)',
                      border: '1px solid rgba(15, 23, 42, 0.10)',
                    }}
                  >
                    <Typography
                      sx={{
                        fontSize: 13,
                        fontWeight: 900,
                        color: 'rgba(15, 23, 42, 0.92)',
                      }}
                    >
                      You’re logged in.
                    </Typography>

                    <Typography
                      sx={{
                        mt: 0.5,
                        fontSize: 13,
                        color: 'rgba(15, 23, 42, 0.66)',
                      }}
                    >
                      Use the top navigation to open{' '}
                      <Box component="span" sx={{ fontWeight: 900, color: 'rgba(15, 23, 42, 0.88)' }}>
                        Projects
                      </Box>{' '}
                      and{' '}
                      <Box component="span" sx={{ fontWeight: 900, color: 'rgba(15, 23, 42, 0.88)' }}>
                        Tasks
                      </Box>
                      .
                    </Typography>
                  </Box>
                </Stack>
              </Paper>

              <Box
                sx={{
                  display: 'grid',
                  gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr', lg: '1fr 1fr 1fr' },
                  gap: 1.5,
                }}
              >
                <Paper elevation={0} sx={{ ...hoverGlassCard, p: 2.5 }}>
                  <Stack spacing={1.25}>
                    <Stack direction="row" alignItems="center" justifyContent="space-between">
                      <Typography sx={{ fontSize: 13, fontWeight: 900, color: 'rgba(15, 23, 42, 0.92)' }}>
                        Projects
                      </Typography>

                      <Chip
                        label="CRUD"
                        size="small"
                        sx={{
                          height: 22,
                          fontSize: 11,
                          fontWeight: 900,
                          borderRadius: 99,
                          backgroundColor: 'rgba(59,130,246,0.12)',
                          color: 'rgba(30, 64, 175, 0.92)',
                          border: '1px solid rgba(59,130,246,0.18)',
                        }}
                      />
                    </Stack>

                    <Typography sx={{ fontSize: 13, color: 'rgba(15, 23, 42, 0.66)' }}>
                      Create, edit, and delete projects.
                    </Typography>

                    <Box sx={{ mt: 0.5 }}>
                      <Box sx={{ height: 6, borderRadius: 999, backgroundColor: 'rgba(15, 23, 42, 0.12)' }}>
                        <Box sx={{ height: 6, width: '66%', borderRadius: 999, backgroundColor: 'rgba(15, 23, 42, 0.24)' }} />
                      </Box>

                      <Typography sx={{ mt: 1, fontSize: 12, color: 'rgba(15, 23, 42, 0.52)' }}>
                        Simple and clean.
                      </Typography>
                    </Box>
                  </Stack>
                </Paper>

                <Paper elevation={0} sx={{ ...hoverGlassCard, p: 2.5 }}>
                  <Stack spacing={1.25}>
                    <Stack direction="row" alignItems="center" justifyContent="space-between">
                      <Typography sx={{ fontSize: 13, fontWeight: 900, color: 'rgba(15, 23, 42, 0.92)' }}>
                        Tasks
                      </Typography>

                      <Chip
                        label="Status"
                        size="small"
                        sx={{
                          height: 22,
                          fontSize: 11,
                          fontWeight: 900,
                          borderRadius: 99,
                          backgroundColor: 'rgba(168,85,247,0.12)',
                          color: 'rgba(88, 28, 135, 0.92)',
                          border: '1px solid rgba(168,85,247,0.18)',
                        }}
                      />
                    </Stack>

                    <Typography sx={{ fontSize: 13, color: 'rgba(15, 23, 42, 0.66)' }}>
                      Add tasks with priority and toggle status.
                    </Typography>

                    <Box sx={{ mt: 0.5 }}>
                      <Box sx={{ height: 6, borderRadius: 999, backgroundColor: 'rgba(15, 23, 42, 0.12)' }}>
                        <Box sx={{ height: 6, width: '50%', borderRadius: 999, backgroundColor: 'rgba(15, 23, 42, 0.24)' }} />
                      </Box>

                      <Typography sx={{ mt: 1, fontSize: 12, color: 'rgba(15, 23, 42, 0.52)' }}>
                        Organized per project.
                      </Typography>
                    </Box>
                  </Stack>
                </Paper>

                <Paper elevation={0} sx={{ ...hoverGlassCard, p: 2.5 }}>
                  <Stack spacing={1.25}>
                    <Stack direction="row" alignItems="center" justifyContent="space-between">
                      <Typography sx={{ fontSize: 13, fontWeight: 900, color: 'rgba(15, 23, 42, 0.92)' }}>
                        System
                      </Typography>

                      <Chip
                        label="Ready"
                        size="small"
                        sx={{
                          height: 22,
                          fontSize: 11,
                          fontWeight: 900,
                          borderRadius: 99,
                          backgroundColor: 'rgba(15, 23, 42, 0.06)',
                          color: 'rgba(15, 23, 42, 0.72)',
                          border: '1px solid rgba(15, 23, 42, 0.10)',
                        }}
                      />
                    </Stack>

                    <Typography sx={{ fontSize: 13, color: 'rgba(15, 23, 42, 0.66)' }}>
                      Backend and frontend are running normally.
                    </Typography>

                    <Box sx={{ mt: 0.5 }}>
                      <Box sx={{ height: 6, borderRadius: 999, backgroundColor: 'rgba(15, 23, 42, 0.12)' }}>
                        <Box sx={{ height: 6, width: '84%', borderRadius: 999, backgroundColor: 'rgba(15, 23, 42, 0.24)' }} />
                      </Box>

                      <Typography sx={{ mt: 1, fontSize: 12, color: 'rgba(15, 23, 42, 0.52)' }}>
                        Dashboard is UI-only.
                      </Typography>
                    </Box>
                  </Stack>
                </Paper>
              </Box>
            </Stack>
          </Container>
        </Box>

        {/* ✅ Footer (slim) */}
        <Box
          component="footer"
          sx={{
            position: 'fixed',
            left: 0,
            right: 0,
            bottom: 0,
            height: `${footerHeight}px`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: 'rgba(10,12,18,0.82)',
            backdropFilter: 'blur(10px)',
            color: 'rgba(255,255,255,0.70)',
            fontSize: 11,
            lineHeight: 1,
            zIndex: 20,
            px: 2,
            textAlign: 'center',
          }}
        >
          @ freddievisayaactivity.
        </Box>
      </Box>
    </AuthenticatedLayout>
  );
}