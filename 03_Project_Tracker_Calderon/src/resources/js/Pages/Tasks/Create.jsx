import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm, router } from '@inertiajs/react';
import { 
    Button, 
    TextField, 
    Typography, 
    Container, 
    MenuItem, 
    Select,
    FormControl,
    FormLabel,
    InputLabel,
    Box,
    Paper,
    Snackbar,
    Alert,
    RadioGroup,
    FormControlLabel,
    Radio
} from '@mui/material';
import { useThemeContext } from '@/Components/ThemeProvider';
import { useState } from 'react';

export default function Create({ projects }) {
    const { theme } = useThemeContext();
    
    // Set project_id to an empty string so it is not pre-filled
    const { data, setData, post, processing, errors } = useForm({
        project_id: '', 
        title: '',
        description: '',
        priority: 'important',
        status: 'pending',
        due_date: '',
    });

    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });

    function submit(e) {
        e.preventDefault();
        post(route('tasks.store'), {
            onSuccess: () => {
                setSnackbar({
                    open: true,
                    message: 'Task successfully created!',
                    severity: 'success'
                });
                setTimeout(() => {
                    router.visit(route('tasks.index'));
                }, 1500);
            },
            onError: () => {
                setSnackbar({
                    open: true,
                    message: 'Error creating task. Please check form.',
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
                    Create Task
                </Typography>
            }
        >
            <Head title="Create Task" />

            <Container maxWidth="md" sx={{ mt: 3, mb: 4 }}>
                
                <Paper sx={{ p: 4, borderRadius: 3, border: '4px solid #333',
                    boxShadow: '0 20px 50px rgba(0,0,0,0.5)'}}>
                    <form onSubmit={submit}>
                        <Typography variant="h5" sx={{ mb: 3, fontWeight: 'bold', color: theme.palette.text.primary }}>
                            Create New Task
                        </Typography>

                        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                            <FormControl fullWidth error={!!errors.project_id}>
                                <InputLabel id="project-select-label">Project</InputLabel>
                                <Select
                                    labelId="project-select-label"
                                    value={data.project_id}
                                    label="Project"
                                    onChange={(e) => setData('project_id', e.target.value)}
                                    required
                                >
                                    <MenuItem value="" disabled>
                                        <em>Select a project</em>
                                    </MenuItem>
                                    
                                    {projects.map((project) => (
                                        <MenuItem key={project.id} value={project.id}>
                                            {project.title}
                                        </MenuItem>
                                    ))}
                                </Select>
                                {errors.project_id && (
                                    <Typography variant="caption" color="error" sx={{ mt: 0.5 }}>
                                        {errors.project_id}
                                    </Typography>
                                )}
                            </FormControl>

                            <TextField
                                label="Title"
                                value={data.title}
                                onChange={(e) => setData('title', e.target.value)}
                                fullWidth
                                required
                                error={!!errors.title}
                                helperText={errors.title}
                            />

                            <TextField
                                label="Description"
                                value={data.description}
                                onChange={(e) => setData('description', e.target.value)}
                                fullWidth
                                multiline
                                rows={4}
                                error={!!errors.description}
                                helperText={errors.description}
                            />

                            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                            <FormControl 
                                component="fieldset" 
                                variant="outlined" 
                                sx={{ 
                                    border: '1px solid rgba(0, 0, 0, 0.23)', 
                                    borderRadius: 1, 
                                    p: 2, 
                                    pt: 1,
                                    position: 'relative',
                                    minWidth: '100%' 
                                }}
                            >
                                <FormLabel 
                                    component="legend" 
                                    sx={{ 
                                        fontSize: '0.75rem', 
                                        px: 0.5, 
                                        mb: 0,
                                        color: theme.palette.text.main,
                                        position: 'absolute',
                                        top: -10,
                                        left: 10,
                                        
                                    }}
                                >
                                    Priority
                                </FormLabel>

                                <RadioGroup
                                    row
                                    name="priority"
                                    value={data.priority}
                                    onChange={(e) => setData('priority', e.target.value)}
                                    sx={{ mt: 0.5 }}
                                >
                                    <FormControlLabel 
                                        value="less important" 
                                        control={<Radio size="small" />} 
                                        label={<Typography variant="body2">Less Important</Typography>} 
                                    />
                                    <FormControlLabel 
                                        value="important" 
                                        control={<Radio size="small" />} 
                                        label={<Typography variant="body2">Important</Typography>} 
                                    />
                                    <FormControlLabel 
                                        value="very important" 
                                        control={<Radio size="small" />} 
                                        label={<Typography variant="body2">Very Important</Typography>} 
                                    />
                                </RadioGroup>
                            </FormControl>

                                <TextField
                                    label="Due Date"
                                    type="date"
                                    value={data.due_date}
                                    onChange={(e) => setData('due_date', e.target.value)}
                                    InputLabelProps={{ shrink: true }}
                                    sx={{ minWidth: 150 }}
                                />
                            </Box>

                            <Box sx={{ display: 'flex', gap: 2, mt: 2 }}>
                                <Button 
                                    variant="contained" 
                                    type="submit" 
                                    disabled={processing}
                                    sx={{
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
                                    {processing ? 'Creating...' : 'Create Task'}
                                </Button>
                                <Button 
                                    variant="outlined" 
                                    onClick={() => router.visit(route('tasks.index'))}
                                    sx={{
                                        borderRadius: 2,
                                        textTransform: 'none',
                                    }}
                                >
                                    Cancel
                                </Button>
                            </Box>
                        </Box>
                    </form>
                </Paper>
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