import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, router } from '@inertiajs/react';
import { Alert, Avatar, Box, Button, Chip, Stack, Typography } from '@mui/material';
import { useTheme } from '@mui/material/styles';

// Jeton-style Animations
const adminAnimations = `
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
    .admin-animate-reveal-0 { animation: reveal-up 1.0s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both; }
    .admin-animate-reveal-1 { animation: reveal-up 1.0s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both; }
    .admin-animate-reveal-2 { animation: reveal-up 1.0s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both; }
    .admin-animate-reveal-3 { animation: reveal-up 1.0s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both; }
    .admin-animate-blob { animation: float-blob 8s infinite ease-in-out; }
    .admin-animation-delay-2000 { animation-delay: 2s; }
    .admin-animation-delay-4000 { animation-delay: 4s; }
`;

export default function RoleRequests({ pendingRequests, manageableUsers = [], flash }) {
    const theme = useTheme();
    const isDark = theme.palette.mode === 'dark';
    const roleLabelMap = { writer: 'Writer', editor: 'Editor', student: 'Student' };
    const requestTypeLabelMap = {
        add: 'Add Role',
        switch: 'Change Role',
        step_down: 'Step Down',
    };

    const handleApprove = (id) => {
        router.post(route('admin.requests.approve', id), {}, { preserveScroll: true });
    };

    const handleReject = (id) => {
        if (confirm('Are you sure you want to reject this application?')) {
            router.post(route('admin.requests.reject', id), {}, { preserveScroll: true });
        }
    };

    const handleRemoveRole = (userId, roleName, userName) => {
        if (confirm(`Remove ${roleName} role from ${userName}?`)) {
            router.post(route('admin.users.roles.remove', userId), {
                role_name: roleName,
            }, { preserveScroll: true });
        }
    };

    // Helper to extract quiz score and clean up justification
    const parseJustification = (text) => {
        const match = text?.match(/\[Quiz Score: (\d+)\/10\]\s*(.*)/is);
        if (match) {
            return { score: parseInt(match[1]), text: match[2] };
        }
        return { score: null, text: text };
    };

    const bentoCardSx = (hover = true) => ({
        p: 3,
        borderRadius: '2rem',
        bgcolor: isDark ? 'rgba(30, 41, 59, 0.8)' : '#fff',
        border: '1px solid',
        borderColor: isDark ? 'rgba(75, 85, 99, 0.6)' : 'rgba(226, 232, 240, 0.9)',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)',
        transition: 'all 0.4s cubic-bezier(0.16, 1, 0.3, 1)',
        ...(hover && {
            '&:hover': {
                transform: 'translateY(-6px)',
                boxShadow: '0 20px 40px rgba(47, 111, 219, 0.12)',
                borderColor: 'rgba(47, 111, 219, 0.25)',
            },
        }),
    });

    return (
        <AuthenticatedLayout
            header={
                <Stack spacing={0.25} className="admin-animate-reveal-0">
                    <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.02em', display: 'flex', alignItems: 'center', gap: 1.5 }}>
                        <span>⚡</span> Super Admin Workspace
                    </Typography>
                    <Typography color="text.secondary" sx={{ fontSize: '1rem', fontWeight: 500 }}>
                        Review staff applications, assign roles, and manage platform access.
                    </Typography>
                </Stack>
            }
            fullWidth
        >
            <Head title="Super Admin Workspace" />
            <style>{adminAnimations}</style>

            <Stack spacing={4} sx={{ maxWidth: 1200, mx: 'auto', py: 2 }}>
                
                {flash?.success && (
                    <Alert severity="success" className="admin-animate-reveal-0" sx={{ borderRadius: '1rem' }}>
                        {flash.success}
                    </Alert>
                )}
                {flash?.error && (
                    <Alert severity="error" className="admin-animate-reveal-0" sx={{ borderRadius: '1rem' }}>
                        {flash.error}
                    </Alert>
                )}

                {/* Hero / Stats Box */}
                <Box
                    className="admin-animate-reveal-1"
                    sx={{
                        position: 'relative',
                        overflow: 'hidden',
                        borderRadius: '2.5rem',
                        bgcolor: isDark ? '#0f172a' : '#1e3a8a',
                        color: '#fff',
                        p: { xs: 4, md: 6 },
                        boxShadow: '0 24px 50px -12px rgba(30, 58, 138, 0.5)',
                    }}
                >
                    {/* Floating blobs */}
                    <Box sx={{ position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none' }}>
                        <Box className="admin-animate-blob" sx={{ position: 'absolute', top: -40, right: -40, width: 300, height: 300, borderRadius: '50%', bgcolor: '#3b82f6', opacity: 0.4, mixBlendMode: 'screen' }} />
                        <Box className="admin-animate-blob admin-animation-delay-2000" sx={{ position: 'absolute', bottom: -40, left: 100, width: 250, height: 250, borderRadius: '50%', bgcolor: '#10b981', opacity: 0.3, mixBlendMode: 'screen' }} />
                    </Box>

                    <Stack direction={{ xs: 'column', md: 'row' }} alignItems="center" justifyContent="space-between" sx={{ position: 'relative', zIndex: 1 }} spacing={4}>
                        <Box>
                            <Typography variant="overline" sx={{ letterSpacing: 2, fontWeight: 800, opacity: 0.8 }}>
                                Action Center
                            </Typography>
                            <Typography variant="h3" sx={{ fontWeight: 800, mt: 1, letterSpacing: '-0.02em' }}>
                                Staff Applications
                            </Typography>
                            <Typography sx={{ mt: 2, opacity: 0.9, maxWidth: 400, lineHeight: 1.6 }}>
                                You have pending requests from students seeking elevated permissions. Review their quiz scores and justifications carefully.
                            </Typography>
                        </Box>
                        
                        <Box sx={{ bgcolor: 'rgba(255,255,255,0.1)', backdropFilter: 'blur(10px)', border: '1px solid rgba(255,255,255,0.2)', borderRadius: '2rem', p: 4, textAlign: 'center', minWidth: 200 }}>
                            <Typography sx={{ fontSize: '3.5rem', fontWeight: 900, lineHeight: 1 }}>
                                {pendingRequests?.length ?? 0}
                            </Typography>
                            <Typography sx={{ fontWeight: 700, opacity: 0.8, textTransform: 'uppercase', letterSpacing: 1, mt: 1 }}>
                                Pending Review
                            </Typography>
                        </Box>
                    </Stack>
                </Box>

                {/* Application Feed */}
                <Box className="admin-animate-reveal-2">
                    <Typography variant="h5" sx={{ fontWeight: 800, mb: 3 }}>
                        Awaiting Your Decision
                    </Typography>

                    {(pendingRequests?.length ?? 0) === 0 ? (
                        <Box sx={{ ...bentoCardSx(false), p: 8, textAlign: 'center', borderStyle: 'dashed' }}>
                            <Typography component="span" sx={{ fontSize: '3rem', mb: 2, display: 'block' }}>☕</Typography>
                            <Typography variant="h6" sx={{ fontWeight: 800, color: 'text.secondary' }}>
                                All caught up! No pending applications.
                            </Typography>
                        </Box>
                    ) : (
                        <Stack spacing={3}>
                            {pendingRequests.map((request, index) => {
                                const { score, text } = parseJustification(request.justification);
                                const roleTone = request.role_name === 'writer'
                                    ? { bg: 'rgba(47,111,219,0.1)', fg: '#2f6fdb', border: 'rgba(47,111,219,0.3)' }
                                    : request.role_name === 'editor'
                                        ? { bg: 'rgba(16,185,129,0.1)', fg: '#10b981', border: 'rgba(16,185,129,0.3)' }
                                        : { bg: 'rgba(234,179,8,0.12)', fg: '#a16207', border: 'rgba(234,179,8,0.35)' };
                                
                                return (
                                    <Box key={request.id} className={`admin-animate-reveal-${Math.min((index % 3) + 2, 5)}`} sx={bentoCardSx(true)}>
                                        <Stack direction={{ xs: 'column', md: 'row' }} spacing={3}>
                                            
                                            {/* User Info Column */}
                                            <Stack spacing={2} sx={{ width: { xs: '100%', md: 280 }, flexShrink: 0, borderRight: { md: '1px solid' }, borderColor: { md: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)' }, pr: { md: 3 } }}>
                                                <Stack direction="row" spacing={2} alignItems="center">
                                                    <Avatar src={request.user?.avatar_url} sx={{ width: 56, height: 56, bgcolor: '#2f6fdb', fontWeight: 'bold' }}>
                                                        {request.user?.name?.charAt(0)}
                                                    </Avatar>
                                                    <Box>
                                                        <Typography variant="subtitle1" sx={{ fontWeight: 800, lineHeight: 1.2 }}>
                                                            {request.user?.name}
                                                        </Typography>
                                                        <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 600 }}>
                                                            {request.user?.email}
                                                        </Typography>
                                                    </Box>
                                                </Stack>

                                                <Box>
                                                    <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 700, textTransform: 'uppercase', letterSpacing: 1 }}>
                                                        Requested Role
                                                    </Typography>
                                                    <Box sx={{ mt: 0.5 }}>
                                                        <Chip 
                                                            label={roleLabelMap[request.role_name] ?? request.role_name} 
                                                            sx={{ 
                                                                fontWeight: 800, 
                                                                borderRadius: '0.75rem',
                                                                bgcolor: roleTone.bg,
                                                                color: roleTone.fg,
                                                                border: '1px solid',
                                                                borderColor: roleTone.border
                                                            }} 
                                                        />
                                                    </Box>
                                                </Box>

                                                <Box>
                                                    <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 700, textTransform: 'uppercase', letterSpacing: 1 }}>
                                                        Request Type
                                                    </Typography>
                                                    <Box sx={{ mt: 0.5 }}>
                                                        <Chip
                                                            label={requestTypeLabelMap[request.request_type ?? 'add']}
                                                            size="small"
                                                            variant="outlined"
                                                            sx={{ fontWeight: 700, borderRadius: '0.65rem' }}
                                                        />
                                                    </Box>
                                                </Box>

                                                <Box>
                                                    <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 700, textTransform: 'uppercase', letterSpacing: 1 }}>
                                                        Applied On
                                                    </Typography>
                                                    <Typography variant="body2" sx={{ fontWeight: 600, mt: 0.5 }}>
                                                        {new Date(request.created_at).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' })}
                                                    </Typography>
                                                </Box>
                                            </Stack>

                                            {/* Justification & Quiz Score Column */}
                                            <Stack spacing={3} sx={{ flex: 1, justifyContent: 'space-between' }}>
                                                <Box>
                                                    <Stack direction="row" alignItems="center" justifyContent="space-between" sx={{ mb: 1.5 }}>
                                                        <Typography variant="subtitle2" sx={{ fontWeight: 800, textTransform: 'uppercase', letterSpacing: 1, color: 'text.secondary' }}>
                                                            Application & Quiz Results
                                                        </Typography>
                                                        
                                                        {score !== null && (
                                                            <Chip 
                                                                label={`Quiz Score: ${score}/10`} 
                                                                icon={<span style={{ marginLeft: 8 }}>{score >= 7 ? '✅' : '⚠️'}</span>}
                                                                sx={{ 
                                                                    fontWeight: 800, 
                                                                    bgcolor: score >= 7 ? 'rgba(16,185,129,0.1)' : 'rgba(239,68,68,0.1)', 
                                                                    color: score >= 7 ? '#10b981' : '#ef4444',
                                                                    borderRadius: '0.75rem'
                                                                }} 
                                                            />
                                                        )}
                                                    </Stack>
                                                    
                                                    <Box sx={{ p: 2.5, bgcolor: isDark ? 'rgba(0,0,0,0.2)' : 'rgba(244, 247, 251, 0.6)', borderRadius: '1.5rem', border: '1px solid', borderColor: isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)' }}>
                                                        <Typography variant="body1" sx={{ fontStyle: 'italic', lineHeight: 1.7, color: 'text.primary' }}>
                                                            "{text}"
                                                        </Typography>
                                                    </Box>
                                                </Box>

                                                {/* Action Buttons */}
                                                <Stack direction="row" spacing={2} justifyContent="flex-end" sx={{ pt: 2, borderTop: '1px solid', borderColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)' }}>
                                                    <Button 
                                                        variant="outlined" 
                                                        color="error"
                                                        onClick={() => handleReject(request.id)}
                                                        sx={{ borderRadius: '1rem', fontWeight: 800, textTransform: 'none', px: 3, borderWidth: '2px', '&:hover': { borderWidth: '2px' } }}
                                                    >
                                                        Reject
                                                    </Button>
                                                    <Button 
                                                        variant="contained" 
                                                        onClick={() => handleApprove(request.id)}
                                                        sx={{ borderRadius: '1rem', fontWeight: 800, textTransform: 'none', px: 4, bgcolor: '#10b981', boxShadow: '0 4px 14px rgba(16,185,129,0.3)', '&:hover': { bgcolor: '#059669', boxShadow: '0 6px 20px rgba(16,185,129,0.4)' } }}
                                                    >
                                                        Approve Request
                                                    </Button>
                                                </Stack>
                                            </Stack>

                                        </Stack>
                                    </Box>
                                );
                            })}
                        </Stack>
                    )}
                </Box>

                <Box className="admin-animate-reveal-3">
                    <Typography variant="h5" sx={{ fontWeight: 800, mb: 3 }}>
                        Current Role Assignments
                    </Typography>

                    {(manageableUsers?.length ?? 0) === 0 ? (
                        <Box sx={{ ...bentoCardSx(false), p: 6, textAlign: 'center', borderStyle: 'dashed' }}>
                            <Typography color="text.secondary">No role assignments found.</Typography>
                        </Box>
                    ) : (
                        <Stack spacing={2}>
                            {manageableUsers.map((user) => {
                                const userRoles = (user.roles ?? [])
                                    .map((role) => role.name)
                                    .filter((roleName) => ['student', 'writer', 'editor'].includes(roleName));

                                return (
                                    <Box key={user.id} sx={bentoCardSx(true)}>
                                        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems={{ md: 'center' }} justifyContent="space-between">
                                            <Stack direction="row" spacing={2} alignItems="center" sx={{ minWidth: 0 }}>
                                                <Avatar src={user.avatar_url} sx={{ width: 44, height: 44, bgcolor: '#2f6fdb', fontWeight: 'bold' }}>
                                                    {user.name?.charAt(0)}
                                                </Avatar>
                                                <Box sx={{ minWidth: 0 }}>
                                                    <Typography sx={{ fontWeight: 800 }} noWrap>{user.name}</Typography>
                                                    <Typography variant="caption" color="text.secondary" noWrap>{user.email}</Typography>
                                                </Box>
                                            </Stack>

                                            <Stack direction="row" spacing={1} useFlexGap flexWrap="wrap">
                                                {userRoles.length === 0 ? (
                                                    <Chip label="No removable roles" size="small" variant="outlined" />
                                                ) : (
                                                    userRoles.map((roleName) => (
                                                        <Button
                                                            key={`${user.id}-${roleName}`}
                                                            color="error"
                                                            variant="outlined"
                                                            size="small"
                                                            onClick={() => handleRemoveRole(user.id, roleName, user.name)}
                                                            sx={{ borderRadius: '0.75rem', textTransform: 'none', fontWeight: 700 }}
                                                        >
                                                            Remove {roleLabelMap[roleName] ?? roleName}
                                                        </Button>
                                                    ))
                                                )}
                                            </Stack>
                                        </Stack>
                                    </Box>
                                );
                            })}
                        </Stack>
                    )}
                </Box>
            </Stack>
        </AuthenticatedLayout>
    );
}
