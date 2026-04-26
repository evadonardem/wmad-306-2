import { useState, useEffect } from 'react';
import { Head, Link, router, useForm } from '@inertiajs/react';
import {
    Box,
    Container,
    Card,
    CardContent,
    Typography,
    TextField,
    Button,
    Grid,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    Paper,
    Stepper,
    Step,
    StepLabel,
    Alert,
    CircularProgress,
    Divider
} from '@mui/material';
import {
    Save,
    Send,
    Visibility,
    ArrowBack,
    Article
} from '@mui/icons-material';
import JoditEditor from '@/Components/JoditEditor';

const steps = ['Basic Information', 'Article Content', 'Review & Submit'];

export default function ArticleForm({
    article = null,
    categories = [],
    isEdit = false,
    submitRouteName = 'writer.articles.store',
    updateRouteName = 'writer.articles.update',
    dashboardRouteName = 'writer.dashboard'
}) {
    const [activeStep, setActiveStep] = useState(0);
    const [content, setContent] = useState(article?.content || '');
    const [previewMode, setPreviewMode] = useState(false);
    const [submitting, setSubmitting] = useState(false);

    const { data, setData, processing, errors } = useForm({
        title: article?.title || '',
        content: article?.content || '',
        category_id: article?.category_id || '',
        status: article?.status?.name?.toLowerCase().replace(/\s+/g, '_') || 'draft'
    });

    useEffect(() => {
        setContent(data.content);
    }, [data.content]);

    const handleNext = () => {
        if (activeStep === steps.length - 1) {
            handleSubmit();
        } else {
            setActiveStep((prevStep) => prevStep + 1);
        }
    };

    const handleBack = () => {
        setActiveStep((prevStep) => prevStep - 1);
    };

    const handleSubmit = () => {
        const formData = {
            ...data,
            content: content
        };

        if (isEdit) {
            router.put(route(updateRouteName, article.id), formData, {
                onStart: () => setSubmitting(true),
                onFinish: () => setSubmitting(false),
                onSuccess: () => {
                    console.log('Article updated successfully');
                },
                onError: (errors) => {
                    console.error('Update errors:', errors);
                }
            });
        } else {
            router.post(route(submitRouteName), formData, {
                onStart: () => setSubmitting(true),
                onFinish: () => setSubmitting(false),
                onSuccess: () => {
                    console.log('Article created successfully');
                },
                onError: (errors) => {
                    console.error('Creation errors:', errors);
                }
            });
        }
    };

    const handleSaveDraft = () => {
        const formData = {
            ...data,
            content: content,
            status: 'draft'
        };

        if (isEdit) {
            router.put(route(updateRouteName, article.id), formData, {
                onStart: () => setSubmitting(true),
                onFinish: () => setSubmitting(false),
            });
        } else {
            router.post(route(submitRouteName), formData, {
                onStart: () => setSubmitting(true),
                onFinish: () => setSubmitting(false),
            });
        }
    };

    const handleSubmitForReview = () => {
        const formData = {
            ...data,
            content: content,
            status: 'submitted'
        };

        if (isEdit) {
            router.put(route(updateRouteName, article.id), formData, {
                onStart: () => setSubmitting(true),
                onFinish: () => setSubmitting(false),
            });
        } else {
            router.post(route(submitRouteName), formData, {
                onStart: () => setSubmitting(true),
                onFinish: () => setSubmitting(false),
            });
        }
    };

    const getStepContent = (step) => {
        switch (step) {
            case 0:
                return (
                    <Grid container spacing={3}>
                        <Grid item xs={12}>
                            <TextField
                                fullWidth
                                label="Article Title"
                                value={data.title}
                                onChange={(e) => setData('title', e.target.value)}
                                error={!!errors.title}
                                helperText={errors.title}
                                required
                                placeholder="Enter a compelling title for your article"
                            />
                        </Grid>
                        
                        <Grid item xs={12} md={6}>
                            <FormControl fullWidth error={!!errors.category_id}>
                                <InputLabel>Category</InputLabel>
                                <Select
                                    value={data.category_id}
                                    label="Category"
                                    onChange={(e) => setData('category_id', e.target.value)}
                                >
                                    {(categories || []).map((category) => {
                                        // Validate category to prevent React error #31
                                        if (!category || typeof category !== 'object') return null;
                                        
                                        return (
                                            <MenuItem key={category.id || `category-${Math.random()}`} value={category.id}>
                                                {category.name || 'Uncategorized'}
                                            </MenuItem>
                                        );
                                    })}
                                </Select>
                                {errors.category_id && (
                                    <Typography variant="caption" color="error">
                                        {errors.category_id}
                                    </Typography>
                                )}
                            </FormControl>
                        </Grid>
                        
                        <Grid item xs={12} md={6}>
                            <FormControl fullWidth>
                                <InputLabel>Status</InputLabel>
                                <Select
                                    value={data.status}
                                    label="Status"
                                    onChange={(e) => setData('status', e.target.value)}
                                    disabled={!isEdit}
                                >
                                    <MenuItem value="draft">Draft</MenuItem>
                                    <MenuItem value="submitted">Submitted</MenuItem>
                                    {isEdit && <MenuItem value="needs_revision">Needs Revision</MenuItem>}
                                    {isEdit && <MenuItem value="published">Published</MenuItem>}
                                </Select>
                            </FormControl>
                        </Grid>
                    </Grid>
                );

            case 1:
                return (
                    <Box>
                        <Typography variant="h6" gutterBottom>
                            Article Content
                        </Typography>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                            Write your article content using the rich text editor. You can format text, add images, links, and more.
                        </Typography>
                        
                        <JoditEditor
                            value={content}
                            onChange={setContent}
                            placeholder="Start writing your article..."
                            height={500}
                            error={!!errors.content}
                            helperText={errors.content}
                        />
                    </Box>
                );

            case 2:
                return (
                    <Box>
                        <Typography variant="h6" gutterBottom>
                            Review & Submit
                        </Typography>
                        
                        <Paper sx={{ p: 3, mb: 3 }}>
                            <Typography variant="subtitle1" gutterBottom>
                                Article Preview
                            </Typography>
                            
                            <Divider sx={{ mb: 2 }} />
                            
                            <Typography variant="h5" gutterBottom>
                                {data.title || 'Untitled Article'}
                            </Typography>
                            
                            {data.category_id && (
                                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                                    Category: {categories.find(c => c.id === data.category_id)?.name}
                                </Typography>
                            )}
                            
                            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                                Status: <strong>{data.status}</strong>
                            </Typography>
                            
                            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                                Word Count: {content.split(/\s+/).filter(word => word.length > 0).length} words
                            </Typography>
                            
                            <Divider sx={{ my: 2 }} />
                            
                            <Typography variant="body1" sx={{ 
                                lineHeight: 1.6,
                                '& img': { maxWidth: '100%', height: 'auto' },
                                '& blockquote': { 
                                    borderLeft: '4px solid #ccc', 
                                    paddingLeft: '16px',
                                    fontStyle: 'italic'
                                }
                            }} 
                            dangerouslySetInnerHTML={{ __html: content }} 
                            />
                        </Paper>
                        
                        {Object.keys(errors).length > 0 && (
                            <Alert severity="error" sx={{ mb: 3 }}>
                                Please fix the errors before submitting:
                                <ul>
                                    {Object.entries(errors).map(([field, error]) => (
                                        <li key={field}>{error}</li>
                                    ))}
                                </ul>
                            </Alert>
                        )}
                    </Box>
                );

            default:
                return 'Unknown step';
        }
    };

    return (
        <>
            <Head title={isEdit ? 'Edit Article' : 'Create Article'} />
            
            <Container maxWidth="lg">
                <Box sx={{ py: 4 }}>
                    {/* Header */}
                    <Paper sx={{ p: 3, mb: 4 }}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                            <Box sx={{ display: 'flex', alignItems: 'center' }}>
                                <Button
                                    component={Link}
                                    href={route(dashboardRouteName)}
                                    startIcon={<ArrowBack />}
                                    sx={{ mr: 2 }}
                                >
                                    Back to Dashboard
                                </Button>
                                
                                <Typography variant="h4" component="h1">
                                    {isEdit ? 'Edit Article' : 'Create New Article'}
                                </Typography>
                            </Box>
                            
                            <Button
                                startIcon={<Article />}
                                onClick={() => setPreviewMode(!previewMode)}
                                variant="outlined"
                            >
                                {previewMode ? 'Edit Mode' : 'Preview Mode'}
                            </Button>
                        </Box>
                    </Paper>

                    {/* Stepper */}
                    <Paper sx={{ p: 3, mb: 4 }}>
                        <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
                            {steps.map((label, index) => (
                                <Step key={label}>
                                    <StepLabel>{label}</StepLabel>
                                </Step>
                            ))}
                        </Stepper>

                        {/* Step Content */}
                        <Box sx={{ mb: 4 }}>
                            {getStepContent(activeStep)}
                        </Box>

                        {/* Navigation Buttons */}
                        <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                            <Button
                                disabled={activeStep === 0}
                                onClick={handleBack}
                                variant="outlined"
                            >
                                Back
                            </Button>

                            <Box sx={{ display: 'flex', gap: 2 }}>
                                {activeStep === 1 && (
                                    <Button
                                        onClick={handleSaveDraft}
                                        variant="outlined"
                                        startIcon={<Save />}
                                        disabled={processing || submitting}
                                    >
                                        Save as Draft
                                    </Button>
                                )}

                                {activeStep === 2 && (
                                    <Button
                                        onClick={handleSubmitForReview}
                                        variant="contained"
                                        color="primary"
                                        startIcon={<Send />}
                                        disabled={processing || submitting || Object.keys(errors).length > 0}
                                    >
                                        {processing || submitting ? (
                                            <CircularProgress size={24} />
                                        ) : (
                                            'Submit for Review'
                                        )}
                                    </Button>
                                )}

                                <Button
                                    onClick={handleNext}
                                    variant="contained"
                                    disabled={processing || submitting}
                                >
                                    {activeStep === steps.length - 1 ? (
                                        isEdit ? 'Update Article' : 'Create Article'
                                    ) : (
                                        'Next'
                                    )}
                                </Button>
                            </Box>
                        </Box>
                    </Paper>
                </Box>
            </Container>
        </>
    );
}
