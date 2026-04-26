import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout';
import { Head, Link } from '@inertiajs/react';
import {
    Container,
    Typography,
    Grid,
    Button,
    Box,
    Card,
    CardContent,
    Tabs,
    Tab
} from '@mui/material';
import { Add, AccountTree } from '@mui/icons-material';
import { useState } from 'react';
import ProjectCard from '@/Components/ProjectCard';
import { useThemeContext } from '@/Components/ThemeProvider';

export default function Index({ projects = [] }) {
    const { theme } = useThemeContext();
    
    const [tabValue, setTabValue] = useState(1);

    const handleTabChange = (event, newValue) => {
        setTabValue(newValue);
    };

    return (
        <AuthenticatedLayout
            header={
                <Typography 
                    variant="h4" 
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
            }
        >
            <Head title="Projects" />

            <Container maxWidth="xl" sx={{ mt: 3, mb: 4 }}>
                
                <Box sx={{ display: 'flex', justifyContent: 'flex-start', mb: -0.2, ml: 2 }}>
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
                        <Tab label="Dashboard" component={Link} href={route('dashboard')}/>
                        <Tab label="Projects"/>
                        <Tab label="Tasks" component={Link} href={route('tasks.index')} />
                    </Tabs>
                </Box>

                <Box sx={{ 
                    p: 4, 
                    borderRadius: '24px', 
                    border: '4px solid #333',
                    boxShadow: '0 20px 50px rgba(0,0,0,0.5)'
                }}>
                    
                    <Box sx={{ mb: 3, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <Typography variant="h5" sx={{ fontWeight: '900', color: '#EDEDED', textTransform: 'uppercase' }}>
                            Projects
                        </Typography>
                        <Typography variant="caption" sx={{ color: '#777', fontWeight: 'bold' }}>
                            Currently has a total of {projects.length} {projects.length === 1 ? 'project' : 'projects'}.
                        </Typography>
                    </Box>

                    <Grid 
                        container 
                        spacing={2} 
                        sx={{ 
                            display: 'flex', 
                            flexWrap: 'nowrap', 
                            overflowX: 'auto', 
                            pb: 2,
                            '&::-webkit-scrollbar': { height: '8px' },
                            '&::-webkit-scrollbar-thumb': { bgcolor: '#DA0037', borderRadius: '4px' }, // Red accent scroll
                            '&::-webkit-scrollbar-track': { bgcolor: '#111' }
                        }}
                    >

                        <Grid item sx={{ flex: '0 0 25%', minWidth: '280px'}}>
                            <Card
                                component={Link}
                                href={route('projects.create')}
                                sx={{
                                    height: 420,
                                    position: 'relative',
                                    borderRadius: 4,
                                    border: '2px solid #000',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    textDecoration: 'none',
                                    transition: '0.2s',
                                    '&:hover': { 
                                    borderColor: '#FFD700',
                                    boxShadow: '0 10px 30px rgba(0,0,0,0.5)'}
                                }}
                            >

                                <Add sx={{ fontSize: 80, color: '#000' }} />
                                <Typography variant="h5" sx={{ fontWeight: 900, color: '#000', mt: 1 }}>
                                    NEW PROJECT
                                </Typography>
                            </Card>
                        </Grid>

                        {(
                            projects.map((project) => (
                                <Grid item sx={{ flex: '0 0 25%', minWidth: '280px' }} key={project.id}>
                                    <ProjectCard project={project} />
                                    <Typography variant="body2" color="text.primary" ml={2} pt={1}>
                                        Started : {new Date(project.created_at).toLocaleDateString()}
                                    </Typography>
                                </Grid>
                            ))
                        )}
                    </Grid>
                </Box>
            </Container>
        </AuthenticatedLayout>
    );
}