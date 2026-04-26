import { Head, useForm, usePage, router } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import {
    Box,
    Container,
    Typography,
    TextField,
    Button,
    Card,
    CardContent,
    CardActions,
    Chip,
    Grid,
    Alert,
    Drawer,
    List,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    Divider,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Snackbar,
    Paper,
} from '@mui/material';
import {
    Pending as PendingIcon,
    CheckCircle as PublishedIcon,
    RateReview as ReviewIcon,
    Publish as PublishIcon,
    EditNote as RevisionIcon,
    LocalOfferOutlined,
    TrackChangesOutlined,
} from '@mui/icons-material';
import { useState } from 'react';

const drawerWidth = 240;

export default function Dashboard({ pendingArticles, publishedArticles }) {
    const { flash } = usePage().props;
    const [view, setView] = useState('pending');
    const [reviewArticle, setReviewArticle] = useState(null);
    const [revisionDialog, setRevisionDialog] = useState({ open: false, article: null });
    const [viewModal, setViewModal] = useState({ open: false, article: null });
    const [snackbar, setSnackbar] = useState({ open: false, message: '' });

    const revisionForm = useForm({
        comments: '',
    });

    const handlePublish = (article) => {
        router.post(route('articles.publish', article.id), {}, {
            onSuccess: () => {
                setSnackbar({ open: true, message: `"${article.title}" has been published!` });
                setReviewArticle(null);
            },
        });
    };

    const handleRequestRevision = () => {
        revisionForm.post(route('articles.revision', revisionDialog.article.id), {
            onSuccess: () => {
                setRevisionDialog({ open: false, article: null });
                revisionForm.reset();
                setSnackbar({ open: true, message: 'Revision requested.' });
                setReviewArticle(null);
            },
        });
    };

    const handleViewArticle = (article) => {
        setViewModal({ open: true, article });
    };

    const renderArticleList = (articleList, isPending = false) => (
        <Grid container spacing={2}>
            {articleList.length === 0 && (
                <Grid size={12}>
                    <Typography color="text.secondary" sx={{ py: 4, textAlign: 'center' }}>
                        No articles found.
                    </Typography>
                </Grid>
            )}
            {articleList.map((article) => (
                <Grid size={{ xs: 12 }} key={article.id}>
                    <Card
                        variant="outlined"
                        onClick={() => !isPending && handleViewArticle(article)}
                        sx={{
                            cursor: !isPending ? 'pointer' : 'default',
                            transition: 'all 0.2s',
                            '&:hover': !isPending ? {
                                boxShadow: '0 4px 16px rgba(27,42,74,0.08)',
                                transform: 'translateY(-1px)',
                            } : {},
                        }}
                    >
                        <CardContent>
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                                <Typography variant="h6">{article.title}</Typography>
                                <Chip
                                    label={article.status?.label}
                                    color={isPending ? 'primary' : 'success'}
                                    size="small"
                                />
                            </Box>
                            <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                Writer: {article.writer?.name} | Category: {article.category?.name} | {new Date(article.updated_at).toLocaleDateString()}
                            </Typography>
                            {reviewArticle?.id === article.id ? (
                                <Box sx={{ mt: 1 }}>
                                    <Typography
                                        variant="body1"
                                        dangerouslySetInnerHTML={{ __html: article.content }}
                                        sx={{ mb: 2, p: 2, bgcolor: 'grey.50', borderRadius: 1, border: '1px solid', borderColor: 'grey.200' }}
                                    />
                                </Box>
                            ) : (
                                <Typography
                                    variant="body2"
                                    sx={{
                                        overflow: 'hidden',
                                        textOverflow: 'ellipsis',
                                        display: '-webkit-box',
                                        WebkitLineClamp: 2,
                                        WebkitBoxOrient: 'vertical',
                                    }}
                                    dangerouslySetInnerHTML={{ __html: article.content }}
                                />
                            )}
                        </CardContent>
                        {isPending && (
                            <CardActions>
                                {reviewArticle?.id !== article.id ? (
                                    <Button
                                        size="small"
                                        startIcon={<ReviewIcon />}
                                        onClick={() => setReviewArticle(article)}
                                    >
                                        Review
                                    </Button>
                                ) : (
                                    <>
                                        <Button
                                            size="small"
                                            color="warning"
                                            startIcon={<RevisionIcon />}
                                            onClick={() => setRevisionDialog({ open: true, article })}
                                        >
                                            Request Revision
                                        </Button>
                                        <Button
                                            size="small"
                                            color="success"
                                            variant="contained"
                                            startIcon={<PublishIcon />}
                                            onClick={() => handlePublish(article)}
                                        >
                                            Publish
                                        </Button>
                                        <Button
                                            size="small"
                                            onClick={() => setReviewArticle(null)}
                                        >
                                            Close
                                        </Button>
                                    </>
                                )}
                            </CardActions>
                        )}
                        {!isPending && article.editor && (
                            <CardContent sx={{ pt: 0 }}>
                                <Typography variant="caption" color="text.secondary">
                                    Published by: {article.editor.name}
                                </Typography>
                            </CardContent>
                        )}
                    </Card>
                </Grid>
            ))}
        </Grid>
    );

    return (
        <AuthenticatedLayout>
            <Head title="Editor Dashboard" />

            <Box sx={{ display: 'flex' }}>
                <Drawer
                    variant="permanent"
                    sx={{
                        width: drawerWidth,
                        flexShrink: 0,
                        '& .MuiDrawer-paper': {
                            width: drawerWidth,
                            boxSizing: 'border-box',
                            position: 'relative',
                        },
                    }}
                >
                    <List>
                        <ListItemButton selected={view === 'pending'} onClick={() => setView('pending')}>
                            <ListItemIcon><PendingIcon /></ListItemIcon>
                            <ListItemText primary={`Pending (${pendingArticles.length})`} />
                        </ListItemButton>
                        <Divider />
                        <ListItemButton selected={view === 'published'} onClick={() => setView('published')}>
                            <ListItemIcon><PublishedIcon /></ListItemIcon>
                            <ListItemText primary={`Published (${publishedArticles.length})`} />
                        </ListItemButton>
                    </List>
                </Drawer>

                <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
                    {flash?.success && (
                        <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>
                    )}

                    {view === 'pending' && (
                        <Box>
                            <Typography variant="h6" gutterBottom>Pending Articles</Typography>
                            {renderArticleList(pendingArticles, true)}
                        </Box>
                    )}

                    {view === 'published' && (
                        <Box>
                            <Typography variant="h6" gutterBottom>Published Articles</Typography>
                            {renderArticleList(publishedArticles, false)}
                        </Box>
                    )}
                </Box>
            </Box>

            {/* Revision Request Dialog */}
            <Dialog
                open={revisionDialog.open}
                onClose={() => { setRevisionDialog({ open: false, article: null }); revisionForm.reset(); }}
                maxWidth="sm"
                fullWidth
            >
                <DialogTitle>Request Revision</DialogTitle>
                <DialogContent>
                    <Typography variant="body2" sx={{ mb: 2 }}>
                        Provide feedback for "{revisionDialog.article?.title}":
                    </Typography>
                    <TextField
                        label="Revision Comments"
                        multiline
                        rows={4}
                        fullWidth
                        value={revisionForm.data.comments}
                        onChange={(e) => revisionForm.setData('comments', e.target.value)}
                        error={!!revisionForm.errors.comments}
                        helperText={revisionForm.errors.comments}
                    />
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => { setRevisionDialog({ open: false, article: null }); revisionForm.reset(); }}>
                        Cancel
                    </Button>
                    <Button
                        onClick={handleRequestRevision}
                        color="warning"
                        variant="contained"
                        disabled={revisionForm.processing}
                    >
                        Send Revision Request
                    </Button>
                </DialogActions>
            </Dialog>

            {/* View Article Modal */}
            <Dialog
                open={viewModal.open}
                onClose={() => setViewModal({ open: false, article: null })}
                maxWidth="md"
                fullWidth
                PaperProps={{
                    sx: {
                        borderRadius: 3,
                        maxHeight: '90vh',
                    }
                }}
            >
                <DialogTitle sx={{ fontWeight: 700, fontSize: '1.25rem', pb: 1 }}>
                    {viewModal.article?.title}
                </DialogTitle>
                <DialogContent sx={{ pt: 0 }}>
                    <Box sx={{ display: 'flex', gap: 2, mb: 2, flexWrap: 'wrap' }}>
                        <Chip
                            label={viewModal.article?.category?.name}
                            size="small"
                            variant="outlined"
                            sx={{ height: 24, fontSize: '0.75rem', borderColor: '#E2E8F0', color: '#5A6B8A' }}
                        />
                        <Chip
                            label="Published"
                            size="small"
                            sx={{
                                bgcolor: '#E8F5E9',
                                color: '#2E7D32',
                                fontWeight: 600,
                                fontSize: '0.75rem',
                                height: 24,
                            }}
                        />
                        <Typography variant="caption" sx={{ color: '#8896AB', alignSelf: 'center' }}>
                            By {viewModal.article?.writer?.name}
                        </Typography>
                        <Typography variant="caption" sx={{ color: '#8896AB', alignSelf: 'center' }}>
                            Published by {viewModal.article?.editor?.name}
                        </Typography>
                    </Box>

                    {/* Article Content */}
                    <Box
                        sx={{
                            prose: {
                                img: { maxWidth: '100%', height: 'auto' },
                                p: { marginBottom: '1rem' },
                                h1: { marginTop: '1.5rem', marginBottom: '1rem', fontSize: '1.5rem', fontWeight: 700 },
                                h2: { marginTop: '1.25rem', marginBottom: '0.75rem', fontSize: '1.25rem', fontWeight: 600 },
                                h3: { marginTop: '1rem', marginBottom: '0.5rem', fontSize: '1.05rem', fontWeight: 600 },
                            }
                        }}
                    >
                        <Box
                            dangerouslySetInnerHTML={{ __html: viewModal.article?.content }}
                            sx={{
                                color: '#333',
                                lineHeight: 1.8,
                                '& img': { maxWidth: '100%', height: 'auto', borderRadius: 1, my: 2 },
                                '& p': { mb: 1.5 },
                                '& h1, & h2, & h3, & h4, & h5, & h6': { fontWeight: 700, my: 1.5 },
                                '& blockquote': { borderLeft: '4px solid #2A7B9B', pl: 2, py: 1, my: 1.5, fontStyle: 'italic', color: '#5A6B8A' },
                                '& ul, & ol': { ml: 2, mb: 1.5 },
                                '& li': { mb: 0.5 },
                                '& code': { bgcolor: '#F4F6F9', px: 1, py: 0.5, borderRadius: 1, fontSize: '0.9rem', fontFamily: 'monospace' },
                                '& pre': { bgcolor: '#F4F6F9', p: 2, borderRadius: 2, overflow: 'auto', mb: 1.5 },
                                '& table': { width: '100%', borderCollapse: 'collapse', mb: 1.5, border: '1px solid #E2E8F0' },
                                '& td, & th': { border: '1px solid #E2E8F0', p: 1 },
                                '& th': { bgcolor: '#F4F6F9', fontWeight: 600 },
                            }}
                        />
                    </Box>
                </DialogContent>
                <DialogActions sx={{ px: 3, pb: 2, pt: 1 }}>
                    <Button
                        onClick={() => setViewModal({ open: false, article: null })}
                        variant="contained"
                        sx={{ borderRadius: 2 }}
                    >
                        Close
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Snackbar */}
            <Snackbar
                open={snackbar.open}
                autoHideDuration={4000}
                onClose={() => setSnackbar({ open: false, message: '' })}
                message={snackbar.message}
            />
        </AuthenticatedLayout>
    );
}
