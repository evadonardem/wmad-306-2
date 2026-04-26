import { useState } from 'react';
import { Head } from '@inertiajs/react';
import {
    Box,
    Container,
    Typography,
    Paper,
    Button,
    Grid,
    Card,
    CardContent
} from '@mui/material';
import {
    Save,
    Preview,
    Code
} from '@mui/icons-material';
import JoditEditor from '@/Components/JoditEditor';

export default function JoditSample() {
    const [content, setContent] = useState('');
    const [showPreview, setShowPreview] = useState(false);

    const sampleContent = `
        <h2>Welcome to Jodit Editor!</h2>
        <p>This is a <strong>rich text editor</strong> that allows you to create beautiful content with ease.</p>
        
        <h3>Features</h3>
        <ul>
            <li><strong>Bold</strong>, <em>italic</em>, and <u>underline</u> text formatting</li>
            <li>Lists (both ordered and unordered)</li>
            <li>Links and images</li>
            <li>Tables and more complex layouts</li>
            <li>Code blocks and syntax highlighting</li>
        </ul>
        
        <h3>Example Code Block</h3>
        <pre><code>function helloWorld() {
    console.log("Hello, World!");
    return true;
}</code></pre>
        
        <blockquote>
            <p>"The best way to learn is by doing. Start creating amazing content today!"</p>
        </blockquote>
        
        <p>Try editing this content to see how the editor works!</p>
    `;

    const handleLoadSample = () => {
        setContent(sampleContent);
    };

    const handleClear = () => {
        setContent('');
    };

    const handleSave = () => {
        console.log('Saving content:', content);
        alert('Content saved! Check the console for the output.');
    };

    return (
        <>
            <Head title="Jodit Editor Sample" />
            
            <Container maxWidth="lg">
                <Box sx={{ py: 4 }}>
                    {/* Header */}
                    <Paper sx={{ p: 3, mb: 4 }}>
                        <Typography variant="h4" component="h1" gutterBottom>
                            Jodit Editor Sample
                        </Typography>
                        <Typography variant="body1" color="text.secondary">
                            Test the rich text editor functionality used in article creation
                        </Typography>
                    </Paper>

                    <Grid container spacing={3}>
                        {/* Editor Section */}
                        <Grid item xs={12} lg={showPreview ? 6 : 12}>
                            <Card>
                                <CardContent>
                                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                                        <Typography variant="h6">
                                            Editor
                                        </Typography>
                                        <Box sx={{ display: 'flex', gap: 1 }}>
                                            <Button
                                                size="small"
                                                onClick={handleLoadSample}
                                                variant="outlined"
                                            >
                                                Load Sample
                                            </Button>
                                            <Button
                                                size="small"
                                                onClick={handleClear}
                                                variant="outlined"
                                                color="error"
                                            >
                                                Clear
                                            </Button>
                                            <Button
                                                size="small"
                                                onClick={handleSave}
                                                variant="contained"
                                                startIcon={<Save />}
                                            >
                                                Save
                                            </Button>
                                        </Box>
                                    </Box>
                                    
                                    <JoditEditor
                                        value={content}
                                        onChange={setContent}
                                        placeholder="Start typing your content here..."
                                        height={500}
                                    />
                                </CardContent>
                            </Card>
                        </Grid>

                        {/* Preview Section */}
                        {showPreview && (
                            <Grid item xs={12} lg={6}>
                                <Card>
                                    <CardContent>
                                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                                            <Typography variant="h6">
                                                Preview
                                            </Typography>
                                            <Button
                                                size="small"
                                                onClick={() => setShowPreview(false)}
                                                variant="outlined"
                                            >
                                                Close Preview
                                            </Button>
                                        </Box>
                                        
                                        <Paper 
                                            sx={{ 
                                                p: 3, 
                                                minHeight: 500,
                                                backgroundColor: 'grey.50',
                                                '& img': { maxWidth: '100%', height: 'auto' },
                                                '& blockquote': { 
                                                    borderLeft: '4px solid #ccc', 
                                                    paddingLeft: '16px',
                                                    fontStyle: 'italic',
                                                    margin: '16px 0'
                                                },
                                                '& pre': {
                                                    backgroundColor: '#f5f5f5',
                                                    padding: '16px',
                                                    borderRadius: '4px',
                                                    overflow: 'auto',
                                                    fontFamily: 'monospace'
                                                },
                                                '& code': {
                                                    backgroundColor: '#f5f5f5',
                                                    padding: '2px 4px',
                                                    borderRadius: '2px',
                                                    fontFamily: 'monospace'
                                                },
                                                '& h1, h2, h3, h4, h5, h6': {
                                                    marginTop: '24px',
                                                    marginBottom: '16px'
                                                },
                                                '& p': {
                                                    marginBottom: '16px',
                                                    lineHeight: 1.6
                                                },
                                                '& ul, ol': {
                                                    marginBottom: '16px',
                                                    paddingLeft: '24px'
                                                }
                                            }}
                                        >
                                            {content ? (
                                                <div dangerouslySetInnerHTML={{ __html: content }} />
                                            ) : (
                                                <Typography variant="body2" color="text.secondary" align="center" sx={{ py: 8 }}>
                                                    Start typing in the editor to see the preview here
                                                </Typography>
                                            )}
                                        </Paper>
                                    </CardContent>
                                </Card>
                            </Grid>
                        )}
                    </Grid>

                    {/* Floating Preview Button */}
                    {!showPreview && (
                        <Button
                            variant="contained"
                            startIcon={<Preview />}
                            onClick={() => setShowPreview(true)}
                            sx={{
                                position: 'fixed',
                                bottom: 24,
                                right: 24,
                                zIndex: 1000
                            }}
                        >
                            Show Preview
                        </Button>
                    )}

                    {/* Instructions */}
                    <Paper sx={{ p: 3, mt: 4 }}>
                        <Typography variant="h6" gutterBottom>
                            How to Use
                        </Typography>
                        <Box component="ul" sx={{ pl: 2 }}>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                <strong>Load Sample:</strong> Click to load pre-formatted content
                            </Typography>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                <strong>Edit Content:</strong> Use the toolbar or keyboard shortcuts to format text
                            </Typography>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                <strong>Preview:</strong> Click "Show Preview" to see how your content will look
                            </Typography>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                <strong>Save:</strong> Click "Save" to output the HTML content to console
                            </Typography>
                        </Box>
                        
                        <Typography variant="h6" sx={{ mt: 3, mb: 1 }}>
                            Available Features
                        </Typography>
                        <Box component="ul" sx={{ pl: 2 }}>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                Text formatting (bold, italic, underline, strikethrough)
                            </Typography>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                Lists (ordered and unordered)
                            </Typography>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                Links and images
                            </Typography>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                Tables and code blocks
                            </Typography>
                            <Typography component="li" variant="body2" sx={{ mb: 1 }}>
                                Blockquotes and headings
                            </Typography>
                            <Typography component="li" variant="body2">
                                Undo/redo functionality
                            </Typography>
                        </Box>
                    </Paper>
                </Box>
            </Container>
        </>
    );
}
