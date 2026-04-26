import ActionButtonGroup from '@/Components/ActionButtonGroup';
import CoolButton from '@/Components/CoolButton';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router, usePage, useForm } from '@inertiajs/react';
import {
    Alert,
    Box,
    Button,
    Card,
    CardContent,
    Chip,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    Divider,
    MenuItem,
    Stack,
    TextField,
    Typography,
} from '@mui/material';
import { useTheme } from '@mui/material/styles';
import { useMemo, useState } from 'react';

const getReadingMetrics = (htmlContent) => {
    const plainText = htmlContent?.replace(/<[^>]*>?/gm, '') || '';
    const wordCount = plainText.trim().split(/\s+/).length;
    const readTime = Math.max(1, Math.ceil(wordCount / 200));
    return { wordCount, readTime };
};

const editorAnimations = `
    @keyframes editor-container-enter {
        0% { opacity: 0; transform: scale(0.94) translateY(24px); }
        100% { opacity: 1; transform: scale(1) translateY(0); }
    }
    @keyframes editor-reveal-up {
        0% { transform: translateY(80px); opacity: 0; filter: blur(8px); }
        100% { transform: translateY(0); opacity: 1; filter: blur(0); }
    }
    .editor-animate-reveal-0 { animation: editor-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
    .editor-animate-reveal-1 { animation: editor-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
    .editor-animate-reveal-2 { animation: editor-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
    .editor-animate-reveal-3 { animation: editor-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both; }
    .editor-container-enter { animation: editor-container-enter 0.7s cubic-bezier(0.16, 1, 0.3, 1) both; }
`;

const textFieldSx = {
    '& .MuiOutlinedInput-root': { borderRadius: '1rem', fontWeight: 500 },
    '& .MuiInputLabel-root': { fontWeight: 600 },
};

