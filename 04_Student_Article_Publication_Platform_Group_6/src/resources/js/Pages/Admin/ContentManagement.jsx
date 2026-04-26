import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router, useForm } from '@inertiajs/react';
import { 
    Alert, Box, Button, Card, CardContent, Chip, Dialog, DialogActions, 
    DialogContent, DialogTitle, MenuItem, Stack, TextField, Typography, Tabs, Tab, Divider
} from '@mui/material';
import { useTheme } from '@mui/material/styles';
import JoditEditor from 'jodit-react';
import { useMemo, useState } from 'react';

const adminAnimations = `
    @keyframes admin-container-enter {
        0% { opacity: 0; transform: scale(0.94) translateY(24px); }
        100% { opacity: 1; transform: scale(1) translateY(0); }
    }
    @keyframes admin-reveal-up {
        0% { transform: translateY(80px); opacity: 0; filter: blur(8px); }
        100% { transform: translateY(0); opacity: 1; filter: blur(0); }
    }
    .admin-animate-reveal-0 { animation: admin-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
    .admin-animate-reveal-1 { animation: admin-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
    .admin-animate-reveal-2 { animation: admin-reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
    .admin-container-enter { animation: admin-container-enter 0.7s cubic-bezier(0.16, 1, 0.3, 1) both; }
`;

const textFieldSx = {
    '& .MuiOutlinedInput-root': { borderRadius: '1rem', fontWeight: 500 },
    '& .MuiInputLabel-root': { fontWeight: 600 },
};

