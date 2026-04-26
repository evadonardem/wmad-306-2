import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import { 
    Container, Grid, Paper, Typography, Box, Avatar, Button, Grow 
} from '@mui/material';
import { 
    FolderCopy as ProjectIcon, 
    Assignment as TaskIcon, 
    CheckCircle as DoneIcon, 
    PendingActions as PendingIcon,
    Add as AddIcon
    // REMOVED: AutoAwesome (TaskFlowIcon)
} from '@mui/icons-material';

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
        background: 'linear-gradient(135deg, #0071e3 0%, #00c6fb 100%)',
        color: '#fff',
        borderRadius: '24px',
        p: 4,
        boxShadow: '0 10px 40px rgba(0, 113, 227, 0.3)',
        position: 'relative',
        overflow: 'hidden'
    },
    statIconBox: (color) => ({
        width: 48,
        height: 48,
        borderRadius: '16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: color,
        color: '#fff',
        mb: 2,
    })
};

export default function Dashboard({ auth, stats }) {
    const safeStats = stats || { projects: 0, total_tasks: 0, pending_tasks: 0, completed_tasks: 0 };

    return (
        <AuthenticatedLayout
            user={auth.user}
            header={
                <Box display="flex" alignItems="center" gap={1}>
                    {/* REMOVED: TaskFlowIcon from header */}
                    <Typography variant="h6" fontWeight="700" color="#1d1d1f">
                        Dashboard
                    </Typography>
                </Box>
            }
        >
            <Head title="Dashboard" />

            <Container maxWidth="lg" sx={{ py: 4 }}>
                <Grid container spacing={3}>
                    
                    {/* 1. Welcome Section */}
                    <Grid item xs={12}>
                        <Grow in={true} timeout={500}>
                            <Paper sx={styles.welcomeCard}>
                                {/* REMOVED: Large decorative star from background */}

                                <Box display="flex" alignItems="center" flexWrap="wrap" position="relative" zIndex={2}>
                                    <Avatar 
                                        sx={{ width: 80, height: 80, mr: 3, border: '4px solid rgba(255,255,255,0.3)', bgcolor: 'rgba(255,255,255,0.2)' }}
                                        alt={auth.user.name}
                                    >
                                        {auth.user.name.charAt(0)}
                                    </Avatar>
                                    <Box flexGrow={1}>
                                        <Typography variant="h4" fontWeight="700">
                                            Welcome back, {auth.user.name.split(' ')[0]}!
                                        </Typography>
                                        <Typography variant="body1" sx={{ opacity: 0.9, mt: 0.5 }}>
                                            You have {safeStats.pending_tasks} pending tasks today. Let's get to work.
                                        </Typography>
                                    </Box>
                                    <Button 
                                        variant="contained" 
                                        component={Link}
                                        href={route('tasks.create')}
                                        sx={{ 
                                            backgroundColor: 'rgba(255,255,255,0.2)', 
                                            backdropFilter: 'blur(10px)',
                                            boxShadow: 'none',
                                            borderRadius: '12px',
                                            textTransform: 'none',
                                            fontWeight: 600,
                                            mt: { xs: 2, md: 0 },
                                            '&:hover': { backgroundColor: 'rgba(255,255,255,0.3)', boxShadow: 'none' }
                                        }}
                                        startIcon={<AddIcon />}
                                    >
                                        New Task
                                    </Button>
                                </Box>
                            </Paper>
                        </Grow>
                    </Grid>

                    {/* 2. Stats Grid */}
                    <Grid item xs={12} md={3} sm={6}>
                        <StatCard 
                            title="Projects" 
                            count={safeStats.projects} 
                            icon={<ProjectIcon />} 
                            color="#5856D6" 
                            link={route('projects.index')}
                            delay={600}
                        />
                    </Grid>
                    <Grid item xs={12} md={3} sm={6}>
                        <StatCard 
                            title="Total Tasks" 
                            count={safeStats.total_tasks} 
                            icon={<TaskIcon />} 
                            color="#FF9500" 
                            link={route('tasks.index')}
                            delay={700}
                        />
                    </Grid>
                    <Grid item xs={12} md={3} sm={6}>
                        <StatCard 
                            title="Pending" 
                            count={safeStats.pending_tasks} 
                            icon={<PendingIcon />} 
                            color="#FF2D55" 
                            link={route('tasks.index')}
                            delay={800}
                        />
                    </Grid>
                    <Grid item xs={12} md={3} sm={6}>
                        <StatCard 
                            title="Completed" 
                            count={safeStats.completed_tasks} 
                            icon={<DoneIcon />} 
                            color="#34C759" 
                            link={route('tasks.index')}
                            delay={900}
                        />
                    </Grid>

                    {/* 3. Quick Actions */}
                    <Grid item xs={12}>
                        <Grow in={true} timeout={1000}>
                            <Paper sx={{ ...styles.glassCard, p: 3, display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 2 }}>
                                <Box>
                                    <Typography variant="h6" fontWeight="700">Quick Actions</Typography>
                                    <Typography variant="body2" color="text.secondary">
                                        Manage your workflow efficiently.
                                    </Typography>
                                </Box>
                                <Box>
                                    <Button component={Link} href={route('projects.create')} sx={{ mr: 1, textTransform: 'none', fontWeight: 600 }}>
                                        Add Project
                                    </Button>
                                    <Button 
                                        component={Link} 
                                        href={route('tasks.create')} 
                                        variant="contained" 
                                        sx={{ borderRadius: '20px', textTransform: 'none', backgroundColor: '#1d1d1f', fontWeight: 600 }}
                                    >
                                        Add Task
                                    </Button>
                                </Box>
                            </Paper>
                        </Grow>
                    </Grid>

                </Grid>
            </Container>
        </AuthenticatedLayout>
    );
}

function StatCard({ title, count, icon, color, link, delay }) {
    return (
        <Grow in={true} timeout={delay}>
            <Paper 
                component={Link} 
                href={link} 
                sx={{ 
                    ...styles.glassCard, 
                    p: 3, 
                    display: 'block', 
                    textDecoration: 'none', 
                    color: 'inherit',
                    position: 'relative',
                    overflow: 'hidden'
                }}
            >
                <Box sx={styles.statIconBox(color)}>
                    {icon}
                </Box>
                <Typography variant="h3" fontWeight="700" sx={{ mb: 0.5, color: '#1d1d1f' }}>
                    {count}
                </Typography>
                <Typography variant="body2" color="text.secondary" fontWeight="600">
                    {title}
                </Typography>
            </Paper>
        </Grow>
    );
}