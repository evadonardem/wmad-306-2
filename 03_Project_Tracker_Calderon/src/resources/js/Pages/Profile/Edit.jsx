import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';
import DeleteUserForm from './Partials/DeleteUserForm';
import UpdatePasswordForm from './Partials/UpdatePasswordForm';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm';
import { Box, Card, CardContent, Typography, Grid, Container } from '@mui/material';

export default function Edit({ auth, mustVerifyEmail, status }) {
    return (
        <AuthenticatedLayout
            header={
                <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold', color: 'text.primary' }}>
                    Profile
                </Typography>
            }
        >
            <Head title="Profile" />

            <Container maxWidth="lg">
                <Box sx={{ py: 4 }}>
                    <Grid container spacing={3}>
                        <Grid item xs={12} lg={6}>
                            <Card>
                                <CardContent sx={{ p: 4 }}>
                                    <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>
                                        Profile Information
                                    </Typography>
                                    <UpdateProfileInformationForm
                                        auth={auth}
                                        mustVerifyEmail={mustVerifyEmail}
                                        status={status}
                                    />
                                </CardContent>
                            </Card>
                        </Grid>

                        <Grid item xs={12} lg={6}>
                            <Card>
                                <CardContent sx={{ p: 4 }}>
                                    <Typography variant="h6" sx={{ mb: 3, fontWeight: 600 }}>
                                        Update Password
                                    </Typography>
                                    <UpdatePasswordForm />
                                </CardContent>
                            </Card>

                            <Box sx={{ mt: 6 }}>
                                <Card>
                                    <CardContent sx={{ p: 4 }}>
                                        <Typography variant="h6" sx={{ mb: 3, fontWeight: 600, color: 'theme.palette.text.primary' }}>
                                            Delete Account
                                        </Typography>
                                        <DeleteUserForm />
                                    </CardContent>
                                </Card>
                            </Box>
                        </Grid>
                    </Grid>
                </Box>
            </Container>
        </AuthenticatedLayout>
    );
}
