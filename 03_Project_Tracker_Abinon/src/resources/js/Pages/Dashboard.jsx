import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import { 
    Container, Grid, Paper, Typography, Box, Avatar, Button, Grow, Fade 
} from '@mui/material';
import { 
    FolderOpen as ProjectIcon,
    Assignment as TaskIcon, 
    CheckCircle as DoneIcon, 
    PendingActions as PendingIcon,
    Add as AddIcon,
    AutoAwesome as TaskFlowIcon,
    TrendingUp as TrendingIcon
} from '@mui/icons-material';

// --- Premium Apple-Inspired Design System ---
const styles = {
    glassCard: {
        borderRadius: '24px',
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        backdropFilter: 'blur(20px)',
        boxShadow: '0 8px 32px rgba(0, 0, 0, 0.04)',
        border: '1px solid rgba(255, 255, 255, 0.6)',
        height: '100%',
        transition: 'transform 0.3s ease, box-shadow 0.3s ease',
        '&:hover': {
            transform: 'translateY(-4px)',
            boxShadow: '0 12px 40px rgba(0, 0, 0, 0.08)',
        }
    },
    welcomeCard: {
        background: 'linear-gradient(135deg, #a855f7 0%, #d946ef 100%)',
        color: '#fff',
        borderRadius: '24px',
        p: 5,
        boxShadow: '0 20px 60px rgba(168, 85, 247, 0.4)',
        position: 'relative',
        overflow: 'hidden'
    },
    statCard: {
        background: 'linear-gradient(135deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.7) 100%)',
        borderRadius: '24px',
        p: 3,
        boxShadow: '0 8px 32px rgba(0, 0, 0, 0.04)',
        border: '1px solid rgba(255, 255, 255, 0.6)',
        backdropFilter: 'blur(20px)',
        height: '100%',
        transition: 'all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1)',
        '&:hover': {
            transform: 'translateY(-6px)',
            boxShadow: '0 16px 48px rgba(168, 85, 247, 0.15)',
        }
    },
    statIconBox: (color) => ({
        width: 56,
        height: 56,
        borderRadius: '16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: `linear-gradient(135deg, ${color}20 0%, ${color}05 100%)`,
        color: color,
        mb: 2,
        fontSize: 28,
    })
};

