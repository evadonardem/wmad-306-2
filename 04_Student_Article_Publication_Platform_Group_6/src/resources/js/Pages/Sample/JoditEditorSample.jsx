import React, { useState, useRef, useMemo, useCallback } from 'react';
import JoditEditor from 'jodit-react';
import { Button, Card, CardContent, Container, Divider, Stack, TextField, Typography } from '@mui/material';
import { Head } from '@inertiajs/react';

export default function JoditEditorSample() {
    const editor = useRef(null);
    const [content, setContent] = useState('');

    const config = useMemo(
        () => ({
            readonly: false,
            minHeight: 280,
            placeholder: 'Write your article content here...',
        }),
        []
    );

    const handleBlur = useCallback((newContent) => {
        setContent(newContent);
    }, []);

    const handleChange = useCallback(() => {
        // No-op sample handler.
    }, []);

    return (
        <Container maxWidth="md" sx={{ py: 4 }}>
            <Head title="Jodit Editor Sample" />
            <Card>
                <CardContent>
                    <Typography variant="h4" gutterBottom>
                        Jodit Editor Sample
                    </Typography>
                    <Typography color="text.secondary">
                        This sample demonstrates the rich text editor used in writer article forms.
                    </Typography>
                    <Divider sx={{ my: 2 }} />
                    <Stack spacing={2}>
                        <TextField label="Article Title" />
                        <JoditEditor
                            ref={editor}
                            value={content}
                            config={config}
                            onBlur={handleBlur}
                            onChange={handleChange}
                        />
                        <Button variant="contained" sx={{ alignSelf: 'flex-start' }}>
                            Save Draft
                        </Button>
                    </Stack>
                </CardContent>
            </Card>
        </Container>
    );
}
