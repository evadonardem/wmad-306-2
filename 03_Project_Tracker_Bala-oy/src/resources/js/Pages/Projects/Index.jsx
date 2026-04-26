import React from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router } from '@inertiajs/react';
import {
    Container, Typography, Button, Grid, Card, CardContent, CardActions,
    IconButton, Box, Grow,
} from '@mui/material';
import { Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon, Folder as FolderIcon } from '@mui/icons-material';

const cardStyle = {
    borderRadius: '24px',
    backgroundColor: '#fff',
    border: '1px solid rgba(0, 0, 0, 0.08)',
    boxShadow: '0 4px 20px rgba(0, 0, 0, 0.04)',
    transition: 'all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)',
    
    // --- THE FIX: STRICT UNIFORM SIZE ---
    width: '100%',
    maxWidth: '350px',
    height: '280px',
    display: 'flex',
    flexDirection: 'column',
    margin: '0 auto',

    '&:hover': {
        transform: 'translateY(-6px)',
        boxShadow: '0 15px 35px rgba(0, 0, 0, 0.1)',
    },
};

export default function Index({ auth, projects }) {
    const handleDelete = (id) => {
        if (confirm('Delete project?')) {
            router.delete(route('projects.destroy', id));
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Typography variant="h5" fontWeight="800">Projects</Typography>
                    <Button
                        variant="contained"
                        component={Link}
                        href={route('projects.create')}
                        startIcon={<AddIcon />}
                        sx={{
                            borderRadius: '30px', textTransform: 'none', fontWeight: '700',
                            backgroundColor: '#0071e3', px: 3
                        }}
                    >
                        New Project
                    </Button>
                </Box>
            }
        >
            <Head title="Projects" />

            <Container maxWidth={false} sx={{ py: 8 }}>
                <Grid container spacing={4} justifyContent="center">
                    {projects.map((project, index) => (
                        <Grid item key={project.id}>
                            <Grow in={true} timeout={(index + 1) * 150}>
                                <Card sx={cardStyle}>
                                    <CardContent sx={{ p: 4, flexGrow: 1 }}>
                                        <Box sx={{
                                            width: 48, height: 48, borderRadius: '12px', 
                                            backgroundColor: 'rgba(0, 113, 227, 0.08)', display: 'flex', 
                                            alignItems: 'center', justifyContent: 'center', mb: 3
                                        }}>
                                            <FolderIcon sx={{ color: '#0071e3' }} />
                                        </Box>
                                        <Typography variant="h6" fontWeight="800" noWrap sx={{ mb: 1 }}>
                                            {project.title}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary" sx={{
                                            display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden'
                                        }}>
                                            {project.description || "Workspace description."}
                                        </Typography>
                                    </CardContent>

                                    <CardActions sx={{ justifyContent: 'flex-end', px: 3, pb: 3 }}>
                                        <IconButton component={Link} href={route('projects.edit', project.id)} size="small">
                                            <EditIcon fontSize="small" />
                                        </IconButton>
                                        <IconButton onClick={() => handleDelete(project.id)} size="small" color="error">
                                            <DeleteIcon fontSize="small" />
                                        </IconButton>
                                    </CardActions>
                                </Card>
                            </Grow>
                        </Grid>
                    ))}
                </Grid>
            </Container>
        </AuthenticatedLayout>
    );
}