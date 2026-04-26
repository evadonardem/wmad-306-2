import React, { useState } from 'react';
import { Inertia } from '@inertiajs/inertia';
import {
    Box,
    Container,
    TextField,
    Button,
    Select,
    MenuItem,
    Typography,
    Paper,
    Chip,
    AppBar,
    Toolbar,
    IconButton,
    Alert,
    Card,
    CardContent,
    Avatar,
    Divider,
    Stack,
    alpha,
    Tooltip,
    Fade,
    Zoom,
    Badge
} from '@mui/material';
import {
    ArrowBack as ArrowBackIcon,
    Edit as EditIcon,
    Save as SaveIcon,
    Cancel as CancelIcon,
    Send as SendIcon,
    Comment as CommentIcon,
    Lightbulb as LightbulbIcon,
    Visibility as VisibilityIcon,
    Schedule as ScheduleIcon,
    Person as PersonIcon,
    Category as CategoryIcon,
    ThumbUp as ThumbUpIcon,
    Share as ShareIcon,
    Bookmark as BookmarkIcon,
    FormatQuote as FormatQuoteIcon
} from '@mui/icons-material';
import JoditEditor from 'jodit-react';

const THEME = {
    primary: '#FF6B6B',
    primaryLight: '#FF8E8E',
    primaryDark: '#E84545',
    secondary: '#4ECDC4',
    secondaryLight: '#6FD1C9',
    secondaryDark: '#3AA89F',
    accent: '#FFE66D',
    success: '#95E1D3',
    warning: '#FFA07A',
    background: {
        main: '#FAF9F8',
        gradient: 'linear-gradient(135deg, #FFF9F5 0%, #F8F3F0 100%)'
    },
    text: {
        primary: '#2D4059',
        secondary: '#5C6B7E',
        light: '#8D9AA9'
    },
    gradient: {
        primary: 'linear-gradient(135deg, #FF6B6B 0%, #E84545 100%)',
        secondary: 'linear-gradient(135deg, #4ECDC4 0%, #3AA89F 100%)',
        success: 'linear-gradient(135deg, #95E1D3 0%, #7ACEC0 100%)'
    }
};

const STATUS_COLORS = {
    draft: { 
        bg: '#F8F3F0', 
        text: '#2D4059', 
        border: '#E8E0DA',
        icon: <EditIcon />
    },
    submitted: { 
        bg: '#E6F7F5', 
        text: '#4ECDC4', 
        border: '#C1F0EB',
        icon: <SendIcon />
    },
    needs_revision: { 
        bg: '#FFF3E6', 
        text: '#FFA07A', 
        border: '#FFE4D4',
        icon: <EditIcon />
    },
    published: { 
        bg: '#F0F6FA', 
        text: '#5C6B7E', 
        border: '#E1E8F0',
        icon: <VisibilityIcon />
    },
};

