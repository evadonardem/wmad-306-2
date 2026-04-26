import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, router } from '@inertiajs/react';
import { Button, TextField, Typography, Box, Card, CardContent, Grid, Container, Snackbar, Alert } from '@mui/material';
import { ArrowBack } from '@mui/icons-material';
import { useThemeContext } from '@/Components/ThemeProvider';
import { useState } from 'react';

export default function Create() {
    const { theme } = useThemeContext();
    const { data, setData, post, errors } = useForm({
        title: '',
        description: '',
    });

    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    const isTitleEmpty = !data.title || data.title.trim() === '';

    function submit(e) {
        e.preventDefault();

        if (isTitleEmpty) {
            setSnackbar({
                open: true,
                message: 'Project title is required!',
                severity: 'warning'
            });
            return;
        }

        post(route('projects.store'), {
            onSuccess: () => {
                setSnackbar({
                    open: true,
                    message: 'Project successfully created!',
                    severity: 'success'
                });
                setTimeout(() => {
                    router.visit(route('projects.index'));
                }, 1500);
            },
            onError: () => {
                setSnackbar({
                    open: true,
                    message: 'Error creating project. Please check form.',
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
                    Create Project
                </Typography>
            }
        >
            <Head title="Create Project" />

            <Container maxWidth="md" sx={{ mt: 3, mb: 4 }}>
                <Button
                    onClick={() => router.visit(route('projects.index'))}
                    startIcon={<ArrowBack />}
                    sx={{ mb: 3 }}
                >
                    Back to Projects
                </Button>

                <Card sx={{ borderRadius: 3 }}>
                    <CardContent sx={{ p: 4 }}>
                        <Typography variant="h6" sx={{ mb: 3, fontWeight: 'bold', color: theme.palette.text.primary }}>
                            Create New Project
                        </Typography>
                        
                        <form onSubmit={submit}>
                            <Grid container spacing={3}>
                                <Grid item xs={12}>
                                    <TextField
                                        fullWidth
                                        label="Project Title"
                                        value={data.title}
                                        onChange={(e) => setData('title', e.target.value)}
                                        error={!!errors.title || (isTitleEmpty && data.title !== '')}
                                        helperText={errors.title || (isTitleEmpty && data.title !== '' ? 'Title cannot be empty' : '')}
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
                                        error={!!errors.description}
                                        helperText={errors.description}
                                        size="small"
                                        multiline
                                    />
                                </Grid>
                                
                                <Grid item xs={12}>
                                    <Button
                                        type="submit"
                                        variant="contained"
                                        disabled={isTitleEmpty}
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
                                            },
                                            '&:disabled': {
                                                background: theme.palette.action.disabledBackground,
                                                color: theme.palette.action.disabled
                                            }
                                        }}
                                    >
                                        Create Project
                                    </Button>
                                    <Button
                                        onClick={() => router.visit(route('projects.index'))}
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