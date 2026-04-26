import { useMemo, useState } from 'react';
import { Head, Link } from '@inertiajs/react';
import {
    Box,
    Container,
    Card,
    CardContent,
    Typography,
    Button,
    Grid,
} from '@mui/material';
import LucideDashboardSidebar from '@/Components/LucideDashboardSidebar';

export default function StudentDashboard({ auth, articles, featuredArticles = [] }) {
    const [activeTab, setActiveTab] = useState('all');

    const allArticles = articles?.data || [];

    const tabs = useMemo(() => ({
        all: allArticles,
        featured: featuredArticles,
    }), [allArticles, featuredArticles]);

    const sidebarMenuItems = [
        { id: 'dashboard', label: 'Dashboard', href: '/student/dashboard' },
        {
            id: 'library',
            label: 'Reading',
            subItems: [
                { id: 'all', label: `All (${allArticles.length})`, href: '#all' },
                { id: 'featured', label: `Featured (${featuredArticles.length})`, href: '#featured' },
            ],
        },
        { id: 'comments', label: 'My Comments', href: '/student/my-comments' },
    ];

    const renderArticles = tabs[activeTab] || [];

    return (
        <>
            <Head title="Student Dashboard" />

            <Box sx={{ display: 'flex', minHeight: '100vh', background: '#0f172a' }}>
                <LucideDashboardSidebar
                    menuItems={sidebarMenuItems}
                    open
                    title="Student Hub"
                    userRole="student"
                    userName={auth?.user?.name}
                    userEmail={auth?.user?.email}
                />

                <Box sx={{ flexGrow: 1, p: { xs: 2, md: 4 } }}>
                    <Container maxWidth="lg" disableGutters>
                        <Typography variant="h4" sx={{ color: 'white', mb: 1, fontWeight: 800 }}>
                            Student Dashboard
                        </Typography>
                        <Typography sx={{ color: '#cbd5e1', mb: 3 }}>
                            Read published articles and comment. Students cannot create articles.
                        </Typography>

                        <Box sx={{ display: 'flex', gap: 1, mb: 3 }}>
                            <Button variant={activeTab === 'all' ? 'contained' : 'outlined'} onClick={() => setActiveTab('all')}>
                                All Articles
                            </Button>
                            <Button variant={activeTab === 'featured' ? 'contained' : 'outlined'} onClick={() => setActiveTab('featured')}>
                                Featured
                            </Button>
                        </Box>

                        <Grid container spacing={2}>
                            {renderArticles.map((article) => (
                                <Grid item xs={12} md={6} lg={4} key={article.id}>
                                    <Card sx={{ background: 'rgba(30,41,59,0.8)', color: 'white' }}>
                                        <CardContent>
                                            <Typography variant="h6" sx={{ mb: 1, fontWeight: 700 }}>
                                                {article.title}
                                            </Typography>
                                            <Typography sx={{ opacity: 0.8, mb: 2 }}>
                                                By {article.writer?.name || 'Unknown writer'}
                                            </Typography>
                                            <Typography sx={{ opacity: 0.7, mb: 2 }}>
                                                {(article.content || '').replace(/<[^>]+>/g, '').slice(0, 120)}
                                            </Typography>
                                            <Button
                                                component={Link}
                                                href={route('student.articles.show', article.id)}
                                                size="small"
                                                variant="contained"
                                            >
                                                Read & Comment
                                            </Button>
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
