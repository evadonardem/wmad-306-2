import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';
import { Box } from '@mui/material';
import DeleteUserForm from './Partials/DeleteUserForm';
import UpdatePasswordForm from './Partials/UpdatePasswordForm';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm';

export default function Edit({ mustVerifyEmail, status }) {

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

  return (
    <AuthenticatedLayout
      header={
        <h2 className="text-xl font-semibold leading-tight text-gray-800">
          Profile
        </h2>
      }
    >
      <Head title="Profile" />

      <Box sx={pageBg}>
        <Box sx={{ flex: 1, py: { xs: 4, sm: 6 }, pb: `${footerHeight + 16}px` }}>
          <div className="mx-auto max-w-7xl space-y-6 px-4 sm:px-6 lg:px-8">
            <div style={glassCard} className="p-4 sm:p-8">
              <UpdateProfileInformationForm
                mustVerifyEmail={mustVerifyEmail}
                status={status}
                className="max-w-xl"
              />
            </div>

            <div style={glassCard} className="p-4 sm:p-8">
              <UpdatePasswordForm className="max-w-xl" />
            </div>

            <div style={glassCard} className="p-4 sm:p-8">
              <DeleteUserForm className="max-w-xl" />
            </div>
          </div>
        </Box>

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