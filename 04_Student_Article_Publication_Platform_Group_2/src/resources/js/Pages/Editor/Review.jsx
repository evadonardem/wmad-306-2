import { Head, useForm, router, usePage } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import {
    Box,
    Typography,
    TextField,
    Button,
    Card,
    CardContent,
    Chip,
    Divider,
    Alert,
} from '@mui/material';
import {
    Publish as PublishIcon,
    EditNote as RevisionIcon,
    ArrowBack as BackIcon,
} from '@mui/icons-material';

export default function Review({ article }) {
    const { flash } = usePage().props;

    const revisionForm = useForm({
        comments: '',
    });

    const handlePublish = () => {
        router.post(route('articles.publish', article.id));
    };

    const handleRequestRevision = (e) => {
        e.preventDefault();
        revisionForm.post(route('articles.revision', article.id));
    };

    return (
        <AuthenticatedLayout>
            <Head title={`Review: ${article.title}`} />

            <Box sx={{ p: 3, maxWidth: 900, mx: 'auto' }}>
                {flash?.success && (
                    <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>
                )}

                <Button
                    startIcon={<BackIcon />}
                    onClick={() => router.visit(route('editor.dashboard'))}
                    sx={{ mb: 2 }}
                >
                    Back to Dashboard
                </Button>

                <Card>
                    <CardContent>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                            <Typography variant="h4">{article.title}</Typography>
                            <Chip label={article.status?.label} color="primary" />
                        </Box>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                            Writer: {article.writer?.name} | Category: {article.category?.name} | Submitted: {new Date(article.updated_at).toLocaleDateString()}
                        </Typography>
                        <Divider sx={{ mb: 2 }} />
                        <Typography
                            variant="body1"
                            dangerouslySetInnerHTML={{ __html: article.content }}
                            sx={{ mb: 3 }}
                        />

                        {article.revisions?.length > 0 && (
                            <Box sx={{ mb: 3 }}>
                                <Typography variant="h6" gutterBottom>Revision History</Typography>
                                {article.revisions.map((rev) => (
                                    <Box key={rev.id} sx={{ p: 1.5, mb: 1, bgcolor: 'grey.50', borderRadius: 1 }}>
                                        <Typography variant="subtitle2">{rev.editor?.name}</Typography>
                                        <Typography variant="caption" color="text.secondary">
                                            {new Date(rev.created_at).toLocaleString()}
                                        </Typography>
                                        <Typography variant="body2" sx={{ mt: 0.5 }}>{rev.comments}</Typography>
                                    </Box>
                                ))}
                            </Box>
                        )}

                        <Divider sx={{ mb: 2 }} />
                        <Typography variant="h6" gutterBottom>Actions</Typography>

                        <Box sx={{ display: 'flex', gap: 2, alignItems: 'flex-start' }}>
                            <Button
                                variant="contained"
                                color="success"
                                startIcon={<PublishIcon />}
                                onClick={handlePublish}
                            >
                                Publish Article
                            </Button>
                        </Box>

                        <Box component="form" onSubmit={handleRequestRevision} sx={{ mt: 3 }}>
                            <Typography variant="subtitle1" gutterBottom>Or Request Revision:</Typography>
                            <TextField
                                label="Revision Comments"
                                multiline
                                rows={4}
                                fullWidth
                                value={revisionForm.data.comments}
                                onChange={(e) => revisionForm.setData('comments', e.target.value)}
                                error={!!revisionForm.errors.comments}
                                helperText={revisionForm.errors.comments}
                                sx={{ mb: 2 }}
                            />
                            <Button
                                type="submit"
                                variant="contained"
                                color="warning"
                                startIcon={<RevisionIcon />}
                                disabled={revisionForm.processing}
                            >
                                Request Revision
                            </Button>
                        </Box>
                    </CardContent>
                </Card>
            </Box>
        </AuthenticatedLayout>
    );
}