export default function ContentManagement({ articles, comments, categories, flash }) {
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';
    
    const [tabIndex, setTabIndex] = useState(0);
    const [editArticle, setEditArticle] = useState(null);

    const editForm = useForm({
        title: '',
        category_id: '',
        content: ''
    });

    const openEditModal = (article) => {
        setEditArticle(article);
        editForm.setData({
            title: article.title,
            category_id: article.category_id,
            content: article.content
        });
    };

    const handleUpdateArticle = (e) => {
        e.preventDefault();
        editForm.put(route('admin.articles.update', editArticle.id), {
            onSuccess: () => setEditArticle(null)
        });
    };

    const handleDeleteArticle = (id) => {
        if (confirm("🚨 WARNING: Are you sure you want to permanently delete this article? This cannot be undone.")) {
            router.delete(route('admin.articles.destroy', id), { preserveScroll: true });
        }
    };

    const handleDeleteComment = (id) => {
        if (confirm("Are you sure you want to delete this comment?")) {
            router.delete(route('admin.comments.destroy', id), { preserveScroll: true });
        }
    };

    // Bento Card Styling perfectly matched to the Editor dashboard
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

    const getStatusColor = (statusName) => {
        switch (statusName) {
            case 'draft': return 'default';
            case 'submitted': return 'primary';
            case 'needs_revision': return 'warning';
            case 'published': return 'success';
            default: return 'default';
        }
    };

    const joditConfig = useMemo(() => ({
        readonly: false, 
        minHeight: 400, 
        style: { background: 'transparent' }
    }), []);

    return (
        <AuthenticatedLayout 
            header={
                <Stack spacing={0.25} className="admin-animate-reveal-0">
                    <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.02em', display: 'flex', alignItems: 'center', gap: 1.5 }}>
                        🛡️ Content Moderation
                    </Typography>
                    <Typography color="text.secondary" sx={{ fontSize: '1rem', fontWeight: 500 }}>
                        God-mode enabled. Edit or delete any article or comment across the platform.
                    </Typography>
                </Stack>
            } 
            fullWidth
        >
            <Head title="Content Moderation" />
            <style>{adminAnimations}</style>

            <Box className="admin-container-enter" sx={{ maxWidth: 1280, mx: 'auto', px: { xs: 2, lg: 3 }, py: { xs: 2.5, lg: 4 } }}>
                
                {flash?.success && (
                    <Alert severity="success" className="admin-animate-reveal-0" sx={{ borderRadius: '1rem', mb: 3 }}>{flash.success}</Alert>
                )}

                <Box sx={{ display: 'flex', gap: 4, flexDirection: { xs: 'column', lg: 'row' } }}>
                    
                    {/* LEFT SIDEBAR (Sticky) */}
                    <Stack spacing={3} sx={{ width: { xs: '100%', lg: 320 }, flexShrink: 0, alignSelf: 'flex-start', position: { lg: 'sticky' }, top: { lg: 92 } }} className="admin-animate-reveal-1">
                        
                        {/* Platform Stats */}
                        <Box sx={{ ...bentoCardSx(true), p: 3 }}>
                            <Typography variant="h6" sx={{ fontWeight: 800, mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <span>📊</span> Platform Overview
                            </Typography>
                            <Stack spacing={2}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2, borderRadius: '1rem', border: '1px solid', borderColor: 'rgba(47, 111, 219, 0.25)', bgcolor: 'rgba(47, 111, 219, 0.06)' }}>
                                    <Typography sx={{ fontWeight: 700, color: '#2f6fdb' }}>Total Articles</Typography>
                                    <Typography sx={{ fontSize: '1.25rem', fontWeight: 800, color: '#2f6fdb' }}>{articles.length}</Typography>
                                </Box>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', p: 2, borderRadius: '1rem', border: '1px solid', borderColor: isDark ? 'rgba(245, 158, 11, 0.35)' : 'rgba(245, 158, 11, 0.25)', bgcolor: isDark ? 'rgba(245, 158, 11, 0.08)' : 'rgba(245, 158, 11, 0.06)' }}>
                                    <Typography sx={{ fontWeight: 700, color: '#d97706' }}>Total Comments</Typography>
                                    <Typography sx={{ fontSize: '1.25rem', fontWeight: 800, color: '#d97706' }}>{comments.length}</Typography>
                                </Box>
                            </Stack>
                        </Box>

                        {/* Info Card - Super Admin Power */}
                        <Box sx={{ ...bentoCardSx(true), p: 3, background: 'linear-gradient(155deg, #ef4444, #b91c1c)', borderColor: '#7f1d1d', color: '#fff' }}>
                            <Typography variant="h6" sx={{ fontWeight: 800, mb: 2, display: 'flex', alignItems: 'center', gap: 1, color: '#fff' }}>
                                <span>⚠️</span> Super Admin Power
                            </Typography>
                            <Typography variant="body2" sx={{ color: 'rgba(255,255,255,0.9)', lineHeight: 1.6 }}>
                                Actions taken here are permanent. Deleting an article will remove it entirely from the database, bypassing the standard editorial workflow.
                            </Typography>
                        </Box>
                    </Stack>

                    {/* MAIN CONTENT AREA */}
                    <Box sx={{ flex: 1, minWidth: 0 }} className="admin-animate-reveal-2">
                        
                        <Box sx={{ borderBottom: 1, borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.8)', mb: 3 }}>
                            <Tabs 
                                value={tabIndex} 
                                onChange={(e, val) => setTabIndex(val)} 
                                sx={{ 
                                    '& .MuiTab-root': { fontWeight: 800, textTransform: 'none', fontSize: '1.05rem', py: 2 },
                                    '& .Mui-selected': { color: '#2f6fdb' },
                                    '& .MuiTabs-indicator': { backgroundColor: '#2f6fdb', height: 3, borderRadius: '3px 3px 0 0' }
                                }}
                            >
                                <Tab label={`Articles Registry`} />
                                <Tab label={`Community Comments`} />
                            </Tabs>
                        </Box>

                        {/* ARTICLES TAB */}
                        {tabIndex === 0 && (
                            <Stack spacing={3}>
                                {articles.length === 0 ? (
                                    <Box sx={{ ...bentoCardSx(false), p: 8, textAlign: 'center' }}>
                                        <Typography sx={{ fontSize: '2.5rem', mb: 2 }}>📂</Typography>
                                        <Typography variant="h6" sx={{ fontWeight: 800 }}>No articles exist yet.</Typography>
                                    </Box>
                                ) : articles.map(article => (
                                    <Card key={article.id} sx={{ ...bentoCardSx(true), boxShadow: 'none' }}>
                                        <CardContent sx={{ p: { xs: 3, sm: 4 } }}>
                                            <Stack direction={{ xs: 'column', sm: 'row' }} justifyContent="space-between" alignItems="flex-start" spacing={3}>
                                                <Box sx={{ flex: 1 }}>
                                                    <Typography variant="h5" sx={{ fontWeight: 800, mb: 1 }}>{article.title}</Typography>
                                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 2, fontWeight: 500 }}>
                                                        By <Box component="span" sx={{ color: '#2f6fdb', fontWeight: 600 }}>{article.writer?.name}</Box> • {article.category?.name} • Updated {new Date(article.updated_at).toLocaleDateString()}
                                                    </Typography>
                                                    <Chip 
                                                        label={article.status?.name.replace('_', ' ').toUpperCase()} 
                                                        size="small" 
                                                        color={getStatusColor(article.status?.name)}
                                                        variant="outlined"
                                                        sx={{ fontWeight: 800, borderRadius: '0.5rem' }} 
                                                    />
                                                </Box>
                                                
                                                <Stack direction={{ xs: 'row', sm: 'column' }} spacing={1.5} sx={{ width: { xs: '100%', sm: 'auto' } }}>
                                                    <Button 
                                                        variant="outlined" 
                                                        onClick={() => openEditModal(article)}
                                                        sx={{ borderRadius: '0.75rem', fontWeight: 700, borderColor: 'rgba(47, 111, 219, 0.4)', flex: { xs: 1, sm: 'auto' }, '&:hover': { borderColor: '#2f6fdb', bgcolor: 'rgba(47, 111, 219, 0.04)' } }}
                                                    >
                                                        Force Edit
                                                    </Button>
                                                    <Button 
                                                        variant="contained" 
                                                        color="error" 
                                                        onClick={() => handleDeleteArticle(article.id)}
                                                        sx={{ borderRadius: '0.75rem', fontWeight: 700, boxShadow: 'none', flex: { xs: 1, sm: 'auto' } }}
                                                    >
                                                        Nuke
                                                    </Button>
                                                </Stack>
                                            </Stack>
                                        </CardContent>
                                    </Card>
                                ))}
                            </Stack>
                        )}

                        {/* COMMENTS TAB */}
                        {tabIndex === 1 && (
                            <Stack spacing={3}>
                                {comments.length === 0 ? (
                                    <Box sx={{ ...bentoCardSx(false), p: 8, textAlign: 'center' }}>
                                        <Typography sx={{ fontSize: '2.5rem', mb: 2 }}>💬</Typography>
                                        <Typography variant="h6" sx={{ fontWeight: 800 }}>No comments to moderate.</Typography>
                                    </Box>
                                ) : comments.map(comment => (
                                    <Card key={comment.id} sx={{ ...bentoCardSx(true), boxShadow: 'none' }}>
                                        <CardContent sx={{ p: { xs: 3, sm: 4 } }}>
                                            <Stack direction={{ xs: 'column', sm: 'row' }} justifyContent="space-between" alignItems="flex-start" spacing={3}>
                                                <Box sx={{ flex: 1 }}>
                                                    <Box sx={{ p: 2.5, borderRadius: '1rem', border: '1px solid', borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.8)', bgcolor: isDark ? 'rgba(30, 41, 59, 0.3)' : 'rgba(248, 250, 252, 0.9)', mb: 2 }}>
                                                        <Typography variant="body1" sx={{ fontWeight: 500, fontStyle: 'italic', color: 'text.secondary' }}>
                                                            "{comment.content}"
                                                        </Typography>
                                                    </Box>
                                                    <Typography variant="caption" color="text.secondary" sx={{ fontSize: '0.85rem', fontWeight: 500 }}>
                                                        Posted by <Box component="span" sx={{ fontWeight: 700 }}>{comment.student?.name}</Box> on article: <br/>
                                                        <Box component="span" sx={{ color: '#2f6fdb', fontWeight: 600 }}>{comment.article?.title}</Box>
                                                    </Typography>
                                                </Box>
                                                <Button 
                                                    variant="contained" 
                                                    color="error" 
                                                    onClick={() => handleDeleteComment(comment.id)}
                                                    sx={{ borderRadius: '0.75rem', fontWeight: 700, boxShadow: 'none', width: { xs: '100%', sm: 'auto' } }}
                                                >
                                                    Remove Comment
                                                </Button>
                                            </Stack>
                                        </CardContent>
                                    </Card>
                                ))}
                            </Stack>
                        )}
                    </Box>
                </Box>
            </Box>

            {/* EDIT ARTICLE MODAL */}
            <Dialog 
                open={!!editArticle} 
                onClose={() => setEditArticle(null)} 
                fullWidth 
                maxWidth="md" 
                PaperProps={{ 
                    sx: { 
                        borderRadius: '1.5rem', 
                        p: 1,
                        bgcolor: 'background.paper',
                    } 
                }}
            >
                <Box component="form" onSubmit={handleUpdateArticle}>
                    <DialogTitle sx={{ fontWeight: 800, fontSize: '1.5rem' }}>Force Edit Article</DialogTitle>
                    <DialogContent>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                            You are bypassing the editorial workflow. Save your changes directly to the live database.
                        </Typography>
                        <Stack spacing={3} sx={{ mt: 1 }}>
                            <TextField 
                                label="Title" 
                                value={editForm.data.title} 
                                onChange={e => editForm.setData('title', e.target.value)} 
                                fullWidth 
                                sx={textFieldSx}
                            />
                            <TextField 
                                select 
                                label="Category" 
                                value={editForm.data.category_id} 
                                onChange={e => editForm.setData('category_id', e.target.value)} 
                                fullWidth
                                sx={textFieldSx}
                            >
                                {categories.map(cat => <MenuItem key={cat.id} value={cat.id}>{cat.name}</MenuItem>)}
                            </TextField>
                            
                            <Box sx={{ border: '1px solid', borderColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)', borderRadius: '1rem', overflow: 'hidden' }}>
                                <JoditEditor 
                                    value={editForm.data.content} 
                                    config={joditConfig}
                                    onBlur={newContent => editForm.setData('content', newContent)} 
                                />
                            </Box>
                        </Stack>
                    </DialogContent>
                    <DialogActions sx={{ p: 3, pt: 1 }}>
                        <Button 
                            onClick={() => setEditArticle(null)}
                            sx={{ color: 'text.secondary', fontWeight: 700, textTransform: 'none', borderRadius: '0.5rem' }}
                        >
                            Cancel
                        </Button>
                        <Button 
                            type="submit" 
                            variant="contained" 
                            disabled={editForm.processing}
                            sx={{ bgcolor: '#2f6fdb', fontWeight: 700, textTransform: 'none', borderRadius: '0.75rem', px: 3, boxShadow: 'none', '&:hover': { bgcolor: '#2157b4' } }}
                        >
                            Save Overwrite
                        </Button>
                    </DialogActions>
                </Box>
            </Dialog>
        </AuthenticatedLayout>
    );
}