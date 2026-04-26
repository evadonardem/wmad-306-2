import { Head, Link } from '@inertiajs/react';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import { Box, Button, Chip, Container, Divider, Paper, Typography } from '@mui/material';

export default function ViewArticle({ article }) {
    return (
        <Box sx={{ bgcolor: '#f4f6f8', minHeight: '100vh', py: 5 }}>
            <Head title={article.title} />

            <Container maxWidth="md">
                {/* Back Button */}
                <Button 
                    component={Link} 
                    href={route('home')} 
                    startIcon={<ArrowBackIcon />} 
                    sx={{ mb: 3 }}
                >
                    Back to Articles
                </Button>

                <Paper sx={{ p: { xs: 3, md: 6 }, borderRadius: 2, boxShadow: 2 }}>
                    {/* Category and Header */}
                    <Chip 
                        label={article.category?.name} 
                        color="primary" 
                        variant="outlined" 
                        sx={{ mb: 2 }} 
                    />
                    
                    <Typography variant="h3" component="h1" gutterBottom sx={{ fontWeight: 'bold' }}>
                        {article.title}
                    </Typography>

                    <Typography variant="subtitle1" color="text.secondary" sx={{ mb: 2 }}>
                        Published by <strong>{article.user?.name}</strong> on {new Date(article.created_at).toLocaleDateString()}
                    </Typography>

                    <Divider sx={{ my: 4 }} />

                    {/* Article Body */}
                    <Typography 
                        variant="body1" 
                        sx={{ 
                            lineHeight: 1.8, 
                            fontSize: '1.1rem', 
                            whiteSpace: 'pre-line', // Preserves line breaks from the database
                            color: '#2c3e50'
                        }}
                    >
                        {article.content}
                    </Typography>
                </Paper>
            </Container>
        </Box>
    );
}