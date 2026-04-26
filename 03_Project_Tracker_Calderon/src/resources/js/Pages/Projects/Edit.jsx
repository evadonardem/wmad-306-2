import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, router } from '@inertiajs/react';
import { Button, TextField, Typography, Box, Card, CardContent, Grid, Container, Snackbar, Alert } from '@mui/material';
import { ArrowBack } from '@mui/icons-material';
import { useThemeContext } from '@/Components/ThemeProvider';
import { useState } from 'react';

export default function Edit({ project }) {
    const { theme } = useThemeContext();
    
    if (!project) {
        return (
            <AuthenticatedLayout
                header={
                    <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold', color: theme.palette.text.primary }}>
                        Project Not Found
                    </Typography>
                }
            >
                <Head title="Project Not Found" />
                <Container maxWidth="md" sx={{ mt: 3, mb: 4 }}>
                    <Typography variant="body1">
                        Project not found or you don't have permission to edit it.
                    </Typography>
                    <Button
                        onClick={() => router.visit(route('projects.index'))}
                        sx={{ mt: 2 }}
                    >
                        Back to Projects
                    </Button>
                </Container>
            </AuthenticatedLayout>
        );
    }
    
    const { data, setData, patch, processing, errors } = useForm({
        title: project.title || '',
        description: project.description || '',
    });

    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    function submit(e) {
        e.preventDefault();
        patch(route('projects.update', project.id), {
            onSuccess: () => {
                setSnackbar({
                    open: true,
                    message: 'Project successfully updated!',
                    severity: 'success'
                });
                router.visit(route('projects.index'));
            },
            onError: () => {
                setSnackbar({
                    open: true,
                    message: 'Error updating project. Please check form.',
                    severity: 'error'
                });
            }
        });
    }

    const handleCloseSnackbar = () => {
        setSnackbar({ ...snackbar, open: false });
    };

    return (
        <AuthenticatedLayout
            header={
                <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold', color: theme.palette.text.primary }}>
                    Edit Project
                </Typography>
            }
        >
            <Head title="Edit Project" />

            <Container maxWidth="md" sx={{ mt: 3, mb: 4 }}>
                <Button
                    onClick={() => router.visit(route('projects.show', project.id))}
                    startIcon={<ArrowBack />}
                    sx={{ mb: 3 }}
                >
                    Back to Project
                </Button>

                <Card sx={{ borderRadius: 3 }}>
                    <CardContent sx={{ p: 4 }}>
                        <Typography variant="h6" sx={{ mb: 3, fontWeight: 'bold', color: theme.palette.text.primary }}>
                            Edit Project
                        </Typography>
                        
                        <form onSubmit={submit}>
                            <Grid container spacing={3}>
                                <Grid item xs={12}>
                                    <TextField
                                        fullWidth
                                        label="Project Title"
                                        value={data.title}
                                        onChange={(e) => setData('title', e.target.value)}
                                        error={!!errors.title}
                                        helperText={errors.title}
                                        required
                                        size="small"
                                    />
                                </Grid>
                                
                                <Grid item xs={12}>
                                    <TextField
                                        fullWidth
                                        label="Description"
                                        value={data.description}
                                        onChange={(e) => setData('description', e.target.value)}
                                        size="small"
                                    />
                                </Grid>
                                
                                <Grid item xs={12}>
                                    <Button
                                        type="submit"
                                        variant="contained"
                                        disabled={processing}
                                        sx={{
                                            mr: 2,
                                            background: theme.palette.primary.main,
                                            color: theme.palette.primary.contrastText,
                                            padding: '10px 24px',
                                            fontWeight: 'bold',
                                            borderRadius: 2,
                                            textTransform: 'none',
                                            '&:hover': {
                                                background: theme.palette.primary.dark,
                                            }
                                        }}
                                    >
                                        {processing ? 'Updating...' : 'Update Project'}
                                    </Button>
                                    <Button
                                        onClick={() => router.visit(route('projects.show', project.id))}
                                        variant="outlined"
                                        sx={{
                                            borderRadius: 2,
                                            textTransform: 'none',
                                        }}
                                    >
                                        Cancel
                                    </Button>
                                </Grid>
                            </Grid>
                        </form>
                    </CardContent>
                </Card>
            </Container>

            <Snackbar
                open={snackbar.open}
                autoHideDuration={3000}
                onClose={handleCloseSnackbar}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
            >
                <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: '100%' }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </AuthenticatedLayout>
    );
}
