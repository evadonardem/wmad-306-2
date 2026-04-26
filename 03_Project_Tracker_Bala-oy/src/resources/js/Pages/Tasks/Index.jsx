import React, { useState } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router } from '@inertiajs/react';
import {
    Container, Typography, Button, Grid, Card, CardContent,
    IconButton, Box, Chip, Checkbox, FormControl, InputLabel, Select, MenuItem, Grow
} from '@mui/material';
import {
    Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon
} from '@mui/icons-material';

const cardStyle = (isDone) => ({
    borderRadius: '24px',
    backgroundColor: '#fff',
    border: '1px solid rgba(0, 0, 0, 0.08)',
    boxShadow: '0 4px 20px rgba(0, 0, 0, 0.04)',
    transition: 'all 0.3s ease',
    // Check against boolean status
    opacity: isDone ? 0.6 : 1,
    
    width: '100%',
    maxWidth: '350px',
    height: '320px',
    display: 'flex',
    flexDirection: 'column',
    margin: '0 auto',

    '&:hover': {
        transform: 'translateY(-6px)',
        boxShadow: '0 12px 30px rgba(0, 0, 0, 0.08)',
    },
});

export default function Index({ auth, tasks, projects, filters }) {
    const [selectedProject, setSelectedProject] = useState(filters?.project_id || '');

    const handleFilterChange = (e) => {
        const projectId = e.target.value;
        setSelectedProject(projectId);
        router.get(route('tasks.index'), { project_id: projectId }, { preserveState: true });
    };

    const toggleStatus = (task) => {
        // Since your Model casts status to boolean, task.status is true/false.
        // We send the string 'completed' or 'pending' because the controller logic expects it.
        const newStatusString = task.status ? 'pending' : 'completed';

        // THE KEY FIX: You must send all fields required by your TaskController validation.
        router.put(route('tasks.update', task.id), {
            title: task.title,
            description: task.description,
            priority: task.priority,
            project_id: task.project_id,
            status: newStatusString 
        }, { preserveScroll: true });
    };

    const handleDelete = (id) => {
        if (confirm('Delete this task?')) {
            router.delete(route('tasks.destroy', id));
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <Box display="flex" justifyContent="space-between" alignItems="center">
                    <Typography variant="h5" fontWeight="700">Tasks</Typography>
                    <Button
                        variant="contained"
                        component={Link}
                        href={route('tasks.create')}
                        startIcon={<AddIcon />}
                        sx={{
                            borderRadius: '30px', textTransform: 'none', backgroundColor: '#0071e3',
                            fontWeight: 600, px: 3
                        }}
                    >
                        New Task
                    </Button>
                </Box>
            }
        >
            <Head title="Tasks" />

            <Container maxWidth={false} sx={{ py: 6 }}>
                {/* Filter Bar */}
                <Box mb={6} display="flex" justifyContent="center">
                    <FormControl size="small" sx={{ minWidth: 300, backgroundColor: 'white', borderRadius: '12px' }}>
                        <InputLabel>Filter by Project</InputLabel>
                        <Select
                            value={selectedProject}
                            label="Filter by Project"
                            onChange={handleFilterChange}
                            sx={{ borderRadius: '12px' }}
                        >
                            <MenuItem value=""><em>All Projects</em></MenuItem>
                            {projects.map((p) => (
                                <MenuItem key={p.id} value={p.id}>{p.title}</MenuItem>
                            ))}
                        </Select>
                    </FormControl>
                </Box>

                <Grid container spacing={3} justifyContent="center">
                    {tasks.map((task, index) => {
                        // Cast status to boolean for reliable UI checking
                        const isDone = Boolean(task.status);

                        return (
                            <Grid item key={task.id}>
                                <Grow in={true} timeout={(index + 1) * 100}>
                                    <Card sx={cardStyle(isDone)}>
                                        <CardContent sx={{ flexGrow: 1, p: 3 }}>
                                            <Box display="flex" justifyContent="space-between" mb={2}>
                                                <Chip
                                                    label={task.priority}
                                                    color={task.priority === 'high' ? 'error' : 'default'}
                                                    size="small"
                                                    sx={{ fontWeight: 800, borderRadius: '8px', fontSize: '0.7rem' }}
                                                />
                                                <Checkbox
                                                    checked={isDone}
                                                    onChange={() => toggleStatus(task)}
                                                    color="success"
                                                    sx={{ p: 0 }}
                                                />
                                            </Box>
                                            <Typography 
                                                variant="h6" 
                                                fontWeight="700" 
                                                sx={{ 
                                                    mb: 1.5, 
                                                    lineHeight: 1.2,
                                                    textDecoration: isDone ? 'line-through' : 'none',
                                                    color: isDone ? 'text.secondary' : 'text.primary'
                                                }}
                                            >
                                                {task.title}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary" sx={{ 
                                                display: '-webkit-box', WebkitLineClamp: 4, WebkitBoxOrient: 'vertical', overflow: 'hidden' 
                                            }}>
                                                {task.description || 'No description provided.'}
                                            </Typography>
                                        </CardContent>

                                        <Box sx={{ p: 3, borderTop: '1px solid rgba(0,0,0,0.05)', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                            <Typography variant="caption" fontWeight="700" color="primary">
                                                {task.project?.title || 'General'}
                                            </Typography>
                                            <Box>
                                                <IconButton component={Link} href={route('tasks.edit', task.id)} size="small">
                                                    <EditIcon fontSize="small" />
                                                </IconButton>
                                                <IconButton onClick={() => handleDelete(task.id)} size="small" color="error">
                                                    <DeleteIcon fontSize="small" />
                                                </IconButton>
                                            </Box>
                                        </Box>
                                    </Card>
                                </Grow>
                            </Grid>
                        );
                    })}
                </Grid>
            </Container>
        </AuthenticatedLayout>
    );
}