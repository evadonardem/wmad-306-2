import React, { useState, useEffect } from 'react';
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
    Divider,
    Avatar,
    Stack,
    LinearProgress,
    alpha,
    Tooltip,
    Fade,
    Zoom
} from '@mui/material';
import {
    ArrowBack as ArrowBackIcon,
    Edit as EditIcon,
    Save as SaveIcon,
    Send as SendIcon,
    Comment as CommentIcon,
    Lightbulb as LightbulbIcon,
    Warning as WarningIcon,
    CheckCircle as CheckCircleIcon,
    FormatQuote as FormatQuoteIcon,
    Psychology as PsychologyIcon,
    AutoStories as AutoStoriesIcon,
    Brush as BrushIcon,
    RocketLaunch as RocketLaunchIcon,
    Create as CreateIcon
} from '@mui/icons-material';
import JoditEditor from 'jodit-react';

// Creative Writing Theme Color Palette
const THEME = {
    primary: '#FF6B6B',
    primaryLight: '#FF8E8E',
    primaryDark: '#E84545',
    secondary: '#4ECDC4',
    secondaryLight: '#6FD1C9',
    secondaryDark: '#3AA89F',
    accent: '#FFE66D',
    accentLight: '#FFF0A5',
    accentDark: '#F7D44A',
    warning: '#FFA07A',
    success: '#95E1D3',
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
        accent: 'linear-gradient(135deg, #FFE66D 0%, #F7D44A 100%)',
        warning: 'linear-gradient(135deg, #FFA07A 0%, #E6896D 100%)'
    }
};

const STATUS_COLORS = {
    draft: { 
        bg: '#F8F3F0', 
        text: '#2D4059', 
        border: '#E8E0DA',
        icon: <CreateIcon />
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
        icon: <BrushIcon />
    },
    published: { 
        bg: '#F0F6FA', 
        text: '#5C6B7E', 
        border: '#E1E8F0',
        icon: <RocketLaunchIcon />
    },
};

