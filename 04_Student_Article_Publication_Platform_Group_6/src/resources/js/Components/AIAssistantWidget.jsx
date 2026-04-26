import SmartToyOutlinedIcon from '@mui/icons-material/SmartToyOutlined';
import CloseIcon from '@mui/icons-material/Close';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import { Box, Button, Fab, IconButton, Paper, Stack, Typography } from '@mui/material';
import { alpha, useTheme } from '@mui/material/styles';
import { useMemo, useState } from 'react';

const cannedReplies = {
    'How do I submit an article?': 'Go to Writer Dashboard, create or edit a draft, then click Submit.',
    'How does review work?': 'Editors can request revision with comments or publish submitted articles.',
    'Where can students comment?': 'Students can comment directly from Student Dashboard on published articles.',
};

export default function AIAssistantWidget() {
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';
    const [open, setOpen] = useState(false);
    const [activeQuestion, setActiveQuestion] = useState('How do I submit an article?');

    const questions = useMemo(() => Object.keys(cannedReplies), []);

    return (
        <Box sx={{ position: 'fixed', right: { xs: 12, sm: 18 }, bottom: { xs: 12, sm: 18 }, zIndex: 1300 }}>
            {open && (
                <Paper
                    elevation={6}
                    sx={{
                        width: { xs: 'min(92vw, 360px)', sm: 360 },
                        p: 2,
                        mb: 1.5,
                        borderRadius: '1.25rem',
                        border: '1px solid',
                        borderColor: isDark ? 'rgba(148, 163, 184, 0.38)' : 'rgba(148, 163, 184, 0.28)',
                        background: isDark
                            ? 'linear-gradient(155deg, rgba(15,23,42,0.96), rgba(30,41,59,0.88))'
                            : 'linear-gradient(155deg, rgba(255,255,255,0.98), rgba(248,250,252,0.94))',
                    }}
                >
                    <Stack spacing={1.5}>
                        <Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ gap: 1 }}>
                            <Stack direction="row" spacing={1} alignItems="center">
                                <AutoAwesomeIcon color="primary" fontSize="small" />
                                <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>
                                    Journal Assistant
                                </Typography>
                            </Stack>
                            <IconButton size="small" onClick={() => setOpen(false)}>
                                <CloseIcon fontSize="small" />
                            </IconButton>
                        </Stack>

                        <Typography variant="body2" color="text.secondary">
                            Quick hard-coded guide for common workflow questions.
                        </Typography>

                        <Stack spacing={0.8}>
                            {questions.map((question) => (
                                <Button
                                    key={question}
                                    onClick={() => setActiveQuestion(question)}
                                    variant={activeQuestion === question ? 'contained' : 'outlined'}
                                    sx={{
                                        justifyContent: 'flex-start',
                                        textAlign: 'left',
                                        textTransform: 'none',
                                        borderRadius: '0.85rem',
                                        px: 1.15,
                                        py: 0.95,
                                        fontSize: '0.84rem',
                                        fontWeight: activeQuestion === question ? 700 : 600,
                                        color: activeQuestion === question ? '#fff' : 'text.primary',
                                        borderColor: isDark ? 'rgba(148,163,184,0.42)' : 'rgba(148,163,184,0.35)',
                                        backgroundColor: activeQuestion === question ? '#2f6fdb' : 'transparent',
                                        '&:hover': {
                                            borderColor: '#2f6fdb',
                                            backgroundColor: activeQuestion === question ? '#2157b4' : alpha('#2f6fdb', 0.08),
                                        },
                                    }}
                                >
                                    {question}
                                </Button>
                            ))}
                        </Stack>

                        <Paper
                            variant="outlined"
                            sx={{
                                p: 1.25,
                                borderRadius: '0.95rem',
                                borderColor: isDark ? 'rgba(148,163,184,0.36)' : 'rgba(148,163,184,0.3)',
                                backgroundColor: isDark ? 'rgba(15,23,42,0.52)' : '#fff',
                            }}
                        >
                            <Typography variant="body2" sx={{ fontWeight: 700, mb: 0.5 }}>
                                Answer
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                                {cannedReplies[activeQuestion]}
                            </Typography>
                        </Paper>
                    </Stack>
                </Paper>
            )}

            <Fab
                color="primary"
                onClick={() => setOpen((value) => !value)}
                aria-label="AI assistant"
                sx={{ boxShadow: '0 10px 24px rgba(47,111,219,0.35)' }}
            >
                <SmartToyOutlinedIcon />
            </Fab>
        </Box>
    );
}
