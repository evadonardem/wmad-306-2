import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import { Box, Button, Card, CardContent, Stack, Typography } from '@mui/material';

const roleLabels = {
    writer: 'Writer Dashboard',
    editor: 'Editor Dashboard',
    student: 'Student Dashboard',
};

export default function Dashboard({ availableDashboards = [] }) {
    return (
        <AuthenticatedLayout
            header={
                <Typography variant="h5" component="h2" sx={{ fontWeight: 700 }}>
                    Dashboard Access
                </Typography>
            }
        >
            <Head title="Dashboard" />

            <Box sx={{ py: 6, px: { xs: 2, sm: 4 } }}>
                <Box sx={{ maxWidth: 900, mx: 'auto' }}>
                    <Card elevation={1}>
                        <CardContent sx={{ p: 4 }}>
                            <Typography variant="h6" sx={{ mb: 1, fontWeight: 700 }}>
                                Choose a dashboard
                            </Typography>
                            <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                                Your account has multiple roles. Select which workspace you want to open.
                            </Typography>

                            {availableDashboards.length > 0 ? (
                                <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
                                    {availableDashboards.map((dashboard) => (
                                        <Button
                                            key={dashboard.role}
                                            component={Link}
                                            href={dashboard.route}
                                            variant="contained"
                                        >
                                            {roleLabels[dashboard.role] ?? dashboard.role}
                                        </Button>
                                    ))}
                                </Stack>
                            ) : (
                                <Typography variant="body2" color="text.secondary">
                                    No role dashboard is currently assigned to this account.
                                </Typography>
                            )}
                        </CardContent>
                    </Card>
                </Box>
            </Box>
        </AuthenticatedLayout>
    );
}
