import React from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, Link } from '@inertiajs/react';
import {
    Container, TextField, Button, Box, Typography, Paper, IconButton, Fade
} from '@mui/material';
import { ArrowBack as ArrowBackIcon } from '@mui/icons-material';

export default function Edit({ auth, project }) {
    const { data, setData, put, processing, errors } = useForm({
        title: project.title,
        description: project.description,
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        put(route('projects.update', project.id));
    };

    const inputStyle = { '& .MuiOutlinedInput-root': { borderRadius: '12px' } };

    return (
        <AuthenticatedLayout user={auth.user}>
            <Head title="Edit Project" />
            <Container maxWidth="sm" sx={{ py: 6 }}>
                <Fade in={true} timeout={600}>
                    <Paper elevation={0} sx={{
                        p: 4,
                        borderRadius: '24px',
                        boxShadow: '0 12px 40px rgba(0,0,0,0.08)',
                    }}>
                        <Box display="flex" alignItems="center" mb={4}>
                            <IconButton component={Link} href={route('projects.index')} sx={{ mr: 1, color: '#1d1d1f' }}>
                                <ArrowBackIcon />
                            </IconButton>
                            <Typography variant="h5" fontWeight="700">Edit Project</Typography>
                        </Box>

                        <Box component="form" onSubmit={handleSubmit} noValidate>
                            <TextField
                                fullWidth
                                label="Project Title"
                                value={data.title}
                                onChange={(e) => setData('title', e.target.value)}
                                error={!!errors.title}
                                helperText={errors.title}
                                sx={{ mb: 3, ...inputStyle }}
                            />

                            <TextField
                                fullWidth
                                multiline
                                rows={4}
                                label="Description"
                                value={data.description}
                                onChange={(e) => setData('description', e.target.value)}
                                error={!!errors.description}
                                helperText={errors.description}
                                sx={{ mb: 4, ...inputStyle }}
                            />

                            <Button
                                type="submit"
                                variant="contained"
                                fullWidth
                                disabled={processing}
                                sx={{
                                    borderRadius: '12px',
                                    textTransform: 'none',
                                    fontWeight: '600',
                                    py: 1.5,
                                    fontSize: '1rem',
                                    backgroundColor: '#0071e3',
                                    boxShadow: 'none',
                                    '&:hover': { backgroundColor: '#0077ed', boxShadow: 'none' },
                                }}
                            >
                                Update Project
                            </Button>
                        </Box>
                    </Paper>
                </Fade>
            </Container>
        </AuthenticatedLayout>
    );
}