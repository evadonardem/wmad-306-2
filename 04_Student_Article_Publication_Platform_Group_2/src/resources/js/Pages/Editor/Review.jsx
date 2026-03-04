import React from 'react';
import {
    Container, Typography, Paper, Chip, Box, Alert, Divider, Stack,
} from '@mui/material';
import { Head, usePage } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';

export default function EditorReview({ article }) {
    const { flash } = usePage().props;

    return (
        <AuthenticatedLayout header={<Typography variant="h5">Review Article</Typography>}>
            <Head title={`Review: ${article.title}`} />
            <Container maxWidth="md" sx={{ py: 4 }}>
                {flash?.success && <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>}

                <Paper sx={{ p: 3 }}>
                    <Typography variant="h4" gutterBottom>{article.title}</Typography>
                    <Stack direction="row" spacing={2} sx={{ mb: 2 }}>
                        <Chip label={article.status?.label} size="small" />
                        <Typography variant="body2" color="text.secondary">
                            By {article.writer?.name} | Category: {article.category?.name || '—'}
                        </Typography>
                    </Stack>
                    <Divider sx={{ mb: 2 }} />
                    <Box dangerouslySetInnerHTML={{ __html: article.content }} sx={{ mb: 3 }} />

                    {article.revisions && article.revisions.length > 0 && (
                        <>
                            <Divider sx={{ mb: 2 }} />
                            <Typography variant="h6" gutterBottom>Revision History</Typography>
                            {article.revisions.map((rev) => (
                                <Paper key={rev.id} variant="outlined" sx={{ p: 2, mb: 1 }}>
                                    <Typography variant="body2" color="text.secondary">
                                        {rev.editor?.name} — {new Date(rev.created_at).toLocaleString()}
                                    </Typography>
                                    <Typography variant="body1">{rev.comments}</Typography>
                                </Paper>
                            ))}
                        </>
                    )}
                </Paper>
            </Container>
        </AuthenticatedLayout>
    );
}