export default function ArticleView({ article, categories }) {
    const [isEditing, setIsEditing] = useState(false);
    const [form, setForm] = useState({
        title: article.title,
        content: article.content,
        category_id: article.category_id,
    });
    const [bookmarked, setBookmarked] = useState(false);

    const handleEdit = () => {
        setIsEditing(true);
    };

    const handleCancel = () => {
        setIsEditing(false);
        setForm({
            title: article.title,
            content: article.content,
            category_id: article.category_id,
        });
    };

    const handleSave = (e) => {
        e.preventDefault();
        Inertia.put(route('writer.articles.update', article.id), form, {
            onSuccess: () => setIsEditing(false)
        });
    };

    const handleSubmit = () => {
        Inertia.post(route('writer.articles.submit', article.id));
    };

    const getWordCount = (content) => {
        if (!content) return 0;
        return content.replace(/<[^>]*>/g, '').split(/\s+/).length;
    };

    const getReadTime = () => {
        const wordsPerMinute = 200;
        const wordCount = getWordCount(article.content);
        const minutes = Math.ceil(wordCount / wordsPerMinute);
        return `${minutes} min read`;
    };

    return (
        <Box sx={{ 
            minHeight: '100vh', 
            background: THEME.background.gradient
        }}>
            {/* Header */}
            <AppBar
                position="sticky"
                elevation={0}
                sx={{
                    background: 'rgba(255, 255, 255, 0.9)',
                    backdropFilter: 'blur(20px)',
                    borderBottom: `1px solid ${alpha(THEME.primary, 0.1)}`,
                    zIndex: 1201,
                }}
            >
                <Toolbar>
                    <IconButton
                        onClick={() => window.location.href = route('writer.dashboard')}
                        sx={{ 
                            mr: 2,
                            bgcolor: alpha(THEME.primary, 0.05),
                            '&:hover': {
                                bgcolor: alpha(THEME.primary, 0.1)
                            }
                        }}
                    >
                        <ArrowBackIcon sx={{ color: THEME.primary }} />
                    </IconButton>
                    
                    <Box sx={{ flexGrow: 1 }}>
                        <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.text.primary }}>
                            {isEditing ? 'Edit Article' : article.title}
                        </Typography>
                        {!isEditing && (
                            <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                {getReadTime()} • {getWordCount(article.content)} words
                            </Typography>
                        )}
                    </Box>

                    {/* Action Buttons */}
                    <Stack direction="row" spacing={1}>
                        <Tooltip title="Share">
                            <IconButton sx={{ color: THEME.text.secondary }}>
                                <ShareIcon />
                            </IconButton>
                        </Tooltip>
                        <Tooltip title={bookmarked ? "Bookmarked" : "Bookmark"}>
                            <IconButton 
                                onClick={() => setBookmarked(!bookmarked)}
                                sx={{ color: bookmarked ? THEME.primary : THEME.text.secondary }}
                            >
                                <BookmarkIcon />
                            </IconButton>
                        </Tooltip>
                    </Stack>
                </Toolbar>
            </AppBar>

            {/* Main Content */}
            <Container maxWidth="lg" sx={{ py: 4 }}>
                <Fade in timeout={500}>
                    <Paper
                        elevation={0}
                        sx={{
                            p: { xs: 3, md: 5 },
                            borderRadius: '16px',
                            background: 'white',
                            border: `1px solid ${alpha(THEME.primary, 0.1)}`,
                            boxShadow: '0 10px 40px rgba(0, 0, 0, 0.05)',
                            position: 'relative',
                            overflow: 'hidden'
                        }}
                    >
                        {/* Decorative Element */}
                        <Box
                            sx={{
                                position: 'absolute',
                                top: 0,
                                right: 0,
                                width: 150,
                                height: 150,
                                background: `radial-gradient(circle, ${alpha(THEME.primary, 0.05)} 0%, transparent 70%)`,
                                borderRadius: '50%',
                                zIndex: 0
                            }}
                        />

                        <Box sx={{ position: 'relative', zIndex: 1 }}>
                            {/* Status and Category */}
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
                                <Stack direction="row" spacing={2}>
                                    <Chip
                                        icon={STATUS_COLORS[article.status.name]?.icon}
                                        label={article.status.label}
                                        sx={{
                                            bgcolor: STATUS_COLORS[article.status.name]?.bg,
                                            color: STATUS_COLORS[article.status.name]?.text,
                                            fontWeight: 600,
                                            border: `1px solid ${STATUS_COLORS[article.status.name]?.border}`,
                                            px: 1
                                        }}
                                    />
                                    <Chip 
                                        label={article.category.name} 
                                        size="medium"
                                        sx={{ 
                                            bgcolor: alpha(THEME.secondary, 0.1),
                                            color: THEME.secondary,
                                            fontWeight: 600
                                        }} 
                                    />
                                </Stack>

                                {/* Metadata */}
                                <Paper
                                    sx={{
                                        p: 1.5,
                                        bgcolor: alpha(THEME.primary, 0.02),
                                        borderRadius: '8px',
                                        display: { xs: 'none', md: 'flex' },
                                        alignItems: 'center',
                                        gap: 2
                                    }}
                                >
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                        <ScheduleIcon sx={{ fontSize: 16, color: THEME.text.light }} />
                                        <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                            {new Date(article.updated_at).toLocaleDateString()}
                                        </Typography>
                                    </Box>
                                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                        <VisibilityIcon sx={{ fontSize: 16, color: THEME.text.light }} />
                                        <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                            {article.views || 0} views
                                        </Typography>
                                    </Box>
                                </Paper>
                            </Box>

                            {isEditing ? (
                                <Box component="form" onSubmit={handleSave}>
                                    <TextField
                                        label="Article Title"
                                        fullWidth
                                        value={form.title}
                                        onChange={(e) => setForm({ ...form, title: e.target.value })}
                                        sx={{
                                            mb: 3,
                                            '& .MuiOutlinedInput-root': {
                                                borderRadius: '12px',
                                                backgroundColor: alpha(THEME.background.main, 0.5),
                                                '&:hover fieldset': { borderColor: THEME.primary },
                                                '&.Mui-focused fieldset': { borderColor: THEME.primary },
                                            },
                                        }}
                                        required
                                        variant="outlined"
                                        InputProps={{
                                            startAdornment: (
                                                <EditIcon sx={{ color: THEME.text.light, mr: 1, fontSize: 20 }} />
                                            ),
                                        }}
                                    />

                                    <Select
                                        fullWidth
                                        value={form.category_id}
                                        onChange={(e) => setForm({ ...form, category_id: e.target.value ? Number(e.target.value) : '' })}
                                        displayEmpty
                                        renderValue={(selected) => {
                                            if (!selected) {
                                                return <Typography sx={{ color: THEME.text.light }}>Select a category</Typography>;
                                            }
                                            const category = categories.find(cat => cat.id === selected);
                                            return category ? category.name : '';
                                        }}
                                        sx={{
                                            mb: 3,
                                            borderRadius: '12px',
                                            backgroundColor: alpha(THEME.background.main, 0.5),
                                            '& .MuiOutlinedInput-root': {
                                                '&:hover fieldset': { borderColor: THEME.primary },
                                                '&.Mui-focused fieldset': { borderColor: THEME.primary },
                                            },
                                        }}
                                    >
                                        {categories.map((cat) => (
                                            <MenuItem key={cat.id} value={cat.id}>{cat.name}</MenuItem>
                                        ))}
                                    </Select>

                                    <Typography sx={{ mb: 2, fontWeight: 700, color: THEME.text.primary }}>
                                        Article Content
                                    </Typography>
                                    <Paper
                                        sx={{
                                            mb: 3,
                                            border: `1px solid ${alpha(THEME.primary, 0.2)}`,
                                            borderRadius: '12px',
                                            overflow: 'hidden',
                                        }}
                                    >
                                        <JoditEditor
                                            value={form.content}
                                            onBlur={(newContent) => setForm({ ...form, content: newContent })}
                                            config={{
                                                buttons: ['bold', 'italic', 'underline', '|', 'ul', 'ol', '|', 'font', 'fontsize', '|', 'image', 'table', 'link', '|', 'align', '|', 'undo', 'redo'],
                                                theme: 'dark',
                                                height: 400,
                                                showCharsCounter: true,
                                                showWordsCounter: true,
                                                showXPathInStatusbar: false,
                                                uploader: {
                                                    url: route('writer.upload.image'),
                                                    format: 'json',
                                                    method: 'POST',
                                                    headers: {
                                                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
                                                    },
                                                    prepareData: function (formdata) {
                                                        // Jodit will automatically add the file as 'upload'
                                                        return formdata;
                                                    },
                                                    isSuccess: function (resp) {
                                                        return resp.uploaded === 1;
                                                    },
                                                    getMessage: function (resp) {
                                                        return resp.msg || 'Upload failed';
                                                    },
                                                    process: function (resp) {
                                                        return {
                                                            files: [resp.url],
                                                            path: resp.url,
                                                            baseurl: '',
                                                            newfilename: resp.fileName
                                                        };
                                                    },
                                                    error: function (e) {
                                                        console.error('Image upload error:', e);
                                                        alert('Image upload failed. Please try again.');
                                                    }
                                                },
                                                image: {
                                                    openOnDblClick: true,
                                                    editSrc: true,
                                                    useImageEditor: false,
                                                    editButtons: ['imageRemove']
                                                }
                                            }}
                                        />
                                    </Paper>

                                    <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
                                        <Button
                                            type="button"
                                            variant="outlined"
                                            startIcon={<CancelIcon />}
                                            onClick={handleCancel}
                                            sx={{
                                                borderColor: alpha(THEME.text.secondary, 0.3),
                                                color: THEME.text.secondary,
                                                '&:hover': {
                                                    borderColor: THEME.text.secondary
                                                }
                                            }}
                                        >
                                            Cancel
                                        </Button>
                                        <Button
                                            type="submit"
                                            variant="contained"
                                            startIcon={<SaveIcon />}
                                            sx={{
                                                background: THEME.gradient.secondary,
                                                color: 'white',
                                                fontWeight: 600,
                                                textTransform: 'none',
                                                px: 4,
                                                '&:hover': {
                                                    boxShadow: `0 8px 16px ${alpha(THEME.secondary, 0.3)}`
                                                }
                                            }}
                                        >
                                            Save Changes
                                        </Button>
                                    </Box>
                                </Box>
                            ) : (
                                <Box>
                                    {/* Article Header */}
                                    <Box sx={{ mb: 4 }}>
                                        <Typography 
                                            variant="h3" 
                                            sx={{ 
                                                fontWeight: 800, 
                                                color: THEME.text.primary,
                                                mb: 3,
                                                lineHeight: 1.2,
                                                fontFamily: '"Playfair Display", serif'
                                            }}
                                        >
                                            {article.title}
                                        </Typography>
                                        
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                                            <Avatar
                                                sx={{
                                                    width: 48,
                                                    height: 48,
                                                    bgcolor: alpha(THEME.primary, 0.1),
                                                    color: THEME.primary,
                                                    fontWeight: 'bold'
                                                }}
                                            >
                                                {article.writer?.name?.charAt(0) || 'A'}
                                            </Avatar>
                                            <Box>
                                                <Typography variant="subtitle1" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                    {article.writer?.name || 'Anonymous'}
                                                </Typography>
                                                <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                                    Published on {new Date(article.created_at).toLocaleDateString()}
                                                </Typography>
                                            </Box>
                                        </Box>
                                    </Box>

                                    {/* Article Content */}
                                    <Paper
                                        sx={{
                                            p: 4,
                                            mb: 4,
                                            bgcolor: alpha(THEME.background.main, 0.5),
                                            borderRadius: '12px',
                                            border: `1px solid ${alpha(THEME.primary, 0.1)}`,
                                            '& p': {
                                                lineHeight: 1.8,
                                                color: THEME.text.primary,
                                                mb: 2
                                            },
                                            '& h2': {
                                                fontSize: '1.8rem',
                                                fontWeight: 700,
                                                color: THEME.text.primary,
                                                mt: 4,
                                                mb: 2
                                            },
                                            '& img': {
                                                maxWidth: '100%',
                                                borderRadius: '8px',
                                                my: 2
                                            },
                                            '& blockquote': {
                                                borderLeft: `4px solid ${THEME.primary}`,
                                                bgcolor: alpha(THEME.primary, 0.02),
                                                py: 2,
                                                px: 3,
                                                my: 2,
                                                fontStyle: 'italic'
                                            }
                                        }}
                                    >
                                        <div dangerouslySetInnerHTML={{ __html: article.content }} />
                                    </Paper>
                                </Box>
                            )}

                            {/* Editor Comments Section - For articles needing revision */}
                            {article.status.name === 'needs_revision' && article.comments && article.comments.length > 0 && (
                                <Zoom in timeout={700}>
                                    <Paper
                                        sx={{
                                            p: 3,
                                            mt: 3,
                                            borderRadius: '12px',
                                            background: alpha(THEME.warning, 0.03),
                                            border: `1px solid ${alpha(THEME.warning, 0.2)}`
                                        }}
                                    >
                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                                            <Badge
                                                badgeContent={article.comments.length}
                                                color="warning"
                                                sx={{ mr: 2 }}
                                            >
                                                <CommentIcon sx={{ color: THEME.warning }} />
                                            </Badge>
                                            <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.warning }}>
                                                Editor's Feedback
                                            </Typography>
                                        </Box>

                                        <Stack spacing={2}>
                                            {article.comments.map((comment, index) => (
                                                <Card
                                                    key={index}
                                                    elevation={0}
                                                    sx={{
                                                        bgcolor: 'white',
                                                        border: `1px solid ${alpha(THEME.warning, 0.2)}`,
                                                        borderRadius: '8px'
                                                    }}
                                                >
                                                    <CardContent>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 1 }}>
                                                            <Avatar
                                                                sx={{
                                                                    width: 24,
                                                                    height: 24,
                                                                    bgcolor: alpha(THEME.warning, 0.1),
                                                                    color: THEME.warning,
                                                                    mr: 1,
                                                                    fontSize: '0.8rem'
                                                                }}
                                                            >
                                                                {comment.user?.name?.charAt(0) || 'E'}
                                                            </Avatar>
                                                            <Typography variant="caption" sx={{ fontWeight: 600, color: THEME.warning }}>
                                                                {comment.user?.name || 'Editor'}
                                                            </Typography>
                                                            <Typography variant="caption" sx={{ color: THEME.text.light, ml: 'auto' }}>
                                                                {new Date(comment.created_at).toLocaleDateString()}
                                                            </Typography>
                                                        </Box>
                                                        <Typography variant="body2" sx={{ color: THEME.text.secondary, pl: 4 }}>
                                                            {comment.comment}
                                                        </Typography>
                                                    </CardContent>
                                                </Card>
                                            ))}
                                        </Stack>
                                    </Paper>
                                </Zoom>
                            )}

                            {/* Reader Comments Section - For published articles */}
                            {article.status.name === 'published' && article.comments && article.comments.length > 0 && (
                                <Zoom in timeout={700}>
                                    <Paper
                                        sx={{
                                            p: 3,
                                            mt: 3,
                                            borderRadius: '12px',
                                            background: alpha(THEME.success, 0.03),
                                            border: `1px solid ${alpha(THEME.success, 0.2)}`
                                        }}
                                    >
                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
                                            <Badge
                                                badgeContent={article.comments.length}
                                                color="success"
                                                sx={{ mr: 2 }}
                                            >
                                                <CommentIcon sx={{ color: THEME.success }} />
                                            </Badge>
                                            <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.success }}>
                                                Reader Discussion ({article.comments.length})
                                            </Typography>
                                        </Box>

                                        <Stack spacing={2}>
                                            {article.comments.map((comment, index) => (
                                                <Card
                                                    key={comment.id || index}
                                                    elevation={0}
                                                    sx={{
                                                        bgcolor: 'white',
                                                        border: `1px solid ${alpha(THEME.success, 0.2)}`,
                                                        borderRadius: '8px',
                                                        transition: 'all 0.3s ease',
                                                        '&:hover': {
                                                            transform: 'translateX(4px)',
                                                            boxShadow: `0 4px 12px ${alpha(THEME.success, 0.1)}`
                                                        }
                                                    }}
                                                >
                                                    <CardContent>
                                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                                                            <Avatar
                                                                sx={{
                                                                    width: 32,
                                                                    height: 32,
                                                                    bgcolor: alpha(THEME.success, 0.1),
                                                                    color: THEME.success,
                                                                    mr: 1.5
                                                                }}
                                                            >
                                                                {comment.user?.name?.charAt(0) || 'R'}
                                                            </Avatar>
                                                            <Box>
                                                                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                                    {comment.user?.name || 'Anonymous Reader'}
                                                                </Typography>
                                                                <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                                    {new Date(comment.created_at).toLocaleDateString()} • {new Date(comment.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                                                                </Typography>
                                                            </Box>
                                                        </Box>
                                                        <Typography variant="body2" sx={{ color: THEME.text.secondary, borderLeft: `2px solid ${alpha(THEME.success, 0.3)}`, pl: 2 }}>
                                                            {comment.content || comment.comment}
                                                        </Typography>
                                                    </CardContent>
                                                </Card>
                                            ))}
                                        </Stack>
                                    </Paper>
                                </Zoom>
                            )}

                            {/* Empty comments message for published articles */}
                            {article.status.name === 'published' && (!article.comments || article.comments.length === 0) && (
                                <Fade in timeout={700}>
                                    <Paper
                                        sx={{
                                            p: 4,
                                            mt: 3,
                                            borderRadius: '12px',
                                            bgcolor: alpha(THEME.primary, 0.02),
                                            border: `1px solid ${alpha(THEME.primary, 0.1)}`,
                                            textAlign: 'center'
                                        }}
                                    >
                                        <CommentIcon sx={{ fontSize: 48, color: THEME.text.light, mb: 2 }} />
                                        <Typography variant="h6" sx={{ color: THEME.text.secondary, mb: 1 }}>
                                            No Comments Yet
                                        </Typography>
                                        <Typography variant="body2" sx={{ color: THEME.text.light }}>
                                            Be the first to start the discussion!
                                        </Typography>
                                    </Paper>
                                </Fade>
                            )}

                            {/* Action Buttons for Drafts */}
                            {!isEditing && article.status.name === 'draft' && (
                                <Fade in timeout={900}>
                                    <Box sx={{ 
                                        mt: 4, 
                                        pt: 4, 
                                        borderTop: `1px solid ${alpha(THEME.primary, 0.1)}`,
                                        display: 'flex',
                                        gap: 2,
                                        justifyContent: 'flex-end'
                                    }}>
                                        <Button
                                            variant="outlined"
                                            startIcon={<EditIcon />}
                                            onClick={handleEdit}
                                            sx={{
                                                borderColor: alpha(THEME.primary, 0.3),
                                                color: THEME.primary,
                                                fontWeight: 600,
                                                textTransform: 'none',
                                                py: 1.5,
                                                px: 4,
                                                '&:hover': {
                                                    borderColor: THEME.primary,
                                                    bgcolor: alpha(THEME.primary, 0.04)
                                                }
                                            }}
                                        >
                                            Edit Article
                                        </Button>
                                        <Button
                                            variant="contained"
                                            startIcon={<SendIcon />}
                                            onClick={handleSubmit}
                                            sx={{
                                                background: THEME.gradient.primary,
                                                color: 'white',
                                                fontWeight: 600,
                                                textTransform: 'none',
                                                py: 1.5,
                                                px: 4,
                                                '&:hover': {
                                                    boxShadow: `0 8px 16px ${alpha(THEME.primary, 0.3)}`
                                                }
                                            }}
                                        >
                                            Submit for Review
                                        </Button>
                                    </Box>
                                </Fade>
                            )}
                        </Box>
                    </Paper>
                </Fade>
            </Container>
        </Box>
    );
}