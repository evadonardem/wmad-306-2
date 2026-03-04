import React, { useState, useRef, useMemo, useCallback } from 'react';
import {
    Container, Typography, TextField, Button, MenuItem, Stack, Divider, Paper,
    Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Chip,
    Box, Alert, IconButton, Dialog, DialogTitle, DialogContent, DialogActions
} from '@mui/material';
import { Edit as EditIcon, Send as SendIcon } from '@mui/icons-material';
import JoditEditor from 'jodit-react';
import { Head, useForm, usePage } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';

const statusColor = {
    draft: 'default',
    submitted: 'primary',
    revision: 'warning',
    published: 'success',
};

export default function WriterDashboard({ articles, categories }) {
    const { flash } = usePage().props;
    const editor = useRef(null);
    const [editArticle, setEditArticle] = useState(null);

    const config = useMemo(() => ({
        readonly: false,
        placeholder: 'Start writing your article...',
        height: 350,
    }), []);

    // --- New Article Form ---
    const { data, setData, post, processing, errors, reset } = useForm({
        title: '',
        content: '',
        category_id: '',
    });

    const handleCreate = (e) => {
        e.preventDefault();
        post(route('writer.articles.store'), {
            onSuccess: () => reset(),
        });
    };

    // --- Edit / Revise Form ---
    const reviseForm = useForm({ title: '', content: '', category_id: '' });

    const openEdit = (article) => {
        setEditArticle(article);
        reviseForm.setData({
            title: article.title,
            content: article.content || '',
            category_id: article.category_id || '',
        });
    };

    const handleRevise = (e) => {
        e.preventDefault();
        reviseForm.patch(route('writer.articles.revise', editArticle.id), {
            onSuccess: () => setEditArticle(null),
        });
    };

    // --- Submit ---
    const submitForm = useForm({});
    const handleSubmit = (articleId) => {
        submitForm.post(route('writer.articles.submit', articleId));
    };

    const handleContentBlur = useCallback((newContent) => {
        setData('content', newContent);
    }, []);

    return (
        <AuthenticatedLayout header={<Typography variant="h5">Writer Dashboard</Typography>}>
            <Head title="Writer Dashboard" />
            <Container maxWidth="lg" sx={{ py: 4 }}>
                {flash?.success && <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>}

                {/* New Article Form */}
                <Paper sx={{ p: 3, mb: 4 }}>
                    <Typography variant="h6" gutterBottom>Create New Article</Typography>
                    <form onSubmit={handleCreate}>
                        <Stack spacing={2}>
                            <TextField
                                label="Title"
                                value={data.title}
                                onChange={(e) => setData('title', e.target.value)}
                                error={!!errors.title}
                                helperText={errors.title}
                                fullWidth
                                required
                            />
                            <TextField
                                select
                                label="Category"
                                value={data.category_id}
                                onChange={(e) => setData('category_id', e.target.value)}
                                fullWidth
                            >
                                <MenuItem value="">None</MenuItem>
                                {categories.map((c) => (
                                    <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>
                                ))}
                            </TextField>
                            <JoditEditor
                                ref={editor}
                                value={data.content}
                                config={config}
                                onBlur={handleContentBlur}
                            />
                            <Button type="submit" variant="contained" disabled={processing}>
                                Create Draft
                            </Button>
                        </Stack>
                    </form>
                </Paper>

                {/* Articles Table */}
                <Typography variant="h6" gutterBottom>My Articles</Typography>
                <TableContainer component={Paper}>
                    <Table>
                        <TableHead>
                            <TableRow>
                                <TableCell>Title</TableCell>
                                <TableCell>Category</TableCell>
                                <TableCell>Status</TableCell>
                                <TableCell>Last Updated</TableCell>
                                <TableCell align="right">Actions</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {articles.map((article) => (
                                <TableRow key={article.id}>
                                    <TableCell>{article.title}</TableCell>
                                    <TableCell>{article.category?.name || '—'}</TableCell>
                                    <TableCell>
                                        <Chip
                                            label={article.status?.label || article.status?.name}
                                            color={statusColor[article.status?.name] || 'default'}
                                            size="small"
                                        />
                                    </TableCell>
                                    <TableCell>{new Date(article.updated_at).toLocaleDateString()}</TableCell>
                                    <TableCell align="right">
                                        {['draft', 'revision'].includes(article.status?.name) && (
                                            <>
                                                <IconButton size="small" onClick={() => openEdit(article)} title="Edit">
                                                    <EditIcon fontSize="small" />
                                                </IconButton>
                                                <IconButton size="small" color="primary" onClick={() => handleSubmit(article.id)} title="Submit">
                                                    <SendIcon fontSize="small" />
                                                </IconButton>
                                            </>
                                        )}
                                    </TableCell>
                                </TableRow>
                            ))}
                            {articles.length === 0 && (
                                <TableRow>
                                    <TableCell colSpan={5} align="center">No articles yet.</TableCell>
                                </TableRow>
                            )}
                        </TableBody>
                    </Table>
                </TableContainer>

                {/* Edit Dialog */}
                <Dialog open={!!editArticle} onClose={() => setEditArticle(null)} maxWidth="md" fullWidth>
                    <form onSubmit={handleRevise}>
                        <DialogTitle>Edit Article</DialogTitle>
                        <DialogContent>
                            <Stack spacing={2} sx={{ mt: 1 }}>
                                <TextField
                                    label="Title"
                                    value={reviseForm.data.title}
                                    onChange={(e) => reviseForm.setData('title', e.target.value)}
                                    fullWidth
                                    required
                                />
                                <TextField
                                    select
                                    label="Category"
                                    value={reviseForm.data.category_id}
                                    onChange={(e) => reviseForm.setData('category_id', e.target.value)}
                                    fullWidth
                                >
                                    <MenuItem value="">None</MenuItem>
                                    {categories.map((c) => (
                                        <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>
                                    ))}
                                </TextField>
                                <JoditEditor
                                    value={reviseForm.data.content}
                                    config={config}
                                    onBlur={(val) => reviseForm.setData('content', val)}
                                />
                            </Stack>
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={() => setEditArticle(null)}>Cancel</Button>
                            <Button type="submit" variant="contained" disabled={reviseForm.processing}>Save</Button>
                        </DialogActions>
                    </form>
                </Dialog>
            </Container>
        </AuthenticatedLayout>
    );
}
