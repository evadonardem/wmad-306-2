import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm } from '@inertiajs/react';
import { Box, Button, MenuItem, Paper, TextField, Typography } from '@mui/material';

export default function Edit({ auth, article, categories }) {
    // PRE-FILLING: The form starts with the current database values
    const { data, setData, patch, processing, errors } = useForm({
        title: article.title || '',
        category_id: article.category_id || '',
        content: article.content || '',
    });

    const submit = (e) => {
        e.preventDefault();
        // Uses 'patch' to update the existing record
        patch(route('writer.articles.update', article.id));
    };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={<h2 className="font-semibold text-xl text-gray-800 leading-tight">Edit Article</h2>}
        >
            <Head title="Edit Article" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <Paper sx={{ p: 4, borderRadius: 2 }}>
                        <Typography variant="h5" mb={3}>Update Your Draft</Typography>
                        
                        <form onSubmit={submit}>
                            {/* Title Input */}
                            <TextField
                                fullWidth
                                label="Article Title"
                                value={data.title}
                                onChange={e => setData('title', e.target.value)}
                                error={!!errors.title}
                                helperText={errors.title}
                                sx={{ mb: 3 }}
                            />

                            {/* Category Dropdown */}
                            <TextField
                                select
                                fullWidth
                                label="Category"
                                value={data.category_id}
                                onChange={e => setData('category_id', e.target.value)}
                                error={!!errors.category_id}
                                helperText={errors.category_id}
                                sx={{ mb: 3 }}
                            >
                                {categories.map((cat) => (
                                    <MenuItem key={cat.id} value={cat.id}>
                                        {cat.name}
                                    </MenuItem>
                                ))}
                            </TextField>

                            {/* Content Area */}
                            <TextField
                                fullWidth
                                multiline
                                rows={10}
                                label="Content"
                                value={data.content}
                                onChange={e => setData('content', e.target.value)}
                                error={!!errors.content}
                                helperText={errors.content}
                                sx={{ mb: 3 }}
                            />

                            <Box sx={{ display: 'flex', gap: 2 }}>
                                <Button 
                                    type="submit" 
                                    variant="contained" 
                                    disabled={processing}
                                >
                                    Save Changes
                                </Button>
                                <Button 
                                    component="a" 
                                    href={route('dashboard')} 
                                    variant="outlined"
                                >
                                    Cancel
                                </Button>
                            </Box>
                        </form>
                    </Paper>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}