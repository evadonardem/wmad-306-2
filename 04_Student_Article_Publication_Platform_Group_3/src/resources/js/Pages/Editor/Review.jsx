import React, { useState } from 'react';
import {
    Container,
    Typography,
    TextField,
    Button,
    Box,
    Card,
    CardContent,
    AppBar,
    Toolbar,
    Grid,
    Paper,
    Divider,
    Alert,
    Chip,
    Avatar,
    IconButton,
    Tooltip,
    LinearProgress,
    Stack,
    alpha,
    Fade
} from '@mui/material';
import { Inertia } from '@inertiajs/inertia';
import {
    ArrowBack as ArrowBackIcon,
    Send as SendIcon,
    Publish as PublishIcon,
    EditNote as EditNoteIcon,
    Warning as WarningIcon,
    CheckCircle as CheckCircleIcon,
    Schedule as ScheduleIcon,
    Person as PersonIcon,
    Category as CategoryIcon,
    CalendarToday as CalendarTodayIcon,
    AccessTime as AccessTimeIcon,
    FormatQuote as FormatQuoteIcon,
    RateReview as RateReviewIcon,
    Spellcheck as SpellcheckIcon,
    FactCheck as FactCheckIcon
} from '@mui/icons-material';

const THEME = {
    primary: '#6366F1',
    primaryLight: '#818CF8',
    primaryDark: '#4F46E5',
    secondary: '#8B5CF6',
    success: '#10B981',
    warning: '#F59E0B',
    error: '#EF4444',
    surface: '#FFFFFF',
    background: '#F9FAFB',
    text: {
        primary: '#1F2937',
        secondary: '#6B7280',
        light: '#9CA3AF'
    },
    gradient: {
        primary: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)',
        secondary: 'linear-gradient(135deg, #8B5CF6 0%, #EC4899 100%)',
        success: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
        warning: 'linear-gradient(135deg, #F59E0B 0%, #D97706 100%)'
    }
};

