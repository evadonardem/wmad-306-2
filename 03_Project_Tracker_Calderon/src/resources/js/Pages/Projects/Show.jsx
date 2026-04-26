import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router } from '@inertiajs/react';
import { 
    Button, Card, CardContent, Typography, Box, Grid, Container, 
    Snackbar, Alert, Dialog, DialogTitle, DialogContent, 
    DialogContentText, DialogActions 
} from '@mui/material';
import { Delete, ArrowBack } from '@mui/icons-material';
import { useThemeContext } from '@/Components/ThemeProvider';
import { useState } from 'react';

export default function Show({ project }) {
    const { theme } = useThemeContext();
    const [openDialog, setOpenDialog] = useState(false);
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    const handleDeleteClick = () => setOpenDialog(true);
    const handleCloseDialog = () => setOpenDialog(false);

    const confirmDelete = () => {
        router.delete(route('projects.destroy', project.id), {
            onSuccess: () => {
                handleCloseDialog();
                setSnackbar({
                    open: true,
                    message: 'Project deleted successfully!',
                    severity: 'success'
                });
                setTimeout(() => router.visit(route('projects.index')), 1500);
            },
            onError: () => {
                setSnackbar({
                    open: true,
                    message: 'Error deleting project.',
                    severity: 'error'
                });
            }
        });
    };

    return (
        <AuthenticatedLayout
            header={
                <Typography variant="h4" sx={{ fontWeight: 'bold', color: theme.palette.text.primary }}>
                    {project.title}
                </Typography>
            }
        >
            <Head title={project.title} />

            <Container maxWidth="lg" sx={{ mt: 3, mb: 4 }}>
                <Box sx={{ mb: 3, display: 'flex', gap: 2 }}>
                    <Button
                        onClick={() => router.visit(route('projects.index'))}
                        startIcon={<ArrowBack />}
                        variant="outlined"
                        sx={{ borderRadius: 2, textTransform: 'none' }}
                    >
                        Back to Projects
                    </Button>
                    <Button
                        onClick={handleDeleteClick}
                        startIcon={<Delete />}
                        variant="outlined"
                        color="error"
                        sx={{ borderRadius: 2, textTransform: 'none' }}
                    >
                        Delete Project
                    </Button>
                </Box>

                <Card sx={{ borderRadius: 3 }}>
                    <CardContent sx={{ p: 4 }}>
                        <Typography variant="h1" sx={{ mb: 3, fontWeight: 'bold', color: theme.palette.text.primary }}>
                            {project.title}
                        </Typography>
                        
                        <Typography variant="body1" color="text.secondary" sx={{ mb: 4, lineHeight: 1.6 }}>
                            {project.description || 'No description provided'}
                        </Typography>

                        <Grid container spacing={3}>
                            <Grid item xs={12} md={6}>
                                <Typography variant="h6" sx={{ mb: 2, fontWeight: 'bold' }}>
                                    Desc
                                </Typography>
                                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                                    <Typography variant="body2" color="text.secondary">
                                        Created: {new Date(project.created_at).toLocaleDateString()}
                                    </Typography>
                                </Box>
                            </Grid>
                        </Grid>
                    </CardContent>
                </Card>
            </Container>

            <Dialog
                open={openDialog}
                onClose={handleCloseDialog}
                aria-labelledby="alert-dialog-title"
                aria-describedby="alert-dialog-description"
                PaperProps={{
                    sx: { borderRadius: 3, p: 1 }
                }}
            >
                <DialogTitle id="alert-dialog-title" sx={{ fontWeight: 'bold' }}>
                    {"Delete this project?"}
                </DialogTitle>
                <DialogContent>
                    <DialogContentText id="alert-dialog-description">
                        This action cannot be undone. All tasks associated with <strong>{project.title}</strong> will be permanently removed from the system.
                    </DialogContentText>
                </DialogContent>
                <DialogActions sx={{ pb: 2, px: 3 }}>
                    <Button onClick={handleCloseDialog} variant="outlined" sx={{ borderRadius: 2 }}>
                        Cancel
                    </Button>
                    <Button onClick={confirmDelete} variant="contained" color="error" autoFocus sx={{ borderRadius: 2 }}>
                        Confirm Delete
                    </Button>
                </DialogActions>
            </Dialog>

            <Snackbar
                open={snackbar.open}
                autoHideDuration={3000}
                onClose={() => setSnackbar({ ...snackbar, open: false })}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
            >
                <Alert severity={snackbar.severity} sx={{ width: '100%' }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </AuthenticatedLayout>
    );
}