export default function ArticleRevise({ article, categories }) {
    const [form, setForm] = useState({
        content: article.content,
    });
    const [wordCount, setWordCount] = useState(0);
    const [saveProgress, setSaveProgress] = useState(false);

    useEffect(() => {
        // Calculate word count
        if (form.content) {
            const words = form.content.replace(/<[^>]*>/g, '').split(/\s+/).length;
            setWordCount(words);
        }
    }, [form.content]);

    const handleSubmit = (e) => {
        e.preventDefault();
        setSaveProgress(true);
        Inertia.post(route('writer.articles.revise', article.id), form, {
            onFinish: () => setSaveProgress(false)
        });
    };

    const getReadTime = () => {
        const wordsPerMinute = 200;
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
                    borderBottom: `1px solid ${alpha(THEME.warning, 0.2)}`,
                    boxShadow: `0 4px 20px ${alpha(THEME.warning, 0.1)}`
                }}
            >
                <Toolbar>
                    <IconButton
                        onClick={() => window.history.back()}
                        sx={{ 
                            mr: 2,
                            bgcolor: alpha(THEME.warning, 0.1),
                            '&:hover': {
                                bgcolor: alpha(THEME.warning, 0.2)
                            }
                        }}
                    >
                        <ArrowBackIcon sx={{ color: THEME.warning }} />
                    </IconButton>
                    
                    <Box sx={{ flexGrow: 1 }}>
                        <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.text.primary }}>
                            Revise Article
                        </Typography>
                        <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                            Address editor feedback and polish your work
                        </Typography>
                    </Box>

                    {/* Revision Progress */}
                    <Chip
                        icon={<BrushIcon />}
                        label="Revision in Progress"
                        sx={{
                            bgcolor: alpha(THEME.warning, 0.1),
                            color: THEME.warning,
                            fontWeight: 600,
                            mr: 2
                        }}
                    />
                </Toolbar>
            </AppBar>

            <Container maxWidth="lg" sx={{ py: 4 }}>
                {/* Article Info Card */}
                <Fade in timeout={500}>
                    <Paper
                        elevation={0}
                        sx={{
                            p: 4,
                            mb: 4,
                            borderRadius: '16px',
                            background: 'white',
                            border: `1px solid ${alpha(THEME.primary, 0.1)}`,
                            position: 'relative',
                            overflow: 'hidden'
                        }}
                    >
                        <Box sx={{ position: 'relative', zIndex: 1 }}>
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 3 }}>
                                <Box>
                                    <Typography variant="h4" sx={{ fontWeight: 800, color: THEME.text.primary, mb: 2 }}>
                                        {article.title}
                                    </Typography>
                                    <Stack direction="row" spacing={2}>
                                        <Chip 
                                            label={article.category.name} 
                                            size="small" 
                                            sx={{ 
                                                bgcolor: alpha(THEME.secondary, 0.1),
                                                color: THEME.secondary,
                                                fontWeight: 600
                                            }} 
                                        />
                                        <Chip
                                            icon={STATUS_COLORS[article.status.name]?.icon}
                                            label={article.status.label}
                                            size="small"
                                            sx={{
                                                bgcolor: STATUS_COLORS[article.status.name]?.bg,
                                                color: STATUS_COLORS[article.status.name]?.text,
                                                fontWeight: 600,
                                            }}
                                        />
                                    </Stack>
                                </Box>
                                <Paper
                                    sx={{
                                        p: 2,
                                        textAlign: 'center',
                                        bgcolor: alpha(THEME.secondary, 0.05),
                                        borderRadius: '12px',
                                        minWidth: 120
                                    }}
                                >
                                    <Typography variant="h4" sx={{ color: THEME.secondary, fontWeight: 700 }}>
                                        {wordCount}
                                    </Typography>
                                    <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                        Words
                                    </Typography>
                                    <Typography variant="caption" sx={{ color: THEME.text.light, display: 'block' }}>
                                        {getReadTime()}
                                    </Typography>
                                </Paper>
                            </Box>
                        </Box>
                        <Box
                            sx={{
                                position: 'absolute',
                                top: -20,
                                right: -20,
                                width: 200,
                                height: 200,
                                borderRadius: '50%',
                                background: alpha(THEME.warning, 0.03),
                                zIndex: 0
                            }}
                        />
                    </Paper>
                </Fade>

                {/* Editor Comments Section */}
                {article.comments && article.comments.length > 0 ? (
                    <Fade in timeout={700}>
                        <Paper
                            sx={{
                                p: 4,
                                mb: 4,
                                borderRadius: '16px',
                                background: `linear-gradient(135deg, ${alpha(THEME.warning, 0.05)} 0%, ${alpha(THEME.warning, 0.02)} 100%)`,
                                border: `2px solid ${alpha(THEME.warning, 0.3)}`,
                                position: 'relative',
                                overflow: 'hidden'
                            }}
                        >
                            {/* Decorative Element */}
                            <Box
                                sx={{
                                    position: 'absolute',
                                    top: 0,
                                    left: 0,
                                    width: '4px',
                                    height: '100%',
                                    background: THEME.gradient.warning
                                }}
                            />

                            <Box sx={{ display: 'flex', alignItems: 'center', mb: 4 }}>
                                <Box
                                    sx={{
                                        width: 48,
                                        height: 48,
                                        borderRadius: '12px',
                                        background: THEME.gradient.warning,
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        mr: 2,
                                        boxShadow: `0 4px 12px ${alpha(THEME.warning, 0.3)}`
                                    }}
                                >
                                    <CommentIcon sx={{ color: 'white', fontSize: 24 }} />
                                </Box>
                                <Box>
                                    <Typography variant="h5" sx={{ fontWeight: 800, color: THEME.warning, mb: 0.5 }}>
                                        Editor's Feedback
                                    </Typography>
                                    <Typography variant="body2" sx={{ color: alpha(THEME.warning, 0.8) }}>
                                        Please address these suggestions in your revision
                                    </Typography>
                                </Box>
                            </Box>

                            <Stack spacing={3}>
                                {article.comments.map((comment, index) => (
                                    <Zoom in timeout={500 + index * 100} key={index}>
                                        <Card
                                            elevation={0}
                                            sx={{
                                                borderRadius: '12px',
                                                border: `1px solid ${alpha(THEME.warning, 0.2)}`,
                                                transition: 'all 0.3s ease',
                                                '&:hover': {
                                                    transform: 'translateX(4px)',
                                                    boxShadow: `0 8px 16px ${alpha(THEME.warning, 0.1)}`,
                                                    borderColor: THEME.warning
                                                }
                                            }}
                                        >
                                            <CardContent sx={{ p: 3 }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                                                    <Avatar
                                                        sx={{
                                                            width: 32,
                                                            height: 32,
                                                            bgcolor: alpha(THEME.warning, 0.1),
                                                            color: THEME.warning,
                                                            mr: 1.5
                                                        }}
                                                    >
                                                        {comment.user?.name?.charAt(0) || 'E'}
                                                    </Avatar>
                                                    <Box>
                                                        <Typography variant="subtitle2" sx={{ fontWeight: 700, color: THEME.warning }}>
                                                            {comment.user?.name || 'Editor'}
                                                        </Typography>
                                                        <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                            {new Date(comment.created_at).toLocaleDateString()} at {new Date(comment.created_at).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                                                        </Typography>
                                                    </Box>
                                                </Box>
                                                <Paper
                                                    sx={{
                                                        p: 2,
                                                        bgcolor: alpha(THEME.warning, 0.02),
                                                        borderRadius: '8px',
                                                        borderLeft: `4px solid ${alpha(THEME.warning, 0.3)}`
                                                    }}
                                                >
                                                    <Typography
                                                        variant="body1"
                                                        sx={{
                                                            color: THEME.text.primary,
                                                            lineHeight: 1.7,
                                                            fontStyle: 'italic'
                                                        }}
                                                    >
                                                        "{comment.comment}"
                                                    </Typography>
                                                </Paper>
                                            </CardContent>
                                        </Card>
                                    </Zoom>
                                ))}
                            </Stack>
                        </Paper>
                    </Fade>
                ) : (
                    <Fade in timeout={700}>
                        <Alert
                            severity="info"
                            icon={<LightbulbIcon />}
                            sx={{
                                mb: 4,
                                borderRadius: '12px',
                                border: `1px solid ${alpha(THEME.secondary, 0.3)}`,
                                bgcolor: alpha(THEME.secondary, 0.05),
                                '& .MuiAlert-icon': {
                                    color: THEME.secondary
                                }
                            }}
                        >
                            <Typography variant="subtitle2" sx={{ fontWeight: 600, color: THEME.secondary, mb: 0.5 }}>
                                No Specific Feedback
                            </Typography>
                            <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                No specific revision comments from the editor. Take this opportunity to review and enhance your article.
                            </Typography>
                        </Alert>
                    </Fade>
                )}

                {/* Revision Form */}
                <Fade in timeout={900}>
                    <Paper
                        elevation={0}
                        sx={{
                            p: 4,
                            borderRadius: '16px',
                            background: 'white',
                            border: `1px solid ${alpha(THEME.primary, 0.1)}`
                        }}
                    >
                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 4 }}>
                            <Box
                                sx={{
                                    width: 40,
                                    height: 40,
                                    borderRadius: '10px',
                                    background: alpha(THEME.primary, 0.1),
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    mr: 2
                                }}
                            >
                                <BrushIcon sx={{ color: THEME.primary }} />
                            </Box>
                            <Typography variant="h6" sx={{ fontWeight: 700, color: THEME.text.primary }}>
                                Make Your Revisions
                            </Typography>
                        </Box>
                        
                        <form onSubmit={handleSubmit}>
                            <Paper
                                sx={{
                                    mb: 4,
                                    border: `1px solid ${alpha(THEME.primary, 0.2)}`,
                                    borderRadius: '12px',
                                    overflow: 'hidden',
                                    '&:hover': {
                                        borderColor: alpha(THEME.primary, 0.4)
                                    }
                                }}
                            >
                                <JoditEditor
                                    value={form.content}
                                    onBlur={(newContent) => setForm({ ...form, content: newContent })}
                                    config={{
                                        buttons: ['bold', 'italic', 'underline', '|', 'ul', 'ol', '|', 'font', 'fontsize', '|', 'image', 'table', 'link', '|', 'align', '|', 'undo', 'redo'],
                                        theme: 'dark',
                                        showCharsCounter: true,
                                        showWordsCounter: true,
                                        showXPathInStatusbar: false,
                                        height: 400,
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

                            {/* Revision Tips */}
                            <Paper
                                sx={{
                                    p: 2,
                                    mb: 3,
                                    bgcolor: alpha(THEME.secondary, 0.05),
                                    borderRadius: '8px',
                                    border: `1px solid ${alpha(THEME.secondary, 0.2)}`
                                }}
                            >
                                <Typography variant="subtitle2" sx={{ display: 'flex', alignItems: 'center', gap: 1, color: THEME.secondary, mb: 1 }}>
                                    <LightbulbIcon sx={{ fontSize: 18 }} />
                                    Revision Tips
                                </Typography>
                                <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                    • Address all editor comments thoroughly<br/>
                                    • Check for clarity and flow<br/>
                                    • Verify facts and citations<br/>
                                    • Read your revision aloud<br/>
                                    • Ensure consistent tone and style
                                </Typography>
                            </Paper>

                            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
                                <Button
                                    type="button"
                                    variant="outlined"
                                    onClick={() => window.history.back()}
                                    sx={{
                                        borderColor: alpha(THEME.text.secondary, 0.3),
                                        color: THEME.text.secondary,
                                        '&:hover': {
                                            borderColor: THEME.text.secondary,
                                            bgcolor: alpha(THEME.text.secondary, 0.04)
                                        }
                                    }}
                                >
                                    Cancel
                                </Button>
                                <Button
                                    type="submit"
                                    variant="contained"
                                    disabled={saveProgress}
                                    startIcon={saveProgress ? <LinearProgress size={20} /> : <SendIcon />}
                                    sx={{
                                        background: THEME.gradient.primary,
                                        color: 'white',
                                        fontWeight: 600,
                                        textTransform: 'none',
                                        px: 4,
                                        '&:hover': {
                                            boxShadow: `0 8px 16px ${alpha(THEME.primary, 0.3)}`
                                        }
                                    }}
                                >
                                    {saveProgress ? 'Submitting...' : 'Submit Revision'}
                                </Button>
                            </Box>
                        </form>
                    </Paper>
                </Fade>
            </Container>
        </Box>
    );
}