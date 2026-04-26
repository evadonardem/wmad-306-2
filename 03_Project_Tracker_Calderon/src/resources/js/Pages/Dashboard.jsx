import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head } from '@inertiajs/react';
import React, { useState } from 'react';
import {
    Container,
    Typography,
    Grid,
    Card,
    CardContent,
    Box,
    Tabs,
    Tab,
    Paper,
    LinearProgress,
    Button,
} from '@mui/material';
import {
    AccountTree,
    CheckCircle,
} from '@mui/icons-material';
import { useThemeContext } from '@/Components/ThemeProvider';

export default function Dashboard({ projectsCount, tasksCount, completedTasksCount, pendingTasksCount }) {
    const { theme } = useThemeContext();
    const [tabValue, setTabValue] = useState(0); 

    const handleTabChange = (event, newValue) => {
        setTabValue(newValue);
    };


    const dashboardStats = [
        { label: 'PROJECTS', count: projectsCount, sub: 'Total Projects' },
        { label: 'TASKS', count: tasksCount, sub: 'Active Tasks' },
        { label: 'COMPLETED', count: completedTasksCount, sub: 'Finished' },
        { label: 'PENDING', count: pendingTasksCount, sub: 'Awaiting' },
    ];

    return (
        <AuthenticatedLayout header={
            <Typography 
                variant="h4" 
                component="h1" 
                sx={{ 
                    fontWeight: 'bold', 
                    color: theme.palette.text.primary,
                    display: 'flex',       
                    alignItems: 'center',  
                    gap: 1.5               
                }}
            >
                <AccountTree />
                Project Tracker
            </Typography>
        }>
            <Head title="Dashboard" />

            <Container sx={{ mt: 4, mb: 4 }}>
                <Box sx={{ display: 'flex', justifyContent: 'flex-start', mb: -0.5, ml: 2}}>
                    <Tabs 
                        value={tabValue} 
                        onChange={handleTabChange}
                        textColor="inherit"
                        TabIndicatorProps={{ sx: { display: 'none' } }}
                        sx={{
                            '& .MuiTab-root': {
                                bgcolor: '#222',
                                color: '#777',
                                mx: 0.5,
                                borderRadius: '12px 12px 0 0',
                                textTransform: 'none',
                                fontWeight: 'bold',
                                minHeight: 40,
                                border: '2px solid #333',
                                borderBottom: 'none',
                                '&.Mui-selected': {
                                    bgcolor: '#499636',
                                    color: '#000',
                                },
                            },
                        }}
                    >
                        <Tab label="Dashboard" />
                        <Tab label="Projects" href={route('projects.index')}/>
                        <Tab label="Tasks" href={route('tasks.index')}/>
                    </Tabs>
                </Box>

                <Paper 
                    sx={{ 
                        p: 4, 
                        borderRadius: '24px', 
                        border: '4px solid #333',
                        boxShadow: '0 20px 50px rgba(0,0,0,0.5)'
                    }}
                >
                    <Box sx={{ mb: 5, px: 2 }}>
                        <Typography variant="caption" sx={{ fontWeight: 'bold', mb: 1, display: 'block' }}>
                            Task Completion Progress
                        </Typography>
                        <Box sx={{ position: 'relative', height: 24, mt: 1 }}>
                            <LinearProgress 
                                variant="determinate" 
                                value={completedTasksCount + 2} 
                                sx={{ 
                                    height: 14, 
                                    borderRadius: 7, 
                                    '& .MuiLinearProgress-bar': { bgcolor: '#4CAF50' } 
                                }} 
                            />
                            {[''].map((val, i) => (
                                <Box key={val} sx={{ position: 'absolute', left: `${99}%`, top: -6, textAlign: 'center' }}>
                                    <CheckCircle sx={{ color: '#4CAF50', fontSize: 22, bgcolor: '#171717', borderRadius: '50%' }} />
                                    <Typography sx={{ fontSize: '10px', fontWeight: 'bold' }}>{val}</Typography>
                                </Box>
                            ))}
                        </Box>
                    </Box>

                    <Grid 
                        container 
                        spacing={2} 
                        sx={{ 
                            display: 'flex', 
                            flexWrap: 'nowrap',   

                        }}
                     >
                        {dashboardStats.map((stat, index) => (
                            <Grid 
                                item 
                                key={index} 
                                sx={{ 
                                    flex: '0 0 23.5%',     
                                    minWidth: '250px',    
                                }}
                            >
                                <Card
                                    sx={{
                                        color: '#EDEDED',
                                        borderRadius: 4,
                                        height: 280,
                                        border: '2px solid',
                                        display: 'flex',
                                        flexDirection: 'column',
                                        '&:hover': { borderColor: '#FFD700' } 
                                    }}
                                >
                                    <CardContent sx={{ p: 2, flexGrow: 1 }}>
                                        <Typography variant="caption" sx={{ color: '#499636', fontWeight: 'bold' }}>
                                            ● Progress: 
                                        </Typography>
                                        <Typography variant="h6" sx={{ mt: 1, fontWeight: 900, lineHeight: 1.1 }}>
                                            {stat.label}
                                        </Typography>
                                    </CardContent>
                                    
                                    <Box sx={{ p: 2, bgcolor: 'rgba(0,0,0,0.2)', borderTop: '1px solid #444' }}>
                                        <Typography variant="h3" sx={{ fontWeight: '900', color: '#DA0037' }}>
                                            {stat.count || 0}
                                        </Typography>
                                        <Typography variant="caption" sx={{ color: '#555', fontWeight: 'bold' }}>
                                            {stat.sub.toUpperCase()}
                                        </Typography>
                                    </Box>
                                </Card>
                            </Grid>
                        ))}
                    </Grid>
                </Paper>
            </Container>
        </AuthenticatedLayout>
    );
}
