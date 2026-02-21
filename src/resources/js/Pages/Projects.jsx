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

  // ===== Design-only styles (match Register/Login dark glass theme) =====
  const pageBg = {
    minHeight: '100vh',
    py: { xs: 3, sm: 4 },
    px: { xs: 2, sm: 3 }, // ✅ stretched page with padding like before
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

  const subtleBtnSx = {
    textTransform: 'none',
    borderRadius: 2,
    fontWeight: 800,
    color: 'rgba(255,255,255,0.70)',
    '&:hover': { backgroundColor: 'rgba(255,255,255,0.08)' },
  };

  const primaryBtnSx = {
    textTransform: 'none',
    fontWeight: 900,
    borderRadius: 2.5,
    py: 1.05,
    px: 2,
    color: '#0b1220',
    backgroundColor: 'rgba(255,255,255,0.92)',
    boxShadow: 'none',
    '&:hover': {
      backgroundColor: 'rgba(255,255,255,0.98)',
      boxShadow: 'none',
    },
  };

  // ✅ same input style as Register/Login (no blue outline)
  const fieldSx = (hasError) => ({
    '& .MuiInputLabel-root': {
      color: 'rgba(255,255,255,0.60)',
      fontSize: 13,
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

    // Chrome autofill fix (same as Register/Login)
    '& input:-webkit-autofill': {
      WebkitBoxShadow: '0 0 0 1000px rgba(255,255,255,0.07) inset',
      WebkitTextFillColor: 'rgba(255,255,255,0.92)',
      caretColor: 'rgba(255,255,255,0.92)',
      borderRadius: 8,
      transition: 'background-color 9999s ease-out 0s',
    },
    '& input:-webkit-autofill:hover': {
      WebkitBoxShadow: '0 0 0 1000px rgba(255,255,255,0.09) inset',
      WebkitTextFillColor: 'rgba(255,255,255,0.92)',
    },
    '& input:-webkit-autofill:focus': {
      WebkitBoxShadow: '0 0 0 1000px rgba(255,255,255,0.09) inset',
      WebkitTextFillColor: 'rgba(255,255,255,0.92)',
    },

    '& .MuiFormHelperText-root': {
      color: hasError ? '#ff6b6b' : 'rgba(255,255,255,0.40)',
      marginLeft: 0,
      fontSize: 12,
    },
  });

  return (
    <Box sx={pageBg}>
      {/* ✅ Full width (stretched). No shell / maxWidth. */}

      {/* Header */}
      <Stack
        direction="row"
        justifyContent="space-between"
        alignItems="center"
        sx={{ mb: 2.25 }}
      >
        <Box>
          <Typography sx={{ fontSize: 18, fontWeight: 900, color: 'rgba(255,255,255,0.92)' }}>
            Projects
          </Typography>
          <Typography sx={{ fontSize: 13, color: 'rgba(255,255,255,0.60)', mt: 0.25 }}>
            Create and manage your projects.
          </Typography>
        </Box>

        <Button size="small" variant="text" onClick={goBack} disabled={loading} sx={subtleBtnSx}>
          Back
        </Button>
      </Stack>

      {/* Error */}
      {error && (
        <Card sx={{ ...glassCard, mb: 2 }}>
          <CardContent sx={{ p: 2 }}>
            <Typography sx={{ fontSize: 13, fontWeight: 800, color: '#ff6b6b' }}>
              {error}
            </Typography>
          </CardContent>
        </Card>
      )}

      {/* Form Card */}
      <Card sx={{ ...glassCard, mb: 2.5 }}>
        <CardContent sx={{ p: { xs: 2.5, sm: 3 } }}>
          <Stack spacing={1.5}>
            <Stack direction="row" justifyContent="space-between" alignItems="center">
              <Typography sx={{ fontSize: 13, fontWeight: 900, color: 'rgba(255,255,255,0.92)' }}>
                {editingId ? 'Edit Project' : 'New Project'}
              </Typography>

              {editingId && (
                <Typography sx={{ fontSize: 12, color: 'rgba(255,255,255,0.55)' }}>
                  Editing mode
                </Typography>
              )}
            </Stack>

            <Divider sx={{ borderColor: 'rgba(255,255,255,0.10)' }} />

            <Box component="form" onSubmit={submit} noValidate>
              <Stack spacing={1.5}>
                <TextField
                  size="small"
                  label="Title"
                  variant="filled"
                  InputProps={{ disableUnderline: true }}
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                  disabled={loading}
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
                  disabled={loading}
                  fullWidth
                  sx={fieldSx(false)}
                />

                <Stack direction="row" spacing={1}>
                  <Button type="submit" size="small" disabled={loading} sx={primaryBtnSx}>
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

      {/* Empty State */}
      {!loading && projects.length === 0 && (
        <Card sx={{ ...glassCard, textAlign: 'center' }}>
          <CardContent sx={{ p: 3 }}>
            <Typography sx={{ fontSize: 13, fontWeight: 900, color: 'rgba(255,255,255,0.80)' }}>
              No projects yet.
            </Typography>
            <Typography sx={{ mt: 0.5, fontSize: 12, color: 'rgba(255,255,255,0.55)' }}>
              Create your first project above.
            </Typography>
          </CardContent>
        </Card>
      )}

      {/* Project List */}
      <Stack spacing={1.5} sx={{ mt: 2 }}>
        {projects.map((p) => (
          <Fade in timeout={400} key={p.id}>
            <Card sx={{ ...hoverGlassCard }}>
              <CardContent sx={{ p: { xs: 2.25, sm: 2.5 } }}>
                <Stack
                  direction="row"
                  justifyContent="space-between"
                  alignItems="flex-start"
                  spacing={2}
                >
                  <Box sx={{ minWidth: 0 }}>
                    <Typography
                      sx={{
                        fontSize: 13,
                        fontWeight: 900,
                        color: 'rgba(255,255,255,0.92)',
                        lineHeight: 1.25,
                        wordBreak: 'break-word',
                      }}
                    >
                      {p.title}
                    </Typography>

                    {p.description && (
                      <Typography
                        sx={{
                          mt: 0.5,
                          fontSize: 13,
                          color: 'rgba(255,255,255,0.62)',
                          wordBreak: 'break-word',
                        }}
                      >
                        {p.description}
                      </Typography>
                    )}
                  </Box>

                  <Stack direction="row" spacing={1} sx={{ flexShrink: 0 }}>
                    <Button
                      size="small"
                      variant="text"
                      onClick={() => edit(p)}
                      disabled={loading}
                      sx={subtleBtnSx}
                    >
                      Edit
                    </Button>

                    <Button
                      size="small"
                      variant="text"
                      color="error"
                      onClick={() => remove(p)}
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
          </Fade>
        ))}
      </Stack>
    </Box>
  );
}