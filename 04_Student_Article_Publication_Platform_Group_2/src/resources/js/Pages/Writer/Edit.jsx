import { Head, useForm, router, usePage } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import {
    Box,
    Typography,
    TextField,
    Button,
    MenuItem,
    Card,
    CardContent,
    Alert,
} from '@mui/material';
import {
    Save as SaveIcon,
    ArrowBack as BackIcon,
    Send as SendIcon,
} from '@mui/icons-material';
import JoditEditor from 'jodit-react';
import { useRef, useMemo } from 'react';

export default function Edit({ article, categories }) {
    const { flash } = usePage().props;
    const editorRef = useRef(null);

    const { data, setData, put, processing, errors } = useForm({
        title: article.title,
        content: article.content,
        category_id: article.category_id,
    });

    const config = useMemo(() => ({
        readonly: false,
        height: 400,
        placeholder: 'Start writing your article...',
        enableDragAndDropFileToEditor: true,
        askBeforePasteHTML: false,
        askBeforePasteFromWord: false,
        defaultActionOnPaste: 'insert_as_html',
        uploader: {
            insertImageAsBase64URI: true,
        },
    }), []);

    const handleUpdate = (e) => {
        e.preventDefault();
        put(route('articles.update', article.id));
    };

    const handleSubmit = () => {
        router.post(route('articles.submit', article.id));
    };

    return (
        <AuthenticatedLayout>
            <Head title={`Edit: ${article.title}`} />

            <Box sx={{ p: 3, maxWidth: 900, mx: 'auto' }}>
                {flash?.success && (
                    <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>
                )}

                <Button
                    startIcon={<BackIcon />}
                    onClick={() => router.visit(route('writer.dashboard'))}
                    sx={{ mb: 2 }}
                >
                    Back to Dashboard
                </Button>

                {article.revisions?.length > 0 && (
                    <Alert severity="warning" sx={{ mb: 2 }}>
                        <Typography variant="subtitle2">Editor Feedback:</Typography>
                        {article.revisions.map((rev) => (
                            <Typography key={rev.id} variant="body2" sx={{ mt: 0.5 }}>
                                {rev.editor?.name}: {rev.comments}
                            </Typography>
                        ))}
                    </Alert>
                )}

                <Card>
                    <CardContent>
                        <Box component="form" onSubmit={handleUpdate}>
                            <TextField
                                label="Title"
                                fullWidth
                                value={data.title}
                                onChange={(e) => setData('title', e.target.value)}
                                error={!!errors.title}
                                helperText={errors.title}
                                sx={{ mb: 2 }}
                            />
                            <TextField
                                select
                                label="Category"
                                fullWidth
                                value={data.category_id}
                                onChange={(e) => setData('category_id', e.target.value)}
                                error={!!errors.category_id}
                                helperText={errors.category_id}
                                sx={{ mb: 2 }}
                            >
                                {categories.map((cat) => (
                                    <MenuItem key={cat.id} value={cat.id}>
                                        {cat.name}
                                    </MenuItem>
                                ))}
                            </TextField>
                            <Box sx={{ mb: 2 }}>
                                <JoditEditor
                                    ref={editorRef}
                                    value={data.content}
                                    config={config}
                                    onBlur={(newContent) => setData('content', newContent)}
                                />
                                {errors.content && (
                                    <Typography color="error" variant="caption">{errors.content}</Typography>
                                )}
                            </Box>
                            <Box sx={{ display: 'flex', gap: 1 }}>
                                <Button
                                    type="submit"
                                    variant="contained"
                                    disabled={processing}
                                    startIcon={<SaveIcon />}
                                >
                                    Save Changes
                                </Button>
                                <Button
                                    variant="contained"
                                    color="primary"
                                    startIcon={<SendIcon />}
                                    onClick={handleSubmit}
                                >
                                    Submit for Review
                                </Button>
                            </Box>
                        </Box>
                    </CardContent>
                </Card>
            </Box>
        </AuthenticatedLayout>
    );
}
