import CoolButton from '@/Components/CoolButton';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm } from '@inertiajs/react';
import { Alert, Box, Button, MenuItem, Stack, TextField, Typography } from '@mui/material';
import { useTheme } from '@mui/material/styles';
import JoditEditor from 'jodit-react';
import { useEffect, useMemo, useState } from 'react';

export default function WriterCreate({ categories = [], flash }) {
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';

    const createForm = useForm({
        title: '',
        content: '',
        category_id: categories[0]?.id ?? '',
        cover_image_url: '',
        cover_image_file: null,
        action: 'draft',
    });
    const [localImagePreviewUrl, setLocalImagePreviewUrl] = useState('');

    const joditConfig = useMemo(() => ({
        readonly: false,
        minHeight: 380,
        placeholder: 'Start writing your campus story here...',
        style: {
            background: isDark ? '#0f172a' : '#ffffff',
            color: isDark ? '#e5e7eb' : '#111827',
        },
    }), [isDark]);

    const handleCreate = (event) => {
        event.preventDefault();

        const requestedAction = event?.nativeEvent?.submitter?.value === 'submit'
            ? 'submit'
            : 'draft';

        createForm.transform((data) => ({
            ...data,
            action: requestedAction,
        }));

        createForm.post(route('articles.store'), {
            forceFormData: true,
            onSuccess: () => {
                createForm.reset('title', 'content', 'cover_image_url', 'cover_image_file');
                setLocalImagePreviewUrl('');
            },
            onFinish: () => createForm.transform((data) => data),
        });
    };

    const handleCoverImageUrlChange = (event) => {
        createForm.setData('cover_image_url', event.target.value);
        createForm.setData('cover_image_file', null);
        setLocalImagePreviewUrl('');
    };

    const handleCoverImageFileChange = (event) => {
        const file = event.target.files?.[0] ?? null;
        createForm.setData('cover_image_file', file);

        if (!file) {
            setLocalImagePreviewUrl('');
            return;
        }

        createForm.setData('cover_image_url', '');
        setLocalImagePreviewUrl(URL.createObjectURL(file));
    };

    useEffect(() => {
        return () => {
            if (localImagePreviewUrl) {
                URL.revokeObjectURL(localImagePreviewUrl);
            }
        };
    }, [localImagePreviewUrl]);

    return (
        <AuthenticatedLayout
            header={
                <Stack spacing={0.25}>
                    <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.02em' }}>
                        New Article
                    </Typography>
                    <Typography color="text.secondary" sx={{ fontSize: '1rem', fontWeight: 500 }}>
                        Write once, then either save as draft or submit for review.
                    </Typography>
                </Stack>
            }
            fullWidth
        >
            <Head title="New Article" />

            <Box sx={{ maxWidth: 1080, mx: 'auto' }}>
                {flash?.success && (
                    <Alert severity="success" sx={{ borderRadius: 2.5, mb: 2 }}>
                        {flash.success}
                    </Alert>
                )}
                {flash?.error && (
                    <Alert severity="error" sx={{ borderRadius: 2.5, mb: 2 }}>
                        {flash.error}
                    </Alert>
                )}

                <Box
                    component="form"
                    onSubmit={handleCreate}
                    sx={{
                        borderRadius: '1.5rem',
                        border: '1px solid',
                        borderColor: 'divider',
                        bgcolor: 'background.paper',
                        p: { xs: 2.5, md: 3.5 },
                    }}
                >
                    <Stack spacing={3}>
                        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2}>
                            <TextField
                                label="Catchy Title"
                                value={createForm.data.title}
                                onChange={(event) => createForm.setData('title', event.target.value)}
                                error={Boolean(createForm.errors.title)}
                                helperText={createForm.errors.title}
                                fullWidth
                            />
                            <TextField
                                select
                                label="Category"
                                value={createForm.data.category_id}
                                onChange={(event) => createForm.setData('category_id', event.target.value)}
                                error={Boolean(createForm.errors.category_id)}
                                helperText={createForm.errors.category_id}
                                fullWidth
                            >
                                {categories.map((category) => (
                                    <MenuItem key={category.id} value={category.id}>
                                        {category.name}
                                    </MenuItem>
                                ))}
                            </TextField>
                        </Stack>

                        <Box
                            sx={{
                                borderRadius: 2,
                                overflow: 'hidden',
                                border: '1px solid',
                                borderColor: 'divider',
                                '& .jodit-container': {
                                    border: 'none',
                                    bgcolor: isDark ? '#0f172a' : '#ffffff',
                                },
                                '& .jodit-toolbar__box': {
                                    bgcolor: isDark ? '#111827' : '#f8fafc',
                                    borderColor: isDark ? '#374151' : '#e5e7eb',
                                },
                                '& .jodit-workplace': {
                                    bgcolor: isDark ? '#0f172a' : '#ffffff',
                                },
                                '& .jodit-wysiwyg': {
                                    color: `${isDark ? '#e5e7eb' : '#111827'} !important`,
                                    bgcolor: `${isDark ? '#0f172a' : '#ffffff'} !important`,
                                },
                                '& .jodit-wysiwyg p, & .jodit-wysiwyg div, & .jodit-wysiwyg span': {
                                    color: `${isDark ? '#e5e7eb' : '#111827'} !important`,
                                },
                                '& .jodit-wysiwyg_empty:before': {
                                    color: `${isDark ? '#9ca3af' : '#6b7280'} !important`,
                                },
                            }}
                        >
                            <JoditEditor
                                value={createForm.data.content}
                                config={joditConfig}
                                onBlur={(value) => createForm.setData('content', value)}
                            />
                        </Box>

                        <Stack spacing={1.5}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 700 }}>
                                Cover Image (optional)
                            </Typography>
                            <TextField
                                label="Cover Image URL"
                                placeholder="https://images.unsplash.com/..."
                                value={createForm.data.cover_image_url}
                                onChange={handleCoverImageUrlChange}
                                error={Boolean(createForm.errors.cover_image_url)}
                                helperText={createForm.errors.cover_image_url}
                                fullWidth
                            />
                            <Stack direction="row" spacing={1.5} alignItems="center" flexWrap="wrap" useFlexGap>
                                <Button component="label" variant="outlined" sx={{ textTransform: 'none', fontWeight: 700 }}>
                                    Upload Local Image
                                    <input
                                        hidden
                                        type="file"
                                        accept="image/png,image/jpeg,image/jpg,image/webp,image/gif"
                                        onChange={handleCoverImageFileChange}
                                    />
                                </Button>
                                {createForm.data.cover_image_file ? (
                                    <Typography variant="body2" color="text.secondary">
                                        {createForm.data.cover_image_file.name}
                                    </Typography>
                                ) : null}
                            </Stack>
                            {createForm.errors.cover_image_file ? (
                                <Typography variant="caption" color="error">
                                    {createForm.errors.cover_image_file}
                                </Typography>
                            ) : null}
                            {(localImagePreviewUrl || createForm.data.cover_image_url) ? (
                                <Box
                                    component="img"
                                    src={localImagePreviewUrl || createForm.data.cover_image_url}
                                    alt="Cover preview"
                                    sx={{
                                        width: '100%',
                                        maxHeight: 260,
                                        objectFit: 'cover',
                                        borderRadius: 2,
                                        border: '1px solid',
                                        borderColor: 'divider',
                                    }}
                                />
                            ) : null}
                        </Stack>

                        <Stack direction="row" spacing={1.5}>
                            <CoolButton type="submit" value="draft" disabled={createForm.processing}>
                                Save Draft
                            </CoolButton>
                            <CoolButton type="submit" value="submit" disabled={createForm.processing}>
                                Submit for Review
                            </CoolButton>
                        </Stack>
                    </Stack>
                </Box>
            </Box>
        </AuthenticatedLayout>
    );
}