export default function Review({ article }) {
    const [comments, setComments] = useState('');
    const [loading, setLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('review');
    const [checklist, setChecklist] = useState({
        plagiarism: false,
        facts: false,
        grammar: false,
        structure: false,
        citations: false
    });

    // Add error handling for missing article data
    if (!article) {
        return (
            <Container maxWidth="lg" sx={{ py: 4 }}>
                <Alert severity="error">
                    Article not found or unable to load article data.
                </Alert>
            </Container>
        );
    }

    const requestRevision = () => {
        if (!comments.trim()) {
            alert('Please provide detailed comments for the revision request.');
            return;
        }
        
        if (!confirm('Are you sure you want to request revision? This will notify the writer.')) {
            return;
        }
        
        setLoading(true);
        
        Inertia.post(route('editor.articles.requestRevision', article.id), { 
            comments: comments.trim() 
        }, {
            onSuccess: () => {
                alert('Revision request sent successfully! The writer has been notified.');
                setComments('');
                setLoading(false);
            },
            onError: (errors) => {
                console.error('Revision request error:', errors);
                alert('Error sending revision request. Please try again.');
                setLoading(false);
            },
            onFinish: () => {
                setLoading(false);
            }
        });
    };

    const publish = () => {
        // Check if all checklist items are completed
        const allChecked = Object.values(checklist).every(Boolean);
        if (!allChecked) {
            if (!confirm('Some quality checks are incomplete. Are you sure you want to publish?')) {
                return;
            }
        }

        if (!confirm('Are you sure you want to publish this article? This action cannot be undone.')) {
            return;
        }
        setLoading(true);
        
        Inertia.post(route('editor.articles.publish', article.id), {}, {
            onSuccess: () => {
                alert('Article published successfully!');
                setLoading(false);
            },
            onError: (errors) => {
                console.error('Publish error:', errors);
                alert('Error publishing article. Please try again.');
                setLoading(false);
            },
            onFinish: () => {
                setLoading(false);
            }
        });
    };

    const handleBack = () => {
        window.history.back();
    };

    const getReadTime = (content) => {
        const wordsPerMinute = 200;
        const wordCount = content?.split(/\s+/).length || 0;
        const readTime = Math.ceil(wordCount / wordsPerMinute);
        return `${readTime} min read`;
    };

    const getWordCount = (content) => {
        return content?.split(/\s+/).length || 0;
    };

    return (
        <Box sx={{ 
            bgcolor: THEME.background,
            minHeight: '100vh',
            pb: 4
        }}>
            {/* Header */}
            <AppBar
                position="sticky"
                elevation={0}
                sx={{
                    background: 'rgba(255, 255, 255, 0.8)',
                    backdropFilter: 'blur(20px)',
                    borderBottom: `1px solid ${alpha(THEME.primary, 0.1)}`,
                }}
            >
                <Toolbar>
                    <IconButton
                        onClick={handleBack}
                        sx={{
                            mr: 2,
                            width: 40,
                            height: 40,
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
                            Editorial Review
                        </Typography>
                        <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                            {article.title}
                        </Typography>
                    </Box>

                    <Chip
                        icon={<ScheduleIcon />}
                        label={getReadTime(article.content)}
                        size="small"
                        sx={{
                            mr: 2,
                            bgcolor: alpha(THEME.primary, 0.05),
                            color: THEME.text.secondary
                        }}
                    />
                </Toolbar>
            </AppBar>

            <Container maxWidth="xl" sx={{ py: 4 }}>
                <Grid container spacing={3}>
                    {/* Article Content */}
                    <Grid item xs={12} lg={8}>
                        <Fade in timeout={500}>
                            <Card
                                elevation={0}
                                sx={{
                                    borderRadius: '16px',
                                    border: `1px solid ${alpha(THEME.primary, 0.1)}`,
                                    overflow: 'hidden'
                                }}
                            >
                                <CardContent sx={{ p: 4 }}>
                                    {/* Article Metadata */}
                                    <Box sx={{ mb: 4 }}>
                                        <Typography 
                                            variant="h4" 
                                            sx={{ 
                                                fontWeight: 800, 
                                                color: THEME.text.primary,
                                                mb: 3,
                                                lineHeight: 1.3
                                            }}
                                        >
                                            {article.title}
                                        </Typography>
                                        
                                        <Grid container spacing={2}>
                                            <Grid item xs={12} sm={6} md={3}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    <Avatar sx={{ width: 32, height: 32, bgcolor: alpha(THEME.primary, 0.1) }}>
                                                        <PersonIcon sx={{ fontSize: 16, color: THEME.primary }} />
                                                    </Avatar>
                                                    <Box>
                                                        <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                            Author
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                            {article.writer?.name || 'Unknown'}
                                                        </Typography>
                                                    </Box>
                                                </Box>
                                            </Grid>
                                            <Grid item xs={12} sm={6} md={3}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    <Avatar sx={{ width: 32, height: 32, bgcolor: alpha(THEME.secondary, 0.1) }}>
                                                        <CategoryIcon sx={{ fontSize: 16, color: THEME.secondary }} />
                                                    </Avatar>
                                                    <Box>
                                                        <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                            Category
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                            {article.category?.name || 'Uncategorized'}
                                                        </Typography>
                                                    </Box>
                                                </Box>
                                            </Grid>
                                            <Grid item xs={12} sm={6} md={3}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    <Avatar sx={{ width: 32, height: 32, bgcolor: alpha(THEME.warning, 0.1) }}>
                                                        <CalendarTodayIcon sx={{ fontSize: 16, color: THEME.warning }} />
                                                    </Avatar>
                                                    <Box>
                                                        <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                            Submitted
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                            {new Date(article.created_at).toLocaleDateString()}
                                                        </Typography>
                                                    </Box>
                                                </Box>
                                            </Grid>
                                            <Grid item xs={12} sm={6} md={3}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                                    <Avatar sx={{ width: 32, height: 32, bgcolor: alpha(THEME.success, 0.1) }}>
                                                        <AccessTimeIcon sx={{ fontSize: 16, color: THEME.success }} />
                                                    </Avatar>
                                                    <Box>
                                                        <Typography variant="caption" sx={{ color: THEME.text.light }}>
                                                            Word Count
                                                        </Typography>
                                                        <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.text.primary }}>
                                                            {getWordCount(article.content).toLocaleString()} words
                                                        </Typography>
                                                    </Box>
                                                </Box>
                                            </Grid>
                                        </Grid>
                                    </Box>

                                    <Divider sx={{ my: 3 }} />

                                    {/* Article Content */}
                                    <Box
                                        sx={{
                                            '& p': { 
                                                lineHeight: 1.8, 
                                                color: THEME.text.primary,
                                                mb: 2,
                                                fontSize: '1rem'
                                            },
                                            '& h2': { 
                                                fontSize: '1.5rem',
                                                fontWeight: 700,
                                                color: THEME.text.primary,
                                                mt: 4,
                                                mb: 2
                                            },
                                            '& h3': { 
                                                fontSize: '1.25rem',
                                                fontWeight: 600,
                                                color: THEME.text.primary,
                                                mt: 3,
                                                mb: 1.5
                                            },
                                            '& img': { 
                                                maxWidth: '100%', 
                                                height: 'auto', 
                                                my: 3,
                                                borderRadius: '8px'
                                            },
                                            '& blockquote': {
                                                borderLeft: `4px solid ${THEME.primary}`,
                                                bgcolor: alpha(THEME.primary, 0.02),
                                                py: 2,
                                                px: 3,
                                                my: 2,
                                                fontStyle: 'italic',
                                                color: THEME.text.secondary
                                            },
                                            '& ul, & ol': {
                                                pl: 3,
                                                mb: 2
                                            },
                                            '& li': {
                                                mb: 0.5
                                            }
                                        }}
                                    >
                                        {article.content ? (
                                            <div dangerouslySetInnerHTML={{ __html: article.content }} />
                                        ) : (
                                            <Typography color="textSecondary">
                                                No content available for this article.
                                            </Typography>
                                        )}
                                    </Box>
                                </CardContent>
                            </Card>
                        </Fade>
                    </Grid>

                    {/* Review Panel */}
                    <Grid item xs={12} lg={4}>
                        <Fade in timeout={700}>
                            <Paper
                                elevation={0}
                                sx={{
                                    p: 3,
                                    borderRadius: '16px',
                                    background: 'white',
                                    border: `1px solid ${alpha(THEME.primary, 0.1)}`,
                                    position: 'sticky',
                                    top: 100,
                                    height: 'fit-content',
                                    maxHeight: 'calc(100vh - 120px)',
                                    overflow: 'auto'
                                }}
                            >
                                <Typography
                                    variant="h6"
                                    sx={{
                                        fontWeight: 700,
                                        color: THEME.text.primary,
                                        mb: 3,
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: 1
                                    }}
                                >
                                    <RateReviewIcon sx={{ color: THEME.primary }} />
                                    Editorial Review Panel
                                </Typography>

                                {/* Progress Indicator */}
                                <Box sx={{ mb: 3 }}>
                                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
                                        <Typography variant="body2" sx={{ color: THEME.text.secondary }}>
                                            Review Progress
                                        </Typography>
                                        <Typography variant="body2" sx={{ fontWeight: 600, color: THEME.primary }}>
                                            {Math.round((Object.values(checklist).filter(Boolean).length / 5) * 100)}%
                                        </Typography>
                                    </Box>
                                    <LinearProgress
                                        variant="determinate"
                                        value={(Object.values(checklist).filter(Boolean).length / 5) * 100}
                                        sx={{
                                            height: 6,
                                            borderRadius: 3,
                                            bgcolor: alpha(THEME.primary, 0.1),
                                            '& .MuiLinearProgress-bar': {
                                                background: THEME.gradient.primary,
                                                borderRadius: 3
                                            }
                                        }}
                                    />
                                </Box>

                                {/* Quality Checklist */}
                                <Typography variant="subtitle2" sx={{ fontWeight: 600, color: THEME.text.primary, mb: 2 }}>
                                    Quality Checklist
                                </Typography>
                                <Stack spacing={1.5} sx={{ mb: 3 }}>
                                    {[
                                        { key: 'plagiarism', label: 'Originality Check', icon: <FactCheckIcon /> },
                                        { key: 'facts', label: 'Fact Verification', icon: <FactCheckIcon /> },
                                        { key: 'grammar', label: 'Grammar & Style', icon: <SpellcheckIcon /> },
                                        { key: 'structure', label: 'Content Structure', icon: <EditNoteIcon /> },
                                        { key: 'citations', label: 'Citations & References', icon: <FormatQuoteIcon /> }
                                    ].map((item) => (
                                        <Box
                                            key={item.key}
                                            onClick={() => setChecklist(prev => ({ ...prev, [item.key]: !prev[item.key] }))}
                                            sx={{
                                                display: 'flex',
                                                alignItems: 'center',
                                                gap: 1.5,
                                                p: 1.5,
                                                borderRadius: '8px',
                                                cursor: 'pointer',
                                                bgcolor: checklist[item.key] ? alpha(THEME.success, 0.05) : 'transparent',
                                                border: `1px solid ${checklist[item.key] ? alpha(THEME.success, 0.2) : alpha(THEME.primary, 0.1)}`,
                                                transition: 'all 0.2s ease',
                                                '&:hover': {
                                                    bgcolor: checklist[item.key] ? alpha(THEME.success, 0.1) : alpha(THEME.primary, 0.02)
                                                }
                                            }}
                                        >
                                            <Box sx={{ 
                                                width: 24, 
                                                height: 24, 
                                                borderRadius: '6px',
                                                display: 'flex',
                                                alignItems: 'center',
                                                justifyContent: 'center',
                                                bgcolor: checklist[item.key] ? THEME.success : 'transparent',
                                                border: `2px solid ${checklist[item.key] ? THEME.success : alpha(THEME.primary, 0.2)}`,
                                                color: 'white',
                                                fontSize: '0.75rem',
                                                fontWeight: 'bold'
                                            }}>
                                                {checklist[item.key] && '✓'}
                                            </Box>
                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, flex: 1 }}>
                                                <Box sx={{ color: checklist[item.key] ? THEME.success : THEME.text.light }}>
                                                    {item.icon}
                                                </Box>
                                                <Typography variant="body2" sx={{ 
                                                    fontWeight: 500,
                                                    color: checklist[item.key] ? THEME.text.primary : THEME.text.secondary
                                                }}>
                                                    {item.label}
                                                </Typography>
                                            </Box>
                                        </Box>
                                    ))}
                                </Stack>

                                {/* Revision Comments */}
                                <Typography
                                    variant="subtitle2"
                                    sx={{
                                        fontWeight: 600,
                                        color: THEME.text.primary,
                                        mb: 1
                                    }}
                                >
                                    Revision Comments
                                </Typography>
                                <TextField
                                    placeholder="Provide detailed feedback for the writer..."
                                    fullWidth
                                    multiline
                                    rows={6}
                                    value={comments}
                                    onChange={(e) => setComments(e.target.value)}
                                    variant="outlined"
                                    sx={{
                                        mb: 2,
                                        '& .MuiOutlinedInput-root': {
                                            borderRadius: '10px',
                                            bgcolor: alpha(THEME.primary, 0.02),
                                            '&:hover fieldset': { borderColor: alpha(THEME.primary, 0.3) },
                                            '&.Mui-focused fieldset': { borderColor: THEME.primary }
                                        }
                                    }}
                                />

                                {/* Action Buttons */}
                                <Stack spacing={2}>
                                    <Tooltip title="Request revision with comments" arrow>
                                        <Button
                                            fullWidth
                                            variant="outlined"
                                            startIcon={<WarningIcon />}
                                            onClick={requestRevision}
                                            disabled={loading || !comments.trim()}
                                            sx={{
                                                borderColor: alpha(THEME.warning, 0.5),
                                                color: THEME.warning,
                                                fontWeight: 600,
                                                textTransform: 'none',
                                                py: 1.5,
                                                borderRadius: '10px',
                                                '&:hover': {
                                                    borderColor: THEME.warning,
                                                    bgcolor: alpha(THEME.warning, 0.04)
                                                }
                                            }}
                                        >
                                            {loading ? 'Sending...' : 'Request Revision'}
                                        </Button>
                                    </Tooltip>
                                    
                                    <Tooltip title="Approve and publish article" arrow>
                                        <Button
                                            fullWidth
                                            variant="contained"
                                            startIcon={<PublishIcon />}
                                            onClick={publish}
                                            disabled={loading}
                                            sx={{
                                                background: THEME.gradient.primary,
                                                color: 'white',
                                                fontWeight: 600,
                                                textTransform: 'none',
                                                py: 1.5,
                                                borderRadius: '10px',
                                                '&:hover': {
                                                    boxShadow: `0 8px 16px ${alpha(THEME.primary, 0.3)}`
                                                }
                                            }}
                                        >
                                            {loading ? 'Publishing...' : 'Approve & Publish'}
                                        </Button>
                                    </Tooltip>
                                </Stack>

                                <Divider sx={{ my: 3 }} />

                                {/* Article Info */}
                                <Box sx={{ textAlign: 'center' }}>
                                    <Chip
                                        label={`Article ID: ${article.id}`}
                                        size="small"
                                        sx={{
                                            bgcolor: alpha(THEME.primary, 0.05),
                                            color: THEME.text.light,
                                            fontSize: '0.7rem'
                                        }}
                                    />
                                </Box>

                                {/* Quick Tips */}
                                <Alert 
                                    severity="info" 
                                    sx={{ 
                                        mt: 2,
                                        borderRadius: '10px',
                                        bgcolor: alpha(THEME.primary, 0.02),
                                        border: `1px solid ${alpha(THEME.primary, 0.1)}`,
                                        '& .MuiAlert-icon': { color: THEME.primary }
                                    }}
                                >
                                    <Typography variant="caption" sx={{ color: THEME.text.secondary }}>
                                        <strong>Pro Tip:</strong> Provide specific, actionable feedback to help writers improve their work.
                                    </Typography>
                                </Alert>
                            </Paper>
                        </Fade>
                    </Grid>
                </Grid>
            </Container>
        </Box>
    );
}