import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';
import { Box, Card, Container, Stack, Typography } from '@mui/material';
import DeleteUserForm from './Partials/DeleteUserForm';
import UpdatePasswordForm from './Partials/UpdatePasswordForm';
import UpdateProfileInformationForm from './Partials/UpdateProfileInformationForm';

export default function Edit({ mustVerifyEmail, status }) {
    return (
        <AuthenticatedLayout>
            <Head title="Profile" />

            <Box sx={{ py: { xs: 3, md: 5 }, bgcolor: 'background.default' }}>
                <Container maxWidth="lg">
                    <Box sx={{ mb: 3 }}>
                        <Typography
                            variant="h4"
                            sx={{
                                fontWeight: 800,
                                color: 'primary.main',
                                letterSpacing: '-0.02em',
                                mb: 1,
                            }}
                        >
                            Profile Settings
                        </Typography>
                        <Typography variant="body1" sx={{ color: 'text.secondary' }}>
                            Manage your account information, security settings, and account actions.
                        </Typography>
                    </Box>

                    <Stack spacing={3}>
                        <Card
                            elevation={0}
                            sx={{
                                p: { xs: 3, md: 4 },
                                borderRadius: 3,
                                border: '1px solid',
                                borderColor: 'divider',
                                bgcolor: 'background.paper',
                            }}
                        >
                        <UpdateProfileInformationForm
                            mustVerifyEmail={mustVerifyEmail}
                            status={status}
                        />
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                p: { xs: 3, md: 4 },
                                borderRadius: 3,
                                border: '1px solid',
                                borderColor: 'divider',
                                bgcolor: 'background.paper',
                            }}
                        >
                            <UpdatePasswordForm />
                        </Card>

                        <Card
                            elevation={0}
                            sx={{
                                p: { xs: 3, md: 4 },
                                borderRadius: 3,
                                border: '1px solid',
                                borderColor: 'divider',
                                bgcolor: 'background.paper',
                            }}
                        >
                            <DeleteUserForm />
                        </Card>
                    </Stack>
                </Container>
            </Box>
        </AuthenticatedLayout>
    );
}
