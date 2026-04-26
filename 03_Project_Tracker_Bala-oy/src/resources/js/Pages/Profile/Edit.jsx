import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm';
import UpdatePasswordForm from './Partials/UpdatePasswordForm';
import DeleteUserForm from './Partials/DeleteUserForm';
import { Head } from '@inertiajs/react';
import { Container, Grid, Typography, Box } from '@mui/material';

export default function Edit({ auth, mustVerifyEmail, status }) {
    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<Typography variant="h6" fontWeight="700">Profile Settings</Typography>}
        >
            <Head title="Profile" />

            <Container maxWidth="lg" sx={{ py: 4 }}>
                <Grid container spacing={3}>
                    
                    {/* Left Column: Profile Info & Password */}
                    <Grid item xs={12} md={8}>
                        <Box display="flex" flexDirection="column" gap={3}>
                            <UpdateProfileInformationForm
                                mustVerifyEmail={mustVerifyEmail}
                                status={status}
                                className="max-w-xl"
                            />
                            <UpdatePasswordForm className="max-w-xl" />
                        </Box>
                    </Grid>

                    {/* Right Column: Danger Zone */}
                    <Grid item xs={12} md={4}>
                        <DeleteUserForm className="max-w-xl" />
                    </Grid>

                </Grid>
            </Container>
        </AuthenticatedLayout>
    );
}