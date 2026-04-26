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
    FormControl,
    InputLabel,
    Select,
    MenuItem,
} from '@mui/material';
import { Eye, Edit2, Send } from 'lucide-react';
import LucideDashboardSidebar from '@/Components/LucideDashboardSidebar';

export default function WriterDashboard({
    auth,
    draftArticles = [],
    submittedArticles = [],
    revisionArticles = [],
    publishedArticles = [],
    categories = [],
}) {
    const [activeTab, setActiveTab] = useState('all');

    const { data, setData, post, processing, errors, reset } = useForm({
        title: '',
        content: '',
        category_id: '',
    });

    const articlesByTab = useMemo(() => {
        const all = [
            ...draftArticles,
            ...submittedArticles,
            ...revisionArticles,
            ...publishedArticles,
        ];

        return {
            all,
            draft: draftArticles,
            submitted: submittedArticles,
            revision: revisionArticles,
            published: publishedArticles,
        };
    }, [draftArticles, submittedArticles, revisionArticles, publishedArticles]);

    const stats = {
        total: articlesByTab.all.length,
        draft: draftArticles.length,
        submitted: submittedArticles.length,
        revision: revisionArticles.length,
        published: publishedArticles.length,
    };

    const handleCreate = (e) => {
        e.preventDefault();
        post(route('writer.articles.store'), {
            onSuccess: () => reset(),
        });
    };

    const handleSubmitArticle = (articleId) => {
        router.post(route('writer.articles.submit', articleId));
    };

    const sidebarMenuItems = [
        { id: 'dashboard', label: 'Dashboard', href: '/writer/dashboard' },
        {
            id: 'articles',
            label: 'My Articles',
            subItems: [
                { id: 'all', label: `All (${stats.total})`, href: '#all' },
                { id: 'draft', label: `Drafts (${stats.draft})`, href: '#draft' },
                { id: 'submitted', label: `Submitted (${stats.submitted})`, href: '#submitted' },
                { id: 'revision', label: `Needs Revision (${stats.revision})`, href: '#revision' },
                { id: 'published', label: `Published (${stats.published})`, href: '#published' },
            ],
        },
    ];

    const articles = articlesByTab[activeTab] ?? [];

    return (
        <>
            <Head title="Writer Dashboard" />

            <Box sx={{ display: 'flex', minHeight: '100vh', background: '#0f172a' }}>
                <LucideDashboardSidebar
                    menuItems={sidebarMenuItems}
                    open
                    title="Writer Hub"
                    userRole="writer"
                    userName={auth?.user?.name}
                    userEmail={auth?.user?.email}
                />

                <Box sx={{ flexGrow: 1, p: { xs: 2, md: 4 } }}>
                    <Container maxWidth="lg" disableGutters>
                        <Typography variant="h4" sx={{ color: 'white', mb: 3, fontWeight: 800 }}>
                            Writer Dashboard
                        </Typography>

                        <Card sx={{ mb: 3, p: 2, background: 'rgba(30,41,59,0.8)' }}>
                            <Typography variant="h6" sx={{ color: 'white', mb: 2 }}>
                                Create New Article (Draft)
                            </Typography>

                            <Box component="form" onSubmit={handleCreate}>
                                <Grid container spacing={2}>
                                    <Grid item xs={12} md={4}>
                                        <TextField
                                            fullWidth
                                            label="Title"
                                            value={data.title}
                                            onChange={(e) => setData('title', e.target.value)}
                                            error={!!errors.title}
                                            helperText={errors.title}
                                        />
                                    </Grid>
                                    <Grid item xs={12} md={4}>
                                        <TextField
                                            fullWidth
                                            label="Content"
                                            value={data.content}
                                            onChange={(e) => setData('content', e.target.value)}
                                            error={!!errors.content}
                                            helperText={errors.content}
                                        />
                                    </Grid>
                                    <Grid item xs={12} md={2}>
                                        <FormControl fullWidth>
                                            <InputLabel>Category</InputLabel>
                                            <Select
                                                label="Category"
                                                value={data.category_id}
                                                onChange={(e) => setData('category_id', e.target.value)}
                                            >
                                                {categories.map((category) => (
                                                    <MenuItem key={category.id} value={category.id}>
                                                        {category.name}
                                                    </MenuItem>
                                                ))}
                                            </Select>
                                        </FormControl>
                                    </Grid>
                                    <Grid item xs={12} md={2}>
                                        <Button
                                            type="submit"
                                            fullWidth
                                            variant="contained"
                                            disabled={processing}
                                            sx={{ height: '56px' }}
                                        >
                                            Save Draft
                                        </Button>
                                    </Grid>
                                </Grid>
                            </Box>
                        </Card>

                        <Box sx={{ display: 'flex', gap: 1, mb: 3, flexWrap: 'wrap' }}>
                            {['all', 'draft', 'submitted', 'revision', 'published'].map((tab) => (
                                <Button
                                    key={tab}
                                    onClick={() => setActiveTab(tab)}
                                    variant={activeTab === tab ? 'contained' : 'outlined'}
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
                                                {(article.content || '').replace(/<[^>]+>/g, '').slice(0, 120)}
                                            </Typography>
                                            <Typography sx={{ fontSize: 13, opacity: 0.7, mb: 2 }}>
                                                {article.category?.name || 'No category'}
                                            </Typography>

                                            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                                <Button
                                                    component={Link}
                                                    href={route('writer.articles.show', article.id)}
                                                    size="small"
                                                    variant="contained"
                                                    startIcon={<Eye size={14} />}
                                                >
                                                    View
                                                </Button>
                                                <Button
                                                    component={Link}
                                                    href={route('writer.articles.edit', article.id)}
                                                    size="small"
                                                    variant="outlined"
                                                    startIcon={<Edit2 size={14} />}
                                                >
                                                    Edit
                                                </Button>
                                                {article.status?.name === 'Draft' && (
                                                    <Button
                                                        size="small"
                                                        variant="outlined"
                                                        color="success"
                                                        startIcon={<Send size={14} />}
                                                        onClick={() => handleSubmitArticle(article.id)}
                                                    >
                                                        Submit
                                                    </Button>
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
        </>
    );
}
