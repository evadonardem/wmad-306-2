import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';
import { Box, Stack, Typography, Container } from '@mui/material';

// Import your partials
import DeleteUserForm from './Partials/DeleteUserForm';
import UpdateAppearancePreferencesForm from './Partials/UpdateAppearancePreferencesForm';
import UpdatePasswordForm from './Partials/UpdatePasswordForm';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm';

export default function Edit({ mustVerifyEmail, status }) {
    // Premium reveal animations
    const profileAnimations = `
        @keyframes reveal-up {
            0% { transform: translateY(30px); opacity: 0; filter: blur(4px); }
            100% { transform: translateY(0); opacity: 1; filter: blur(0); }
        }
        .animate-reveal-0 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
        .animate-reveal-1 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
        .animate-reveal-2 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
        .animate-reveal-3 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both; }

        /* These classes help show the "Larger Text" feature in real-time */
        body[data-larger-text="1"] .profile-settings-container {
            font-size: 1.25rem;
        }
        
        /* Ensures the custom gap override works */
        body[data-dashboard-density="compact"] .profile-stack {
            gap: 1.5rem !important;
        }
    `;

    return (
        <AuthenticatedLayout fullWidth={true}>
            <Head title="Profile Settings" />
            <style>{profileAnimations}</style>

            <Container maxWidth="lg" className="profile-settings-container">
                <Box sx={{ 
                    py: { xs: 6, md: 10 },
                    px: { xs: 2, md: 4 }
                }}>
                    
                    {/* Header Section */}
                    <Box className="animate-reveal-0" sx={{ mb: 8 }}>
                        <Typography 
                            variant="h2" 
                            sx={{ 
                                fontWeight: 900, 
                                letterSpacing: '-0.04em',
                                fontSize: { xs: '2.5rem', md: '3.5rem' },
                                mb: 2,
                                color: 'text.primary'
                            }}
                        >
                            Settings
                        </Typography>
                        <Typography 
                            variant="h6" 
                            color="text.secondary" 
                            sx={{ fontWeight: 400, opacity: 0.8, maxWidth: 600 }}
                        >
                            Customize your editorial workspace and manage your campus account security.
                        </Typography>
                    </Box>

                    {/* The Stack - Spacing is controlled by CSS override in profileAnimations */}
                    <Stack 
                        className="profile-stack"
                        spacing={6} // Default "Comfortable" spacing
                    >
                        {/* 1. Appearance - Removed shadow-2xl class */}
                        <Box className="animate-reveal-1">
                            <UpdateAppearancePreferencesForm />
                        </Box>

                        {/* 2. Personal Identity */}
                        <Box className="animate-reveal-2">
                            <UpdateProfileInformationForm 
                                mustVerifyEmail={mustVerifyEmail} 
                                status={status} 
                            />
                        </Box>

                        {/* 3. Security Credentials */}
                        <Box className="animate-reveal-3">
                            <UpdatePasswordForm />
                        </Box>

                        {/* 4. Danger Zone (Final check) */}
                        <Box className="animate-reveal-3" sx={{ animationDelay: '0.6s' }}>
                            <DeleteUserForm />
                        </Box>
                    </Stack>
                </Box>
            </Container>
        </AuthenticatedLayout>
    );
}