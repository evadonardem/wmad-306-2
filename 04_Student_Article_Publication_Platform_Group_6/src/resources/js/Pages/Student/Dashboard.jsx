import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link, router, usePage, useForm } from '@inertiajs/react';
import { 
    Alert, Box, Button, MenuItem, Stack, TextField, Typography, 
    Dialog, DialogTitle, DialogContent, DialogActions, Radio, RadioGroup, FormControlLabel, FormControl, LinearProgress
} from '@mui/material';
import { useTheme } from '@mui/material/styles';
import { useMemo, useState } from 'react';

const fallbackImage = 'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=1400&q=80';
const stripHtml = (value) => value?.replace(/<[^>]*>?/gm, '') ?? '';

// --- QUIZ DATA BANKS ---
const allWriterQuestions = [
    { q: "What is the primary goal of a headline?", options: ["To summarize the entire article", "To grab attention and indicate the topic", "To state the author's opinion", "To deceive the reader for clicks"], a: 1 },
    { q: "Which of the following is considered plagiarism?", options: ["Quoting a source with proper citation", "Using common knowledge", "Copying a paragraph without credit", "Interviewing an expert"], a: 2 },
    { q: "What does 'off the record' mean?", options: ["Information can be published anonymously", "Information cannot be published at all", "The interview is not being recorded", "The information is only for editors"], a: 1 },
    { q: "Which part of an article should contain the most important facts?", options: ["The conclusion", "The lead (first paragraph)", "The middle section", "The headline"], a: 1 },
    { q: "How should a journalist handle a conflict of interest?", options: ["Ignore it", "Disclose it to the editor and readers", "Write the story anyway in secret", "Only tell their friends"], a: 1 },
    { q: "What is a 'byline'?", options: ["A line of code", "The author's name printed with the story", "A secondary headline", "A photo caption"], a: 1 },
    { q: "When covering a controversy, a writer should:", options: ["Only interview the side they agree with", "Present multiple perspectives fairly", "Avoid the topic entirely", "Publish rumors as facts"], a: 1 },
    { q: "Which is the best way to verify a fact?", options: ["Check Wikipedia", "Ask a friend", "Consult primary sources or official documents", "Guess based on context"], a: 2 },
    { q: "What is the 'inverted pyramid' structure?", options: ["Most important info first, least important last", "A visual graph in the article", "Ending with a cliffhanger", "Starting with a joke"], a: 0 },
    { q: "If you make a factual error in a published article, you should:", options: ["Delete the article", "Deny it", "Issue a prompt correction", "Blame the editor"], a: 2 },
    { q: "What is 'libel'?", options: ["A type of formatting", "A published false statement that damages a reputation", "A valid critique", "A direct quote"], a: 1 },
    { q: "Why is an active voice preferred in journalism?", options: ["It is longer", "It sounds more confusing", "It is more direct and engaging", "It hides the subject"], a: 2 },
    { q: "When writing a quote, punctuation (like a comma) usually goes:", options: ["Outside the quotation marks", "Inside the quotation marks", "Nowhere", "Before the quote starts"], a: 1 },
    { q: "What is a 'nut graph'?", options: ["A paragraph explaining the core value/context of the story", "A graph about agriculture", "A crazy statistic", "The author's bio"], a: 0 },
    { q: "An anonymous source should be used:", options: ["Whenever possible", "Only when absolutely necessary and verified", "To spread rumors safely", "To save time during interviews"], a: 1 }
];

