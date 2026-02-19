import React, { useState } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router } from '@inertiajs/react';
import {
  Container, Typography, Card, CardContent, CardActions,
  Button, TextField, Box, Alert
} from '@mui/material';

export default function Create({ auth }) {
  const [values, setValues] = useState({
    title: '',
    description: '',
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

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

    router.post(route('projects.store'), values, {
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
    router.get(route('projects.index'));
  };

  return (
    <AuthenticatedLayout user={auth.user}>
      <Head title="Create Project" />

      <Container maxWidth="sm" sx={{ py: 8 }}>
        <Card sx={{ borderRadius: 3, boxShadow: '0 4px 20px rgba(0, 0, 0, 0.08)' }}>
          <CardContent sx={{ p: 4 }}>
            <Typography variant="h5" fontWeight="700" gutterBottom sx={{ mb: 3 }}>
              Create New Project
            </Typography>

            <Box component="form" onSubmit={handleSubmit}>
              {Object.keys(errors).length > 0 && (
                <Alert severity="error" sx={{ mb: 2 }}>
                  Please fix the errors below
                </Alert>
              )}

              <TextField
                label="Project Title"
                name="title"
                value={values.title}
                onChange={handleChange}
                fullWidth
                required
                error={!!errors.title}
                helperText={errors.title}
                placeholder="Enter project title"
                sx={{ mb: 3 }}
              />

              <TextField
                label="Description"
                name="description"
                value={values.description}
                onChange={handleChange}
                fullWidth
                multiline
                rows={5}
                error={!!errors.description}
                helperText={errors.description}
                placeholder="Enter project description (optional)"
                sx={{ mb: 3 }}
              />

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
                  color="primary"
                  disabled={loading}
                  sx={{ ml: 1 }}
                >
                  {loading ? 'Creating...' : 'Create Project'}
                </Button>
              </CardActions>
            </Box>
          </CardContent>
        </Card>
      </Container>
    </AuthenticatedLayout>
  );
}
