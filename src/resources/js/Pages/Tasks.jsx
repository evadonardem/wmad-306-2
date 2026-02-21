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

  const goBack = () => {
    if (window.history.length > 1) window.history.back();
    else window.location.href = '/dashboard';
  };

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [pr, ts] = await Promise.all([axios.get('/projects'), axios.get('/tasks')]);

      setProjects(pr.data.data || []);

      const list = ts.data.data || [];
      setTasks([...list].reverse());

      if (!projectId && (pr.data.data || []).length) setProjectId((pr.data.data || [])[0].id);
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

  // ===== Design-only styles (match Register/Login + Projects dark glass theme) =====
  const pageBg = {
    minHeight: '100vh',
    py: { xs: 3, sm: 4 },
    px: { xs: 2, sm: 3 },
    background:
      'radial-gradient(900px 520px at 20% 10%, rgba(255,255,255,0.08), transparent 60%), #141821',
  };

  const glassCard = {
    borderRadius: 4,
    border: '1px solid rgba(255,255,255,0.10)',
    backgroundColor: 'rgba(255,255,255,0.06)',
    backdropFilter: 'blur(12px)',
    WebkitBackdropFilter: 'blur(12px)',
  };

  const hoverGlassCard = {
    ...glassCard,
    transition: 'background-color 160ms ease, box-shadow 160ms ease, transform 160ms ease',
    '&:hover': {
      backgroundColor: 'rgba(255,255,255,0.075)',
      boxShadow: '0 12px 30px rgba(0,0,0,0.25)',
      transform: 'translateY(-2px)',
    },
  };

  // ✅ Header typography (same style)
  const hTitleSx = {
    fontSize: 18,
    fontWeight: 900,
    color: 'rgba(255,255,255,0.92)',
    lineHeight: 1.15,
  };

  const hSubSx = {
    fontSize: 13,
    color: 'rgba(255,255,255,0.60)',
    mt: 0.25,
  };

  // ✅ IMPORTANT: make section titles same as Projects ("New Project" style)
  // (not uppercase, not too small)
  const sectionTitleSx = {
    fontSize: 13,
    fontWeight: 900,
    color: 'rgba(255,255,255,0.92)',
  };

  const subtleBtnSx = {
    textTransform: 'none',
    borderRadius: 2,
    fontWeight: 800,
    fontSize: 12.5,
    color: 'rgba(255,255,255,0.70)',
    '&:hover': { backgroundColor: 'rgba(255,255,255,0.08)' },
  };

  const primaryBtnSx = {
    textTransform: 'none',
    fontWeight: 900,
    fontSize: 12.5,
    borderRadius: 2.5,
    py: 1.0,
    px: 2,
    color: '#0b1220',
    backgroundColor: 'rgba(255,255,255,0.92)',
    boxShadow: 'none',
    '&:hover': {
      backgroundColor: 'rgba(255,255,255,0.98)',
      boxShadow: 'none',
    },
  };

  const pillBtnSx = {
    ...subtleBtnSx,
    borderRadius: 999,
    px: 1.4,
    backgroundColor: 'rgba(255,255,255,0.06)',
    border: '1px solid rgba(255,255,255,0.10)',
    '&:hover': { backgroundColor: 'rgba(255,255,255,0.10)' },
  };

  const fieldSx = (hasError) => ({
    '& .MuiInputLabel-root': {
      color: 'rgba(255,255,255,0.60)',
      fontSize: 12.5,
    },
    '& .MuiInputLabel-root.Mui-focused': {
      color: 'rgba(255,255,255,0.75)',
    },

    '& .MuiFilledInput-root': {
      borderRadius: 2,
      backgroundColor: 'rgba(255,255,255,0.07)',
      color: 'rgba(255,255,255,0.92)',
      border: hasError
        ? '1px solid rgba(255, 107, 107, 0.70)'
        : '1px solid rgba(255,255,255,0.10)',
      transition: '0.15s ease',
      overflow: 'hidden',
    },
    '& .MuiFilledInput-root:hover': {
      backgroundColor: 'rgba(255,255,255,0.09)',
      borderColor: hasError
        ? 'rgba(255, 107, 107, 0.85)'
        : 'rgba(255,255,255,0.16)',
    },
    '& .MuiFilledInput-root.Mui-focused': {
      backgroundColor: 'rgba(255,255,255,0.09)',
      borderColor: hasError
        ? 'rgba(255, 107, 107, 0.95)'
        : 'rgba(255,255,255,0.22)',
      boxShadow: 'none',
      outline: 'none',
    },

    '& .MuiFormHelperText-root': {
      color: hasError ? '#ff6b6b' : 'rgba(255,255,255,0.40)',
      marginLeft: 0,
      fontSize: 12,
    },
  });

  // ✅ FIX: dropdown menu must be DARK with WHITE text (Project + Priority)
  const menuPaperSx = {
    mt: 0.75,
    borderRadius: 2,
    backgroundColor: 'rgba(18, 22, 30, 0.98)',
    color: 'rgba(255,255,255,0.92)',
    border: '1px solid rgba(255,255,255,0.10)',
    backdropFilter: 'blur(10px)',
    WebkitBackdropFilter: 'blur(10px)',
    boxShadow: '0 18px 40px rgba(0,0,0,0.45)',
    '& .MuiList-root': { py: 0.5 },
  };

  const menuItemSx = {
    fontSize: 13,
    color: 'rgba(255,255,255,0.88)',
    borderRadius: 1.5,
    mx: 0.5,
    my: 0.25,
    '&:hover': { backgroundColor: 'rgba(255,255,255,0.08)' },
    '&.Mui-selected': {
      backgroundColor: 'rgba(255,255,255,0.10)',
      color: 'rgba(255,255,255,0.96)',
    },
    '&.Mui-selected:hover': { backgroundColor: 'rgba(255,255,255,0.12)' },
  };

  // ✅ IMPORTANT FIX: remove BLUE label + remove black selected text
  const selectSx = (hasError) => ({
    '& .MuiFilledInput-root': {
      borderRadius: 2,
      backgroundColor: 'rgba(255,255,255,0.07)',
      border: hasError
        ? '1px solid rgba(255, 107, 107, 0.70)'
        : '1px solid rgba(255,255,255,0.10)',
      transition: '0.15s ease',
      overflow: 'hidden',
    },
    '& .MuiFilledInput-root:hover': {
      backgroundColor: 'rgba(255,255,255,0.09)',
      borderColor: hasError
        ? 'rgba(255, 107, 107, 0.85)'
        : 'rgba(255,255,255,0.16)',
    },
    '& .MuiFilledInput-root.Mui-focused': {
      backgroundColor: 'rgba(255,255,255,0.09)',
      borderColor: hasError
        ? 'rgba(255, 107, 107, 0.95)'
        : 'rgba(255,255,255,0.22)',
      boxShadow: 'none',
      outline: 'none',
    },

    // ✅ selected value color
    '& .MuiSelect-select': { color: 'rgba(255,255,255,0.92)' },
    '& .MuiSelect-icon': { color: 'rgba(255,255,255,0.60)' },
  });

  // ✅ This is what removes the BLUE "Project" label when focused
  const formLabelFixSx = {
    '& .MuiInputLabel-root': { color: 'rgba(255,255,255,0.60)', fontSize: 12.5 },
    '& .MuiInputLabel-root.Mui-focused': { color: 'rgba(255,255,255,0.75)' },
  };

  const chipBaseSx = {
    height: 22,
    borderRadius: 999,
    fontWeight: 900,
    fontSize: 11,
    textTransform: 'capitalize',
    backgroundColor: 'rgba(255,255,255,0.06)',
    border: '1px solid rgba(255,255,255,0.10)',
    color: 'rgba(255,255,255,0.82)',
    '& .MuiChip-label': { px: 1.0 },
  };

  const taskTitleSx = {
    fontSize: 12.75,
    fontWeight: 900,
    color: 'rgba(255,255,255,0.92)',
    lineHeight: 1.25,
    wordBreak: 'break-word',
  };

  const taskDescSx = {
    mt: 0.35,
    fontSize: 12.5,
    color: 'rgba(255,255,255,0.62)',
    wordBreak: 'break-word',
  };

  return (
    <Box sx={pageBg}>
      {/* Header */}
      <Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ mb: 2.25 }}>
        <Box>
          <Typography sx={hTitleSx}>Tasks</Typography>
          <Typography sx={hSubSx}>Create and manage your tasks.</Typography>
        </Box>

        <Button size="small" variant="text" onClick={goBack} disabled={loading} sx={subtleBtnSx}>
          Back
        </Button>
      </Stack>

      {/* Error */}
      {error && (
        <Card sx={{ ...glassCard, mb: 2 }}>
          <CardContent sx={{ p: 2 }}>
            <Typography sx={{ fontSize: 12.5, fontWeight: 800, color: '#ff6b6b' }}>
              {error}
            </Typography>
          </CardContent>
        </Card>
      )}

      {/* Project Selector */}
      <Card sx={{ ...glassCard, mb: 2.25 }}>
        <CardContent sx={{ p: { xs: 2.25, sm: 2.5 } }}>
          <Stack spacing={1.1}>
            <Typography sx={sectionTitleSx}>Select Project</Typography>
            <Divider sx={{ borderColor: 'rgba(255,255,255,0.10)' }} />

            <FormControl
              fullWidth
              size="small"
              variant="filled"
              disabled={loading}
              sx={formLabelFixSx}
            >
              <InputLabel>Project</InputLabel>
              <Select
                value={projectId || ''}
                label="Project"
                onChange={(e) => setProjectId(e.target.value)}
                disableUnderline
                sx={selectSx(false)}
                MenuProps={{ PaperProps: { sx: menuPaperSx } }}
              >
                {projects.map((p) => (
                  <MenuItem key={p.id} value={p.id} sx={menuItemSx}>
                    {p.title}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Stack>
        </CardContent>
      </Card>

      {/* New/Edit Task */}
      <Card sx={{ ...glassCard, mb: 2.25 }}>
        <CardContent sx={{ p: { xs: 2.25, sm: 2.5 } }}>
          <Stack spacing={1.35}>
            <Stack direction="row" justifyContent="space-between" alignItems="center">
              <Typography sx={sectionTitleSx}>{editingId ? 'Edit Task' : 'New Task'}</Typography>

              {editingId && (
                <Typography sx={{ fontSize: 12, color: 'rgba(255,255,255,0.55)' }}>
                  Editing mode
                </Typography>
              )}
            </Stack>

            <Divider sx={{ borderColor: 'rgba(255,255,255,0.10)' }} />

            <Box component="form" onSubmit={submit} noValidate>
              <Stack spacing={1.35}>
                <TextField
                  size="small"
                  label="Title"
                  variant="filled"
                  InputProps={{ disableUnderline: true }}
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                  disabled={loading || !projectId}
                  fullWidth
                  sx={fieldSx(false)}
                />

                <TextField
                  size="small"
                  label="Description"
                  variant="filled"
                  InputProps={{ disableUnderline: true }}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  disabled={loading || !projectId}
                  fullWidth
                  sx={fieldSx(false)}
                />

                <Stack
                  direction={{ xs: 'column', sm: 'row' }}
                  spacing={1.1}
                  alignItems={{ xs: 'stretch', sm: 'center' }}
                >
                  <FormControl
                    size="small"
                    variant="filled"
                    disabled={loading || !projectId}
                    sx={{ minWidth: { sm: 180 }, ...formLabelFixSx }}
                  >
                    <InputLabel>Priority</InputLabel>
                    <Select
                      value={priority}
                      label="Priority"
                      onChange={(e) => setPriority(e.target.value)}
                      disableUnderline
                      sx={selectSx(false)}
                      MenuProps={{ PaperProps: { sx: menuPaperSx } }}
                    >
                      <MenuItem value="low" sx={menuItemSx}>Low</MenuItem>
                      <MenuItem value="medium" sx={menuItemSx}>Medium</MenuItem>
                      <MenuItem value="high" sx={menuItemSx}>High</MenuItem>
                    </Select>
                  </FormControl>

                  <Stack direction="row" spacing={1} sx={{ flexShrink: 0 }}>
                    <Button type="submit" size="small" disabled={loading || !projectId} sx={primaryBtnSx}>
                      {editingId ? 'Update' : 'Create'}
                    </Button>

                    {editingId && (
                      <Button
                        type="button"
                        size="small"
                        variant="text"
                        onClick={cancelEdit}
                        disabled={loading}
                        sx={subtleBtnSx}
                      >
                        Cancel
                      </Button>
                    )}
                  </Stack>
                </Stack>

                {loading && (
                  <Typography sx={{ fontSize: 12, color: 'rgba(255,255,255,0.55)' }}>
                    Loading…
                  </Typography>
                )}
              </Stack>
            </Box>
          </Stack>
        </CardContent>
      </Card>

      {/* Empty state */}
      {!loading && projectId && visibleTasks.length === 0 && (
        <Card sx={{ ...glassCard, textAlign: 'center', mb: 2 }}>
          <CardContent sx={{ p: 3 }}>
            <Typography sx={{ fontSize: 12.75, fontWeight: 900, color: 'rgba(255,255,255,0.80)' }}>
              No tasks yet.
            </Typography>
            <Typography sx={{ mt: 0.5, fontSize: 12, color: 'rgba(255,255,255,0.55)' }}>
              Create your first task above.
            </Typography>
          </CardContent>
        </Card>
      )}

      {/* Task list */}
      <Stack spacing={1.25}>
        {visibleTasks.map((t) => (
          <Card key={t.id} sx={{ ...hoverGlassCard }}>
            <CardContent sx={{ p: { xs: 2.0, sm: 2.25 } }}>
              <Stack
                direction={{ xs: 'column', sm: 'row' }}
                justifyContent="space-between"
                alignItems={{ xs: 'flex-start', sm: 'center' }}
                spacing={1.5}
              >
                <Box sx={{ minWidth: 0 }}>
                  <Typography sx={taskTitleSx}>{t.title}</Typography>

                  {t.description && <Typography sx={taskDescSx}>{t.description}</Typography>}

                  <Stack direction="row" spacing={1} sx={{ mt: 1 }}>
                    <Chip
                      size="small"
                      label={t.priority}
                      color={getPriorityColor(t.priority)}
                      variant="outlined"
                      sx={chipBaseSx}
                    />
                    <Chip
                      size="small"
                      label={t.status}
                      color={getStatusColor(t.status)}
                      sx={chipBaseSx}
                    />
                  </Stack>
                </Box>

                <Stack direction="row" spacing={1} sx={{ flexShrink: 0 }}>
                  <Button size="small" variant="text" onClick={() => edit(t)} disabled={loading} sx={subtleBtnSx}>
                    Edit
                  </Button>

                  <Button size="small" variant="text" onClick={() => toggleStatus(t)} disabled={loading} sx={pillBtnSx}>
                    Toggle
                  </Button>

                  <Button
                    size="small"
                    variant="text"
                    onClick={() => remove(t)}
                    disabled={loading}
                    sx={{
                      ...subtleBtnSx,
                      color: '#ff6b6b',
                      '&:hover': { backgroundColor: 'rgba(255, 107, 107, 0.12)' },
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