const allEditorQuestions = [
    { q: "What is an editor's primary responsibility?", options: ["To rewrite the whole article", "To ensure clarity, accuracy, and fairness", "To change the writer's opinion", "To add more big words"], a: 1 },
    { q: "If an article lacks a reliable source for a major claim, an editor should:", options: ["Publish it anyway", "Delete the paragraph silently", "Send it back to the writer for a source", "Make up a source"], a: 2 },
    { q: "What does 'AP Style' refer to?", options: ["A clothing brand", "A standardized set of grammar and formatting rules", "A type of photography", "A coding language"], a: 1 },
    { q: "When giving feedback to a writer, an editor should be:", options: ["Vague and brief", "Constructive, specific, and respectful", "Harsh and demanding", "Passive-aggressive"], a: 1 },
    { q: "What is a 'lede'?", options: ["The main editor", "A heavy metal", "The introductory section of a news story", "A type of font"], a: 2 },
    { q: "Fact-checking is primarily the responsibility of:", options: ["The reader", "The writer and the editor", "The publisher only", "No one"], a: 1 },
    { q: "If a writer's tone is inappropriate for the topic, the editor should:", options: ["Leave it alone", "Reject the article entirely", "Suggest tone adjustments to align with publication standards", "Change it without telling the writer"], a: 2 },
    { q: "What is a 'pull quote'?", options: ["A quote taken out of context", "A key phrase highlighted visually to draw readers in", "A quote the editor dislikes", "A retracted statement"], a: 1 },
    { q: "When checking a headline, the editor must ensure:", options: ["It uses clickbait", "It is extremely long", "It accurately reflects the story without misleading", "It contains no verbs"], a: 2 },
    { q: "An article covering an ongoing emergency is breaking news. The editor should prioritize:", options: ["Perfection over speed", "Speed over accuracy", "Accuracy and rapid updates", "Waiting until tomorrow"], a: 2 },
    { q: "If two writers submit similar story pitches, the editor should:", options: ["Publish both identical stories", "Have them collaborate or assign distinct angles", "Flip a coin", "Reject both"], a: 1 },
    { q: "A writer submits a piece highly critical of the university. The editor should:", options: ["Censor it immediately", "Ensure claims are factual and give the university a chance to respond", "Publish it without reviewing", "Fire the writer"], a: 1 },
    { q: "What is the purpose of a style guide?", options: ["To maintain consistency across all publications", "To make articles look pretty", "To tell writers what opinions to have", "To list CSS classes"], a: 0 },
    { q: "If an editor discovers plagiarism in a draft, they should:", options: ["Fix it and say nothing", "Reject the piece and address the ethical breach with the writer", "Publish it anyway", "Change the author's name"], a: 1 },
    { q: "The 'editorial voice' of a publication represents:", options: ["The personal voice of the current editor", "The established tone, values, and style of the platform", "A random selection of styles", "The loudest writer's opinion"], a: 1 }
];

// Shuffle helper
const getRandomQuestions = (bank, count = 10) => {
    return [...bank].sort(() => 0.5 - Math.random()).slice(0, count);
};

// Jeton-style CSS Animations
const jetonAnimations = `
    @keyframes reveal-up {
        0% { transform: translateY(80px); opacity: 0; filter: blur(8px); }
        100% { transform: translateY(0); opacity: 1; filter: blur(0); }
    }
    @keyframes float-blob {
        0% { transform: translate(0px, 0px) scale(1); }
        33% { transform: translate(30px, -50px) scale(1.1); }
        66% { transform: translate(-20px, 20px) scale(0.9); }
        100% { transform: translate(0px, 0px) scale(1); }
    }
    .student-animate-reveal-0 { animation: reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
    .student-animate-reveal-1 { animation: reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
    .student-animate-reveal-2 { animation: reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
    .student-animate-reveal-3 { animation: reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both; }
    .student-animate-reveal-4 { animation: reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.5s both; }
    .student-animate-reveal-5 { animation: reveal-up 1.2s cubic-bezier(0.16, 1, 0.3, 1) 0.6s both; }
    .student-animate-blob { animation: float-blob 8s infinite ease-in-out; }
    .student-animation-delay-2000 { animation-delay: 2s; }
    .student-animation-delay-4000 { animation-delay: 4s; }
    .student-bento-card:hover .student-bento-img { transform: scale(1.08); }
`;

