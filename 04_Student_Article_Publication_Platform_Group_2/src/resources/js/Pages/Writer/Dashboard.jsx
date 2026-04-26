import { Head, useForm, usePage, router } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import {
    Box,
    Typography,
    TextField,
    Button,
    Card,
    CardContent,
    Avatar,
    Chip,
    Alert,
    List,
    ListItemButton,
    ListItemIcon,
    ListItemText,
    Divider,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogContentText,
    DialogActions,
    Snackbar,
    Autocomplete,
    LinearProgress,
    IconButton,
    Collapse,
    Tooltip,
    Paper,
} from '@mui/material';
import {
    AddCircleOutline as AddIcon,
    DraftsOutlined as DraftsIcon,
    SendOutlined as SendIcon,
    EditOutlined as EditIcon,
    DeleteOutline as DeleteIcon,
    ArticleOutlined as ArticleIcon,
    WarningAmberOutlined as RevisionIcon,
    ChevronRightOutlined,
    ChevronLeftOutlined,
    NoteAltOutlined,
    LocalOfferOutlined,
    TrackChangesOutlined,
    SaveOutlined,
    VisibilityOutlined,
    ChatBubbleOutline,
} from '@mui/icons-material';
import JoditEditor from 'jodit-react';
import { useState, useRef, useMemo, useCallback, useEffect } from 'react';

const SIDEBAR_WIDTH = 260;
const META_SIDEBAR_WIDTH = 280;

const TAG_OPTIONS = [
    'Academic', 'Research', 'Opinion', 'Tutorial', 'Review',
    'News', 'Analysis', 'Feature', 'Interview', 'Guide',
];

const statusStyles = {
    draft: { color: '#5A6B8A', bg: '#F4F6F9', label: 'Draft' },
    submitted: { color: '#2A7B9B', bg: '#E1F5FE', label: 'Submitted' },
    needs_revision: { color: '#ED6C02', bg: '#FFF3E0', label: 'Needs Revision' },
    published: { color: '#2E7D32', bg: '#E8F5E9', label: 'Published' },
};

