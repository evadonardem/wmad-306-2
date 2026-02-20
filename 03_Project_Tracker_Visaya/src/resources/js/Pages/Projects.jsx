import { useToast } from '@/Components/ToastProvider';
import {
  Box,
  Button,
  Card,
  CardContent,
  Divider,
  Fade,
  Stack,
  TextField,
  Typography
} from '@mui/material';
import axios from 'axios';
import { useEffect, useState } from 'react';

export default function Projects() {
  const [projects, setProjects] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const { showToast } = useToast();

  // ✅ UI-only: safer back behavior (no backend impact)
  const goBack = () => {
    if (window.history.length > 1) window.history.back();
    else window.location.href = '/dashboard';
  };

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await axios.get('/projects');
      const list = res.data.data || [];

      // ✅ FIX: show newest projects on top (UI-only change)
      setProjects([...list].reverse());
    } catch (err) {
      setError('Failed to load projects');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const submit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const data = { title, description };

    try {
      if (editingId) {
        const res = await axios.put(`/projects/${editingId}`, data);
        showToast(res.data.message || 'Project updated', 'success');
      } else {
        const res = await axios.post('/projects', data);
        showToast(res.data.message || 'Project created', 'success');
      }

      setTitle('');
      setDescription('');
      setEditingId(null);
      await load();
    } catch (err) {
      const msg = err.response?.data?.message || 'Save failed';
      setError(msg);
      showToast(msg, 'error');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const edit = (p) => {
    setEditingId(p.id);
    setTitle(p.title || '');
    setDescription(p.description || '');
  };

  // ✅ UI-only: cancel edit (does NOT affect backend)
  const cancelEdit = () => {
    setEditingId(null);
    setTitle('');
    setDescription('');
  };

  const remove = async (p) => {
    if (!confirm('Delete project?')) return;
    setLoading(true);
    setError(null);
    try {
      const res = await axios.delete(`/projects/${p.id}`);
      showToast(res.data.message || 'Project deleted', 'success');
      await load();
    } catch (err) {
      setError('Delete failed');
      showToast('Delete failed', 'error');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        p: 3,
        backgroundColor: '#f5f7fa',
        minHeight: '100vh'
      }}
    >
      {/* Dashboard Header */}
      <Stack
        direction="row"
        justifyContent="space-between"
        alignItems="center"
        sx={{ mb: 3 }}
      >
        <Typography variant="h6" fontWeight={600}>
          Projects
        </Typography>

        <Button
          size="small"
          variant="text"
          onClick={goBack}
          sx={{ textTransform: 'none' }}
        >
          Back
        </Button>
      </Stack>

      {error && (
        <Typography color="error" sx={{ mb: 2 }}>
          {error}
        </Typography>
      )}

      {/* Compact Form Card */}
      <Card sx={{ mb: 3, borderRadius: 2 }}>
        <CardContent sx={{ p: 2 }}>
          <Typography variant="body2" fontWeight={600} sx={{ mb: 1 }}>
            {editingId ? 'Edit Project' : 'New Project'}
          </Typography>

          <Divider sx={{ mb: 2 }} />

          <Box component="form" onSubmit={submit}>
            <Stack spacing={1.5}>
              <TextField
                size="small"
                label="Title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                required
                disabled={loading}
                fullWidth
              />

              <TextField
                size="small"
                label="Description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                disabled={loading}
                fullWidth
              />

              <Stack direction="row" spacing={1}>
                <Button
                  type="submit"
                  size="small"
                  variant="contained"
                  disabled={loading}
                  sx={{
                    alignSelf: 'flex-start',
                    textTransform: 'none'
                  }}
                >
                  {editingId ? 'Update' : 'Create'}
                </Button>

                {/* ✅ UI-only: Cancel button only while editing */}
                {editingId && (
                  <Button
                    type="button"
                    size="small"
                    variant="text"
                    onClick={cancelEdit}
                    disabled={loading}
                    sx={{ textTransform: 'none' }}
                  >
                    Cancel
                  </Button>
                )}
              </Stack>
            </Stack>
          </Box>
        </CardContent>
      </Card>

      {/* Loading */}
      {loading && (
        <Typography variant="body2" sx={{ mb: 2 }}>
          Loading…
        </Typography>
      )}

      {/* Empty State */}
      {!loading && projects.length === 0 && (
        <Card
          sx={{
            borderRadius: 2,
            textAlign: 'center',
            p: 3,
            backgroundColor: '#ffffff'
          }}
        >
          <Typography variant="body2" color="text.secondary">
            No projects yet.
          </Typography>
          <Typography variant="caption" color="text.secondary">
            Create your first project above.
          </Typography>
        </Card>
      )}

      {/* Project List with Soft Animation */}
      <Stack spacing={1.5}>
        {projects.map((p) => (
          <Fade in timeout={400} key={p.id}>
            <Card
              sx={{
                borderRadius: 2,
                '&:hover': {
                  boxShadow: 3
                }
              }}
            >
              {/* ✅ UI-only: consistent padding */}
              <CardContent sx={{ p: 2 }}>
                <Stack
                  direction="row"
                  justifyContent="space-between"
                  alignItems="center"
                >
                  <Box>
                    <Typography variant="subtitle2" fontWeight={600}>
                      {p.title}
                    </Typography>

                    {p.description && (
                      <Typography variant="body2" color="text.secondary">
                        {p.description}
                      </Typography>
                    )}
                  </Box>

                  <Stack direction="row" spacing={1}>
                    <Button
                      size="small"
                      variant="text"
                      onClick={() => edit(p)}
                      disabled={loading}
                      sx={{ textTransform: 'none' }}
                    >
                      Edit
                    </Button>

                    <Button
                      size="small"
                      variant="text"
                      color="error"
                      onClick={() => remove(p)}
                      disabled={loading}
                      sx={{ textTransform: 'none' }}
                    >
                      Delete
                    </Button>
                  </Stack>
                </Stack>
              </CardContent>
            </Card>
          </Fade>
        ))}
      </Stack>
    </Box>
  );
}