export default function StudentDashboard({ publishedArticles, featuredArticle, latestPublications, myComments, flash, categories, filters }) {
    const { url } = usePage();
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';
    
    // Role Application State
    const roleForm = useForm({ request_type: 'add', role_name: '', justification: '' });
    const [isRoleModalOpen, setIsRoleModalOpen] = useState(false);
    const [quizStep, setQuizStep] = useState(0); // 0: Select Role, 1: Quiz, 2: Result/Apply
    const [currentQuestions, setCurrentQuestions] = useState([]);
    const [userAnswers, setUserAnswers] = useState({});
    const [quizScore, setQuizScore] = useState(0);

    const [searchFilters, setSearchFilters] = useState(() => ({
        search: filters?.search ?? '',
        category_id: filters?.category_id ?? '',
        date_from: filters?.date_from ?? '',
        date_to: filters?.date_to ?? '',
        sort: filters?.sort ?? 'newest',
    }));

    const applyFilters = (nextFilters) => {
        router.get(url, nextFilters, { preserveState: true, replace: true });
    };

    const handleFilterChange = (field, value) => {
        setSearchFilters((previous) => ({ ...previous, [field]: value }));
    };

    const articlePool = useMemo(() => {
        return latestPublications?.length > 0 ? latestPublications : (publishedArticles ?? []);
    }, [latestPublications, publishedArticles]);

    const heroArticle = featuredArticle ?? articlePool[0] ?? null;
    const heroImage = heroArticle?.cover_image_url || fallbackImage;

    // Quiz Handlers
    const startQuiz = (role) => {
        roleForm.setData('role_name', role);
        setCurrentQuestions(getRandomQuestions(role === 'writer' ? allWriterQuestions : allEditorQuestions, 10));
        setUserAnswers({});
        setQuizScore(0);
        setQuizStep(1);
    };

    const submitQuiz = () => {
        let score = 0;
        currentQuestions.forEach((q, index) => {
            if (userAnswers[index] === q.a) score++;
        });
        setQuizScore(score);
        setQuizStep(2);
    };

    const handleRoleRequest = (event) => {
        event.preventDefault();
        // Append score to justification so admins see it
        const finalData = {
            ...roleForm.data,
            justification: `[Quiz Score: ${quizScore}/10] ${roleForm.data.justification}`
        };
        
        router.post(route('role-requests.store'), finalData, {
            onSuccess: () => {
                setIsRoleModalOpen(false);
                setQuizStep(0);
                roleForm.reset('justification', 'role_name');
                roleForm.setData('request_type', 'add');
            }
        });
    };

    return (
        <AuthenticatedLayout
            header={
                <Stack spacing={0.25} className="student-animate-reveal-0">
                    <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.02em' }}>
                        Student Dashboard
                    </Typography>
                    <Typography color="text.secondary" sx={{ fontSize: '1rem', fontWeight: 500 }}>
                        Read published journals and leave feedback.
                    </Typography>
                </Stack>
            }
            fullWidth
        >
            <Head title="Student Dashboard" />
            <style>{jetonAnimations}</style>

            <Stack spacing={2.5} component="div">
                {flash?.success && <Alert severity="success" className="student-animate-reveal-0">{flash.success}</Alert>}
                {flash?.error && <Alert severity="error" className="student-animate-reveal-0">{flash.error}</Alert>}

                {/* Filters – bento-style card */}
                <Box
                    className="student-animate-reveal-1"
                    sx={{
                        p: { xs: 2, md: 2.5 },
                        borderRadius: '2rem',
                        bgcolor: isDark ? 'rgba(17, 24, 39, 0.6)' : 'rgba(244, 247, 251, 0.9)',
                        border: '1px solid',
                        borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.8)',
                        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)',
                    }}
                >
                    <Stack spacing={2} direction={{ xs: 'column', md: 'row' }} alignItems={{ xs: 'stretch', md: 'flex-end' }} useFlexGap flexWrap="wrap">
                        <Box sx={{ flex: 2, minWidth: 220 }}>
                            <TextField label="Search journals" value={searchFilters.search} onChange={(e) => handleFilterChange('search', e.target.value)} fullWidth size="small" sx={{ '& .MuiOutlinedInput-root': { borderRadius: '1rem' } }} />
                        </Box>
                        <Box sx={{ flex: 1, minWidth: 180 }}>
                            <TextField select label="Subject / category" value={searchFilters.category_id} onChange={(e) => handleFilterChange('category_id', e.target.value)} fullWidth size="small" sx={{ '& .MuiOutlinedInput-root': { borderRadius: '1rem' } }}>
                                <MenuItem value="">All subjects</MenuItem>
                                {categories?.map((c) => <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>)}
                            </TextField>
                        </Box>
                        <Box sx={{ display: 'flex', gap: 1 }}>
                            <Button variant="outlined" size="small" onClick={() => { const reset = { search: '', category_id: '', date_from: '', date_to: '', sort: 'newest' }; setSearchFilters(reset); applyFilters(reset); }} sx={{ borderRadius: '1rem', fontWeight: 700, textTransform: 'none' }}>Clear</Button>
                            <Button variant="contained" size="small" onClick={() => applyFilters(searchFilters)} sx={{ borderRadius: '1rem', fontWeight: 700, textTransform: 'none', bgcolor: '#2f6fdb', '&:hover': { bgcolor: '#2157b4' } }}>Apply filters</Button>
                        </Box>
                    </Stack>
                </Box>

                <Box sx={{ display: 'flex', flexDirection: { xs: 'column', md: 'row' }, gap: 2.5 }}>
                    {/* Hero section with floating blobs */}
                    <Box
                        className="student-animate-reveal-2"
                        sx={{
                            position: 'relative',
                            overflow: 'hidden',
                            borderRadius: '2rem',
                            flex: 2,
                            minHeight: { xs: 220, md: 280 },
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'flex-start',
                        }}
                    >
                        <Box sx={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
                            <Box className="student-animate-blob" sx={{ position: 'absolute', top: 80, left: -40, width: 288, height: 288, borderRadius: '50%', bgcolor: '#2f6fdb', mixBlendMode: 'multiply', opacity: 0.3 }} />
                            <Box className="student-animate-blob student-animation-delay-2000" sx={{ position: 'absolute', top: 80, right: -40, width: 288, height: 288, borderRadius: '50%', bgcolor: '#7ea5ea', mixBlendMode: 'multiply', opacity: 0.3 }} />
                        </Box>

                        <Box sx={{ position: 'relative', zIndex: 1, minHeight: { xs: 220, md: 280 }, width: '100%', backgroundImage: `linear-gradient(115deg, rgba(8, 16, 35, 0.82), rgba(47, 111, 219, 0.35)), url(${heroImage})`, backgroundSize: 'cover', backgroundPosition: 'center', display: 'flex', alignItems: 'center', justifyContent: 'flex-start', borderRadius: '2rem' }}>
                            <Box sx={{ p: { xs: 2.25, md: 3.25 }, color: '#fff', maxWidth: 720, backdropFilter: 'blur(4px)' }}>
                                <Typography variant="overline" sx={{ opacity: 0.95, letterSpacing: 2, fontWeight: 800 }}>Featured journal</Typography>
                                <Typography variant="h4" sx={{ color: '#fff', fontWeight: 800, textShadow: '0 10px 30px rgba(0,0,0,0.45)', letterSpacing: '-0.02em', mt: 0.5 }}>{heroArticle?.title ?? 'Latest Published Articles'}</Typography>
                                <Typography sx={{ mt: 0.75, color: 'rgba(255,255,255,0.92)', fontSize: 15 }}>{stripHtml(heroArticle?.content).slice(0, 170) || 'Explore the latest campus publications.'}</Typography>
                                {heroArticle && (
                                    <Link href={route('publications.show', heroArticle.id)} className="inline-flex items-center gap-2 mt-4 px-6 py-2.5 rounded-full text-sm font-bold text-white no-underline" style={{ backgroundColor: '#2f6fdb' }}>
                                        Read featured journal <span aria-hidden="true">&rarr;</span>
                                    </Link>
                                )}
                            </Box>
                        </Box>
                    </Box>

                    {/* NEW: Join the Staff Card */}
                    <Box
                        className="student-animate-reveal-3"
                        sx={{
                            flex: 1,
                            p: 3,
                            borderRadius: '2rem',
                            bgcolor: isDark ? 'rgba(47, 111, 219, 0.1)' : 'rgba(47, 111, 219, 0.05)',
                            border: '1px solid',
                            borderColor: 'rgba(47, 111, 219, 0.2)',
                            display: 'flex',
                            flexDirection: 'column',
                            justifyContent: 'center',
                            textAlign: 'center'
                        }}
                    >
                        <Typography variant="h5" sx={{ fontWeight: 800, color: '#2f6fdb', mb: 1 }}>Join the Staff</Typography>
                        <Typography variant="body2" sx={{ color: 'text.secondary', mb: 3 }}>
                            Pass the qualification quiz to request a role as a Campus Press Writer or Editor.
                        </Typography>
                        <Button 
                            variant="contained" 
                            fullWidth 
                            onClick={() => { setQuizStep(0); setIsRoleModalOpen(true); }}
                            sx={{ bgcolor: '#2f6fdb', borderRadius: '1rem', py: 1.5, fontWeight: 'bold', textTransform: 'none', '&:hover': { bgcolor: '#2157b4' } }}
                        >
                            Apply Now
                        </Button>
                    </Box>
                </Box>

                {/* Latest publications – bento cards */}
                <Box className="student-animate-reveal-4" sx={{ p: { xs: 2, md: 3 }, borderRadius: '2rem', bgcolor: isDark ? 'rgba(17, 24, 39, 0.6)' : 'rgba(244, 247, 251, 0.9)', border: '1px solid', borderColor: isDark ? 'rgba(75, 85, 99, 0.5)' : 'rgba(226, 232, 240, 0.8)' }}>
                    <Typography variant="h6" sx={{ fontWeight: 800, mb: 2 }}>Latest publications</Typography>
                    {articlePool.length === 0 ? (
                        <Typography color="text.secondary">No publications are available yet.</Typography>
                    ) : (
                        <Box sx={{ display: 'grid', gap: 2, gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, minmax(0, 1fr))', xl: 'repeat(3, minmax(0, 1fr))' } }}>
                            {articlePool.slice(0, 6).map((article, i) => (
                                <Box key={article.id} className="student-bento-card" sx={{ display: 'flex', flexDirection: 'column', borderRadius: '2rem', bgcolor: isDark ? 'rgba(30, 41, 59, 0.8)' : '#fff', border: '1px solid', borderColor: isDark ? 'rgba(75, 85, 99, 0.6)' : 'rgba(226, 232, 240, 0.9)', overflow: 'hidden', transition: 'all 0.3s', '&:hover': { transform: 'translateY(-8px)', borderColor: 'rgba(47, 111, 219, 0.25)' } }}>
                                    <Box sx={{ position: 'relative', pt: '62%', overflow: 'hidden' }}>
                                        <Box component="img" className="student-bento-img" src={article.cover_image_url || fallbackImage} sx={{ position: 'absolute', inset: 0, width: '100%', height: '100%', objectFit: 'cover', transition: 'transform 0.5s' }} />
                                    </Box>
                                    <Box sx={{ p: 2.25, flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
                                        <Typography variant="subtitle1" sx={{ fontWeight: 700, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>{article.title}</Typography>
                                        <Typography variant="caption" color="text.secondary" sx={{ mt: 0.5, fontWeight: 600 }}>By {article.writer?.name ?? 'Anonymous'}</Typography>
                                        <Typography color="text.secondary" sx={{ mt: 0.8, fontSize: 13, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>{stripHtml(article.content).slice(0, 220)}</Typography>
                                        <Link href={route('publications.show', article.id)} className="mt-4 flex w-full justify-center rounded-xl py-3 text-sm font-bold no-underline" style={{ border: '1px solid rgba(47,111,219,0.3)', color: '#2f6fdb' }}>Read article</Link>
                                    </Box>
                                </Box>
                            ))}
                        </Box>
                    )}
                </Box>
            </Stack>

            {/* ROLE APPLICATION & QUIZ MODAL */}
            <Dialog 
                open={isRoleModalOpen} 
                onClose={() => setIsRoleModalOpen(false)}
                fullWidth maxWidth="sm"
                PaperProps={{ sx: { borderRadius: '1.5rem', p: 1 } }}
            >
                {/* STEP 0: Select Role */}
                {quizStep === 0 && (
                    <>
                        <DialogTitle sx={{ fontWeight: 800, textAlign: 'center' }}>Join Campus Press</DialogTitle>
                        <DialogContent>
                            <Typography textAlign="center" color="text.secondary" sx={{ mb: 4 }}>
                                Choose a role to apply for. You must pass a short 10-question qualification quiz before submitting your request.
                            </Typography>
                            <Stack spacing={2}>
                                <Button variant="outlined" onClick={() => startQuiz('writer')} sx={{ py: 2, borderRadius: '1rem', fontWeight: 'bold', fontSize: '1.1rem', borderColor: '#2f6fdb', color: '#2f6fdb' }}>Apply as Writer</Button>
                                <Button variant="outlined" onClick={() => startQuiz('editor')} sx={{ py: 2, borderRadius: '1rem', fontWeight: 'bold', fontSize: '1.1rem', borderColor: '#10b981', color: '#10b981' }}>Apply as Editor</Button>
                            </Stack>
                        </DialogContent>
                        <DialogActions><Button onClick={() => setIsRoleModalOpen(false)}>Cancel</Button></DialogActions>
                    </>
                )}

                {/* STEP 1: The Quiz */}
                {quizStep === 1 && (
                    <>
                        <DialogTitle sx={{ fontWeight: 800 }}>
                            {roleForm.data.role_name === 'writer' ? 'Writer' : 'Editor'} Qualification Quiz
                        </DialogTitle>
                        <DialogContent dividers sx={{ maxHeight: '60vh' }}>
                            <Box sx={{ mb: 3 }}>
                                <Typography variant="caption" sx={{ fontWeight: 'bold' }}>Progress: {Object.keys(userAnswers).length} / 10</Typography>
                                <LinearProgress variant="determinate" value={(Object.keys(userAnswers).length / 10) * 100} sx={{ height: 8, borderRadius: 4, mt: 1 }} />
                            </Box>
                            
                            <Stack spacing={4}>
                                {currentQuestions.map((q, qIndex) => (
                                    <Box key={qIndex}>
                                        <Typography sx={{ fontWeight: 700, mb: 1 }}>{qIndex + 1}. {q.q}</Typography>
                                        <FormControl component="fieldset">
                                            <RadioGroup 
                                                value={userAnswers[qIndex] !== undefined ? userAnswers[qIndex] : ''}
                                                onChange={(e) => setUserAnswers({ ...userAnswers, [qIndex]: parseInt(e.target.value) })}
                                            >
                                                {q.options.map((opt, oIndex) => (
                                                    <FormControlLabel key={oIndex} value={oIndex} control={<Radio />} label={opt} />
                                                ))}
                                            </RadioGroup>
                                        </FormControl>
                                    </Box>
                                ))}
                            </Stack>
                        </DialogContent>
                        <DialogActions sx={{ p: 2 }}>
                            <Button onClick={() => setIsRoleModalOpen(false)} sx={{ color: 'text.secondary' }}>Cancel</Button>
                            <Button 
                                variant="contained" 
                                disabled={Object.keys(userAnswers).length < 10} 
                                onClick={submitQuiz}
                                sx={{ bgcolor: '#2f6fdb', borderRadius: '0.5rem' }}
                            >
                                Submit Answers
                            </Button>
                        </DialogActions>
                    </>
                )}

                {/* STEP 2: Quiz Results & Application */}
                {quizStep === 2 && (
                    <Box component="form" onSubmit={handleRoleRequest}>
                        <DialogTitle sx={{ fontWeight: 800, textAlign: 'center' }}>
                            {quizScore >= 7 ? '🎉 You Passed!' : '❌ Not Quite...'}
                        </DialogTitle>
                        <DialogContent>
                            <Box sx={{ textAlign: 'center', mb: 3 }}>
                                <Typography variant="h2" sx={{ fontWeight: 900, color: quizScore >= 7 ? '#10b981' : '#ef4444' }}>
                                    {quizScore}/10
                                </Typography>
                                <Typography color="text.secondary" sx={{ mt: 1 }}>
                                    {quizScore >= 7 
                                        ? "Great job! You have demonstrated the knowledge required. Fill out the application below to send your request to the Super Admins."
                                        : "You need at least 7/10 to apply for this role. Review journalistic guidelines and try again later!"}
                                </Typography>
                            </Box>

                            {quizScore >= 7 && (
                                <TextField
                                    label="Why should we approve your request?"
                                    multiline
                                    rows={4}
                                    placeholder="I have experience writing for the school paper and would love to contribute..."
                                    value={roleForm.data.justification}
                                    onChange={(e) => roleForm.setData('justification', e.target.value)}
                                    fullWidth
                                    required
                                    sx={{ '& .MuiOutlinedInput-root': { borderRadius: '1rem' } }}
                                />
                            )}
                        </DialogContent>
                        <DialogActions sx={{ p: 2, justifyContent: 'center' }}>
                            {quizScore >= 7 ? (
                                <Button type="submit" variant="contained" disabled={roleForm.processing} sx={{ px: 4, py: 1.5, borderRadius: '1rem', bgcolor: '#2f6fdb', fontWeight: 'bold' }}>
                                    Submit Application
                                </Button>
                            ) : (
                                <Button variant="outlined" onClick={() => setIsRoleModalOpen(false)} sx={{ px: 4, borderRadius: '1rem' }}>
                                    Close
                                </Button>
                            )}
                        </DialogActions>
                    </Box>
                )}
            </Dialog>

        </AuthenticatedLayout>
    );
}
