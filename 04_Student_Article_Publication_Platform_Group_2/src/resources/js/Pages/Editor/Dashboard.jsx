import React, { useState } from 'react';
import {
    Container, Typography, Paper, Table, TableBody, TableCell, TableContainer,
    TableHead, TableRow, Chip, Button, Alert, Stack, Dialog, DialogTitle,
    DialogContent, DialogActions, TextField, Tabs, Tab, Box, Divider,
} from '@mui/material';
import { Head, useForm, usePage } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';

function TabPanel({ children, value, index }) {
    return value === index ? <Box sx={{ pt: 2 }}>{children}</Box> : null;
}

export default function EditorDashboard({ pending, published }) {
    const { flash } = usePage().props;
    const [tab, setTab] = useState(0);
    const [revisionTarget, setRevisionTarget] = useState(null);

    const revisionForm = useForm({ comments: '' });
    const publishForm = useForm({});

    const handleRequestRevision = (e) => {
        e.preventDefault();
        revisionForm.post(route('editor.articles.revision', revisionTarget.id), {
            onSuccess: () => {
                setRevisionTarget(null);
                revisionForm.reset();
            },
        });
    };

    const handlePublish = (articleId) => {
        publishForm.post(route('editor.articles.publish', articleId));
    };

    return (
        <AuthenticatedLayout header={<Typography variant="h5">Editor Dashboard</Typography>}>
            <Head title="Editor Dashboard" />
            <Container maxWidth="lg" sx={{ py: 4 }}>
                {flash?.success && <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>}

                <Tabs value={tab} onChange={(_, v) => setTab(v)}>
                    <Tab label={`Pending Articles (${pending.length})`} />
                    <Tab label={`Published Articles (${published.length})`} />
                </Tabs>

                {/* Pending Tab */}
                <TabPanel value={tab} index={0}>
                    <TableContainer component={Paper}>
                        <Table>
                            <TableHead>
                                <TableRow>
                                    <TableCell>Title</TableCell>
                                    <TableCell>Writer</TableCell>
                                    <TableCell>Category</TableCell>
                                    <TableCell>Submitted</TableCell>
                                    <TableCell align="right">Actions</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {pending.map((article) => (
                                    <TableRow key={article.id}>
                                        <TableCell>{article.title}</TableCell>
                                        <TableCell>{article.writer?.name}</TableCell>
                                        <TableCell>{article.category?.name || '—'}</TableCell>
                                        <TableCell>{new Date(article.updated_at).toLocaleDateString()}</TableCell>
                                        <TableCell align="right">
                                            <Stack direction="row" spacing={1} justifyContent="flex-end">
                                                <Button
                                                    size="small"
                                                    variant="outlined"
                                                    color="warning"
                                                    onClick={() => setRevisionTarget(article)}
                                                >
                                                    Request Revision
                                                </Button>
                                                <Button
                                                    size="small"
                                                    variant="contained"
                                                    color="success"
                                                    onClick={() => handlePublish(article.id)}
                                                    disabled={publishForm.processing}
                                                >
                                                    Publish
                                                </Button>
                                            </Stack>
                                        </TableCell>
                                    </TableRow>
                                ))}
                                {pending.length === 0 && (
                                    <TableRow>
                                        <TableCell colSpan={5} align="center">No pending articles.</TableCell>
                                    </TableRow>
                                )}
                            </TableBody>
                        </Table>
                    </TableContainer>
                </TabPanel>

                {/* Published Tab */}
                <TabPanel value={tab} index={1}>
                    <TableContainer component={Paper}>
                        <Table>
                            <TableHead>
                                <TableRow>
                                    <TableCell>Title</TableCell>
                                    <TableCell>Writer</TableCell>
                                    <TableCell>Category</TableCell>
                                    <TableCell>Published</TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody>
                                {published.map((article) => (
                                    <TableRow key={article.id}>
                                        <TableCell>{article.title}</TableCell>
                                        <TableCell>{article.writer?.name}</TableCell>
                                        <TableCell>{article.category?.name || '—'}</TableCell>
                                        <TableCell>{article.published_at ? new Date(article.published_at).toLocaleDateString() : '—'}</TableCell>
                                    </TableRow>
                                ))}
                                {published.length === 0 && (
                                    <TableRow>
                                        <TableCell colSpan={4} align="center">No published articles yet.</TableCell>
                                    </TableRow>
                                )}
                            </TableBody>
                        </Table>
                    </TableContainer>
                </TabPanel>

                {/* Revision Dialog */}
                <Dialog open={!!revisionTarget} onClose={() => setRevisionTarget(null)} maxWidth="sm" fullWidth>
                    <form onSubmit={handleRequestRevision}>
                        <DialogTitle>Request Revision</DialogTitle>
                        <DialogContent>
                            <Typography variant="body2" sx={{ mb: 2 }}>
                                Article: <strong>{revisionTarget?.title}</strong>
                            </Typography>
                            <TextField
                                multiline
                                rows={4}
                                label="Revision Comments"
                                fullWidth
                                value={revisionForm.data.comments}
                                onChange={(e) => revisionForm.setData('comments', e.target.value)}
                                error={!!revisionForm.errors.comments}
                                helperText={revisionForm.errors.comments}
                                required
                            />
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={() => setRevisionTarget(null)}>Cancel</Button>
                            <Button type="submit" variant="contained" color="warning" disabled={revisionForm.processing}>
                                Send Revision Request
                            </Button>
                        </DialogActions>
                    </form>
                </Dialog>
            </Container>
        </AuthenticatedLayout>
    );
}