export default function Dashboard({ articles, categories }) {
    const { flash } = usePage().props;
    const [view, setView] = useState('create');
    const [editingArticle, setEditingArticle] = useState(null);
    const [deleteDialog, setDeleteDialog] = useState({ open: false, article: null });
    const [viewModal, setViewModal] = useState({ open: false, article: null });
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
    const [metaSidebarOpen, setMetaSidebarOpen] = useState(true);
    const [tags, setTags] = useState([]);
    const [reviewerNotes, setReviewerNotes] = useState('');
    const [wordCount, setWordCount] = useState(0);
    const [charCount, setCharCount] = useState(0);
    const editorRef = useRef(null);

    const { data, setData, post, processing, errors, reset } = useForm({
        title: '',
        content: '',
        category_id: '',
        tags: [],
        reviewer_notes: '',
    });

    const editForm = useForm({
        title: '',
        content: '',
        category_id: '',
        tags: [],
        reviewer_notes: '',
    });

    // Minimalist Jodit config — essential toolbar only
    const config = useMemo(() => ({
        readonly: false,
        height: 450,
        placeholder: 'Start writing your article content here...',
        toolbarAdaptive: false,
        toolbarSticky: false,
        enableDragAndDropFileToEditor: true,
        showCharsCounter: false,
        showWordsCounter: false,
        showXPathInStatusbar: false,
        askBeforePasteHTML: false,
        askBeforePasteFromWord: false,
        defaultActionOnPaste: 'insert_as_html',
        uploader: {
            insertImageAsBase64URI: true,
        },
        buttons: [
            'bold', 'italic', 'underline', 'strikethrough', '|',
            'ul', 'ol', '|',
            'paragraph', 'fontsize', '|',
            'link', 'image', '|',
            'align', '|',
            'undo', 'redo', '|',
            'dots',
        ],
        buttonsMD: [
            'bold', 'italic', 'underline', '|',
            'ul', 'ol', '|',
            'link', 'image', '|',
            'dots',
        ],
        buttonsXS: [
            'bold', 'italic', '|',
            'ul', 'link', '|',
            'dots',
        ],
        style: {
            font: '15px Inter, Roboto, sans-serif',
        },
    }), []);

    const drafts = articles.filter(a => a.status?.name === 'draft');
    const submitted = articles.filter(a => a.status?.name === 'submitted');
    const needsRevision = articles.filter(a => a.status?.name === 'needs_revision');
    const published = articles.filter(a => a.status?.name === 'published');

    // Word/char counting
    const updateCounts = useCallback((content) => {
        const text = content.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim();
        const words = text ? text.split(/\s+/).filter(Boolean).length : 0;
        const chars = text.length;
        setWordCount(words);
        setCharCount(chars);
    }, []);

    useEffect(() => {
        updateCounts(data.content);
    }, [data.content, updateCounts]);

    const WORD_GOAL = 500;
    const wordProgress = Math.min((wordCount / WORD_GOAL) * 100, 100);

    const handleCreate = (e) => {
        e.preventDefault();
        setData('tags', tags);
        setData('reviewer_notes', reviewerNotes);
        post(route('articles.store'), {
            onSuccess: () => {
                reset();
                setTags([]);
                setReviewerNotes('');
                setSnackbar({ open: true, message: 'Article saved as draft!', severity: 'success' });
            },
        });
    };

    const handleSubmitDirectly = (e) => {
        e.preventDefault();
        router.post(route('articles.store'), {
            title: data.title,
            content: data.content,
            category_id: data.category_id,
            tags: tags,
            reviewer_notes: reviewerNotes,
            submit: true,
        }, {
            onSuccess: () => {
                reset();
                setTags([]);
                setReviewerNotes('');
                setView('submitted');
                setSnackbar({ open: true, message: 'Article submitted for review!', severity: 'success' });
            },
        });
    };

    const handleViewArticle = (article) => {
        setViewModal({ open: true, article });
    };

    const handleStartEdit = (article) => {
        setEditingArticle(article);
        editForm.setData({
            title: article.title,
            content: article.content,
            category_id: article.category_id,
            tags: article.tags || [],
            reviewer_notes: article.reviewer_notes || '',
        });
        setTags(article.tags || []);
        setReviewerNotes(article.reviewer_notes || '');
        updateCounts(article.content);
        setView('edit');
    };

    const handleUpdate = (e) => {
        e.preventDefault();
        editForm.setData('tags', tags);
        editForm.setData('reviewer_notes', reviewerNotes);
        editForm.put(route('articles.update', editingArticle.id), {
            onSuccess: () => {
                setEditingArticle(null);
                setView('drafts');
                setSnackbar({ open: true, message: 'Article updated!', severity: 'success' });
            },
        });
    };

    const handleSubmit = (article) => {
        router.post(route('articles.submit', article.id), {}, {
            onSuccess: () => {
                setSnackbar({ open: true, message: 'Article submitted for review!', severity: 'success' });
            },
        });
    };

    const handleDelete = () => {
        router.delete(route('articles.destroy', deleteDialog.article.id), {
            onSuccess: () => {
                setDeleteDialog({ open: false, article: null });
                setSnackbar({ open: true, message: 'Article deleted.', severity: 'info' });
            },
        });
    };

    const sidebarItems = [
        { key: 'create', icon: <AddIcon />, label: 'Create Article', count: null },
        { key: 'drafts', icon: <DraftsIcon />, label: 'My Drafts', count: drafts.length },
        { key: 'submitted', icon: <SendIcon />, label: 'Submitted', count: submitted.length },
        { key: 'revision', icon: <RevisionIcon />, label: 'Needs Revision', count: needsRevision.length },
        { key: 'published', icon: <ArticleIcon />, label: 'Published', count: published.length },
    ];

    // Article List Renderer
    const renderArticleList = (articleList, showActions = true, onArticleClick = null) => (
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            {articleList.length === 0 && (
                <Paper
                    elevation={0}
                    sx={{
                        py: 8,
                        textAlign: 'center',
                        bgcolor: 'transparent',
                        border: '2px dashed',
                        borderColor: 'divider',
                        borderRadius: 3,
                    }}
                >
                    <ArticleIcon sx={{ fontSize: 48, color: '#C5CEE0', mb: 1 }} />
                    <Typography color="text.secondary" variant="body2">
                        No articles in this category yet.
                    </Typography>
                </Paper>
            )}
            {articleList.map((article) => {
                const st = statusStyles[article.status?.name] || statusStyles.draft;
                return (
                    <Card
                        key={article.id}
                        elevation={0}
                        onClick={() => onArticleClick && onArticleClick(article)}
                        sx={{
                            transition: 'all 0.2s',
                            cursor: onArticleClick ? 'pointer' : 'default',
                            '&:hover': {
                                boxShadow: '0 4px 16px rgba(27,42,74,0.08)',
                                transform: 'translateY(-1px)',
                            },
                        }}
                    >
                        <CardContent sx={{ p: 2.5, '&:last-child': { pb: 2.5 } }}>
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}>
                                <Typography variant="subtitle1" sx={{ fontWeight: 600, color: 'text.primary', flex: 1, mr: 2 }}>
                                    {article.title}
                                </Typography>
                                <Chip
                                    label={st.label}
                                    size="small"
                                    sx={{
                                        bgcolor: st.bg,
                                        color: st.color,
                                        fontWeight: 600,
                                        fontSize: '0.7rem',
                                        height: 24,
                                    }}
                                />
                            </Box>
                            <Box sx={{ display: 'flex', gap: 1, mb: 1.5, flexWrap: 'wrap', alignItems: 'center' }}>
                                <Chip
                                    label={article.category?.name}
                                    size="small"
                                    variant="outlined"
                                    sx={{ height: 22, fontSize: '0.7rem', borderColor: '#E2E8F0', color: '#5A6B8A' }}
                                />
                                {article.status?.name === 'published' && (
                                    <Chip
                                        label={`${article.comments_count || 0} comments`}
                                        size="small"
                                        variant="outlined"
                                        icon={<ChatBubbleOutline sx={{ fontSize: 14 }} />}
                                        sx={{ height: 22, fontSize: '0.7rem', borderColor: '#E2E8F0', color: '#5A6B8A' }}
                                    />
                                )}
                                <Typography variant="caption" sx={{ color: '#8896AB' }}>
                                    Updated {new Date(article.updated_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                                </Typography>
                            </Box>
                            <Typography
                                variant="body2"
                                sx={{
                                    overflow: 'hidden',
                                    textOverflow: 'ellipsis',
                                    display: '-webkit-box',
                                    WebkitLineClamp: 2,
                                    WebkitBoxOrient: 'vertical',
                                    color: '#5A6B8A',
                                    fontSize: '0.8125rem',
                                    lineHeight: 1.6,
                                }}
                                dangerouslySetInnerHTML={{ __html: article.content }}
                            />
                            {article.revisions && article.revisions.length > 0 && (
                                <Box
                                    sx={{
                                        mt: 2,
                                        p: 2,
                                        bgcolor: '#FFF8F0',
                                        borderRadius: 2,
                                        border: '1px solid #FFE0B2',
                                    }}
                                >
                                    <Typography variant="caption" sx={{ fontWeight: 700, color: '#E65100', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
                                        Editor Feedback
                                    </Typography>
                                    {article.revisions.map((rev) => (
                                        <Box key={rev.id} sx={{ mt: 1 }}>
                                            <Typography variant="body2" sx={{ color: '#5A6B8A', fontSize: '0.8125rem' }}>
                                                <strong>{rev.editor?.name}:</strong> {rev.comments}
                                            </Typography>
                                        </Box>
                                    ))}
                                </Box>
                            )}
                        </CardContent>
                        {showActions && (article.status?.name === 'draft' || article.status?.name === 'needs_revision') && (
                            <Box sx={{ px: 2, pb: 2, display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                <Button
                                    size="small"
                                    variant="outlined"
                                    startIcon={<EditIcon />}
                                    onClick={() => handleStartEdit(article)}
                                    sx={{ borderRadius: 2, fontSize: '0.8rem' }}
                                >
                                    Edit
                                </Button>
                                <Button
                                    size="small"
                                    variant="contained"
                                    color="secondary"
                                    startIcon={<SendIcon />}
                                    onClick={() => handleSubmit(article)}
                                    sx={{ borderRadius: 2, fontSize: '0.8rem' }}
                                >
                                    Submit for Review
                                </Button>
                                {article.status?.name === 'draft' && (
                                    <Button
                                        size="small"
                                        color="error"
                                        startIcon={<DeleteIcon />}
                                        onClick={() => setDeleteDialog({ open: true, article })}
                                        sx={{ borderRadius: 2, fontSize: '0.8rem', ml: 'auto' }}
                                    >
                                        Delete
                                    </Button>
                                )}
                            </Box>
                        )}
                    </Card>
                );
            })}
        </Box>
    );

    // Editor form (shared between create & edit views)
    const renderEditorForm = (isEdit = false) => {
        const form = isEdit ? editForm : { data, setData, errors, processing };
        const onSubmit = isEdit ? handleUpdate : handleCreate;
        const currentContent = isEdit ? editForm.data.content : data.content;

        return (
            <Box sx={{ display: 'flex', gap: 3, flex: 1, minHeight: 0 }}>
                {/* Main Editor */}
                <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 2.5 }}>
                    <Box component="form" onSubmit={onSubmit} id="article-form">
                        <TextField
                            label="Article Title"
                            placeholder="Enter a compelling title..."
                            fullWidth
                            value={form.data.title}
                            onChange={(e) => isEdit ? editForm.setData('title', e.target.value) : setData('title', e.target.value)}
                            error={!!form.errors.title}
                            helperText={form.errors.title}
                            sx={{ mb: 2.5 }}
                            InputProps={{
                                sx: { fontSize: '1.05rem', fontWeight: 500 },
                            }}
                        />

                        <Autocomplete
                            options={categories}
                            getOptionLabel={(opt) => typeof opt === 'object' ? opt.name : ''}
                            value={categories.find(c => c.id === form.data.category_id) || null}
                            onChange={(_, val) => {
                                const id = val?.id || '';
                                isEdit ? editForm.setData('category_id', id) : setData('category_id', id);
                            }}
                            renderInput={(params) => (
                                <TextField
                                    {...params}
                                    label="Category"
                                    placeholder="Select a category"
                                    error={!!form.errors.category_id}
                                    helperText={form.errors.category_id}
                                />
                            )}
                            sx={{ mb: 2.5 }}
                        />

                        {/* WYSIWYG Editor */}
                        <Box
                            sx={{
                                borderRadius: 2,
                                overflow: 'hidden',
                                border: '1px solid',
                                borderColor: 'divider',
                                transition: 'border-color 0.2s',
                                '&:focus-within': {
                                    borderColor: 'primary.main',
                                },
                            }}
                        >
                            <JoditEditor
                                ref={editorRef}
                                value={currentContent}
                                config={config}
                                onBlur={(newContent) => {
                                    isEdit ? editForm.setData('content', newContent) : setData('content', newContent);
                                    updateCounts(newContent);
                                }}
                                onChange={(newContent) => updateCounts(newContent)}
                            />
                        </Box>
                        {form.errors.content && (
                            <Typography color="error" variant="caption" sx={{ mt: 0.5, display: 'block' }}>
                                {form.errors.content}
                            </Typography>
                        )}
                    </Box>

                    {/* Bottom Status Bar */}
                    <Box
                        sx={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            mt: 1,
                        }}
                    >
                        <Box sx={{ display: 'flex', gap: 3, alignItems: 'center' }}>
                            <Typography variant="caption" sx={{ color: '#8896AB', fontWeight: 500, fontSize: '0.75rem', letterSpacing: '0.03em' }}>
                                {charCount.toLocaleString()} characters
                            </Typography>
                            <Typography variant="caption" sx={{ color: '#8896AB', fontWeight: 500, fontSize: '0.75rem', letterSpacing: '0.03em' }}>
                                {wordCount.toLocaleString()} words
                            </Typography>
                        </Box>
                        <Box sx={{ display: 'flex', gap: 1.5 }}>
                            <Button
                                variant="outlined"
                                startIcon={<SaveOutlined />}
                                type="submit"
                                form="article-form"
                                disabled={form.processing}
                                sx={{
                                    borderColor: '#E2E8F0',
                                    color: 'text.secondary',
                                    '&:hover': { borderColor: 'primary.main', color: 'primary.main' },
                                }}
                            >
                                {isEdit ? 'Save Changes' : 'Save as Draft'}
                            </Button>
                            {!isEdit && (
                                <Button
                                    type="button"
                                    variant="contained"
                                    startIcon={<SendIcon />}
                                    disabled={form.processing || !data.title || !data.content}
                                    onClick={handleSubmitDirectly}
                                    sx={{
                                        background: 'linear-gradient(135deg, #1B2A4A 0%, #2A7B9B 100%)',
                                        color: 'white !important',
                                        px: 3,
                                        '& .MuiSvgIcon-root': {
                                            color: 'white',
                                        },
                                    }}
                                >
                                    Submit for Review
                                </Button>
                            )}
                            {isEdit && (
                                <Box sx={{ display: 'flex', gap: 1 }}>
                                    <Button
                                        type="button"
                                        variant="contained"
                                        startIcon={<SendIcon />}
                                        onClick={() => handleSubmit(editingArticle)}
                                        sx={{
                                            background: 'linear-gradient(135deg, #1B2A4A 0%, #2A7B9B 100%)',
                                            color: 'white !important',
                                            px: 3,
                                            '& .MuiSvgIcon-root': {
                                                color: 'white',
                                            },
                                        }}
                                    >
                                        Submit for Review
                                    </Button>
                                    <Button
                                        type="button"
                                        variant="text"
                                        color="inherit"
                                        onClick={() => { setView('drafts'); setEditingArticle(null); }}
                                    >
                                        Cancel
                                    </Button>
                                </Box>
                            )}
                        </Box>
                    </Box>
                </Box>

                {/* Right Metadata Sidebar */}
                <Collapse in={metaSidebarOpen} orientation="horizontal" sx={{ flexShrink: 0 }}>
                    <Box
                        sx={{
                            width: META_SIDEBAR_WIDTH,
                            flexShrink: 0,
                            display: 'flex',
                            flexDirection: 'column',
                            gap: 2.5,
                        }}
                    >
                        <Paper
                            elevation={0}
                            sx={{
                                p: 2.5,
                                borderRadius: 3,
                                border: '1px solid',
                                borderColor: '#B9DAEA',
                                bgcolor: '#EAF6FC',
                            }}
                        >
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                <LocalOfferOutlined sx={{ fontSize: 18, color: 'secondary.main' }} />
                                <Typography variant="subtitle2" sx={{ color: 'text.primary' }}>Tags</Typography>
                            </Box>
                            <Autocomplete
                                multiple
                                options={TAG_OPTIONS}
                                value={tags}
                                onChange={(_, val) => setTags(val)}
                                renderTags={(value, getTagProps) =>
                                    value.map((option, index) => {
                                        const { key, ...tagProps } = getTagProps({ index });
                                        return (
                                            <Chip
                                                key={key}
                                                label={option}
                                                size="small"
                                                {...tagProps}
                                                sx={{
                                                    bgcolor: 'rgba(42,123,155,0.1)',
                                                    color: 'secondary.main',
                                                    fontWeight: 500,
                                                    '& .MuiChip-deleteIcon': { color: 'secondary.light' },
                                                }}
                                            />
                                        );
                                    })
                                }
                                renderInput={(params) => (
                                    <TextField
                                        {...params}
                                        placeholder={tags.length === 0 ? "Add tags..." : ""}
                                        size="small"
                                    />
                                )}
                                size="small"
                            />
                        </Paper>

                        <Paper
                            elevation={0}
                            sx={{
                                p: 2.5,
                                borderRadius: 3,
                                border: '1px solid',
                                borderColor: '#CCD8EC',
                                bgcolor: '#EEF3FB',
                            }}
                        >
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                <NoteAltOutlined sx={{ fontSize: 18, color: 'secondary.main' }} />
                                <Typography variant="subtitle2" sx={{ color: 'text.primary' }}>Notes to Reviewer</Typography>
                            </Box>
                            <TextField
                                multiline
                                rows={3}
                                fullWidth
                                size="small"
                                placeholder="Any context for the editor..."
                                value={reviewerNotes}
                                onChange={(e) => setReviewerNotes(e.target.value)}
                                sx={{
                                    '& .MuiOutlinedInput-root': {
                                        fontSize: '0.8125rem',
                                    },
                                }}
                            />
                        </Paper>

                        <Paper
                            elevation={0}
                            sx={{
                                p: 2.5,
                                borderRadius: 3,
                                border: '1px solid',
                                borderColor: '#B8DFCF',
                                bgcolor: '#E7F6EE',
                            }}
                        >
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                                <TrackChangesOutlined sx={{ fontSize: 18, color: 'secondary.main' }} />
                                <Typography variant="subtitle2" sx={{ color: 'text.primary' }}>Word Goal</Typography>
                            </Box>
                            <Box sx={{ mb: 1 }}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                                    <Typography variant="caption" sx={{ fontWeight: 600, color: 'text.primary' }}>
                                        {wordCount} / {WORD_GOAL}
                                    </Typography>
                                    <Typography variant="caption" sx={{ fontWeight: 600, color: wordProgress >= 100 ? 'success.main' : 'secondary.main' }}>
                                        {Math.round(wordProgress)}%
                                    </Typography>
                                </Box>
                                <LinearProgress
                                    variant="determinate"
                                    value={wordProgress}
                                    color={wordProgress >= 100 ? 'success' : 'secondary'}
                                    sx={{ height: 6, borderRadius: 3 }}
                                />
                            </Box>
                            <Typography variant="caption" sx={{ color: '#8896AB' }}>
                                {wordProgress >= 100 ? 'Goal reached!' : `${WORD_GOAL - wordCount} words remaining`}
                            </Typography>
                        </Paper>

                        {/* Status */}
                        <Paper
                            elevation={0}
                            sx={{
                                p: 2.5,
                                borderRadius: 3,
                                border: '1px solid',
                                borderColor: '#D9C9F0',
                                bgcolor: '#F3ECFC',
                            }}
                        >
                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                                <VisibilityOutlined sx={{ fontSize: 18, color: 'secondary.main' }} />
                                <Typography variant="subtitle2" sx={{ color: 'text.primary' }}>Status</Typography>
                            </Box>
                            <Chip
                                label={isEdit ? (statusStyles[editingArticle?.status?.name]?.label || 'Draft') : 'New Draft'}
                                size="small"
                                sx={{
                                    bgcolor: isEdit ? (statusStyles[editingArticle?.status?.name]?.bg || '#F4F6F9') : '#F4F6F9',
                                    color: isEdit ? (statusStyles[editingArticle?.status?.name]?.color || '#5A6B8A') : '#5A6B8A',
                                    fontWeight: 600,
                                }}
                            />
                        </Paper>
                    </Box>
                </Collapse>

                {/* Meta sidebar toggle */}
                <Tooltip title={metaSidebarOpen ? 'Hide metadata' : 'Show metadata'}>
                    <IconButton
                        onClick={() => setMetaSidebarOpen(!metaSidebarOpen)}
                        size="small"
                        sx={{
                            alignSelf: 'flex-start',
                            mt: 0.5,
                            border: '1px solid',
                            borderColor: 'divider',
                            borderRadius: 1.5,
                            width: 28,
                            height: 28,
                            color: '#8896AB',
                        }}
                    >
                        {metaSidebarOpen ? <ChevronRightOutlined sx={{ fontSize: 16 }} /> : <ChevronLeftOutlined sx={{ fontSize: 16 }} />}
                    </IconButton>
                </Tooltip>
            </Box>
        );
    };

    return (
        <AuthenticatedLayout>
            <Head title="Writer Dashboard" />

            <Box sx={{ display: 'flex', height: 'calc(100vh - 64px)' }}>
                {/* Left Navigation Sidebar */}
                <Box
                    sx={{
                        width: SIDEBAR_WIDTH,
                        flexShrink: 0,
                        bgcolor: '#E7F0FA',
                        borderRight: '1px solid',
                        borderColor: '#B8CCE3',
                        display: 'flex',
                        flexDirection: 'column',
                        overflow: 'auto',
                    }}
                >
                    <Box sx={{ p: 2.5, pb: 1.5 }}>
                        <Typography
                            variant="overline"
                            sx={{
                                color: '#8896AB',
                                fontSize: '0.65rem',
                                fontWeight: 700,
                                letterSpacing: '0.1em',
                            }}
                        >
                            Writer Dashboard
                        </Typography>
                    </Box>

                    <List sx={{ px: 1, flex: 1 }}>
                        {sidebarItems.slice(0, 1).map(({ key, icon, label }) => (
                            <ListItemButton
                                key={key}
                                selected={view === key}
                                onClick={() => { setView(key); setEditingArticle(null); }}
                                sx={{ mb: 0.5 }}
                            >
                                <ListItemIcon>{icon}</ListItemIcon>
                                <ListItemText
                                    primary={label}
                                    primaryTypographyProps={{ fontSize: '0.8375rem', fontWeight: view === key ? 600 : 500 }}
                                />
                            </ListItemButton>
                        ))}

                        <Divider sx={{ my: 1.5, mx: 1 }} />

                        <Box sx={{ px: 1.5, py: 0.5 }}>
                            <Typography
                                variant="overline"
                                sx={{ color: '#8896AB', fontSize: '0.6rem', fontWeight: 700, letterSpacing: '0.1em' }}
                            >
                                My Articles
                            </Typography>
                        </Box>

                        {sidebarItems.slice(1).map(({ key, icon, label, count }) => (
                            <ListItemButton
                                key={key}
                                selected={view === key || (view === 'edit' && key === 'drafts')}
                                onClick={() => { setView(key); setEditingArticle(null); }}
                                sx={{ mb: 0.25 }}
                            >
                                <ListItemIcon>{icon}</ListItemIcon>
                                <ListItemText
                                    primary={label}
                                    primaryTypographyProps={{ fontSize: '0.8375rem', fontWeight: view === key ? 600 : 500 }}
                                />
                                {count > 0 && (
                                    <Chip
                                        label={count}
                                        size="small"
                                        sx={{
                                            height: 20,
                                            minWidth: 20,
                                            fontSize: '0.7rem',
                                            fontWeight: 700,
                                            bgcolor: view === key ? 'rgba(42,123,155,0.15)' : '#F4F6F9',
                                            color: view === key ? 'secondary.main' : '#8896AB',
                                        }}
                                    />
                                )}
                            </ListItemButton>
                        ))}
                    </List>

                    {/* Sidebar Footer Stats */}
                    <Box sx={{ p: 2, borderTop: '1px solid', borderColor: '#B8CCE3', bgcolor: '#DDEAF7' }}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 0.5 }}>
                            <Typography variant="caption" sx={{ color: '#8896AB', fontSize: '0.7rem' }}>Total Articles</Typography>
                            <Typography variant="caption" sx={{ color: 'text.primary', fontWeight: 700, fontSize: '0.7rem' }}>{articles.length}</Typography>
                        </Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                            <Typography variant="caption" sx={{ color: '#8896AB', fontSize: '0.7rem' }}>Published</Typography>
                            <Typography variant="caption" sx={{ color: 'success.main', fontWeight: 700, fontSize: '0.7rem' }}>{published.length}</Typography>
                        </Box>
                    </Box>
                </Box>

                {/* Main Content Area */}
                <Box
                    component="main"
                    sx={{
                        flex: 1,
                        display: 'flex',
                        flexDirection: 'column',
                        overflow: 'auto',
                        p: 3,
                        bgcolor: 'background.default',
                    }}
                >
                    {flash?.success && (
                        <Alert
                            severity="success"
                            sx={{ mb: 2.5, borderRadius: 2 }}
                            onClose={() => {}}
                        >
                            {flash.success}
                        </Alert>
                    )}

                    {/* Create View */}
                    {view === 'create' && (
                        <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                            <Box sx={{ mb: 2.5 }}>
                                <Typography variant="h5" sx={{ fontWeight: 700, color: 'text.primary' }}>
                                    Article Writer
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#8896AB', mt: 0.5 }}>
                                    Create and format your article. Use the toolbar for formatting options.
                                </Typography>
                            </Box>
                            {renderEditorForm(false)}
                        </Box>
                    )}

                    {/* Edit View */}
                    {view === 'edit' && editingArticle && (
                        <Box sx={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                            <Box sx={{ mb: 2.5 }}>
                                <Typography variant="h5" sx={{ fontWeight: 700, color: 'text.primary' }}>
                                    Edit Article
                                </Typography>
                                <Typography variant="body2" sx={{ color: '#8896AB', mt: 0.5 }}>
                                    Revise your article based on feedback or make improvements.
                                </Typography>
                            </Box>
                            {editingArticle.revisions?.length > 0 && (
                                <Alert
                                    severity="warning"
                                    sx={{ mb: 2.5, borderRadius: 2 }}
                                    icon={<RevisionIcon />}
                                >
                                    <Typography variant="subtitle2" sx={{ mb: 0.5 }}>Editor Feedback</Typography>
                                    {editingArticle.revisions.map((rev) => (
                                        <Typography key={rev.id} variant="body2" sx={{ fontSize: '0.8125rem' }}>
                                            <strong>{rev.editor?.name}:</strong> {rev.comments}
                                        </Typography>
                                    ))}
                                </Alert>
                            )}
                            {renderEditorForm(true)}
                        </Box>
                    )}

                    {/* List Views */}
                    {view === 'drafts' && (
                        <Box>
                            <Box sx={{ mb: 3 }}>
                                <Typography variant="h5" sx={{ fontWeight: 700 }}>My Drafts</Typography>
                                <Typography variant="body2" sx={{ color: '#8896AB', mt: 0.5 }}>
                                    Articles you're still working on. Edit or submit them for review.
                                </Typography>
                            </Box>
                            {renderArticleList(drafts)}
                        </Box>
                    )}

                    {view === 'submitted' && (
                        <Box>
                            <Box sx={{ mb: 3 }}>
                                <Typography variant="h5" sx={{ fontWeight: 700 }}>Submitted Articles</Typography>
                                <Typography variant="body2" sx={{ color: '#8896AB', mt: 0.5 }}>
                                    Articles awaiting editor review.
                                </Typography>
                            </Box>
                            {renderArticleList(submitted, false, handleViewArticle)}
                        </Box>
                    )}

                    {view === 'revision' && (
                        <Box>
                            <Box sx={{ mb: 3 }}>
                                <Typography variant="h5" sx={{ fontWeight: 700 }}>Needs Revision</Typography>
                                <Typography variant="body2" sx={{ color: '#8896AB', mt: 0.5 }}>
                                    Articles that need changes based on editor feedback.
                                </Typography>
                            </Box>
                            {renderArticleList(needsRevision, true, handleViewArticle)}
                        </Box>
                    )}

                    {view === 'published' && (
                        <Box>
                            <Box sx={{ mb: 3 }}>
                                <Typography variant="h5" sx={{ fontWeight: 700 }}>Published Articles</Typography>
                                <Typography variant="body2" sx={{ color: '#8896AB', mt: 0.5 }}>
                                    Your articles that are live and visible to students.
                                </Typography>
                            </Box>
                            {renderArticleList(published, false, handleViewArticle)}
                        </Box>
                    )}
                </Box>
            </Box>

            {/* Delete Dialog */}
            <Dialog
                open={deleteDialog.open}
                onClose={() => setDeleteDialog({ open: false, article: null })}
                maxWidth="xs"
                fullWidth
            >
                <DialogTitle sx={{ fontWeight: 600 }}>Delete Article</DialogTitle>
                <DialogContent>
                    <DialogContentText sx={{ fontSize: '0.875rem' }}>
                        Are you sure you want to delete <strong>"{deleteDialog.article?.title}"</strong>? This action cannot be undone.
                    </DialogContentText>
                </DialogContent>
                <DialogActions sx={{ px: 3, pb: 2 }}>
                    <Button onClick={() => setDeleteDialog({ open: false, article: null })} sx={{ color: 'text.secondary' }}>
                        Cancel
                    </Button>
                    <Button onClick={handleDelete} color="error" variant="contained">
                        Delete Article
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
                            label={statusStyles[viewModal.article?.status?.name]?.label || 'Unknown'}
                            size="small"
                            sx={{
                                bgcolor: statusStyles[viewModal.article?.status?.name]?.bg || '#F4F6F9',
                                color: statusStyles[viewModal.article?.status?.name]?.color || '#5A6B8A',
                                fontWeight: 600,
                                fontSize: '0.75rem',
                                height: 24,
                            }}
                        />
                        <Typography variant="caption" sx={{ color: '#8896AB', alignSelf: 'center' }}>
                            Updated {viewModal.article?.updated_at && new Date(viewModal.article.updated_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
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

                    {/* Tags */}
                    {viewModal.article?.tags && viewModal.article.tags.length > 0 && (
                        <Box sx={{ mt: 3, pt: 2, borderTop: '1px solid #E2E8F0' }}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <LocalOfferOutlined sx={{ fontSize: 18 }} />
                                Tags
                            </Typography>
                            <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                {viewModal.article.tags.map((tag, idx) => (
                                    <Chip
                                        key={idx}
                                        label={tag}
                                        size="small"
                                        sx={{
                                            bgcolor: '#E8F2F5',
                                            color: '#2A7B9B',
                                            fontWeight: 500,
                                        }}
                                    />
                                ))}
                            </Box>
                        </Box>
                    )}

                    {/* Revisions/Feedback */}
                    {viewModal.article?.revisions && viewModal.article.revisions.length > 0 && (
                        <Box sx={{ mt: 3, pt: 2, borderTop: '1px solid #E2E8F0' }}>
                            <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1.5, display: 'flex', alignItems: 'center', gap: 1 }}>
                                <TrackChangesOutlined sx={{ fontSize: 18 }} />
                                Editor Feedback
                            </Typography>
                            <Box
                                sx={{
                                    p: 2,
                                    bgcolor: '#FFF8F0',
                                    borderRadius: 2,
                                    border: '1px solid #FFE0B2',
                                }}
                            >
                                {viewModal.article.revisions.map((rev, idx) => (
                                    <Box key={rev.id} sx={{ mb: idx < viewModal.article.revisions.length - 1 ? 1.5 : 0 }}>
                                        <Typography variant="caption" sx={{ fontWeight: 700, color: '#E65100', textTransform: 'uppercase' }}>
                                            {rev.editor?.name}
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: '#5A6B8A', fontSize: '0.875rem', mt: 0.5 }}>
                                            {rev.comments}
                                        </Typography>
                                    </Box>
                                ))}
                            </Box>
                        </Box>
                    )}

                    {viewModal.article?.status?.name === 'published' && (
                        <Box sx={{ mt: 3, pt: 2, borderTop: '1px solid #E2E8F0' }}>
                            <Typography
                                variant="subtitle2"
                                sx={{ fontWeight: 600, mb: 1.5, display: 'flex', alignItems: 'center', gap: 1 }}
                            >
                                <ChatBubbleOutline sx={{ fontSize: 18 }} />
                                Reader Comments ({viewModal.article?.comments?.length || 0})
                            </Typography>

                            {(viewModal.article?.comments?.length || 0) === 0 ? (
                                <Typography variant="body2" sx={{ color: '#8896AB' }}>
                                    No comments yet on this article.
                                </Typography>
                            ) : (
                                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.25 }}>
                                    {viewModal.article.comments.map((comment) => (
                                        <Box
                                            key={comment.id}
                                            sx={{
                                                display: 'flex',
                                                gap: 1.5,
                                                p: 1.5,
                                                bgcolor: '#F8FAFC',
                                                borderRadius: 2,
                                                border: '1px solid #E2E8F0',
                                            }}
                                        >
                                            <Avatar sx={{ width: 30, height: 30, fontSize: 13, bgcolor: '#2A7B9B' }}>
                                                {comment.student?.name?.[0] || '?'}
                                            </Avatar>
                                            <Box sx={{ minWidth: 0 }}>
                                                <Typography variant="body2" sx={{ fontWeight: 700, color: 'text.primary' }}>
                                                    {comment.student?.name || 'Unknown User'}
                                                </Typography>
                                                <Typography variant="caption" sx={{ color: '#8896AB' }}>
                                                    {new Date(comment.created_at).toLocaleString()}
                                                </Typography>
                                                <Typography variant="body2" sx={{ mt: 0.5, color: '#334155' }}>
                                                    {comment.content}
                                                </Typography>
                                            </Box>
                                        </Box>
                                    ))}
                                </Box>
                            )}
                        </Box>
                    )}
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
                onClose={() => setSnackbar({ ...snackbar, open: false })}
                anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
            >
                <Alert
                    onClose={() => setSnackbar({ ...snackbar, open: false })}
                    severity={snackbar.severity}
                    variant="filled"
                    sx={{ borderRadius: 2, fontWeight: 500 }}
                >
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </AuthenticatedLayout>
    );
}
