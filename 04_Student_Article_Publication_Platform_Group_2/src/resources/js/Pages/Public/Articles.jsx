import { Head, Link, router, usePage } from '@inertiajs/react';
import { useState } from 'react';
import {
    AppBar,
    Toolbar,
    Typography,
    Box,
    Button,
    Container,
    Grid,
    Card,
    CardContent,
    Chip,
    Pagination,
    Stack,
    Avatar,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogContentText,
    DialogActions,
} from '@mui/material';
import { Article as ArticleIcon, ChatBubbleOutline } from '@mui/icons-material';

export default function Articles({ articles }) {
    const { auth } = usePage().props;
    const user = auth?.user;
    const roles = auth?.roles || [];
    const [signupDialogOpen, setSignupDialogOpen] = useState(false);

    const handlePageChange = (_event, page) => {
        router.get(
            route('public.articles.index'),
            { page },
            { preserveState: true, preserveScroll: true }
        );
    };

    const handleReadMore = (articleId) => {
        if (!user) {
            setSignupDialogOpen(true);
            return;
        }

        if (roles.includes('student')) {
            router.visit(route('articles.show', articleId));
            return;
        }

        router.visit('/dashboard');
    };

    return (
        <>
            <Head title="Published Articles" />

            <AppBar
                position="sticky"
                elevation={0}
                sx={{
                    backgroundColor: '#FFFFFF',
                    borderBottom: '1px solid',
                    borderColor: 'divider',
                }}
            >
                <Container maxWidth="lg">
                    <Toolbar sx={{ justifyContent: 'space-between', px: 0 }}>
                        <Box
                            component={Link}
                            href="/"
                            sx={{
                                display: 'flex',
                                alignItems: 'center',
                                gap: 1,
                                textDecoration: 'none',
                            }}
                        >
                            <Box
                                sx={{
                                    width: 40,
                                    height: 40,
                                    borderRadius: '10px',
                                    background: 'linear-gradient(135deg, #1B2A4A 0%, #2A7B9B 100%)',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                }}
                            >
                                <ArticleIcon sx={{ color: '#fff', fontSize: 20 }} />
                            </Box>
                            <Typography
                                variant="h5"
                                sx={{
                                    fontWeight: 800,
                                    color: 'primary.main',
                                    letterSpacing: '-0.02em',
                                }}
                            >
                                UniVox
                            </Typography>
                        </Box>

                        <Stack direction="row" spacing={1.5} alignItems="center">
                            <Button component={Link} href="/" color="inherit">
                                Home
                            </Button>
                            {user ? (
                                <>
                                    <Avatar
                                        sx={{
                                            width: 34,
                                            height: 34,
                                            bgcolor: 'primary.main',
                                            fontSize: '0.875rem',
                                            fontWeight: 700,
                                        }}
                                    >
                                        {user.name?.charAt(0)?.toUpperCase() || 'U'}
                                    </Avatar>
                                    <Button variant="contained" component={Link} href="/dashboard">
                                        Dashboard
                                    </Button>
                                </>
                            ) : (
                                <>
                                    <Button component={Link} href="/login" color="inherit">
                                        Log In
                                    </Button>
                                    <Button variant="contained" component={Link} href="/register">
                                        Sign Up
                                    </Button>
                                </>
                            )}
                        </Stack>
                    </Toolbar>
                </Container>
            </AppBar>

            <Box sx={{ py: { xs: 5, md: 7 }, backgroundColor: 'background.default', minHeight: '100vh' }}>
                <Container maxWidth="lg">
                    <Box sx={{ mb: 4 }}>
                        <Typography variant="h4" sx={{ fontWeight: 800, mb: 1 }}>
                            Published Articles
                        </Typography>
                        <Typography variant="body1" color="text.secondary">
                            Explore all articles published on UniVox.
                        </Typography>
                    </Box>

                    <Grid container spacing={2.5}>
                        {articles.data.map((article) => (
                            <Grid size={{ xs: 12, md: 6, lg: 4 }} key={article.id}>
                                <Card
                                    sx={{
                                        height: '100%',
                                        minHeight: 280,
                                        border: '1px solid',
                                        borderColor: 'divider',
                                        boxShadow: 'none',
                                        display: 'flex',
                                        flexDirection: 'column',
                                    }}
                                >
                                    <CardContent
                                        sx={{
                                            p: 2.5,
                                            display: 'flex',
                                            flexDirection: 'column',
                                            height: '100%',
                                        }}
                                    >
                                        <Typography
                                            variant="h6"
                                            sx={{
                                                fontWeight: 700,
                                                mb: 1,
                                                minHeight: 64,
                                                display: '-webkit-box',
                                                WebkitLineClamp: 2,
                                                WebkitBoxOrient: 'vertical',
                                                overflow: 'hidden',
                                            }}
                                        >
                                            {article.title}
                                        </Typography>

                                        <Stack direction="row" spacing={1} sx={{ mb: 1.5, flexWrap: 'wrap' }}>
                                            <Chip label={article.category || 'General'} size="small" variant="outlined" />
                                            <Chip
                                                icon={<ChatBubbleOutline sx={{ fontSize: 14 }} />}
                                                label={`${article.comments_count} comments`}
                                                size="small"
                                                variant="outlined"
                                            />
                                        </Stack>

                                        <Typography
                                            variant="body2"
                                            color="text.secondary"
                                            sx={{ mb: 1.5, minHeight: 22 }}
                                        >
                                            By {article.writer || 'Unknown Writer'} • {new Date(article.published_at).toLocaleDateString()}
                                        </Typography>

                                        <Typography
                                            variant="body2"
                                            sx={{
                                                lineHeight: 1.7,
                                                color: 'text.secondary',
                                                minHeight: 74,
                                                display: '-webkit-box',
                                                WebkitLineClamp: 3,
                                                WebkitBoxOrient: 'vertical',
                                                overflow: 'hidden',
                                            }}
                                        >
                                            {article.excerpt}
                                        </Typography>

                                        <Button
                                            size="small"
                                            sx={{ mt: 'auto', pt: 1.5, px: 0, fontWeight: 700, alignSelf: 'flex-start' }}
                                            onClick={() => handleReadMore(article.id)}
                                        >
                                            Read More
                                        </Button>
                                    </CardContent>
                                </Card>
                            </Grid>
                        ))}
                    </Grid>

                    {articles.last_page > 1 && (
                        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
                            <Pagination
                                count={articles.last_page}
                                page={articles.current_page}
                                onChange={handlePageChange}
                                color="primary"
                            />
                        </Box>
                    )}
                </Container>
            </Box>

            <Dialog
                open={signupDialogOpen && !user}
                onClose={() => setSignupDialogOpen(false)}
                maxWidth="xs"
                fullWidth
            >
                <DialogTitle sx={{ fontWeight: 700 }}>Sign Up Required</DialogTitle>
                <DialogContent>
                    <DialogContentText>
                        You need to sign up to read more articles. Do you want to go to the registration page now?
                    </DialogContentText>
                </DialogContent>
                <DialogActions sx={{ px: 3, pb: 2 }}>
                    <Button variant="text" onClick={() => setSignupDialogOpen(false)}>
                        No
                    </Button>
                    <Button variant="contained" onClick={() => router.visit('/register')}>
                        Yes
                    </Button>
                </DialogActions>
            </Dialog>
        </>
    );
}
