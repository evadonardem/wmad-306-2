import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router } from '@inertiajs/react';
import { Box, Button, Chip, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography } from '@mui/material';

export default function EditorDashboard({ auth, pendingArticles, publishedArticles }) {
    
    // Function to Approve/Publish (Status 3)
    const handleApprove = (id) => {
        if (confirm('Approve and Publish this article?')) {
            router.post(route('editor.articles.approve', id));
        }
    };

    // Function to Reject (Status 1)
    const handleReject = (id) => {
        if (confirm('Reject this article? It will return to the Writer as a Draft.')) {
            router.post(route('editor.articles.reject', id));
        }
    };

    // Function to navigate to the Edit page
    const handleEdit = (id) => {
        router.get(route('editor.articles.edit', id));
    };

    // NEW: Function to permanently delete a published paper
    const handleRemove = (id) => {
        if (confirm('Are you sure you want to PERMANENTLY remove this published article? This action cannot be undone.')) {
            router.delete(route('editor.articles.destroy', id));
        }
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Editor Management Console</h2>}
        >
            <Head title="Editor Dashboard" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    
                    {/* SECTION 1: Review Queue (Pending Articles) */}
                    <Box sx={{ p: 3, bgcolor: 'white', borderRadius: 2, boxShadow: 1, mb: 5 }}>
                        <Typography variant="h5" sx={{ mb: 3, fontWeight: 'bold', color: '#1976d2' }}>
                            Articles Pending Review
                        </Typography>

                        <TableContainer component={Paper}>
                            <Table>
                                <TableHead sx={{ bgcolor: '#f5f5f5' }}>
                                    <TableRow>
                                        <TableCell><strong>Title</strong></TableCell>
                                        <TableCell><strong>Writer</strong></TableCell>
                                        <TableCell><strong>Category</strong></TableCell>
                                        <TableCell align="right"><strong>Review Actions</strong></TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {pendingArticles.length > 0 ? (
                                        pendingArticles.map((article) => (
                                            <TableRow key={article.id}>
                                                <TableCell>{article.title}</TableCell>
                                                <TableCell>{article.user ? article.user.name : 'Unknown'}</TableCell>
                                                <TableCell>
                                                    <Chip label={article.category ? article.category.name : 'N/A'} variant="outlined" size="small" />
                                                </TableCell>
                                                <TableCell align="right">
                                                    <Button 
                                                        variant="contained" 
                                                        color="success" 
                                                        onClick={() => handleApprove(article.id)}
                                                        sx={{ mr: 1, textTransform: 'none' }}
                                                    >
                                                        Approve
                                                    </Button>
                                                    <Button 
                                                        variant="outlined" 
                                                        color="error" 
                                                        onClick={() => handleReject(article.id)}
                                                        sx={{ textTransform: 'none' }}
                                                    >
                                                        Reject
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))
                                    ) : (
                                        <TableRow>
                                            <TableCell colSpan={4} align="center" sx={{ py: 3 }}>
                                                <Typography color="textSecondary">No articles are currently pending review.</Typography>
                                            </TableCell>
                                        </TableRow>
                                    )}
                                </TableBody>
                            </Table>
                        </TableContainer>
                    </Box>

                    {/* SECTION 2: Published Papers Management */}
                    <Box sx={{ p: 3, bgcolor: 'white', borderRadius: 2, boxShadow: 1 }}>
                        <Typography variant="h5" sx={{ mb: 3, fontWeight: 'bold', color: '#2e7d32' }}>
                            Manage Published Papers
                        </Typography>

                        <TableContainer component={Paper}>
                            <Table>
                                <TableHead sx={{ bgcolor: '#f5f5f5' }}>
                                    <TableRow>
                                        <TableCell><strong>Title</strong></TableCell>
                                        <TableCell><strong>Original Writer</strong></TableCell>
                                        <TableCell><strong>Category</strong></TableCell>
                                        <TableCell align="right"><strong>Management</strong></TableCell>
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {publishedArticles.length > 0 ? (
                                        publishedArticles.map((article) => (
                                            <TableRow key={article.id}>
                                                <TableCell>{article.title}</TableCell>
                                                <TableCell>{article.user?.name || 'Unknown'}</TableCell>
                                                <TableCell>
                                                    <Chip label={article.category?.name || 'N/A'} size="small" color="primary" variant="outlined" />
                                                </TableCell>
                                                <TableCell align="right">
                                                    <Button 
                                                        variant="contained" 
                                                        color="info" 
                                                        onClick={() => handleEdit(article.id)}
                                                        sx={{ textTransform: 'none', mr: 1 }}
                                                    >
                                                        Edit Content
                                                    </Button>
                                                    {/* NEW: Remove Button added here */}
                                                    <Button 
                                                        variant="outlined" 
                                                        color="error" 
                                                        onClick={() => handleRemove(article.id)}
                                                        sx={{ textTransform: 'none' }}
                                                    >
                                                        Remove
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))
                                    ) : (
                                        <TableRow>
                                            <TableCell colSpan={4} align="center" sx={{ py: 3 }}>
                                                <Typography color="textSecondary">No published papers found.</Typography>
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