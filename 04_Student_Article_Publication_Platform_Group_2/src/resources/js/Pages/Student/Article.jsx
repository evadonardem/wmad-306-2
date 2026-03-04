import React from 'react';
import {
    Container, Typography, Paper, Box, Alert, Chip, Divider, Stack,
    TextField, Button,
} from '@mui/material';
import { Head, useForm, usePage } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';

export default function StudentArticle({ article }) {
    const { flash } = usePage().props;
    const { data, setData, post, processing, errors, reset } = useForm({
        content: '',
    });

    const handleComment = (e) => {
        e.preventDefault();
        post(route('student.articles.comment', article.id), {
            onSuccess: () => reset(),
        });
    };

    return (
        <AuthenticatedLayout header={<Typography variant="h5">{article.title}</Typography>}>
            <Head title={article.title} />
            <Container maxWidth="md" sx={{ py: 4 }}>
                {flash?.success && <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>}

                <Paper sx={{ p: 3, mb: 3 }}>
                    <Stack direction="row" spacing={2} sx={{ mb: 2 }}>
                        <Chip label={article.category?.name || 'Uncategorized'} size="small" />
                        <Typography variant="body2" color="text.secondary">
                            By {article.writer?.name} |
                            Published {article.published_at ? new Date(article.published_at).toLocaleDateString() : ''}
                        </Typography>
                    </Stack>
                    <Divider sx={{ mb: 2 }} />
                    <Box dangerouslySetInnerHTML={{ __html: article.content }} />
                </Paper>

                {/* Comments */}
                <Typography variant="h6" gutterBottom>Comments</Typography>
                {article.comments && article.comments.length > 0 ? (
                    article.comments.map((c) => (
                        <Paper key={c.id} variant="outlined" sx={{ p: 2, mb: 1 }}>
                            <Typography variant="body2" color="text.secondary">
                                {c.student?.name} — {new Date(c.created_at).toLocaleDateString()}
                            </Typography>
                            <Typography variant="body1">{c.content}</Typography>
                        </Paper>
                    ))
                ) : (
                    <Typography color="text.secondary" sx={{ mb: 2 }}>
                        No comments yet. Be the first!
                    </Typography>
                )}

                <Divider sx={{ my: 2 }} />

                {/* Comment Form */}
                <Paper sx={{ p: 2 }}>
                    <Typography variant="subtitle1" gutterBottom>Post a Comment</Typography>
                    <form onSubmit={handleComment}>
                        <TextField
                            multiline
                            rows={3}
                            label="Your comment"
                            fullWidth
                            value={data.content}
                            onChange={(e) => setData('content', e.target.value)}
                            error={!!errors.content}
                            helperText={errors.content}
                            required
                            sx={{ mb: 2 }}
                        />
                        <Button type="submit" variant="contained" disabled={processing}>
                            Post Comment
                        </Button>
                    </form>
                </Paper>
            </Container>
        </AuthenticatedLayout>
    );
}
