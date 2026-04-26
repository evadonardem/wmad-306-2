import { useMemo, useState } from 'react';
import { Head, Link, router, useForm } from '@inertiajs/react';
import {
    Box,
    Container,
    Card,
    CardContent,
    Typography,
    Button,
    Grid,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
} from '@mui/material';
import { Eye } from 'lucide-react';
import LucideDashboardSidebar from '@/Components/LucideDashboardSidebar';

export default function EditorDashboard({
    auth,
    submittedArticles = [],
    revisionArticles = [],
    publishedArticles = [],
}) {
    const [activeTab, setActiveTab] = useState('submitted');
    const [selectedArticle, setSelectedArticle] = useState(null);

    const { data, setData, post, processing, errors, reset } = useForm({ comments: '' });

    const allArticles = useMemo(
        () => [...submittedArticles, ...revisionArticles, ...publishedArticles],
        [submittedArticles, revisionArticles, publishedArticles]
    );

    const stats = {
        total: allArticles.length,
        submitted: submittedArticles.length,
        revision: revisionArticles.length,
        published: publishedArticles.length,
    };

    const tabMap = {
        submitted: submittedArticles,
        revision: revisionArticles,
        published: publishedArticles,
    };

    const articles = tabMap[activeTab] ?? [];

    const sidebarMenuItems = [
        { id: 'dashboard', label: 'Dashboard', href: '/editor/dashboard' },
        {
            id: 'reviews',
            label: 'Reviews',
            subItems: [
                { id: 'submitted', label: `Submitted (${stats.submitted})`, href: '#submitted' },
                { id: 'revision', label: `Needs Revision (${stats.revision})`, href: '#revision' },
                { id: 'published', label: `Published (${stats.published})`, href: '#published' },
            ],
        },
    ];

    const openRevisionDialog = (article) => {
        setSelectedArticle(article);
        setData('comments', '');
    };

    const closeRevisionDialog = () => {
        setSelectedArticle(null);
        reset('comments');
    };

    const requestRevision = () => {
        if (!selectedArticle) return;
        post(route('editor.articles.request-revision', selectedArticle.id), {
            preserveScroll: true,
            onSuccess: () => closeRevisionDialog(),
        });
    };

    const publishArticle = (articleId) => {
        router.post(route('editor.articles.publish', articleId));
    };

    return (
        <>
            <Head title="Editor Dashboard" />

            <Box sx={{ display: 'flex', minHeight: '100vh', background: '#0f172a' }}>
                <LucideDashboardSidebar
                    menuItems={sidebarMenuItems}
                    open
                    title="Editor Hub"
                    userRole="editor"
                    userName={auth?.user?.name}
                    userEmail={auth?.user?.email}
                />

                <Box sx={{ flexGrow: 1, p: { xs: 2, md: 4 } }}>
                    <Container maxWidth="lg" disableGutters>
                        <Typography variant="h4" sx={{ color: 'white', mb: 3, fontWeight: 800 }}>
                            Editor Dashboard
                        </Typography>

                        <Grid container spacing={2} sx={{ mb: 3 }}>
                            <Grid item><Typography sx={{ color: '#cbd5e1' }}>Total: {stats.total}</Typography></Grid>
                            <Grid item><Typography sx={{ color: '#cbd5e1' }}>Submitted: {stats.submitted}</Typography></Grid>
                            <Grid item><Typography sx={{ color: '#cbd5e1' }}>Needs Revision: {stats.revision}</Typography></Grid>
                            <Grid item><Typography sx={{ color: '#cbd5e1' }}>Published: {stats.published}</Typography></Grid>
                        </Grid>

                        <Box sx={{ display: 'flex', gap: 1, mb: 3, flexWrap: 'wrap' }}>
                            {['submitted', 'revision', 'published'].map((tab) => (
                                <Button
                                    key={tab}
                                    variant={activeTab === tab ? 'contained' : 'outlined'}
                                    onClick={() => setActiveTab(tab)}
                                >
                                    {tab}
                                </Button>
                            ))}
                        </Box>

                        <Grid container spacing={2}>
                            {articles.map((article) => (
                                <Grid item xs={12} md={6} lg={4} key={article.id}>
                                    <Card sx={{ background: 'rgba(30,41,59,0.8)', color: 'white' }}>
                                        <CardContent>
                                            <Typography variant="h6" sx={{ mb: 1, fontWeight: 700 }}>
                                                {article.title}
                                            </Typography>
                                            <Typography sx={{ opacity: 0.8, mb: 1 }}>
                                                By: {article.writer?.name || 'Unknown writer'}
                                            </Typography>
                                            <Typography sx={{ opacity: 0.7, mb: 2 }}>
                                                {(article.content || '').replace(/<[^>]+>/g, '').slice(0, 120)}
                                            </Typography>

                                            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                                <Button
                                                    component={Link}
                                                    href={route('editor.articles.review', article.id)}
                                                    size="small"
                                                    variant="contained"
                                                    startIcon={<Eye size={14} />}
                                                >
                                                    Review
                                                </Button>

                                                {article.status?.name !== 'Published' && (
                                                    <>
                                                        <Button
                                                            size="small"
                                                            variant="outlined"
                                                            color="success"
                                                            onClick={() => publishArticle(article.id)}
                                                        >
                                                            Publish
                                                        </Button>
                                                        <Button
                                                            size="small"
                                                            variant="outlined"
                                                            color="warning"
                                                            onClick={() => openRevisionDialog(article)}
                                                        >
                                                            Request Revision
                                                        </Button>
                                                    </>
                                                )}
                                            </Box>
                                        </CardContent>
                                    </Card>
                                </Grid>
                            ))}
                        </Grid>
                    </Container>
                </Box>
            </Box>

            <Dialog open={!!selectedArticle} onClose={closeRevisionDialog} fullWidth maxWidth="sm">
                <DialogTitle>Request Revision</DialogTitle>
                <DialogContent>
                    <Typography sx={{ mb: 2 }}>
                        {selectedArticle ? `Article: ${selectedArticle.title}` : ''}
                    </Typography>
                    <TextField
                        fullWidth
                        multiline
                        rows={4}
                        label="Revision comments"
                        value={data.comments}
                        onChange={(e) => setData('comments', e.target.value)}
                        error={!!errors.comments}
                        helperText={errors.comments}
                    />
                </DialogContent>
                <DialogActions>
                    <Button onClick={closeRevisionDialog}>Cancel</Button>
                    <Button onClick={requestRevision} variant="contained" disabled={processing}>
                        Send
                    </Button>
                </DialogActions>
            </Dialog>
        </>
    );
}