export default function Dashboard({ auth, stats }) {
    // Default stats to 0 if data hasn't loaded yet
    const safeStats = stats || { projects: 0, total_tasks: 0, pending_tasks: 0, completed_tasks: 0 };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <Box display="flex" alignItems="center" gap={1}>
                    {/* TaskFlow Icon added here */}
                    <TaskFlowIcon sx={{ color: '#a855f7' }} /> 
                    <Typography variant="h6" fontWeight="700" color="#1d1d1f">
                        Dashboard
                    </Typography>
                </Box>
            }
        >
            <Head title="Dashboard" />

            <Container maxWidth="lg" sx={{ py: 6 }}>
                <Grid container spacing={4}>
                    
                    {/* 1. Welcome Hero Section */}
                    <Grid item xs={12}>
                        <Grow in={true} timeout={500}>
                            <Paper sx={styles.welcomeCard}>
                                {/* Decorative Background Elements */}
                                <TaskFlowIcon sx={{ 
                                    position: 'absolute', 
                                    right: -50, 
                                    top: -50, 
                                    fontSize: '300px', 
                                    opacity: 0.08, 
                                    transform: 'rotate(15deg)' 
                                }} />
                                <TrendingIcon sx={{
                                    position: 'absolute',
                                    left: -30,
                                    bottom: -30,
                                    fontSize: '200px',
                                    opacity: 0.08,
                                    transform: 'rotate(-20deg)'
                                }} />

                                <Box display="flex" alignItems="center" flexWrap="wrap" position="relative" zIndex={2} gap={4}>
                                    <Avatar 
                                        sx={{ 
                                            width: 96, 
                                            height: 96, 
                                            border: '4px solid rgba(255,255,255,0.3)', 
                                            bgcolor: 'rgba(255,255,255,0.2)',
                                            fontSize: 40,
                                            fontWeight: 700,
                                            flexShrink: 0
                                        }}
                                        alt={auth.user.name}
                                    >
                                        {auth.user.name.charAt(0).toUpperCase()}
                                    </Avatar>
                                    <Box flexGrow={1}>
                                        <Typography variant="h2" fontWeight="700" sx={{ mb: 1, fontSize: { xs: '2.5rem', md: '3.5rem' }, lineHeight: 1.1 }}>
                                            Welcome back, {auth.user.name.split(' ')[0]}! 👋
                                        </Typography>
                                        <Typography variant="h6" sx={{ opacity: 0.95, mb: 3, fontWeight: '500' }}>
                                            You have <strong>{safeStats.pending_tasks}</strong> pending {safeStats.pending_tasks === 1 ? 'task' : 'tasks'} today. Let's get productive!
                                        </Typography>
                                    </Box>
                                    <Button 
                                        variant="contained" 
                                        component={Link}
                                        href={route('tasks.create')}
                                        sx={{ 
                                            backgroundColor: 'rgba(255,255,255,0.25)', 
                                            backdropFilter: 'blur(10px)',
                                            boxShadow: 'none',
                                            borderRadius: '16px',
                                            textTransform: 'none',
                                            fontWeight: 600,
                                            width: '100%',
                                            py: 2,
                                            '&:hover': { 
                                                backgroundColor: 'rgba(255,255,255,0.35)', 
                                                boxShadow: '0 8px 24px rgba(0,0,0,0.15)' 
                                            }
                                        }}
                                        startIcon={<AddIcon />}
                                    >
                                        Create Task
                                    </Button>
                                </Box>
                            </Paper>
                        </Grow>
                    </Grid>

                    {/* 2. Statistics Grid */}
                    <Grid item xs={12} md={3} sm={6}>
                        <Grow in={true} timeout={600}>
                            <Paper 
                                sx={styles.statCard}
                                component={Link}
                                href={route('projects.index')}
                                style={{ textDecoration: 'none', color: 'inherit', display: 'block', cursor: 'pointer' }}
                            >
                                <Box sx={styles.statIconBox('#a855f7')}>
                                    <ProjectIcon />
                                </Box>
                                <Typography variant="h3" fontWeight="700" sx={{ mb: 0.5, color: '#1d1d1f' }}>
                                    {safeStats.projects}
                                </Typography>
                                <Typography variant="body2" color="text.secondary" fontWeight="600">
                                    {safeStats.projects === 1 ? 'Project' : 'Projects'}
                                </Typography>
                                <Typography variant="caption" sx={{ mt: 1, display: 'block', color: '#a855f7', fontWeight: '600' }}>
                                    View All →
                                </Typography>
                            </Paper>
                        </Grow>
                    </Grid>

                    <Grid item xs={12} md={3} sm={6}>
                        <Grow in={true} timeout={700}>
                            <Paper 
                                sx={styles.statCard}
                                component={Link}
                                href={route('tasks.index')}
                                style={{ textDecoration: 'none', color: 'inherit', display: 'block', cursor: 'pointer' }}
                            >
                                <Box sx={styles.statIconBox('#a855f7')}>
                                    <TaskIcon />
                                </Box>
                                <Typography variant="h3" fontWeight="700" sx={{ mb: 0.5, color: '#1d1d1f' }}>
                                    {safeStats.total_tasks}
                                </Typography>
                                <Typography variant="body2" color="text.secondary" fontWeight="600">
                                    {safeStats.total_tasks === 1 ? 'Task' : 'Tasks'}
                                </Typography>
                                <Typography variant="caption" sx={{ mt: 1, display: 'block', color: '#a855f7', fontWeight: '600' }}>
                                    View All →
                                </Typography>
                            </Paper>
                        </Grow>
                    </Grid>

                    <Grid item xs={12} md={3} sm={6}>
                        <Grow in={true} timeout={800}>
                            <Paper 
                                sx={styles.statCard}
                                component={Link}
                                href={route('tasks.index')}
                                style={{ textDecoration: 'none', color: 'inherit', display: 'block', cursor: 'pointer' }}
                            >
                                <Box sx={styles.statIconBox('#FF9500')}>
                                    <PendingIcon />
                                </Box>
                                <Typography variant="h3" fontWeight="700" sx={{ mb: 0.5, color: '#1d1d1f' }}>
                                    {safeStats.pending_tasks}
                                </Typography>
                                <Typography variant="body2" color="text.secondary" fontWeight="600">
                                    Pending
                                </Typography>
                                <Typography variant="caption" sx={{ mt: 1, display: 'block', color: '#FF9500', fontWeight: '600' }}>
                                    Need attention →
                                </Typography>
                            </Paper>
                        </Grow>
                    </Grid>

                    <Grid item xs={12} md={3} sm={6}>
                        <Grow in={true} timeout={900}>
                            <Paper sx={styles.statCard}>
                                <Box sx={styles.statIconBox('#34C759')}>
                                    <DoneIcon />
                                </Box>
                                <Typography variant="h3" fontWeight="700" sx={{ mb: 0.5, color: '#1d1d1f' }}>
                                    {safeStats.completed_tasks}
                                </Typography>
                                <Typography variant="body2" color="text.secondary" fontWeight="600">
                                    Completed
                                </Typography>
                                <Box sx={{ mt: 2, pt: 1, borderTop: '1px solid rgba(0,0,0,0.05)' }}>
                                    <Typography variant="caption" sx={{ color: '#34C759', fontWeight: '600' }}>
                                        Great Progress! 🎉
                                    </Typography>
                                </Box>
                            </Paper>
                        </Grow>
                    </Grid>

                    {/* 3. Quick Actions */}
                    <Grid item xs={12}>
                        <Grow in={true} timeout={1000}>
                            <Paper sx={{ ...styles.glassCard, p: 4 }}>
                                <Grid container spacing={2} alignItems="center">
                                    <Grid item xs={12} sm="auto" sx={{ flexGrow: 1 }}>
                                        <Typography variant="h6" fontWeight="700" sx={{ mb: 0.5, color: '#1d1d1f' }}>
                                            Quick Actions
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary">
                                            Manage your workflow efficiently
                                        </Typography>
                                    </Grid>
                                    <Grid item xs={12} sm="auto">
                                        <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                            <Button 
                                                component={Link} 
                                                href={route('projects.create')}
                                                variant="outlined"
                                                sx={{ 
                                                    borderRadius: '12px', 
                                                    textTransform: 'none', 
                                                    fontWeight: '600',
                                                    borderColor: '#a855f7',
                                                    color: '#a855f7',
                                                    '&:hover': {
                                                        backgroundColor: 'rgba(168, 85, 247, 0.05)',
                                                        borderColor: '#9333ea'
                                                    }
                                                }}
                                            >
                                                Add Project
                                            </Button>
                                            <Button 
                                                component={Link} 
                                                href={route('tasks.create')}
                                                variant="contained" 
                                                sx={{ 
                                                    borderRadius: '12px', 
                                                    textTransform: 'none', 
                                                    fontWeight: '600',
                                                    backgroundColor: '#a855f7',
                                                    '&:hover': {
                                                        backgroundColor: '#9333ea'
                                                    }
                                                }}
                                                startIcon={<AddIcon />}
                                            >
                                                Add Task
                                            </Button>
                                        </Box>
                                    </Grid>
                                </Grid>
                            </Paper>
                        </Grow>
                    </Grid>

                    {/* 4. Summary Stats */}
                    {safeStats.total_tasks > 0 && (
                        <Grid item xs={12}>
                            <Grow in={true} timeout={1100}>
                                <Paper sx={styles.glassCard} component="div">
                                    <Box sx={{ p: 3 }}>
                                        <Typography variant="h6" fontWeight="700" sx={{ mb: 2, color: '#1d1d1f' }}>
                                            Overview
                                        </Typography>
                                        <Grid container spacing={2}>
                                            <Grid item xs={12} sm={6}>
                                                <Box sx={{ p: 2, backgroundColor: 'rgba(0, 113, 227, 0.08)', borderRadius: '12px' }}>
                                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                                                        Completion Rate
                                                    </Typography>
                                                    <Typography variant="h5" fontWeight="700" color="#a855f7">
                                                        {safeStats.total_tasks > 0 ? Math.round((safeStats.completed_tasks / safeStats.total_tasks) * 100) : 0}%
                                                    </Typography>
                                                </Box>
                                            </Grid>
                                            <Grid item xs={12} sm={6}>
                                                <Box sx={{ p: 2, backgroundColor: 'rgba(255, 149, 0, 0.08)', borderRadius: '12px' }}>
                                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                                                        Tasks Remaining
                                                    </Typography>
                                                    <Typography variant="h5" fontWeight="700" color="#FF9500">
                                                        {safeStats.pending_tasks}
                                                    </Typography>
                                                </Box>
                                            </Grid>
                                        </Grid>
                                    </Box>
                                </Paper>
                            </Grow>
                        </Grid>
                    )}

                </Grid>
            </Container>
        </AuthenticatedLayout>
    );
}