export default function EditorDashboard({ submittedArticles, publishedArticles, flash }) {
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';
    const { errors = {} } = usePage().props;
    const [revisionComments, setRevisionComments] = useState({});
    
    // Role Request Form
    const roleForm = useForm({
        request_type: 'add',
        role_name: 'writer',
        justification: '',
    });
    const [isRoleModalOpen, setIsRoleModalOpen] = useState(false);
    const requestTypeRoleOptions = {
        add: [{ value: 'writer', label: 'Writer (Add)' }],
        switch: [{ value: 'writer', label: 'Writer (Switch To)' }],
        step_down: [{ value: 'student', label: 'Student (Step Down)' }],
    };

    const allArticles = useMemo(
        () => [...(submittedArticles ?? []), ...(publishedArticles ?? [])],
        [submittedArticles, publishedArticles],
    );
    const [coverImageDrafts, setCoverImageDrafts] = useState(() => {
        const map = {};
        for (const article of allArticles) {
            map[article.id] = article.cover_image_url ?? '';
        }
        return map;
    });
    const [coverImageFiles, setCoverImageFiles] = useState({});
    const [coverImagePreviews, setCoverImagePreviews] = useState({});

    const syncDraftsFromPageProps = (page) => {
        const nextSubmitted = page?.props?.submittedArticles ?? [];
        const nextPublished = page?.props?.publishedArticles ?? [];
        const nextMap = {};

        for (const article of [...nextSubmitted, ...nextPublished]) {
            nextMap[article.id] = article.cover_image_url ?? '';
        }

        setCoverImageDrafts((prev) => ({ ...prev, ...nextMap }));
    };

    const saveCoverImage = (articleId) => {
        const normalizedCoverImageUrl = (coverImageDrafts[articleId] ?? '').trim();
        const selectedFile = coverImageFiles[articleId] ?? null;
        const payload = {
            _method: 'patch',
            cover_image_url: normalizedCoverImageUrl === '' ? null : normalizedCoverImageUrl,
        };

        if (selectedFile) {
            payload.cover_image_file = selectedFile;
        }

        router.post(route('articles.cover-image', articleId), payload, {
            preserveScroll: true,
            forceFormData: true,
            onSuccess: (page) => {
                syncDraftsFromPageProps(page);
                setCoverImageFiles((prev) => ({ ...prev, [articleId]: null }));
                setCoverImagePreviews((prev) => ({ ...prev, [articleId]: null }));
            },
        });
    };

    const handleRoleRequest = (event) => {
        event.preventDefault();
        roleForm.post(route('role-requests.store'), { 
            onSuccess: () => {
                setIsRoleModalOpen(false);
                roleForm.setData({
                    request_type: 'add',
                    role_name: 'writer',
                    justification: '',
                });
            } 
        });
    };

    const bentoCardSx = (hover = true) => ({
        borderRadius: '2rem',
        border: '1px solid',
        borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.9)',
        bgcolor: isDark ? 'rgba(17, 24, 39, 0.6)' : 'rgba(244, 247, 251, 0.9)',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)',
        overflow: 'hidden',
        transition: 'all 0.5s cubic-bezier(0.16, 1, 0.3, 1)',
        ...(hover && {
            '&:hover': {
                transform: 'translateY(-4px)',
                boxShadow: '0 20px 40px rgba(47, 111, 219, 0.12)',
                borderColor: 'rgba(47, 111, 219, 0.25)',
            },
        }),
    });

    const imagePreviewSx = {
        position: 'relative',
        width: '100%',
        height: 160,
        borderRadius: '1rem',
        overflow: 'hidden',
        border: '1px dashed',
        borderColor: isDark ? 'rgba(75, 85, 99, 0.6)' : 'rgba(203, 213, 225, 0.9)',
        bgcolor: isDark ? 'rgba(30, 41, 59, 0.5)' : 'rgba(241, 245, 249, 0.9)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        '& img': { width: '100%', height: '100%', objectFit: 'cover' },
    };

    return (
        <AuthenticatedLayout
            header={
                <Stack spacing={0.25} className="editor-animate-reveal-0">
                    <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.02em' }}>
                        Editor's Desk
                    </Typography>
                    <Typography color="text.secondary" sx={{ fontSize: '1rem', fontWeight: 500 }}>
                        Review submissions, curate visual content, and publish the latest campus news.
                    </Typography>
                </Stack>
            }
            fullWidth
        >
            <Head title="Editor Dashboard" />
            <style>{editorAnimations}</style>

            <Box className="editor-container-enter" sx={{ maxWidth: 1280, mx: 'auto', px: { xs: 2, lg: 3 }, py: { xs: 2.5, lg: 4 } }}>
                
                {/* Notifications Panel */}
                {flash?.success && (
                    <Alert severity="success" className="editor-animate-reveal-0" sx={{ borderRadius: '1rem', mb: 2 }}>{flash.success}</Alert>
                )}
                {flash?.error && (
                    <Alert severity="error" className="editor-animate-reveal-0" sx={{ borderRadius: '1rem', mb: 2 }}>{flash.error}</Alert>
                )}
                {errors?.cover_image_url && (
                    <Alert severity="error" className="editor-animate-reveal-0" sx={{ borderRadius: '1rem', mb: 2 }}>
                        {errors.cover_image_url}
                    </Alert>
                )}
                {errors?.cover_image_file && (
                    <Alert severity="error" className="editor-animate-reveal-0" sx={{ borderRadius: '1rem', mb: 2 }}>
                        {errors.cover_image_file}
                    </Alert>
                )}

                <Box sx={{ display: 'flex', gap: 4, flexDirection: { xs: 'column', lg: 'row' } }}>
                    {/* LEFT SIDEBAR (Sticky) */}
                    <Stack spacing={3} sx={{ width: { xs: '100%', lg: 320 }, alignSelf: 'flex-start', position: { lg: 'sticky' }, top: { lg: 92 } }} className="editor-animate-reveal-1">
                        
                        {/* Queue Stats Bento */}
                        <Box sx={{ ...bentoCardSx(true), p: 3 }}>
                            <Typography variant="h6" sx={{ fontWeight: 800, mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <span>📋</span> Editorial Queue
                            </Typography>
                            <Stack spacing={2}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2, borderRadius: '1rem', border: '1px solid', borderColor: 'rgba(47, 111, 219, 0.25)', bgcolor: 'rgba(47, 111, 219, 0.06)' }}>
                                    <Typography sx={{ fontWeight: 700, color: '#2f6fdb' }}>Pending Review</Typography>
                                    <Typography sx={{ fontSize: '1.25rem', fontWeight: 800, color: '#2f6fdb' }}>{submittedArticles?.length ?? 0}</Typography>
                                </Box>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2, borderRadius: '1rem', border: '1px solid', borderColor: isDark ? 'rgba(16, 185, 129, 0.35)' : 'rgba(16, 185, 129, 0.25)', bgcolor: isDark ? 'rgba(16, 185, 129, 0.08)' : 'rgba(16, 185, 129, 0.06)' }}>
                                    <Typography sx={{ fontWeight: 700, color: '#10b981' }}>Published</Typography>
                                    <Typography sx={{ fontSize: '1.25rem', fontWeight: 800, color: '#10b981' }}>{publishedArticles?.length ?? 0}</Typography>
                                </Box>
                            </Stack>
                        </Box>

                        {/* Workflow Tips */}
                        <Box sx={{ ...bentoCardSx(true), p: 3, background: 'linear-gradient(155deg, rgba(47, 111, 219, 0.95), rgba(30, 75, 155, 0.9))', borderColor: 'rgba(47, 111, 219, 0.4)', color: '#fff' }}>
                            <Typography variant="h6" sx={{ fontWeight: 800, mb: 2, display: 'flex', alignItems: 'center', gap: 1, color: '#fff' }}>
                                <span>🎨</span> Image Curation
                            </Typography>
                            <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.9)', lineHeight: 1.6 }}>
                                Strong visuals lead to higher reader engagement. Test your cover image URLs in the live preview box before publishing to ensure they load correctly.
                            </Typography>
                        </Box>

                        {/* Role Management Card (NEW) */}
                        <Box sx={{ ...bentoCardSx(true), p: 3, bgcolor: isDark ? 'rgba(47, 111, 219, 0.1)' : 'rgba(47, 111, 219, 0.05)', borderColor: 'rgba(47, 111, 219, 0.2)' }}>
                            <Typography variant="h6" sx={{ fontWeight: 800, mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <span>🔄</span> Add a Role
                            </Typography>
                            <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3, lineHeight: 1.6 }}>
                                Want to draft your own campus stories? Request to add the Writer role to your account.
                            </Typography>
                            <Button 
                                variant="contained" 
                                fullWidth 
                                onClick={() => setIsRoleModalOpen(true)}
                                sx={{ 
                                    bgcolor: '#2f6fdb', 
                                    borderRadius: '0.75rem', 
                                    textTransform: 'none', 
                                    fontWeight: 'bold',
                                    boxShadow: 'none',
                                    '&:hover': { bgcolor: '#2157b4', boxShadow: '0 4px 12px rgba(47, 111, 219, 0.25)' }
                                }}
                            >
                                Request Role Change
                            </Button>
                        </Box>

                    </Stack>

                    {/* MAIN CONTENT AREA */}
                    <Stack spacing={4} sx={{ flex: 1, minWidth: 0 }}>
                        {/* PENDING ARTICLES */}
                        <Box className="editor-animate-reveal-2">
                            <Typography variant="h5" sx={{ fontWeight: 800, mb: 3, letterSpacing: '-0.02em' }}>Needs Review</Typography>
                            <Stack spacing={3}>
                                {(submittedArticles?.length ?? 0) === 0 ? (
                                    <Box sx={{ ...bentoCardSx(false), p: 6, textAlign: 'center' }}>
                                        <Typography component="span" sx={{ fontSize: '2.5rem', display: 'block', mb: 2 }}>🎉</Typography>
                                        <Typography variant="h6" sx={{ fontWeight: 800, mb: 1 }}>Inbox Zero!</Typography>
                                        <Typography color="text.secondary">There are no pending submissions right now.</Typography>
                                    </Box>
                                ) : (
                                    submittedArticles.map((article) => {
                                        const comments = revisionComments[article.id] ?? '';
                                        const commentsError = comments.trim().length === 0;
                                        const metrics = getReadingMetrics(article.content);
                                        const imageUrl = coverImagePreviews[article.id] ?? coverImageDrafts[article.id];

                                        return (
                                            <Card key={article.id} sx={{ ...bentoCardSx(true), boxShadow: 'none' }}>
                                                <CardContent sx={{ p: { xs: 3, sm: 4 } }}>
                                                    <Stack spacing={3}>
                                                        <Stack direction={{ xs: 'column', sm: 'row' }} justifyContent="space-between" alignItems="flex-start" spacing={2}>
                                                            <Box>
                                                                <Typography variant="h5" sx={{ fontWeight: 800, mb: 1 }}>{article.title}</Typography>
                                                                <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>
                                                                    By <Box component="span" sx={{ color: '#2f6fdb', fontWeight: 600 }}>{article.writer?.name}</Box> • {article.category?.name}
                                                                </Typography>
                                                                <Stack direction="row" spacing={1} sx={{ mt: 2 }} useFlexGap flexWrap="wrap">
                                                                    <Chip label={article.status?.label} size="small" sx={{ fontWeight: 700, bgcolor: '#2f6fdb', color: '#fff' }} />
                                                                    <Chip label={`~${metrics.readTime} min read (${metrics.wordCount} words)`} size="small" variant="outlined" sx={{ fontWeight: 600 }} />
                                                                </Stack>
                                                            </Box>
                                                        </Stack>

                                                        <Box sx={{ p: 2, borderRadius: '1rem', border: '1px solid', borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.8)', bgcolor: isDark ? 'rgba(30, 41, 59, 0.3)' : 'rgba(248, 250, 252, 0.9)', color: 'text.secondary', fontSize: 14, lineHeight: 1.6 }}>
                                                            {(article.content || '').replace(/<[^>]*>?/gm, '').slice(0, 300)}...
                                                        </Box>

                                                        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr' }, gap: 2, alignItems: 'center', p: 2, borderRadius: '1.5rem', border: '1px solid', borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.9)', bgcolor: isDark ? 'rgba(17, 24, 39, 0.3)' : 'rgba(255,255,255,0.7)' }}>
                                                            <Box sx={{ ...imagePreviewSx }}>
                                                                {imageUrl ? (
                                                                    <img src={imageUrl} alt="Cover Preview" onError={(e) => { e.target.style.display = 'none'; if (e.target.nextSibling) e.target.nextSibling.style.display = 'block'; }} />
                                                                ) : null}
                                                                <Typography component="span" sx={{ display: imageUrl ? 'none' : 'block', color: 'text.secondary', fontSize: 14, fontWeight: 500 }}>No Image Set</Typography>
                                                            </Box>
                                                            <Stack spacing={2}>
                                                                <TextField
                                                                    label="Cover Image URL"
                                                                    placeholder="https://images.unsplash.com/..."
                                                                    value={imageUrl}
                                                                    onChange={(event) => setCoverImageDrafts((prev) => ({ ...prev, [article.id]: event.target.value }))}
                                                                    fullWidth
                                                                    size="small"
                                                                    sx={textFieldSx}
                                                                />
                                                                <Stack direction="row" spacing={1} alignItems="center">
                                                                    <Button component="label" variant="outlined" size="small" sx={{ borderRadius: '0.65rem', textTransform: 'none', fontWeight: 700 }}>
                                                                        Upload Local File
                                                                        <input
                                                                            hidden
                                                                            type="file"
                                                                            accept="image/png,image/jpeg,image/jpg,image/webp,image/gif"
                                                                            onChange={(event) => {
                                                                                const file = event.target.files?.[0] ?? null;
                                                                                setCoverImageFiles((prev) => ({ ...prev, [article.id]: file }));
                                                                                if (!file) {
                                                                                    setCoverImagePreviews((prev) => ({ ...prev, [article.id]: null }));
                                                                                    return;
                                                                                }
                                                                                setCoverImagePreviews((prev) => ({
                                                                                    ...prev,
                                                                                    [article.id]: URL.createObjectURL(file),
                                                                                }));
                                                                            }}
                                                                        />
                                                                    </Button>
                                                                    {coverImageFiles[article.id] ? (
                                                                        <Typography variant="caption" color="text.secondary" sx={{ maxWidth: 200 }} noWrap>
                                                                            {coverImageFiles[article.id].name}
                                                                        </Typography>
                                                                    ) : null}
                                                                </Stack>
                                                                <CoolButton tone="outline" sx={{ alignSelf: 'flex-start' }} onClick={() => saveCoverImage(article.id)}>
                                                                    Save Image
                                                                </CoolButton>
                                                            </Stack>
                                                        </Box>

                                                        <Stack spacing={2} sx={{ pt: 2, borderTop: '1px solid', borderColor: 'divider' }}>
                                                            <TextField
                                                                multiline
                                                                minRows={2}
                                                                label="Revision Notes for Writer"
                                                                placeholder="Great draft! Just needs a clearer conclusion..."
                                                                value={comments}
                                                                onChange={(event) => setRevisionComments((prev) => ({ ...prev, [article.id]: event.target.value }))}
                                                                helperText="Required when requesting a revision"
                                                                fullWidth
                                                                sx={textFieldSx}
                                                            />
                                                            <ActionButtonGroup
                                                                variant="contained"
                                                                sx={{ alignSelf: 'flex-start', '& .MuiButton-contained': { bgcolor: '#2f6fdb', '&:hover': { bgcolor: '#2157b4' } } }}
                                                                actions={[
                                                                    { key: 'request-revision', label: 'Request Revision', disabled: commentsError, onClick: () => router.post(route('articles.revision', article.id), { comments }) },
                                                                    { key: 'publish', label: 'Publish to Campus', onClick: () => router.post(route('articles.publish', article.id)) },
                                                                ]}
                                                            />
                                                        </Stack>
                                                    </Stack>
                                                </CardContent>
                                            </Card>
                                        );
                                    })
                                )}
                            </Stack>
                        </Box>

                        <Divider sx={{ my: 2, borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.8)' }} />

                        {/* PUBLISHED ARTICLES */}
                        <Box className="editor-animate-reveal-3">
                            <Typography variant="h5" sx={{ fontWeight: 800, mb: 3, letterSpacing: '-0.02em' }}>Recently Published</Typography>
                            <Stack spacing={2}>
                                {(publishedArticles?.length ?? 0) === 0 ? (
                                    <Box sx={{ ...bentoCardSx(false), p: 4, textAlign: 'center' }}>
                                        <Typography color="text.secondary">No published articles yet.</Typography>
                                    </Box>
                                ) : (
                                    publishedArticles.map((article) => (
                                        <Card key={article.id} sx={{ ...bentoCardSx(true), boxShadow: 'none' }}>
                                            <CardContent sx={{ p: 2.5 }}>
                                                <Stack direction={{ xs: 'column', sm: 'row' }} spacing={3} alignItems="center">
                                                    <Box sx={{ width: { xs: '100%', sm: 192 }, flexShrink: 0 }}>
                                                        <Box sx={{ ...imagePreviewSx, height: 100 }}>
                                                            {(coverImagePreviews[article.id] ?? coverImageDrafts[article.id]) ? (
                                                                <img src={coverImagePreviews[article.id] ?? coverImageDrafts[article.id]} alt="Cover" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                                            ) : (
                                                                <Typography variant="caption" color="text.secondary">No Image</Typography>
                                                            )}
                                                        </Box>
                                                    </Box>
                                                    <Stack spacing={1.5} sx={{ flex: 1, width: '100%' }}>
                                                        <Box>
                                                            <Typography variant="subtitle1" sx={{ fontWeight: 800 }}>{article.title}</Typography>
                                                            <Typography variant="body2" color="text.secondary">By {article.writer?.name} • {article.category?.name}</Typography>
                                                        </Box>
                                                        <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1} alignItems="flex-start" useFlexGap flexWrap="wrap">
                                                            <TextField
                                                                label="Update Image URL"
                                                                value={coverImageDrafts[article.id] ?? ''}
                                                                onChange={(event) => setCoverImageDrafts((prev) => ({ ...prev, [article.id]: event.target.value }))}
                                                                fullWidth
                                                                size="small"
                                                                sx={{ ...textFieldSx, flex: 1, minWidth: 160 }}
                                                            />
                                                            <Button component="label" variant="outlined" size="small" sx={{ borderRadius: '0.65rem', textTransform: 'none', fontWeight: 700 }}>
                                                                Upload File
                                                                <input
                                                                    hidden
                                                                    type="file"
                                                                    accept="image/png,image/jpeg,image/jpg,image/webp,image/gif"
                                                                    onChange={(event) => {
                                                                        const file = event.target.files?.[0] ?? null;
                                                                        setCoverImageFiles((prev) => ({ ...prev, [article.id]: file }));
                                                                        if (!file) {
                                                                            setCoverImagePreviews((prev) => ({ ...prev, [article.id]: null }));
                                                                            return;
                                                                        }
                                                                        setCoverImagePreviews((prev) => ({
                                                                            ...prev,
                                                                            [article.id]: URL.createObjectURL(file),
                                                                        }));
                                                                    }}
                                                                />
                                                            </Button>
                                                            {coverImageFiles[article.id] ? (
                                                                <Typography variant="caption" color="text.secondary" sx={{ maxWidth: 180 }} noWrap>
                                                                    {coverImageFiles[article.id].name}
                                                                </Typography>
                                                            ) : null}
                                                            <CoolButton tone="outline" onClick={() => saveCoverImage(article.id)}>Update</CoolButton>
                                                        </Stack>
                                                    </Stack>
                                                </Stack>
                                            </CardContent>
                                        </Card>
                                    ))
                                )}
                            </Stack>
                        </Box>
                    </Stack>
                </Box>
            </Box>

            {/* ROLE REQUEST DIALOG */}
            <Dialog 
                open={isRoleModalOpen} 
                onClose={() => setIsRoleModalOpen(false)}
                PaperProps={{
                    sx: {
                        borderRadius: '1.5rem',
                        padding: 1,
                        width: '100%',
                        maxWidth: 500,
                        bgcolor: 'background.paper',
                    }
                }}
            >
                <Box component="form" onSubmit={handleRoleRequest}>
                    <DialogTitle sx={{ fontWeight: 800, pb: 1 }}>Role Change Request</DialogTitle>
                    <DialogContent>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                            Choose whether to add a role, switch roles, or step down. Requests are reviewed by Super Admins.
                        </Typography>

                        <Stack spacing={3}>
                            <TextField
                                select
                                label="Request Type"
                                value={roleForm.data.request_type}
                                onChange={(e) => {
                                    const nextType = e.target.value;
                                    const nextRole = requestTypeRoleOptions[nextType]?.[0]?.value ?? 'writer';
                                    roleForm.setData({
                                        ...roleForm.data,
                                        request_type: nextType,
                                        role_name: nextRole,
                                    });
                                }}
                                fullWidth
                            >
                                <MenuItem value="add">Add Role</MenuItem>
                                <MenuItem value="switch">Change Role</MenuItem>
                                <MenuItem value="step_down">Step Down</MenuItem>
                            </TextField>

                            <TextField
                                select
                                label="Select Role"
                                value={roleForm.data.role_name}
                                onChange={(e) => roleForm.setData('role_name', e.target.value)}
                                fullWidth
                            >
                                {(requestTypeRoleOptions[roleForm.data.request_type] ?? []).map((option) => (
                                    <MenuItem key={option.value} value={option.value}>{option.label}</MenuItem>
                                ))}
                            </TextField>

                            <TextField
                                label="Why should we approve this request?"
                                multiline
                                rows={4}
                                placeholder="Share your reason for this role change..."
                                value={roleForm.data.justification}
                                onChange={(e) => roleForm.setData('justification', e.target.value)}
                                error={Boolean(roleForm.errors.justification)}
                                helperText={roleForm.errors.justification || roleForm.errors.request_type || roleForm.errors.role_name}
                                fullWidth
                                required
                            />
                        </Stack>
                    </DialogContent>
                    <DialogActions sx={{ px: 3, pb: 3 }}>
                        <Button 
                            onClick={() => setIsRoleModalOpen(false)} 
                            sx={{ color: 'text.secondary', fontWeight: 'bold', textTransform: 'none' }}
                        >
                            Cancel
                        </Button>
                        <Button 
                            type="submit" 
                            variant="contained" 
                            disabled={roleForm.processing}
                            sx={{ 
                                bgcolor: '#2f6fdb', 
                                borderRadius: '0.5rem', 
                                textTransform: 'none', 
                                fontWeight: 'bold',
                                '&:hover': { bgcolor: '#2157b4' }
                            }}
                        >
                            Submit Request
                        </Button>
                    </DialogActions>
                </Box>
            </Dialog>

        </AuthenticatedLayout>
    );
}
