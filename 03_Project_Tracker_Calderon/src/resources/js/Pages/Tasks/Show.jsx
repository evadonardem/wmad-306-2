import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';
import { Button, Card, CardContent, Typography, Container, Chip, Box } from '@mui/material';
import { router } from '@inertiajs/react';
import { useThemeContext } from '@/Components/ThemeProvider';

const PRIORITY_LABEL = {
    'less important': 'Less Important',
    'important': 'Important',
    'very important': 'Very Important',
};

const STATUS_LABEL = {
    'pending': 'Pending',
    'on going': 'On Going',
    'completed': 'Completed',
};

export default function Show({ task }) {
    const { theme } = useThemeContext();

    function destroy() {
        if (!confirm('Are you sure you want to delete this task?')) return;
        router.delete(route('tasks.destroy', task.id));
    }

    function toggleStatus() {
        const statuses = ['pending', 'on going', 'completed'];
        const currentIndex = statuses.indexOf(task.status);
        const nextStatus = statuses[(currentIndex + 1) % statuses.length];
        router.patch(route('tasks.update', task.id), { status: nextStatus });
    }

    return (
        <AuthenticatedLayout
            header={
                <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold', color: theme.palette.text.primary }}>
                    Task Details
                </Typography>
            }
        >
            <Head title={task.title} />

            <Container maxWidth="md" sx={{ mt: 3, mb: 4 }}>
                <Card variant="outlined" sx={{ borderRadius: 3 }}>
                    <CardContent>
                        <Typography variant="h4" sx={{ mb: 3, fontWeight: 'bold', color: theme.palette.text.primary }}>
                            {task.title}
                        </Typography>
                        
                        <Typography variant="body1" color={theme.palette.text.secondary} paragraph sx={{ mb: 3 }}>
                            {task.description || 'No description provided'}
                        </Typography>

                        <Box sx={{ mb: 3 }}>
                            <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 'medium' }}>
                                Project: {task.project?.title}
                            </Typography>
                            
                            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                <Chip 
                                    label={`Priority: ${PRIORITY_LABEL[task.priority] || task.priority}`} 
                                    color="primary"
                                    variant="outlined"
                                    size="small"
                                />
                                
                                <Chip 
                                    label={`Status: ${STATUS_LABEL[task.status] || task.status}`} 
                                    color="secondary"
                                    variant="outlined"
                                    size="small"
                                />
                            </Box>
                        </Box>

                        <Box sx={{ display: 'flex', gap: 2, mt: 4 }}>
                            <Button 
                                variant="contained" 
                                href={route('tasks.edit', task.id)}
                                sx={{
                                    background: theme.palette.primary.main,
                                    color: theme.palette.primary.contrastText,
                                    fontWeight: 'bold',
                                    borderRadius: 2,
                                    textTransform: 'none',
                                    '&:hover': {
                                        background: theme.palette.primary.dark,
                                    }
                                }}
                            >
                                Edit
                            </Button>
                            
                            <Button 
                                variant="outlined" 
                                onClick={toggleStatus}
                                sx={{
                                    borderRadius: 2,
                                    textTransform: 'none',
                                }}
                            >
                                Toggle Status
                            </Button>
                            
                            <Button 
                                variant="outlined" 
                                href={route('tasks.index')}
                                sx={{
                                    borderRadius: 2,
                                    textTransform: 'none',
                                }}
                            >
                                Back to Tasks
                            </Button>
                            <Button 
                                variant="outlined" 
                                color="error"
                                onClick={destroy}
                                sx={{
                                    borderRadius: 2,
                                    textTransform: 'none',
                                }}
                            >
                                Delete
                            </Button>
                        </Box>
                    </CardContent>
                </Card>

                <Card variant="outlined" sx={{ mt: 3, borderRadius: 3 }}>
                    <CardContent>
                        <Typography variant="h6" sx={{ mb: 2, fontWeight: 'bold', color: theme.palette.text.primary }}>
                            Project Details
                        </Typography>
                        <Typography variant="body2" sx={{ mb: 1 }}>
                            <strong>Project:</strong> {task.project?.title}
                        </Typography>
                        {task.project?.description && (
                            <Typography variant="body2" sx={{ mt: 1 }}>
                                <strong>Description:</strong> {task.project.description}
                            </Typography>
                        )}
                        <Button 
                            variant="text" 
                            size="small" 
                            href={route('projects.show', task.project_id)}
                            sx={{ mt: 2 }}
                        >
                            View Project
                        </Button>
                    </CardContent>
                </Card>
            </Container>
        </AuthenticatedLayout>
    );
}
