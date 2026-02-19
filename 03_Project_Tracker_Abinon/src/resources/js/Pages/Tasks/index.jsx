import React, { useState } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router, usePage } from '@inertiajs/react';
import {
  Container, Typography, Button, Grid, Card, CardContent, CardActions,
  IconButton, Box, Dialog, DialogTitle, DialogContent, DialogActions,
  Chip, Stack, Checkbox, FormControlLabel
} from '@mui/material';
import { Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon, CheckCircle as CheckCircleIcon, RadioButtonUnchecked as RadioButtonUncheckedIcon } from '@mui/icons-material';

const getPriorityColor = (priority) => {
  switch (priority?.toLowerCase()) {
    case 'high':
      return '#d32f2f';
    case 'medium':
      return '#f57c00';
    case 'low':
      return '#388e3c';
    default:
      return '#1976d2';
  }
};

const getStatusColor = (status) => {
  return status === 'done' ? '#388e3c' : '#f57c00';
};

const cardStyle = {
  borderRadius: '16px',
  backgroundColor: '#fff',
  border: '1px solid rgba(0, 0, 0, 0.08)',
  boxShadow: '0 4px 20px rgba(0, 0, 0, 0.04)',
  width: '100%',
  display: 'flex',
  flexDirection: 'column',
  transition: 'all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)',
  '&:hover': {
    boxShadow: '0 15px 35px rgba(0, 0, 0, 0.1)',
  },
};

