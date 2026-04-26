import { Head, useForm, usePage, router } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import {
    Box,
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
    Snackbar,
    Avatar,
} from '@mui/material';
import {
    Article as ArticleIcon,
    Comment as CommentIcon,
    Visibility as ViewIcon,
} from '@mui/icons-material';
import { useMemo, useState } from 'react';

const drawerWidth = 240;

export default function Dashboard({ articles, myComments }) {
    const { flash } = usePage().props;
    const [view, setView] = useState('articles');
    const [selectedArticle, setSelectedArticle] = useState(null);
    const [snackbar, setSnackbar] = useState({ open: false, message: '' });
    const [visibleComments, setVisibleComments] = useState(10);

    const selectedArticleComments = selectedArticle?.comments || [];
    const displayedComments = useMemo(
        () => selectedArticleComments.slice(0, visibleComments),
        [selectedArticleComments, visibleComments]
    );
    const hasMoreComments = selectedArticleComments.length > visibleComments;

    const commentForm = useForm({
        content: '',
    });

    const handleComment = (e) => {
        e.preventDefault();
        commentForm.post(route('articles.comment', selectedArticle.id), {
            onSuccess: () => {
                commentForm.reset();
                setSnackbar({ open: true, message: 'Comment posted!' });
            },
        });
    };

    const getPreviewText = (html = '') => {
        return html
            .replace(/<img[^>]*>/gi, ' ')
            .replace(/<[^>]*>/g, ' ')
            .replace(/&nbsp;/g, ' ')
            .replace(/\s+/g, ' ')
            .trim();
    };

    return (
        <AuthenticatedLayout>
            <Head title="Student Dashboard" />

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
                        <ListItemButton selected={view === 'articles'} onClick={() => { setView('articles'); setSelectedArticle(null); }}>
                            <ListItemIcon><ArticleIcon /></ListItemIcon>
                            <ListItemText primary={`Articles (${articles.length})`} />
                        </ListItemButton>
                        <Divider />
                        <ListItemButton selected={view === 'comments'} onClick={() => { setView('comments'); setSelectedArticle(null); }}>
                            <ListItemIcon><CommentIcon /></ListItemIcon>
                            <ListItemText primary={`My Comments (${myComments.length})`} />
                        </ListItemButton>
                    </List>
                </Drawer>

                <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
                    {flash?.success && (
                        <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>
                    )}

                    {view === 'articles' && !selectedArticle && (
                        <Box>
                            <Typography variant="h6" gutterBottom>Published Articles</Typography>
                            <Grid container spacing={2}>
                                {articles.length === 0 && (
                                    <Grid size={12}>
                                        <Typography color="text.secondary" sx={{ py: 4, textAlign: 'center' }}>
                                            No published articles yet.
                                        </Typography>
                                    </Grid>
                                )}
                                {articles.map((article) => (
                                    <Grid size={{ xs: 12, md: 6 }} key={article.id}>
                                        <Card variant="outlined">
                                            <CardContent>
                                                <Typography variant="h6" gutterBottom>{article.title}</Typography>
                                                <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                                    By {article.writer?.name} | {article.category?.name} | {new Date(article.created_at).toLocaleDateString()}
                                                </Typography>
                                                <Typography
                                                    variant="body2"
                                                    sx={{
                                                        minHeight: 72,
                                                        overflow: 'hidden',
                                                        textOverflow: 'ellipsis',
                                                        display: '-webkit-box',
                                                        WebkitLineClamp: 3,
                                                        WebkitBoxOrient: 'vertical',
                                                    }}
                                                >
                                                    {getPreviewText(article.content)}
                                                </Typography>
                                            </CardContent>
                                            <CardActions>
                                                <Button
                                                    size="small"
                                                    startIcon={<ViewIcon />}
                                                    onClick={() => {
                                                        setSelectedArticle(article);
                                                        setVisibleComments(10);
                                                    }}
                                                >
                                                    Read More
                                                </Button>
                                                <Chip
                                                    label={`${article.comments?.length || 0} comments`}
                                                    size="small"
                                                    variant="outlined"
                                                />
                                            </CardActions>
                                        </Card>
                                    </Grid>
                                ))}
                            </Grid>
                        </Box>
                    )}

                    {view === 'articles' && selectedArticle && (
                        <Box>
                            <Button
                                variant="text"
                                onClick={() => setSelectedArticle(null)}
                                sx={{ mb: 2 }}
                            >
                                &larr; Back to Articles
                            </Button>
                            <Card>
                                <CardContent>
                                    <Typography variant="h4" gutterBottom>{selectedArticle.title}</Typography>
                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                                        By {selectedArticle.writer?.name} | {selectedArticle.category?.name} | {new Date(selectedArticle.created_at).toLocaleDateString()}
                                    </Typography>
                                    <Divider sx={{ mb: 2 }} />
                                    <Typography
                                        variant="body1"
                                        dangerouslySetInnerHTML={{ __html: selectedArticle.content }}
                                        sx={{ mb: 3 }}
                                    />

                                    <Divider sx={{ mb: 2 }} />
                                    <Typography variant="h6" gutterBottom>
                                        Comments ({selectedArticle.comments?.length || 0})
                                    </Typography>

                                    {displayedComments.map((comment) => (
                                        <Box key={comment.id} sx={{ display: 'flex', gap: 2, mb: 2, p: 1.5, bgcolor: 'grey.50', borderRadius: 1 }}>
                                            <Avatar sx={{ width: 32, height: 32, fontSize: 14 }}>
                                                {comment.student?.name?.[0]}
                                            </Avatar>
                                            <Box>
                                                <Typography variant="subtitle2">{comment.student?.name}</Typography>
                                                <Typography variant="caption" color="text.secondary">
                                                    {new Date(comment.created_at).toLocaleString()}
                                                </Typography>
                                                <Typography variant="body2" sx={{ mt: 0.5 }}>{comment.content}</Typography>
                                            </Box>
                                        </Box>
                                    ))}

                                    {hasMoreComments && (
                                        <Button
                                            variant="outlined"
                                            size="small"
                                            onClick={() => setVisibleComments((count) => count + 10)}
                                            sx={{ mb: 2 }}
                                        >
                                            Load 10 more comments
                                        </Button>
                                    )}

                                    {/* Comment Form */}
                                    <Box component="form" onSubmit={handleComment} sx={{ mt: 2 }}>
                                        <TextField
                                            label="Write a comment..."
                                            multiline
                                            rows={3}
                                            fullWidth
                                            value={commentForm.data.content}
                                            onChange={(e) => commentForm.setData('content', e.target.value)}
                                            error={!!commentForm.errors.content}
                                            helperText={commentForm.errors.content}
                                            sx={{ mb: 1 }}
                                        />
                                        <Button
                                            type="submit"
                                            variant="contained"
                                            disabled={commentForm.processing}
                                            startIcon={<CommentIcon />}
                                        >
                                            Post Comment
                                        </Button>
                                    </Box>
                                </CardContent>
                            </Card>
                        </Box>
                    )}

                    {view === 'comments' && (
                        <Box>
                            <Typography variant="h6" gutterBottom>My Comments</Typography>
                            {myComments.length === 0 ? (
                                <Typography color="text.secondary" sx={{ py: 4, textAlign: 'center' }}>
                                    You haven't posted any comments yet.
                                </Typography>
                            ) : (
                                <Grid container spacing={2}>
                                    {myComments.map((comment) => (
                                        <Grid size={{ xs: 12 }} key={comment.id}>
                                            <Card variant="outlined">
                                                <CardContent>
                                                    <Typography variant="subtitle2" color="primary">
                                                        On: {comment.article?.title}
                                                    </Typography>
                                                    <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 1 }}>
                                                        {new Date(comment.created_at).toLocaleString()}
                                                    </Typography>
                                                    <Typography variant="body2">{comment.content}</Typography>
                                                </CardContent>
                                            </Card>
                                        </Grid>
                                    ))}
                                </Grid>
                            )}
                        </Box>
                    )}
                </Box>
            </Box>

            {/* Footer */}
            <Box sx={{ p: 2, textAlign: 'center', borderTop: '1px solid', borderColor: 'divider', mt: 2 }}>
                <Typography variant="body2" color="text.secondary">
                    {articles.length} published articles | {myComments.length} comments posted
                </Typography>
            </Box>

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
