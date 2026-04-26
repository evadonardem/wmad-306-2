import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, router, usePage } from '@inertiajs/react';
import { useState, useEffect } from 'react';
import {
    Container,
    Typography,
    Button,
    Box,
    Paper,
    Snackbar,
    Alert,
    LinearProgress,
} from '@mui/material';
import { Add, AccountTree} from '@mui/icons-material';
import TaskCard from '@/Components/TaskCard';
import { useThemeContext } from '@/Components/ThemeProvider';

export default function Index({ tasks, projects }) {
    const { theme } = useThemeContext();
    const { flash } = usePage().props;
    
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    useEffect(() => {
        if (flash?.success) {
            setSnackbar({
                open: true,
                message: flash.success,
                severity: 'success'
            });
        }
    }, [flash]);

    const handleDelete = (taskId) => {
        if (window.confirm('Are you sure you want to delete this task?')) {
            router.delete(route('tasks.destroy', taskId), {
                preserveScroll: true,
                preserveState: true,
                onSuccess: () => {
                    setSnackbar({ open: true, message: 'Task deleted successfully!', severity: 'success' });
                },
                onError: () => {
                    setSnackbar({ open: true, message: 'Error deleting task.', severity: 'error' });
                }
            });
        }
    };

    const handleUpdate = (taskId, updateData) => {
        router.patch(route('tasks.update', taskId), updateData, {
            preserveScroll: true,
            preserveState: true,
            onSuccess: () => {
                setSnackbar({ open: true, message: 'Task successfully updated', severity: 'success' });
            },
            onError: () => {
                setSnackbar({ open: true, message: 'Error updating task.', severity: 'error' });
            }
        });
    };

    const handleToggleStatus = (task) => {
        router.post(route('tasks.toggle-status', task.id), {}, {
            onSuccess: () => {
                setSnackbar({ open: true, message: 'Task status updated', severity: 'success' });
            },
            onError: () => {
                setSnackbar({ open: true, message: 'Error updating task status.', severity: 'error' });
            }
        });
    };

    const handleCloseSnackbar = () => setSnackbar({ ...snackbar, open: false });

    const completedTasks = tasks.filter(t => t.status === 'completed').length;
    const progressPercent = tasks.length > 0 ? (completedTasks / tasks.length) * 100 : 0;

    const tabs = [
        { name: 'Dashboard', route: 'dashboard' }, 
        { name: 'Projects', route: 'projects.index' },
        { name: 'Tasks', route: 'tasks.index' },
    ];

    return (
        <AuthenticatedLayout
        header={
                        <Typography 
                            variant="h4" 
                            sx={{ 
                                fontWeight: 'bold', 
                                color: theme.palette.text.primary,
                                display: 'flex',       
                                alignItems: 'center',  
                                gap: 1.5               
                            }}
                        >
                            <AccountTree />
                            Project Tracker
                        </Typography>
                    }
        >
            <Head title="Tasks Tracker" />

            <Container maxWidth="xl" sx={{ mt: 5, mb: 4 }}>
                

                <Box sx={{ display: 'flex', fontSize: '1rem', gap: 1, ml: { xs: 2, md: 8 }, mb: '-3px', position: 'relative', zIndex: 0 }}>
                    {tabs.map((tab) => {
                        const isActive = tab.name === 'Tasks';
                        return (
                            <Box
                                key={tab.name}
                                onClick={() => !isActive && router.visit(route(tab.route))}
                                sx={{
                                    bgcolor: isActive ? '#499636' : '#222', 
                                    color: isActive ? theme.palette.text.primary : '#777',
                                    px: 2,
                                    py: 1.5,
                                    borderTopLeftRadius: 12,
                                    borderTopRightRadius: 12,
                                    border: '2px solid #111',
                                    borderBottom: 'none',
                                    fontWeight: '900',
                                    cursor: isActive ? 'default' : 'pointer',
                                    transition: 'all 0.2s',
                                    boxShadow: isActive ? '0 -4px 15px rgba(255, 193, 7, 0.2)' : 'none',
                                    '&:hover': {
                                        bgcolor: isActive ? '#499636' : '#444',
                                        color: isActive ? '#000' : '#FFF',
                                    }
                                }}
                            >
                                {tab.name}
                            </Box>
                        );
                    })}
                </Box>

                <Paper sx={{ 
                    bgcolor: theme.palette.primary.secondary, 
                    border: '4px solid #111', 
                    borderRadius: 4, 
                    display: 'flex',
                    minHeight: '65vh',
                    position: 'relative',
                    overflow: 'hidden',
                    boxShadow: '0 20px 50px rgba(0,0,0,0.5)'
                }}>
    

                    <Box sx={{ flex: 1, p: { xs: 2, md: 4 }, display: 'flex', flexDirection: 'column' }}>
                        
                        <Box sx={{ 
                            display: 'flex', 
                            alignItems: 'center', 
                            justifyContent: 'space-between',
                            bgcolor: theme.palette.primary.secondary,
                            p: 2,
                            borderRadius: 3,
                            border: '2px solid #bdb1b1cc',
                            mb: 4
                        }}>


                            <Button
                                onClick={() => router.visit(route('tasks.create'))}
                                startIcon={<Add />}
                                sx={{
                                    bgcolor: '#DA0037',
                                    color: '#000',
                                    fontWeight: '900',
                                    borderRadius: 8,
                                    px: 3,
                                    textTransform: 'uppercase',
                                    '&:hover': { bgcolor: '#499636' }
                                }}
                            >
                                Create Task
                            </Button>
                        </Box>

                        <Box sx={{ 
                            display: 'flex', 
                            gap: 3, 
                            overflowX: 'auto', 
                            pb: 2,
                            flex: 1,
                            '&::-webkit-scrollbar': { height: 8 },
                            '&::-webkit-scrollbar-track': { bgcolor: '#111', borderRadius: 4 },
                            '&::-webkit-scrollbar-thumb': { bgcolor: '#444', borderRadius: 4 },
                        }}>
                            {tasks.length > 0 ? (
                                tasks.map((task) => (
                                    <Box key={task.id} sx={{ minWidth: 320, maxWidth: 350 }}>
                                        <TaskCard
                                            task={task}
                                            projects={projects}
                                            onDelete={handleDelete}
                                            onUpdate={handleUpdate}
                                            onToggleStatus={handleToggleStatus}
                                        />
                                    </Box>
                                ))
                            ) : (
                                <Box sx={{ display: 'flex', width: '100%', alignItems: 'center', justifyContent: 'center' }}>
                                    <Typography variant="h5" sx={{ color: '#555', fontWeight: 900, textTransform: 'uppercase' }}>
                                        No Tasks Created
                                    </Typography>
                                </Box>
                            )}
                        </Box>

                    </Box>
                </Paper>

                <Snackbar
                    open={snackbar.open}
                    autoHideDuration={3000}
                    onClose={handleCloseSnackbar}
                    anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
                >
                    <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} variant="filled">
                        {snackbar.message}
                    </Alert>
                </Snackbar>
            </Container>
        </AuthenticatedLayout>
    );
}