export default function Index({ auth }) {
  const { tasks } = usePage().props;
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedTaskId, setSelectedTaskId] = useState(null);
  const [selectedTaskTitle, setSelectedTaskTitle] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');

  const openDeleteDialog = (id, title) => {
    setSelectedTaskId(id);
    setSelectedTaskTitle(title);
    setDeleteDialogOpen(true);
  };

  const closeDeleteDialog = () => {
    setSelectedTaskId(null);
    setSelectedTaskTitle('');
    setDeleteDialogOpen(false);
  };

  const handleDelete = () => {
    if (selectedTaskId) {
      router.delete(route('tasks.destroy', selectedTaskId), {
        onSuccess: () => closeDeleteDialog(),
      });
    }
  };

  const handleToggleStatus = (task) => {
      router.post(route('tasks.toggleStatus', task.id), {});
  };

  const filteredTasks = tasks.filter(task => {
    if (filterStatus === 'done') return task.status === 'done';
    if (filterStatus === 'pending') return task.status === 'pending';
    return true;
  });

  return (
    <AuthenticatedLayout
      user={auth.user}
      header={
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Typography variant="h5" fontWeight="800">Tasks</Typography>
          <Button
            variant="contained"
            component={Link}
            href={route('tasks.create')}
            startIcon={<AddIcon />}
            sx={{
              borderRadius: '30px', textTransform: 'none', fontWeight: '700',
              backgroundColor: '#a855f7', px: 3, '&:hover': { backgroundColor: '#9333ea' }
            }}
          >
            New Task
          </Button>
        </Box>
      }
    >
      <Head title="Tasks" />

      <Container maxWidth={false} sx={{ py: 8 }}>
        {tasks.length > 0 ? (
          <>
            <Stack direction="row" spacing={2} sx={{ mb: 4 }}>
              <Button
                variant={filterStatus === 'all' ? 'contained' : 'outlined'}
                onClick={() => setFilterStatus('all')}
                sx={{ borderRadius: 2 }}
              >
                All ({tasks.length})
              </Button>
              <Button
                variant={filterStatus === 'pending' ? 'contained' : 'outlined'}
                onClick={() => setFilterStatus('pending')}
                sx={{ borderRadius: 2 }}
              >
                Pending ({tasks.filter(t => t.status === 'pending').length})
              </Button>
              <Button
                variant={filterStatus === 'done' ? 'contained' : 'outlined'}
                onClick={() => setFilterStatus('done')}
                sx={{ borderRadius: 2 }}
              >
                Done ({tasks.filter(t => t.status === 'done').length})
              </Button>
            </Stack>

            <Grid container spacing={3}>
              {filteredTasks.map((task) => (
                <Grid item xs={12} sm={6} md={4} lg={3} key={task.id}>
                  <Card sx={{ ...cardStyle, opacity: task.status === 'done' ? 0.8 : 1 }}>
                    <CardContent sx={{ p: 3, flexGrow: 1 }}>
                      <Stack direction="row" spacing={1} sx={{ mb: 2, alignItems: 'flex-start' }}>
                        <Box sx={{ flexGrow: 1 }}>
                          <Stack direction="row" spacing={1} sx={{ alignItems: 'center', mb: 1 }}>
                            <Chip
                              label={task.project?.title || 'Unknown Project'}
                              size="small"
                              variant="outlined"
                              sx={{ backgroundColor: 'rgba(0, 113, 227, 0.08)' }}
                            />
                          </Stack>
                          <Typography 
                            variant="h6" 
                            fontWeight="700" 
                            sx={{ 
                              mb: 1, 
                              textDecoration: task.status === 'done' ? 'line-through' : 'none',
                              color: task.status === 'done' ? 'text.secondary' : 'text.primary'
                            }}
                          >
                            {task.title}
                          </Typography>
                        </Box>
                      </Stack>

                      <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                        {task.description || 'No description'}
                      </Typography>

                      <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                        <Chip
                          label={task.priority || 'Medium'}
                          size="small"
                          sx={{
                            backgroundColor: getPriorityColor(task.priority),
                            color: 'white',
                            fontWeight: 600
                          }}
                        />
                        <Chip
                          label={task.status === 'done' ? 'Done' : 'Pending'}
                          size="small"
                          sx={{
                            backgroundColor: getStatusColor(task.status),
                            color: 'white',
                            fontWeight: 600
                          }}
                        />
                      </Stack>
                    </CardContent>

                    <CardActions sx={{ justifyContent: 'space-between', px: 3, pb: 3, borderTop: '1px solid rgba(0,0,0,0.05)' }}>
                      <IconButton
                        onClick={() => handleToggleStatus(task)}
                        size="small"
                        sx={{ color: task.status === 'done' ? '#388e3c' : '#999' }}
                      >
                        {task.status === 'done' ? (
                          <CheckCircleIcon fontSize="small" />
                        ) : (
                          <RadioButtonUncheckedIcon fontSize="small" />
                        )}
                      </IconButton>
                      <Box>
                        <IconButton
                          component={Link}
                          href={route('tasks.edit', task.id)}
                          size="small"
                          sx={{ color: '#a855f7' }}
                        >
                          <EditIcon fontSize="small" />
                        </IconButton>
                        <IconButton
                          onClick={() => openDeleteDialog(task.id, task.title)}
                          size="small"
                          color="error"
                        >
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      </Box>
                    </CardActions>
                  </Card>
                </Grid>
              ))}
            </Grid>
          </>
        ) : (
          <Box sx={{ textAlign: 'center', py: 8 }}>
            <CheckCircleIcon sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
            <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
              No tasks yet
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
              Create your first task to track your work
            </Typography>
            <Button
              variant="contained"
              component={Link}
              href={route('tasks.create')}
              startIcon={<AddIcon />}
              sx={{
                borderRadius: '30px', textTransform: 'none', fontWeight: '700',
                backgroundColor: '#a855f7', px: 3
              }}
            >
              Create Task
            </Button>
          </Box>
        )}
      </Container>

      <Dialog
        open={deleteDialogOpen}
        onClose={closeDeleteDialog}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle sx={{ fontWeight: 700 }}>
          Delete Task
        </DialogTitle>
        <DialogContent sx={{ py: 2 }}>
          <Typography>
            Are you sure you want to delete <strong>"{selectedTaskTitle}"</strong>? This action cannot be undone.
          </Typography>
        </DialogContent>
        <DialogActions sx={{ p: 2 }}>
          <Button variant="outlined" onClick={closeDeleteDialog}>
            Cancel
          </Button>
          <Button variant="contained" color="error" onClick={handleDelete}>
            Delete
          </Button>
        </DialogActions>
      </Dialog>
    </AuthenticatedLayout>
  );
}
