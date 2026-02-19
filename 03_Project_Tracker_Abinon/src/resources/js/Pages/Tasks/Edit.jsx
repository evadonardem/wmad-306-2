import React, { useState, useEffect } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router } from '@inertiajs/react';
import {
  Container, Typography, Card, CardContent, CardActions,
  Button, TextField, Box, Alert, FormControl, InputLabel, Select, MenuItem
} from '@mui/material';

export default function Edit({ auth, task, projects }) {
  const [values, setValues] = useState({
    title: '',
    description: '',
    project_id: '',
    priority: 'Medium',
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  // Sync form values when task prop changes
  useEffect(() => {
    if (task) {
      setValues({
        title: task.title || '',
        description: task.description || '',
        project_id: task.project_id || '',
        priority: task.priority || 'Medium',
      });
    }
  }, [task]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setValues(prev => ({ ...prev, [name]: value }));
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    setLoading(true);

    router.put(route('tasks.update', task.id), values, {
      onError: (errors) => {
        setErrors(errors);
        setLoading(false);
      },
      onSuccess: () => {
        setLoading(false);
      },
    });
  };

  const handleCancel = () => {
    router.get(route('tasks.index'));
  };

  return (
    <AuthenticatedLayout user={auth.user}>
      <Head title="Edit Task" />

      <Container maxWidth="sm" sx={{ py: 8 }}>
        <Card sx={{ borderRadius: 3, boxShadow: '0 4px 20px rgba(0, 0, 0, 0.08)' }}>
          <CardContent sx={{ p: 4 }}>
            <Typography variant="h5" fontWeight="700" gutterBottom sx={{ mb: 3 }}>
              Edit Task
            </Typography>

            <Box component="form" onSubmit={handleSubmit}>
              {Object.keys(errors).length > 0 && (
                <Alert severity="error" sx={{ mb: 2 }}>
                  Please fix the errors below
                </Alert>
              )}

              <FormControl fullWidth sx={{ mb: 3 }} error={!!errors.project_id}>
                <InputLabel>Project</InputLabel>
                <Select
                  name="project_id"
                  value={values.project_id}
                  onChange={handleChange}
                  label="Project"
                  required
                >
                  <MenuItem value="">
                    <em>Select a project</em>
                  </MenuItem>
                  {projects.map((project) => (
                    <MenuItem key={project.id} value={project.id}>
                      {project.title}
                    </MenuItem>
                  ))}
                </Select>
                {errors.project_id && (
                  <Typography variant="caption" color="error" sx={{ mt: 0.5, display: 'block' }}>
                    {errors.project_id}
                  </Typography>
                )}
              </FormControl>

              <TextField
                label="Task Title"
                name="title"
                value={values.title}
                onChange={handleChange}
                fullWidth
                required
                error={!!errors.title}
                helperText={errors.title}
                placeholder="Enter task title"
                sx={{ mb: 3 }}
              />

              <TextField
                label="Description"
                name="description"
                value={values.description}
                onChange={handleChange}
                fullWidth
                multiline
                rows={4}
                error={!!errors.description}
                helperText={errors.description}
                placeholder="Enter task description"
                sx={{ mb: 3 }}
              />

              <FormControl fullWidth sx={{ mb: 3 }} error={!!errors.priority}>
                <InputLabel>Priority</InputLabel>
                <Select
                  name="priority"
                  value={values.priority}
                  onChange={handleChange}
                  label="Priority"
                >
                  <MenuItem value="Low">Low</MenuItem>
                  <MenuItem value="Medium">Medium</MenuItem>
                  <MenuItem value="High">High</MenuItem>
                </Select>
                {errors.priority && (
                  <Typography variant="caption" color="error" sx={{ mt: 0.5, display: 'block' }}>
                    {errors.priority}
                  </Typography>
                )}
              </FormControl>

              <CardActions sx={{ justifyContent: 'flex-end', p: 0 }}>
                <Button 
                  variant="outlined" 
                  onClick={handleCancel}
                  disabled={loading}
                >
                  Cancel
                </Button>
                <Button 
                  type="submit" 
                  variant="contained" 
                  color="success"
                  disabled={loading}
                  sx={{ ml: 1 }}
                >
                  {loading ? 'Updating...' : 'Update Task'}
                </Button>
              </CardActions>
            </Box>
          </CardContent>
        </Card>
      </Container>
    </AuthenticatedLayout>
  );
}