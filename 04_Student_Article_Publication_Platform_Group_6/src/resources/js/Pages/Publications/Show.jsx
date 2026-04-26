import ApplicationLogo from '@/Components/ApplicationLogo';
import ThemeModeToggle from '@/Components/ThemeModeToggle';
import { Head, Link, useForm, usePage } from '@inertiajs/react';
import { Alert, Box, Button, Card, CardContent, Container, Divider, Paper, Stack, TextField, Typography } from '@mui/material';
import { alpha, useTheme } from '@mui/material/styles';

const stripHtml = (value) => value?.replace(/<[^>]*>?/gm, '') ?? '';

export default function PublicPublicationShow({ article, latestPublications = [] }) {
    const theme = useTheme();
    const { auth, flash } = usePage().props;
    const homeHref = auth?.user ? route('dashboard') : route('welcome');
    const isGuest = !auth?.user;
    const isStudent = auth?.roles?.includes('student');
    
    // For the preview, we strip HTML so we don't accidentally cut a tag in half
    const plainContent = stripHtml(article?.content);
    const previewText = plainContent.slice(0, 1400);
    const commentForm = useForm({ content: '' });

    const submitComment = (event) => {
        event.preventDefault();
        commentForm.post(route('articles.comment', article.id), {
            onSuccess: () => commentForm.reset('content'),
        });
    };

    // Sleek reveal animations for the article view
    const showAnimations = `
        @keyframes reveal-up {
            0% { transform: translateY(30px); opacity: 0; filter: blur(4px); }
            100% { transform: translateY(0); opacity: 1; filter: blur(0); }
        }
        .animate-reveal-0 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
        .animate-reveal-1 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
        .animate-reveal-2 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
        .animate-reveal-3 { animation: reveal-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both; }
    `;

    return (
        <>
            <Head title={article?.title ?? 'Publication'} />
            <style>{showAnimations}</style>

            <Box
                sx={{
                    minHeight: '100vh',
                    background: `radial-gradient(1000px 360px at 12% -10%, ${alpha(theme.palette.primary.main, 0.16)}, transparent), ${theme.palette.background.default}`,
                }}
            >
                <Container maxWidth="lg" className="publication-show-wrap" sx={{ py: { xs: 3, md: 5 } }}>
                    {/* Header Nav - Animates First */}
                    <Stack className="animate-reveal-0" direction="row" alignItems="center" justifyContent="space-between" sx={{ mb: 4 }}>
                        <Stack component={Link} href={homeHref} direction="row" spacing={1} sx={{ textDecoration: 'none', color: 'text.primary', alignItems: 'center' }}>
                            <ApplicationLogo style={{ width: 32, height: 32, color: theme.palette.primary.main }} />
                            <Typography variant="h6" sx={{ fontWeight: 'bold' }}>Campus Press</Typography>
                        </Stack>
                        <Stack direction="row" spacing={2} alignItems="center">
                            <ThemeModeToggle size="small" />
                            {auth?.user ? (
                                <Button variant="contained" component={Link} href={route('dashboard')} sx={{ borderRadius: 2, textTransform: 'none', fontWeight: 'bold' }}>
                                    Dashboard
                                </Button>
                            ) : (
                                <Button variant="contained" component={Link} href={route('login')} sx={{ borderRadius: 2, textTransform: 'none', fontWeight: 'bold' }}>
                                    Log in
                                </Button>
                            )}
                        </Stack>
                    </Stack>

                    {/* Main Article Area - Animates Second */}
                    <Paper className="publication-show-paper animate-reveal-1" sx={{ p: { xs: 3, md: 6 }, borderRadius: 4, boxShadow: theme.shadows[2] }}>
                        <div className="mb-6">
                            <span className="inline-flex items-center rounded-full bg-blue-50 dark:bg-blue-900/30 px-3 py-1 text-xs font-black uppercase tracking-wider text-[#2f6fdb] mb-3">
                                {article?.category?.name || 'Journal'}
                            </span>
                            <Typography variant="h3" sx={{ fontSize: { xs: '2rem', md: '3rem' }, fontWeight: 900, lineHeight: 1.2, color: 'text.primary' }}>
                                {article?.title}
                            </Typography>
                            
                            <div className="flex flex-wrap items-center gap-3 mt-4 text-gray-500 dark:text-gray-400">
                                <Typography variant="subtitle1" sx={{ fontWeight: 600, color: 'text.primary' }}>
                                    By {article?.writer?.name}
                                </Typography>
                                
                                {/* WRITER TIER BADGE */}
                                <span className="inline-flex items-center rounded-md bg-amber-100 dark:bg-amber-900/30 px-2.5 py-1 text-xs font-black uppercase tracking-wider text-amber-800 dark:text-amber-400 border border-amber-200 dark:border-amber-800/50">
                                    🏆 {article?.writer?.writer_tier || 'Entry-Level Writer'}
                                </span>
                                
                                <Typography variant="body2">
                                    • Updated {new Date(article?.updated_at).toLocaleDateString()}
                                </Typography>
                            </div>
                        </div>

                        <Divider sx={{ my: 4 }} />

                        {/* Article Content */}
                        {isGuest ? (
                            <Box>
                                <Typography sx={{ whiteSpace: 'pre-line', fontSize: '1.125rem', lineHeight: 1.8, color: 'text.secondary' }}>
                                    {previewText}{plainContent.length > previewText.length ? '...' : ''}
                                </Typography>
                                
                                {/* Paywall / Login Wall */}
                                <Paper sx={{ mt: 6, p: 4, bgcolor: alpha(theme.palette.primary.main, 0.05), borderRadius: 3, textAlign: 'center', border: `1px solid ${alpha(theme.palette.primary.main, 0.1)}` }}>
                                    <span className="text-4xl mb-2 block">🔒</span>
                                    <Typography variant="h6" sx={{ fontWeight: 'bold' }}>Guest Preview Access</Typography>
                                    <Typography variant="body1" color="text.secondary" sx={{ mt: 1, mb: 3, maxWidth: 500, mx: 'auto' }}>
                                        You are viewing a limited journal preview. Sign in to your campus account to read the full story and join the conversation.
                                    </Typography>
                                    <Button size="large" variant="contained" component={Link} href={route('login')} sx={{ borderRadius: 2, px: 4, fontWeight: 'bold' }}>
                                        Log in for full access
                                    </Button>
                                </Paper>
                            </Box>
                        ) : (
                            <Box>
                                {/* We use dangerouslySetInnerHTML here so JoditEditor's rich text renders properly */}
                                <Box 
                                    sx={{ 
                                        fontSize: '1.125rem', 
                                        lineHeight: 1.8, 
                                        color: 'text.primary',
                                        '& p': { mb: 2 },
                                        '& ul': { pl: 4, mb: 2, listStyleType: 'disc' },
                                        '& ol': { pl: 4, mb: 2, listStyleType: 'decimal' },
                                        '& h1, & h2, & h3': { mt: 4, mb: 2, fontWeight: 'bold' },
                                        '& a': { color: theme.palette.primary.main, textDecoration: 'underline' }
                                    }}
                                    dangerouslySetInnerHTML={{ __html: article?.content }}
                                />
                            </Box>
                        )}

                        {/* Comments Section - Animates Third */}
                        {!isGuest && (
                            <Box className="animate-reveal-2" sx={{ mt: 8, pt: 4, borderTop: `1px solid ${theme.palette.divider}` }}>
                                <Typography variant="h5" sx={{ fontWeight: 'bold', mb: 3 }}>
                                    Discussion ({article?.comments?.length || 0})
                                </Typography>

                                {flash?.success && (
                                    <Alert severity="success" sx={{ mb: 3, borderRadius: 2 }}>
                                        {flash.success}
                                    </Alert>
                                )}

                                {isStudent ? (
                                    <Paper elevation={0} sx={{ p: 3, bgcolor: alpha(theme.palette.background.default, 0.5), borderRadius: 3, border: `1px solid ${theme.palette.divider}`, mb: 4 }}>
                                        <Stack component="form" onSubmit={submitComment} spacing={2}>
                                            <TextField
                                                placeholder="What are your thoughts?"
                                                multiline
                                                minRows={3}
                                                value={commentForm.data.content}
                                                onChange={(event) => commentForm.setData('content', event.target.value)}
                                                error={Boolean(commentForm.errors.content)}
                                                helperText={commentForm.errors.content}
                                                fullWidth
                                                variant="outlined"
                                                sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: 'background.paper' } }}
                                            />
                                            <Button type="submit" variant="contained" sx={{ alignSelf: 'flex-end', borderRadius: 2, px: 4, fontWeight: 'bold' }} disabled={commentForm.processing}>
                                                Post Comment
                                            </Button>
                                        </Stack>
                                    </Paper>
                                ) : (
                                    <Alert severity="info" sx={{ mb: 4, borderRadius: 2 }}>
                                        Only student accounts can participate in the discussion.
                                    </Alert>
                                )}

                                <Stack spacing={2}>
                                    {(article?.comments ?? []).slice(0, 10).map((comment) => (
                                        <Paper key={comment.id} variant="outlined" sx={{ p: 2.5, borderRadius: 3, bgcolor: 'background.default' }}>
                                            <Stack direction="row" alignItems="center" spacing={1.5} sx={{ mb: 1 }}>
                                                <div className="h-8 w-8 rounded-full bg-[#2f6fdb] text-white flex items-center justify-center font-bold text-sm">
                                                    {(comment.student?.name ?? 'S')[0]}
                                                </div>
                                                <Typography variant="subtitle2" sx={{ fontWeight: 'bold' }}>
                                                    {comment.student?.name ?? 'Student'}
                                                </Typography>
                                            </Stack>
                                            <Typography variant="body1" sx={{ color: 'text.secondary', pl: 4.5 }}>
                                                {comment.content}
                                            </Typography>
                                        </Paper>
                                    ))}
                                    {article?.comments?.length === 0 && (
                                        <Typography color="text.secondary" sx={{ fontStyle: 'italic', textAlign: 'center', py: 4 }}>
                                            Be the first to share your thoughts!
                                        </Typography>
                                    )}
                                </Stack>
                            </Box>
                        )}
                    </Paper>

                    {/* More Publications Section - Animates Fourth */}
                    {latestPublications.length > 0 && (
                        <Box className="publication-show-more animate-reveal-3" sx={{ mt: 8 }}>
                            <Typography variant="h5" sx={{ mb: 3, fontWeight: 'bold' }}>
                                More from the Press
                            </Typography>
                            <Box className="publication-show-more-grid" sx={{ display: 'grid', gap: 3, gridTemplateColumns: { xs: '1fr', md: 'repeat(2, 1fr)' } }}>
                                {latestPublications.map((item, index) => (
                                    <Card 
                                        key={item.id}
                                        className="publication-show-more-card"
                                        sx={{ 
                                            borderRadius: 3, 
                                            transition: 'all 0.4s cubic-bezier(0.16, 1, 0.3, 1)', 
                                            '&:hover': { transform: 'translateY(-6px)', boxShadow: theme.shadows[6] } 
                                        }}
                                    >
                                        <CardContent sx={{ p: 3 }}>
                                            <div className="flex justify-between items-start mb-2">
                                                <Typography variant="h6" sx={{ fontWeight: 'bold', lineHeight: 1.3, mb: 1 }}>
                                                    {item.title}
                                                </Typography>
                                            </div>
                                            <Typography variant="caption" sx={{ display: 'block', mb: 2, color: 'text.secondary', fontWeight: 'bold' }}>
                                                By {item?.writer?.name} • <span className="text-[#2f6fdb]">{item?.writer?.writer_tier || 'Entry-Level Writer'}</span>
                                            </Typography>
                                            <Typography color="text.secondary" sx={{ mb: 3, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                                                {stripHtml(item.content)}
                                            </Typography>
                                            <Button variant="outlined" component={Link} href={route('publications.show', item.id)} sx={{ borderRadius: 2, textTransform: 'none', fontWeight: 'bold', width: '100%' }}>
                                                Read Article
                                            </Button>
                                        </CardContent>
                                    </Card>
                                ))}
                            </Box>
                        </Box>
                    )}
                </Container>
            </Box>
        </>
    );
}
