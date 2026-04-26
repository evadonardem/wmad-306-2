import { Head, useForm, usePage, router } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import {
    Box,
    Typography,
    TextField,
    Button,
    Card,
    CardContent,
    Divider,
    Alert,
    Avatar,
    Snackbar,
} from '@mui/material';
import {
    Comment as CommentIcon,
    ArrowBack as BackIcon,
} from '@mui/icons-material';
import { useMemo, useState } from 'react';

export default function Show({ article }) {
    const { flash } = usePage().props;
    const [snackbar, setSnackbar] = useState({ open: false, message: '' });
    const [visibleComments, setVisibleComments] = useState(10);

    const displayedComments = useMemo(
        () => (article.comments || []).slice(0, visibleComments),
        [article.comments, visibleComments]
    );

    const hasMoreComments = (article.comments?.length || 0) > visibleComments;

    const commentForm = useForm({
        content: '',
    });

    const handleComment = (e) => {
        e.preventDefault();
        commentForm.post(route('articles.comment', article.id), {
            onSuccess: () => {
                commentForm.reset();
                setSnackbar({ open: true, message: 'Comment posted!' });
            },
        });
    };

    return (
        <AuthenticatedLayout>
            <Head title={article.title} />

            <Box sx={{ p: 3, maxWidth: 900, mx: 'auto' }}>
                {flash?.success && (
                    <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>
                )}

                <Button
                    startIcon={<BackIcon />}
                    onClick={() => router.visit(route('student.dashboard'))}
                    sx={{ mb: 2 }}
                >
                    Back to Dashboard
                </Button>

                <Card>
                    <CardContent>
                        <Typography variant="h4" gutterBottom>{article.title}</Typography>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                            By {article.writer?.name} | {article.category?.name} | {new Date(article.created_at).toLocaleDateString()}
                        </Typography>
                        <Divider sx={{ mb: 2 }} />

                        <Typography
                            variant="body1"
                            dangerouslySetInnerHTML={{ __html: article.content }}
                            sx={{ mb: 3 }}
                        />

                        <Divider sx={{ mb: 2 }} />
                        <Typography variant="h6" gutterBottom>
                            Comments ({article.comments?.length || 0})
                        </Typography>

                        {displayedComments.map((comment) => (
                            <Box key={comment.id} sx={{ display: 'flex', gap: 2, mb: 2, p: 1.5, bgcolor: 'grey.50', borderRadius: 1 }}>
                                <Avatar sx={{ width: 32, height: 32, fontSize: 14 }}>
                                    {comment.student?.name?.[0]}
                                </Avatar>
                                <Box>
                                    <Typography variant="subtitle2">{comment.student?.name}</Typography>
                                    <Typography variant="caption" color="text.secondary">
                                        {new Date(comment.created_at).toLocaleString()}
                                    </Typography>
                                    <Typography variant="body2" sx={{ mt: 0.5 }}>{comment.content}</Typography>
                                </Box>
                            </Box>
                        ))}

                        {hasMoreComments && (
                            <Button
                                variant="outlined"
                                size="small"
                                onClick={() => setVisibleComments((count) => count + 10)}
                                sx={{ mb: 2 }}
                            >
                                Load 10 more comments
                            </Button>
                        )}

                        {/* Comment Form */}
                        <Box component="form" onSubmit={handleComment} sx={{ mt: 2 }}>
                            <TextField
                                label="Write a comment..."
                                multiline
                                rows={3}
                                fullWidth
                                value={commentForm.data.content}
                                onChange={(e) => commentForm.setData('content', e.target.value)}
                                error={!!commentForm.errors.content}
                                helperText={commentForm.errors.content}
                                sx={{ mb: 1 }}
                            />
                            <Button
                                type="submit"
                                variant="contained"
                                disabled={commentForm.processing}
                                startIcon={<CommentIcon />}
                            >
                                Post Comment
                            </Button>
                        </Box>
                    </CardContent>
                </Card>
            </Box>

            <Snackbar
                open={snackbar.open}
                autoHideDuration={4000}
                onClose={() => setSnackbar({ open: false, message: '' })}
                message={snackbar.message}
            />
        </AuthenticatedLayout>
    );
}
