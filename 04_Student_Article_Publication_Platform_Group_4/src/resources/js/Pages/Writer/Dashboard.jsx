import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router } from '@inertiajs/react';
import { Box, Button, Chip, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography } from '@mui/material';

export default function Dashboard({ auth, articles }) {
    
    // Function to handle the delete action
    const handleDelete = (id) => {
        if (confirm('Are you sure you want to delete this article?')) {
            // Using the 'writer.' prefix defined in web.php
            router.delete(route('writer.articles.destroy', id));
        }
    };

    // Function to handle the submit action
    const handleSubmit = (id) => {
        if (confirm('Submit this article for review? You won’t be able to edit it until the Editor responds.')) {
            // SUCCESS FIX: Ensure this points to 'writer.articles.submit'
            router.post(route('writer.articles.submit', id), {}, {
                onSuccess: () => {
                    // Page will automatically reload with fresh data from DashboardController
                },
                onError: (errors) => {
                    console.error("Submission failed:", errors);
                }
            });
        }
    };

    // Helper to determine Chip color based on Status ID
    const getStatusColor = (statusId) => {
        switch (statusId) {
            case 1: return "default"; // Draft
            case 2: return "warning"; // Submitted (Yellow/Orange)
            case 3: return "success"; // Published (Green)
            default: return "primary";
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Writer Dashboard</h2>}
        >
            <Head title="Dashboard" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <Box sx={{ p: 3, bgcolor: 'white', borderRadius: 2, boxShadow: 1 }}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                            <Typography variant="h5">My Articles</Typography>
                            <Button 
                                component={Link} 
                                href={route('writer.articles.create')} 
                                variant="contained"
                                sx={{ backgroundColor: '#4f46e5', '&:hover': { backgroundColor: '#4338ca' } }}
                            >
                                Create New Article
                            </Button>
                        </Box>

                        <TableContainer component={Paper}>
                            <Table>
                                <TableHead sx={{ bgcolor: '#f9fafb' }}>
                                    <TableRow>
                                        <TableCell sx={{ fontWeight: 'bold' }}>Title</TableCell>
                                        <TableCell sx={{ fontWeight: 'bold' }}>Category</TableCell>
                                        <TableCell sx={{ fontWeight: 'bold' }}>Status</TableCell>
                                        <TableCell align="right" sx={{ fontWeight: 'bold' }}>Actions</TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {articles.length > 0 ? (
                                        articles.map((article) => (
                                            <TableRow key={article.id} hover>
                                                <TableCell>{article.title}</TableCell>
                                                <TableCell>
                                                    {article.category ? article.category.name : 'Uncategorized'}
                                                </TableCell>
                                                <TableCell>
                                                    <Chip 
                                                        label={article.status ? article.status.name : 'N/A'} 
                                                        color={getStatusColor(article.status_id)}
                                                        size="small"
                                                        sx={{ fontWeight: 'medium' }}
                                                    />
                                                </TableCell>
                                                
                                                <TableCell align="right">
                                                    {/* Actions only available if the article is still a Draft (ID 1) */}
                                                    {article.status_id === 1 ? (
                                                        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1 }}>
                                                            <Button 
                                                                variant="contained" 
                                                                color="success" 
                                                                size="small"
                                                                onClick={() => handleSubmit(article.id)}
                                                                sx={{ textTransform: 'none' }}
                                                            >
                                                                Submit
                                                            </Button>

                                                            <Button 
                                                                component={Link} 
                                                                href={route('writer.articles.edit', article.id)}
                                                                variant="outlined"
                                                                size="small"
                                                                sx={{ textTransform: 'none' }}
                                                            >
                                                                Edit
                                                            </Button>

                                                            <Button 
                                                                color="error"
                                                                size="small"
                                                                onClick={() => handleDelete(article.id)}
                                                                sx={{ textTransform: 'none' }}
                                                            >
                                                                Delete
                                                            </Button>
                                                        </Box>
                                                    ) : (
                                                        <Typography variant="body2" color="textSecondary" sx={{ fontStyle: 'italic' }}>
                                                            {article.status_id === 2 ? 'Under Review' : 'Published'}
                                                        </Typography>
                                                    )}
                                                </TableCell>
                                            </TableRow>
                                        ))
                                    ) : (
                                        <TableRow>
                                            <TableCell colSpan={4} align="center" sx={{ py: 4 }}>
                                                <Typography color="textSecondary">No articles found. Start by creating one!</Typography>
                                            </TableCell>
                                        </TableRow>
                                    )}
                                </TableBody>
                            </Table>
                        </TableContainer>
                    </Box>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}