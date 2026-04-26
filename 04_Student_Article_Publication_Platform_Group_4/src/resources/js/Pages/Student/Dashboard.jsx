import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import { Box, Button, Card, CardActions, CardContent, Chip, Grid, Typography } from '@mui/material';

export default function StudentDashboard({ auth, articles }) {
    return (
        <AuthenticatedLayout
            user={auth.user}
            // Updated to 'Student Library' to match your intended role
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Student Library</h2>}
        >
            {/* Updated title for the browser tab */}
            <Head title="Student Library" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <Typography variant="h4" sx={{ mb: 4, fontWeight: 'bold' }}>
                        Browse Published Papers
                    </Typography>

                    <Grid container spacing={3}>
                        {articles.length > 0 ? (
                            articles.map((article) => (
                                <Grid item xs={12} sm={6} md={4} key={article.id}>
                                    <Card sx={{ height: '100%', display: 'flex', flexDirection: 'column', boxShadow: 3 }}>
                                        <CardContent sx={{ flexGrow: 1 }}>
                                            <Chip 
                                                label={article.category?.name || 'General'} 
                                                size="small" 
                                                sx={{ mb: 1 }} 
                                                color="primary" 
                                                variant="outlined" 
                                            />
                                            <Typography variant="h6" component="div" gutterBottom>
                                                {article.title}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                By {article.user?.name || 'Anonymous'}
                                            </Typography>
                                        </CardContent>
                                        <CardActions sx={{ borderTop: '1px solid #eee' }}>
                                            <Button 
                                                component={Link} 
                                                href={route('articles.show', article.id)} 
                                                size="small" 
                                                variant="contained"
                                                fullWidth
                                            >
                                                Read Full Paper
                                            </Button>
                                        </CardActions>
                                    </Card>
                                </Grid>
                            ))
                        ) : (
                            <Box sx={{ p: 4, width: '100%', textAlign: 'center' }}>
                                <Typography color="textSecondary">No papers have been published yet. Check back later!</Typography>
                            </Box>
                        )}
                    </Grid>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}