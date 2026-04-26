import React from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm } from '@inertiajs/react';
import { 
    Container, Typography, TextField, Button, Box, 
    FormControl, InputLabel, Select, MenuItem, Paper 
} from '@mui/material';

export default function Edit({ auth, task, projects }) {
    // We initialize the form with existing task data
    const { data, setData, put, processing, errors } = useForm({
        title: task.title || '',
        description: task.description || '',
        priority: task.priority || 'medium',
        project_id: task.project_id || '',
        status: task.status === 1 || task.status === true ? 'completed' : 'pending',
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        // This sends the data back to your TaskController@update
        put(route('tasks.update', task.id));
    };

    return (
        <AuthenticatedLayout user={auth.user}>
            <Head title="Edit Task" />

            <Container maxWidth="sm" sx={{ py: 8 }}>
                <Paper sx={{ p: 4, borderRadius: '24px', boxShadow: '0 4px 20px rgba(0,0,0,0.05)' }}>
                    <Typography variant="h5" fontWeight="700" mb={3}>
                        Edit Task: {task.title}
                    </Typography>

                    <form onSubmit={handleSubmit}>
                        <TextField
                            fullWidth
                            label="Task Title"
                            value={data.title}
                            onChange={e => setData('title', e.target.value)}
                            error={!!errors.title}
                            helperText={errors.title}
                            margin="normal"
                        />

                        <TextField
                            fullWidth
                            multiline
                            rows={4}
                            label="Description"
                            value={data.description}
                            onChange={e => setData('description', e.target.value)}
                            margin="normal"
                        />

                        <Box sx={{ display: 'flex', gap: 2, mt: 2 }}>
                            <FormControl fullWidth>
                                <InputLabel>Priority</InputLabel>
                                <Select
                                    value={data.priority}
                                    label="Priority"
                                    onChange={e => setData('priority', e.target.value)}
                                >
                                    <MenuItem value="low">Low</MenuItem>
                                    <MenuItem value="medium">Medium</MenuItem>
                                    <MenuItem value="high">High</MenuItem>
                                </Select>
                            </FormControl>

                            <FormControl fullWidth>
                                <InputLabel>Project</InputLabel>
                                <Select
                                    value={data.project_id}
                                    label="Project"
                                    onChange={e => setData('project_id', e.target.value)}
                                >
                                    {projects.map(p => (
                                        <MenuItem key={p.id} value={p.id}>{p.title}</MenuItem>
                                    ))}
                                </Select>
                            </FormControl>
                        </Box>

                        <Button
                            type="submit"
                            fullWidth
                            variant="contained"
                            disabled={processing}
                            sx={{ mt: 4, py: 1.5, borderRadius: '12px', backgroundColor: '#0071e3' }}
                        >
                            {processing ? 'Saving...' : 'Save Changes'}
                        </Button>
                    </form>
                </Paper>
            </Container>
        </AuthenticatedLayout>
    );
}