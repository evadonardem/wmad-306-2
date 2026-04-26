import { Head, Link } from '@inertiajs/react';
import { Box, Button, Chip, Container, Divider, Paper, Typography } from '@mui/material';

export default function Show({ article }) {
    return (
        <Container maxWidth="md" sx={{ py: 8 }}>
            <Head title={article.title} />
            
            <Box sx={{ mb: 4 }}>
                <Button component={Link} href="/" variant="text" sx={{ mb: 2 }}>
                    ← Back to Gallery
                </Button>
                
                <Typography variant="h3" component="h1" gutterBottom sx={{ fontWeight: 'bold' }}>
                    {article.title}
                </Typography>

                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
                    <Typography variant="subtitle1" color="text.secondary">
                        By {article.user.name}
                    </Typography>
                    <Divider orientation="vertical" flexItem />
                    <Chip label={article.category.name} size="small" color="primary" variant="outlined" />
                    <Typography variant="subtitle2" color="text.secondary">
                        {new Date(article.created_at).toLocaleDateString()}
                    </Typography>
                </Box>
            </Box>

            <Paper elevation={0} sx={{ p: 4, bgcolor: '#fdfdfd', borderRadius: 2, border: '1px solid #eee' }}>
                {/* We use dangerouslySetInnerHTML if you are using a Rich Text Editor 
                   Otherwise, just render the content simply 
                */}
                <Typography 
                    variant="body1" 
                    sx={{ lineHeight: 1.8, fontSize: '1.1rem', whiteSpace: 'pre-wrap' }}
                >
                    {article.content}
                </Typography>
            </Paper>
        </Container>
    );
}