import CoolButton from '@/Components/CoolButton';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router, useForm } from '@inertiajs/react';
import { 
    Alert, Box, Button, Chip, MenuItem, Stack, TextField, Typography,
    Dialog, DialogTitle, DialogContent, DialogActions
} from '@mui/material';
import { useMemo, useState } from 'react';

export default function WriterDashboard({ articles, flash }) {
    // Role Request Form
    const roleForm = useForm({
        request_type: 'add',
        role_name: 'editor',
        justification: '',
    });
    const [isRoleModalOpen, setIsRoleModalOpen] = useState(false);
    const requestTypeRoleOptions = {
        add: [{ value: 'editor', label: 'Editor (Add)' }],
        switch: [{ value: 'editor', label: 'Editor (Switch To)' }],
        step_down: [{ value: 'student', label: 'Student (Step Down)' }],
    };

    const [revisionDrafts, setRevisionDrafts] = useState(() => {
        const draftMap = {};
        for (const article of articles) {
            draftMap[article.id] = { title: article.title, content: article.content, category_id: article.category_id };
        }
        return draftMap;
    });
    const [coverImageDrafts, setCoverImageDrafts] = useState(() => {
        const draftMap = {};
        for (const article of articles) {
            draftMap[article.id] = article.cover_image_url ?? '';
        }
        return draftMap;
    });
    const [coverImageFiles, setCoverImageFiles] = useState({});
    const [coverImagePreviews, setCoverImagePreviews] = useState({});

    const drafts = articles.filter((article) => article.status?.name === 'draft');
    const submitted = articles.filter((article) => article.status?.name === 'submitted');
    const needsRevision = articles.filter((article) => article.status?.name === 'needs_revision');
    const publishedCount = articles.filter((article) => article.status?.name === 'published').length;

    const [statusFilter, setStatusFilter] = useState('all');

    const visibleArticles = useMemo(() => {
        if (statusFilter === 'draft') return drafts;
        if (statusFilter === 'submitted') return submitted;
        if (statusFilter === 'needs_revision') return needsRevision;
        return articles;
    }, [articles, drafts, submitted, needsRevision, statusFilter]);

    const handleRoleRequest = (event) => {
        event.preventDefault();
        roleForm.post(route('role-requests.store'), { 
            onSuccess: () => {
                setIsRoleModalOpen(false);
                roleForm.setData({
                    request_type: 'add',
                    role_name: 'editor',
                    justification: '',
                });
            } 
        });
    };

    const updateRevisionField = (articleId, field, value) => {
        setRevisionDrafts((prev) => ({ ...prev, [articleId]: { ...prev[articleId], [field]: value } }));
    };

    const syncCoverImageDraftsFromPage = (page) => {
        const nextArticles = page?.props?.articles ?? [];
        const nextCoverMap = {};

        for (const article of nextArticles) {
            nextCoverMap[article.id] = article.cover_image_url ?? '';
        }

        setCoverImageDrafts((prev) => ({ ...prev, ...nextCoverMap }));
    };

    const saveDraftCoverImage = (articleId) => {
        const selectedFile = coverImageFiles[articleId] ?? null;
        const normalizedCoverImageUrl = (coverImageDrafts[articleId] ?? '').trim();
        const payload = {
            cover_image_url: normalizedCoverImageUrl === '' ? null : normalizedCoverImageUrl,
        };

        if (selectedFile) {
            payload.cover_image_file = selectedFile;
        }

        router.post(route('writer.articles.cover-image', articleId), {
            _method: 'patch',
            ...payload,
        }, {
            preserveScroll: true,
            forceFormData: true,
            onSuccess: (page) => {
                syncCoverImageDraftsFromPage(page);
                setCoverImageFiles((prev) => ({ ...prev, [articleId]: null }));
                setCoverImagePreviews((prev) => ({ ...prev, [articleId]: null }));
            },
        });
    };

    const getStatusColor = (statusName) => {
        switch (statusName) {
            case 'draft': return 'default';
            case 'submitted': return 'primary';
            case 'needs_revision': return 'warning';
            case 'published': return 'success';
            default: return 'default';
        }
    };

    const getTierInfo = (count) => {
        if (count >= 20) return { title: 'Expert Strategist', next: 'Max Level', target: 20 };
        if (count >= 10) return { title: 'Senior Columnist', next: 'Expert Strategist', target: 20 };
        if (count >= 5) return { title: 'Seasoned Author', next: 'Senior Columnist', target: 10 };
        if (count >= 1) return { title: 'Junior Contributor', next: 'Seasoned Author', target: 5 };
        return { title: 'Entry-Level Writer', next: 'Junior Contributor', target: 1 };
    };

    const tierInfo = getTierInfo(publishedCount);
    const progressPercentage = Math.min(100, (publishedCount / tierInfo.target) * 100);

    const dashboardAnimations = `
        @keyframes reveal-up {
            0% { transform: translateY(30px); opacity: 0; filter: blur(4px); }
            100% { transform: translateY(0); opacity: 1; filter: blur(0); }
        }
        .animate-reveal-0 { animation: reveal-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
        .animate-reveal-1 { animation: reveal-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
        .animate-reveal-2 { animation: reveal-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
        
        .custom-scrollbar::-webkit-scrollbar { width: 4px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
        .dark .custom-scrollbar::-webkit-scrollbar-thumb { background: #475569; }
    `;

    return (
        <AuthenticatedLayout fullWidth={true}>
            <Head title="Writer Dashboard" />
            <style>{dashboardAnimations}</style>

            <div className="mx-auto max-w-7xl px-4 lg:px-8 py-8 lg:py-12">
                <div className="mb-8 animate-reveal-0">
                    <h1 className="text-3xl font-black tracking-tight text-gray-900 dark:text-white sm:text-4xl">
                        Writer Workspace
                    </h1>
                    <p className="mt-2 text-lg text-gray-600 dark:text-gray-400">
                        Draft new stories, track your rank, and manage your campus publications.
                    </p>
                </div>

                {/* Notifications Panel */}
                {flash?.success && (
                    <div className="mb-6 animate-reveal-0">
                        <Alert severity="success" sx={{ borderRadius: 3 }}>{flash.success}</Alert>
                    </div>
                )}
                {flash?.error && (
                    <div className="mb-6 animate-reveal-0">
                        <Alert severity="error" sx={{ borderRadius: 3 }}>{flash.error}</Alert>
                    </div>
                )}

                <div className="flex flex-col lg:flex-row gap-8">
                    
                    {/* LEFT SIDEBAR */}
                    <div className="w-full lg:w-[340px] flex-shrink-0 space-y-6 lg:sticky lg:top-24 lg:max-h-[calc(100vh-7rem)] lg:overflow-y-auto animate-reveal-1 pb-4 pr-1 custom-scrollbar">
                        
                        {/* 1. Gamification / Rank Bento */}
                        <div className="bg-white dark:bg-gray-800/80 rounded-[2rem] p-6 shadow-sm border border-gray-100 dark:border-gray-700/50">
                            <div className="flex justify-between items-center mb-4">
                                <h3 className="text-lg font-bold text-gray-900 dark:text-white">Your Rank</h3>
                                <span className="text-3xl">🏆</span>
                            </div>
                            
                            <div className="mb-5">
                                <span className="inline-flex items-center rounded-xl bg-amber-100 dark:bg-amber-900/30 px-4 py-2 text-sm font-black uppercase tracking-wider text-amber-800 dark:text-amber-400 border border-amber-200 dark:border-amber-800/50">
                                    {tierInfo.title}
                                </span>
                            </div>
                            
                            <div className="space-y-2">
                                <div className="flex justify-between text-sm font-bold text-gray-600 dark:text-gray-400">
                                    <span>{publishedCount} Published</span>
                                    <span>{tierInfo.target === 20 && publishedCount >= 20 ? 'Maxed' : `Goal: ${tierInfo.target}`}</span>
                                </div>
                                <div className="h-4 w-full bg-gray-100 dark:bg-gray-700 rounded-full overflow-hidden shadow-inner">
                                    <div 
                                        className="h-full bg-gradient-to-r from-amber-400 to-amber-600 rounded-full transition-all duration-1000 ease-out relative"
                                        style={{ width: `${progressPercentage}%` }}
                                    >
                                        <div className="absolute inset-0 bg-white/20 animate-pulse"></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* 2. Portfolio Statistics Grid */}
                        <div className="bg-white dark:bg-gray-800/80 rounded-[2rem] p-6 shadow-sm border border-gray-100 dark:border-gray-700/50">
                            <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-4">Portfolio Overview</h3>
                            <div className="grid grid-cols-2 gap-3">
                                <div className="bg-emerald-50 dark:bg-emerald-900/10 border border-emerald-100 dark:border-emerald-800/30 rounded-2xl p-4 flex flex-col items-center justify-center text-center">
                                    <span className="text-2xl mb-1">✅</span>
                                    <span className="text-2xl font-black text-emerald-600 dark:text-emerald-400">{publishedCount}</span>
                                    <span className="text-xs font-bold text-emerald-800 dark:text-emerald-500 uppercase tracking-wide">Published</span>
                                </div>
                                <div className="bg-gray-50 dark:bg-gray-900/50 border border-gray-200 dark:border-gray-700/50 rounded-2xl p-4 flex flex-col items-center justify-center text-center">
                                    <span className="text-2xl mb-1">📝</span>
                                    <span className="text-2xl font-black text-gray-700 dark:text-gray-300">{drafts.length}</span>
                                    <span className="text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wide">Drafts</span>
                                </div>
                            </div>
                        </div>

                        {/* 3. Role Management Card (NEW) */}
                        <div className="bg-[#2f6fdb]/5 dark:bg-[#2f6fdb]/10 rounded-[2rem] p-6 shadow-sm border border-[#2f6fdb]/20 dark:border-[#2f6fdb]/30">
                            <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-2 flex items-center gap-2">
                                <span>🔄</span> Add a Role
                            </h3>
                            <p className="text-sm text-gray-600 dark:text-gray-400 mb-4 leading-relaxed">
                                Want to review and publish articles? Request to add the Editor role to your account.
                            </p>
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
                        </div>

                    </div>

                    {/* MAIN CONTENT AREA */}
                    <div className="flex-1 min-w-0 space-y-8">
                        {/* Articles List */}
                        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 animate-reveal-2 pt-4">
                            <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Your Articles Workspace</h2>
                            <Button
                                component={Link}
                                href={route('writer.articles.create')}
                                variant="contained"
                                sx={{
                                    bgcolor: '#2f6fdb',
                                    borderRadius: '0.75rem',
                                    textTransform: 'none',
                                    fontWeight: 'bold',
                                    px: 2.5,
                                    '&:hover': { bgcolor: '#2157b4' },
                                }}
                            >
                                New Article
                            </Button>
                        </div>
                        <div className="space-y-6 animate-reveal-2">
                            {visibleArticles.length === 0 ? (
                                <div className="bg-white dark:bg-gray-800/80 rounded-[2rem] p-12 text-center shadow-sm border border-gray-100 dark:border-gray-700/50">
                                    <span className="text-4xl mb-4 block">📝</span>
                                    <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-2">No articles found</h3>
                                </div>
                            ) : (
                                visibleArticles.map((article) => (
                                    <div key={article.id} className="bg-white dark:bg-gray-800/80 rounded-[2rem] p-6 sm:p-8 shadow-sm border border-gray-100 dark:border-gray-700/50">
                                        <Stack spacing={3}>
                                            <div className="flex flex-col sm:flex-row justify-between items-start gap-4">
                                                <div>
                                                    <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-1">{article.title}</h3>
                                                    <p className="text-sm font-medium text-gray-500 dark:text-gray-400">
                                                        {article.category?.name} • Updated {new Date(article.updated_at).toLocaleDateString()}
                                                    </p>
                                                </div>
                                                <Chip label={article.status?.label ?? 'Unknown'} color={getStatusColor(article.status?.name)} variant="outlined" sx={{ fontWeight: 'bold', borderRadius: 2 }}/>
                                            </div>
                                            {(article.status?.name === 'draft' || article.status?.name === 'needs_revision') && (
                                                <Stack spacing={1.5}>
                                                    <Box
                                                        sx={{
                                                            width: '100%',
                                                            maxWidth: 420,
                                                            height: 180,
                                                            borderRadius: '1rem',
                                                            overflow: 'hidden',
                                                            border: '1px dashed',
                                                            borderColor: 'divider',
                                                            bgcolor: 'action.hover',
                                                            display: 'flex',
                                                            alignItems: 'center',
                                                            justifyContent: 'center',
                                                        }}
                                                    >
                                                        {(coverImagePreviews[article.id] ?? coverImageDrafts[article.id]) ? (
                                                            <Box
                                                                component="img"
                                                                src={coverImagePreviews[article.id] ?? coverImageDrafts[article.id]}
                                                                alt="Draft cover"
                                                                sx={{ width: '100%', height: '100%', objectFit: 'cover' }}
                                                            />
                                                        ) : (
                                                            <Typography variant="caption" color="text.secondary">No Image</Typography>
                                                        )}
                                                    </Box>
                                                    <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1.5} alignItems={{ xs: 'stretch', sm: 'center' }}>
                                                        <TextField
                                                            label="Cover Image URL"
                                                            placeholder="https://images.unsplash.com/..."
                                                            value={coverImageDrafts[article.id] ?? ''}
                                                            onChange={(event) => setCoverImageDrafts((prev) => ({ ...prev, [article.id]: event.target.value }))}
                                                            fullWidth
                                                            size="small"
                                                        />
                                                        <Button component="label" variant="outlined" sx={{ textTransform: 'none', fontWeight: 'bold' }}>
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

                                                                    setCoverImagePreviews((prev) => ({ ...prev, [article.id]: URL.createObjectURL(file) }));
                                                                }}
                                                            />
                                                        </Button>
                                                    </Stack>
                                                    <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap" useFlexGap>
                                                        {coverImageFiles[article.id] && (
                                                            <Typography variant="caption" color="text.secondary">
                                                                {coverImageFiles[article.id].name}
                                                            </Typography>
                                                        )}
                                                        <CoolButton tone="outline" onClick={() => saveDraftCoverImage(article.id)}>
                                                            Save Image
                                                        </CoolButton>
                                                    </Stack>
                                                </Stack>
                                            )}
                                            <div className="flex flex-wrap gap-3 pt-2">
                                                {article.status?.name === 'draft' && <CoolButton onClick={() => router.post(route('articles.submit', article.id))}>Submit for Review</CoolButton>}
                                            </div>
                                        </Stack>
                                    </div>
                                ))
                            )}
                        </div>
                    </div>
                </div>
            </div>

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
                                    const nextRole = requestTypeRoleOptions[nextType]?.[0]?.value ?? 'editor';
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
