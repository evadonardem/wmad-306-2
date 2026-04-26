import { useEffect } from 'react';
import { router } from '@inertiajs/react';
import { Head } from '@inertiajs/react';
import { Box, CircularProgress, Typography } from '@mui/material';

export default function Dashboard({ auth }) {
    useEffect(() => {
        // Redirect based on user role
        if (auth?.user?.role) {
            const role = auth.user.role.toLowerCase();
            
            switch (role) {
                case 'writer':
                    router.visit(route('writer.dashboard'));
                    break;
                case 'editor':
                    router.visit(route('editor.dashboard'));
                    break;
                case 'student':
                    router.visit(route('student.dashboard'));
                    break;
                default:
                    router.visit('/');
            }
        } else {
            router.visit('/');
        }
    }, [auth?.user?.role]);

    return (
        <>
            <Head title="Dashboard" />
            <Box
                sx={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    justifyContent: 'center',
                    minHeight: '100vh',
                    backgroundColor: 'background.default'
                }}
            >
                <CircularProgress size={60} sx={{ mb: 2 }} />
                <Typography variant="h6" color="text.secondary">
                    Redirecting to your dashboard...
                </Typography>
            </Box>
        </>
    );
}
