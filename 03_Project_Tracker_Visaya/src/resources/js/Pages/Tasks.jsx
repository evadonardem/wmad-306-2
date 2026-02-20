import { useToast } from '@/Components/ToastProvider';
import {
  Box,
  Button,
  Card,
  CardContent,
  Chip,
  Divider,
  FormControl,
  InputLabel,
  MenuItem,
  Select,
  Stack,
  TextField,
  Typography
} from '@mui/material';
import axios from 'axios';
import { useEffect, useState } from 'react';

export default function Tasks() {
  const [projects, setProjects] = useState([]);
  const [tasks, setTasks] = useState([]);
  const [projectId, setProjectId] = useState(null);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [priority, setPriority] = useState('medium');
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
      const [pr, ts] = await Promise.all([
        axios.get('/projects'),
        axios.get('/tasks')
      ]);

      setProjects(pr.data.data || []);

      const list = ts.data.data || [];
      // ✅ FIX (UI-only): newest tasks appear on top
      setTasks([...list].reverse());

      if (!projectId && (pr.data.data || []).length)
        setProjectId((pr.data.data || [])[0].id);
    } catch (err) {
      setError('Failed to load data');
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

    const data = {
      project_id: projectId,
      title,
      description,
      priority,
      status: 'todo'
    };

    try {
      if (editingId) {
        const res = await axios.put(`/tasks/${editingId}`, data);
        showToast(res.data.message || 'Task updated', 'success');
      } else {
        const res = await axios.post('/tasks', data);
        showToast(res.data.message || 'Task created', 'success');
      }

      setTitle('');
      setDescription('');
      setPriority('medium');
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

  const edit = (t) => {
    setEditingId(t.id);
    setTitle(t.title || '');
    setDescription(t.description || '');
    setPriority(t.priority || 'medium');
  };

  // ✅ UI-only: cancel edit (does NOT affect backend)
  const cancelEdit = () => {
    setEditingId(null);
    setTitle('');
    setDescription('');
    setPriority('medium');
  };

  const remove = async (t) => {
    if (!confirm('Delete task?')) return;
    setLoading(true);
    setError(null);
    try {
      const res = await axios.delete(`/tasks/${t.id}`);
      showToast(res.data.message || 'Task deleted', 'success');
      await load();
    } catch (err) {
      setError('Delete failed');
      showToast('Delete failed', 'error');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleStatus = async (t) => {
    setLoading(true);
    setError(null);
    try {
      const res = await axios.post(`/tasks/${t.id}/toggle-status`);
      showToast(res.data.message || 'Status updated', 'success');
      await load();
    } catch (err) {
      setError('Toggle failed');
      showToast('Toggle failed', 'error');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const visibleTasks = tasks.filter((t) => t.project_id === projectId);

  const getPriorityColor = (priority) => {
    if (priority === 'high') return 'error';
    if (priority === 'medium') return 'warning';
    return 'success';
  };

  const getStatusColor = (status) => {
    if (status === 'done') return 'success';
    return 'default';
  };

  return (
    <Box
      sx={{
        p: 3,
        backgroundColor: '#f5f7fa',
        minHeight: '100vh'
      }}
    >
      {/* Header (same style as Projects.jsx) */}
      <Stack
        direction="row"
        justifyContent="space-between"
        alignItems="center"
        sx={{ mb: 3 }}
      >
        <Typography variant="h6" fontWeight={600}>
          Tasks
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

      {/* Project Selector (compact) */}
      <Card sx={{ mb: 3, borderRadius: 2 }}>
        <CardContent sx={{ p: 2 }}>
          <Typography variant="body2" fontWeight={600} sx={{ mb: 1 }}>
            Select Project
          </Typography>
          <Divider sx={{ mb: 2 }} />

          <FormControl fullWidth size="small">
            <InputLabel>Project</InputLabel>
            <Select
              value={projectId || ''}
              label="Project"
              onChange={(e) => setProjectId(e.target.value)}
              disabled={loading}
            >
              {projects.map((p) => (
                <MenuItem key={p.id} value={p.id}>
                  {p.title}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </CardContent>
      </Card>

      {/* New/Edit Task (compact + minimal like Projects.jsx) */}
      <Card sx={{ mb: 3, borderRadius: 2 }}>
        <CardContent sx={{ p: 2 }}>
          <Typography variant="body2" fontWeight={600} sx={{ mb: 1 }}>
            {editingId ? 'Edit Task' : 'New Task'}
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
                disabled={loading || !projectId}
                fullWidth
              />

              <TextField
                size="small"
                label="Description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                disabled={loading || !projectId}
                fullWidth
              />

              <Stack direction="row" spacing={1.5} alignItems="center">
                <FormControl size="small" sx={{ minWidth: 160 }} disabled={loading || !projectId}>
                  <InputLabel>Priority</InputLabel>
                  <Select
                    value={priority}
                    label="Priority"
                    onChange={(e) => setPriority(e.target.value)}
                  >
                    <MenuItem value="low">Low</MenuItem>
                    <MenuItem value="medium">Medium</MenuItem>
                    <MenuItem value="high">High</MenuItem>
                  </Select>
                </FormControl>

                <Stack direction="row" spacing={1}>
                  <Button
                    type="submit"
                    size="small"
                    variant="contained"
                    // ✅ UI-only: prevent submit if no project selected
                    disabled={loading || !projectId}
                    sx={{ textTransform: 'none' }}
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
            </Stack>
          </Box>
        </CardContent>
      </Card>

      {loading && (
        <Typography variant="body2" sx={{ mb: 2 }}>
          Loading…
        </Typography>
      )}

      {/* Empty state (simple) */}
      {!loading && projectId && visibleTasks.length === 0 && (
        <Card
          sx={{
            borderRadius: 2,
            textAlign: 'center',
            p: 3,
            backgroundColor: '#ffffff',
            mb: 2
          }}
        >
          <Typography variant="body2" color="text.secondary">
            No tasks yet.
          </Typography>
          <Typography variant="caption" color="text.secondary">
            Create your first task above.
          </Typography>
        </Card>
      )}

      {/* Task list (clean + minimal) */}
      <Stack spacing={1.5}>
        {visibleTasks.map((t) => (
          <Card
            key={t.id}
            sx={{
              borderRadius: 2,
              '&:hover': { boxShadow: 3 }
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
                    {t.title}
                  </Typography>

                  {t.description && (
                    <Typography variant="body2" color="text.secondary" sx={{ mt: 0.25 }}>
                      {t.description}
                    </Typography>
                  )}

                  <Stack direction="row" spacing={1} sx={{ mt: 1 }}>
                    <Chip
                      size="small"
                      label={t.priority}
                      color={getPriorityColor(t.priority)}
                      variant="outlined"
                    />
                    <Chip
                      size="small"
                      label={t.status}
                      color={getStatusColor(t.status)}
                    />
                  </Stack>
                </Box>

                <Stack direction="row" spacing={1}>
                  <Button
                    size="small"
                    variant="text"
                    onClick={() => edit(t)}
                    disabled={loading}
                    sx={{ textTransform: 'none' }}
                  >
                    Edit
                  </Button>

                  <Button
                    size="small"
                    variant="outlined"
                    onClick={() => toggleStatus(t)}
                    disabled={loading}
                    sx={{ textTransform: 'none', borderRadius: 2 }}
                  >
                    Toggle
                  </Button>

                  <Button
                    size="small"
                    variant="text"
                    onClick={() => remove(t)}
                    disabled={loading}
                    sx={{
                      textTransform: 'none',
                      color: '#d32f2f',
                      '&:hover': { backgroundColor: 'rgba(211,47,47,0.08)' }
                    }}
                  >
                    Delete
                  </Button>
                </Stack>
              </Stack>
            </CardContent>
          </Card>
        ))}
      </Stack>
    </Box>
  );
}
