import React, { useState } from 'react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router } from '@inertiajs/react';
import {
  Container, Typography, Button, Grid, Card, CardContent, CardActions,
  IconButton, Box, Dialog, DialogTitle, DialogContent, DialogActions,
  Chip, Stack
} from '@mui/material';
import { Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon, Folder as FolderIcon, Check as CheckIcon } from '@mui/icons-material';

const cardStyle = {
  borderRadius: '16px',
  backgroundColor: 'rgba(255, 255, 255, 0.8)',
  backdropFilter: 'blur(20px)',
  border: '1px solid rgba(255, 255, 255, 0.6)',
  boxShadow: '0 8px 32px rgba(0, 0, 0, 0.04)',
  width: '100%',
  display: 'flex',
  flexDirection: 'column',
  transition: 'all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)',
  '&:hover': {
    transform: 'translateY(-2px)',
    boxShadow: '0 12px 40px rgba(0, 0, 0, 0.08)',
    backdropFilter: 'blur(24px)',
  },
};

export default function Index({ auth, projects }) {
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedProjectId, setSelectedProjectId] = useState(null);
  const [selectedProjectTitle, setSelectedProjectTitle] = useState('');

  const openDeleteDialog = (id, title) => {
    setSelectedProjectId(id);
    setSelectedProjectTitle(title);
    setDeleteDialogOpen(true);
  };

  const closeDeleteDialog = () => {
    setSelectedProjectId(null);
    setSelectedProjectTitle('');
    setDeleteDialogOpen(false);
  };

  const handleDelete = () => {
    if (selectedProjectId) {
            router.delete(route('projects.destroy', selectedProjectId), {
        onSuccess: () => closeDeleteDialog(),
      });
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
            href="/projects/create"
            startIcon={<AddIcon />}
            sx={{
              borderRadius: '30px', textTransform: 'none', fontWeight: '700',
              backgroundColor: '#a855f7', px: 3, '&:hover': { backgroundColor: '#9333ea' }
            }}
          >
            New Project
          </Button>
        </Box>
      }
    >
      <Head title="Projects" />

      <Container maxWidth={false} sx={{ py: 8 }}>
        {projects.length > 0 ? (
          <Grid container spacing={3}>
            {projects.map((project) => (
              <Grid item xs={12} sm={6} md={4} lg={3} key={project.id}>
                <Card sx={cardStyle}>
                  <CardContent sx={{ p: 3, flexGrow: 1 }}>
                    <Box sx={{
                      width: 48, height: 48, borderRadius: '12px',
                      backgroundColor: 'rgba(0, 113, 227, 0.08)', display: 'flex',
                      alignItems: 'center', justifyContent: 'center', mb: 3
                    }}>
                      <FolderIcon sx={{ color: '#a855f7', fontSize: 28 }} />
                    </Box>
                    <Typography variant="h6" fontWeight="800" noWrap sx={{ mb: 1 }}>
                      {project.title}
                    </Typography>
                    <Typography variant="body2" color="text.secondary" sx={{
                      display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', 
                      overflow: 'hidden', mb: 2, minHeight: '60px'
                    }}>
                      {project.description || "No description provided."}
                    </Typography>
                    <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                      <Chip 
                        icon={<CheckIcon />}
                        label={`${project.tasks?.length || 0} tasks`}
                        size="small"
                        variant="outlined"
                      />
                    </Stack>
                  </CardContent>

                  <CardActions sx={{ justifyContent: 'flex-end', px: 3, pb: 3, borderTop: '1px solid rgba(0,0,0,0.05)', gap: 1 }}>
                    <IconButton 
                      component={Link} 
                      href={route('projects.edit', project.id)} 
                      size="small"
                      sx={{ color: '#a855f7', '&:hover': { backgroundColor: 'rgba(168, 85, 247, 0.08)' } }}
                    >
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton 
                      onClick={() => openDeleteDialog(project.id, project.title)} 
                      size="small" 
                      color="error"
                      sx={{ '&:hover': { backgroundColor: 'rgba(211, 47, 47, 0.08)' } }}
                    >
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </CardActions>
                </Card>
              </Grid>
            ))}
          </Grid>
        ) : (
          <Box sx={{ textAlign: 'center', py: 8 }}>
            <FolderIcon sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
            <Typography variant="h6" color="text.secondary" sx={{ mb: 2 }}>
              No projects yet
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
              Create your first project to get started
            </Typography>
            <Button
              variant="contained"
              component={Link}
              href={route('projects.create')}
              startIcon={<AddIcon />}
              sx={{
                borderRadius: '30px', textTransform: 'none', fontWeight: '700',
                backgroundColor: '#a855f7', px: 3
              }}
            >
              Create Project
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
          Delete Project
        </DialogTitle>
        <DialogContent sx={{ py: 2 }}>
          <Typography>
            Are you sure you want to delete <strong>"{selectedProjectTitle}"</strong>? This action cannot be undone.
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
