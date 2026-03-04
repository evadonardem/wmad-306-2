import React, { useState } from 'react';
import {
    Container, Typography, Paper, Card, CardContent, CardActions, Button,
    Box, Alert, Chip, TextField, Stack, Divider, Grid,
} from '@mui/material';
import { Head, useForm, usePage, Link } from '@inertiajs/react';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';

export default function StudentDashboard({ articles, myComments }) {
    const { flash } = usePage().props;

    return (
        <AuthenticatedLayout header={<Typography variant="h5">Student Dashboard</Typography>}>
            <Head title="Student Dashboard" />
            <Container maxWidth="lg" sx={{ py: 4 }}>
                {flash?.success && <Alert severity="success" sx={{ mb: 2 }}>{flash.success}</Alert>}

                <Typography variant="h6" gutterBottom>Published Articles</Typography>
                <Grid container spacing={3} sx={{ mb: 4 }}>
                    {articles?.data?.map((article) => (
                        <Grid item xs={12} md={6} key={article.id}>
                            <Card>
                                <CardContent>
                                    <Typography variant="h6">{article.title}</Typography>
                                    <Stack direction="row" spacing={1} sx={{ mt: 1, mb: 1 }}>
                                        <Chip label={article.category?.name || 'Uncategorized'} size="small" />
                                        <Typography variant="caption" color="text.secondary">
                                            By {article.writer?.name}
                                        </Typography>
                                    </Stack>
                                    <Typography variant="body2" color="text.secondary">
                                        {article.content?.replace(/<[^>]+>/g, '').substring(0, 150)}...
                                    </Typography>
                                </CardContent>
                                <CardActions>
                                    <Button
                                        size="small"
                                        component={Link}
                                        href={route('student.articles.show', article.id)}
                                    >
                                        Read More
                                    </Button>
                                    <Typography variant="caption" sx={{ ml: 'auto', mr: 1 }}>
                                        {article.comments?.length || 0} comments
                                    </Typography>
                                </CardActions>
                            </Card>
                        </Grid>
                    ))}
                    {(!articles?.data || articles.data.length === 0) && (
                        <Grid item xs={12}>
                            <Paper sx={{ p: 3, textAlign: 'center' }}>
                                <Typography color="text.secondary">No published articles yet.</Typography>
                            </Paper>
                        </Grid>
                    )}
                </Grid>

                <Divider sx={{ mb: 3 }} />

                <Typography variant="h6" gutterBottom>My Comments</Typography>
                {myComments && myComments.length > 0 ? (
                    myComments.map((c) => (
                        <Paper key={c.id} variant="outlined" sx={{ p: 2, mb: 1 }}>
                            <Typography variant="body2" color="text.secondary">
                                On: {c.article?.title} — {new Date(c.created_at).toLocaleDateString()}
                            </Typography>
                            <Typography variant="body1">{c.content}</Typography>
                        </Paper>
                    ))
                ) : (
                    <Typography color="text.secondary">You haven't posted any comments yet.</Typography>
                )}

                <Box sx={{ mt: 2 }}>
                    <Typography variant="caption" color="text.secondary">
                        Total comments: {myComments?.length || 0}
                    </Typography>
                </Box>
            </Container>
        </AuthenticatedLayout>
    );
}
