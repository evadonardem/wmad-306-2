import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, useForm } from '@inertiajs/react';
import { Button, MenuItem, Paper, TextField, Typography } from '@mui/material';
import JoditEditor from 'jodit-react';
import { useRef } from 'react';

export default function Create({ auth, categories = [] }) { // Default to empty array
    const editor = useRef(null);
    const { data, setData, post, processing, errors } = useForm({
        title: '', 
        category_id: '',
        content: '', 
    });

    const submit = (e) => {
        e.preventDefault();
        post(route('writer.articles.store'));
    };

    return (
        <AuthenticatedLayout user={auth.user}>
            <Head title="Create Article" />
            <div className="py-12">
                <div className="max-w-4xl mx-auto sm:px-6 lg:px-8">
                    <Paper className="p-6">
                        <Typography variant="h5" gutterBottom>Create New Draft</Typography>
                        
                        <form onSubmit={submit}>
                            {/* Title Field */}
                            <TextField
                                fullWidth
                                label="Article Title"
                                value={data.title}
                                onChange={e => setData('title', e.target.value)}
                                margin="normal"
                                error={!!errors.title}
                                helperText={errors.title}
                            />

                            {/* Category Dropdown with Safety Check */}
                            <TextField
                                select
                                fullWidth
                                label="Category"
                                value={data.category_id}
                                onChange={e => setData('category_id', e.target.value)}
                                margin="normal"
                                error={!!errors.category_id}
                                helperText={errors.category_id || (categories.length === 0 ? "No categories found in database" : "")}
                            >
                                {categories.length > 0 ? (
                                    categories.map((cat) => (
                                        <MenuItem key={cat.id} value={cat.id}>
                                            {cat.name}
                                        </MenuItem>
                                    ))
                                ) : (
                                    <MenuItem disabled value="">
                                        <em>No Categories Available</em>
                                    </MenuItem>
                                )}
                            </TextField>

                            {/* Jodit Editor Section */}
                            <div className="mt-4 mb-8">
                                <Typography variant="subtitle1" gutterBottom 
                                    color={errors.content ? 'error' : 'initial'}>
                                    Content
                                </Typography>
                                <JoditEditor
                                    ref={editor}
                                    value={data.content}
                                    onBlur={newContent => setData('content', newContent)} 
                                />
                                {errors.content && (
                                    <Typography variant="caption" color="error">
                                        {errors.content}
                                    </Typography>
                                )}
                            </div>

                            <Button type="submit" variant="contained" disabled={processing || categories.length === 0}>
                                Save as Draft
                            </Button>
                        </form>
                    </Paper>
                </div>
            </div>
        </AuthenticatedLayout>
    );
}