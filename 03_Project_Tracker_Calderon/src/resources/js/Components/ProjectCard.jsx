import {
    Card,
    CardContent,
    CardActions,
    Typography,
    Button,
    Box,
    Chip,
    Avatar,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogContentText,
    DialogActions as MuiDialogActions
} from '@mui/material';
import {
    Assignment,
    Edit,
    Delete,
    DoneAll,
} from '@mui/icons-material';
import { router } from '@inertiajs/react';
import { useState } from 'react';
import { useThemeContext } from './ThemeProvider';

const ProjectCard = ({ project }) => {
    const { theme } = useThemeContext();
    const [openDeleteDialog, setOpenDeleteDialog] = useState(false);
    const [openCompleteDialog, setOpenCompleteDialog] = useState(false);

    // Dialog Handlers
    const handleOpenDialog = (e) => {
        e.preventDefault(); // Prevent accidental navigation if card is wrapped in Link
        setOpenDeleteDialog(true);
        setOpenCompleteDialog(true);
    };

    const handleCloseDialog = () => setOpenDeleteDialog(false);
    const confirmDelete = () => {
        handleCloseDialog();
        router.delete(route('projects.destroy', project.id));
    };

    const actionButtonStyle = {
        bgcolor: '#000',
        color: '#FFF',
        fontWeight: '900',
        borderRadius: 10,
        textTransform: 'uppercase',
        letterSpacing: '1.5px',
        py: 1,
        fontSize: '0.75rem',
        border: '2px solid rgba(255,255,255,0.1)',
        transition: '0.2s cubic-bezier(0.4, 0, 0.2, 1)',
        '&:hover': {
            bgcolor: '#DA0037',
            color: '#000',
            transform: 'scale(1.03)',
            boxShadow: '0 4px 15px rgba(218, 0, 55, 0.3)',
        },
    };

    return (
        <>
            <Card
                sx={{
                    height: 420, 
                    display: 'flex',
                    flexDirection: 'column',
                    bgcolor: theme.palette.primary.secondary,
                    color: theme.palette.text.primary,
                    borderRadius: 4,
                    border: '2px solid #333',
                    position: 'relative',
                    '&:hover': {
                        borderColor: '#FFD700',
                        boxShadow: '0 10px 30px rgba(0,0,0,0.5)',
                    }
                }}
            >
                {/* Status Badge (Top Left like reference)*/}
                <Box sx={{ 
                    position: 'absolute', top: 15, right: 15, 
                    borderRadius: 2,
                }}>
                    <Button
                        onClick={handleOpenDialog}
                        fullWidth
                        startIcon={<Delete/>}
                        sx={actionButtonStyle}
                    >   
                    </Button>
                </Box> 

                <CardContent sx={{ flexGrow: 1, p: 3, mt: 3 }}>
                    <Box display="flex" alignItems="center" mb={2}>
                        <Avatar sx={{ bgcolor: '#DA0037', mr: 2 }}>
                            <Assignment />
                        </Avatar>
                        <Box>
                            <Typography variant="h6" sx={{ fontWeight: '900', color: '#EDEDED' }}>
                                {project.title}
                            </Typography>
                            <Typography variant="caption" sx={{ color: theme.palette.text.primary, textTransform: 'uppercase' }}>
                                {project.tasks_count || 0} Registered Tasks
                            </Typography>
                        </Box>
                    </Box>
                    
                    <Typography 
                        variant="body2" 
                        sx={{ 
                            color: theme.palette.text.primary, 
                            lineHeight: 1.6,
                            display: '-webkit-box',
                            WebkitLineClamp: 4,
                            WebkitBoxOrient: 'vertical',
                            overflow: 'hidden'
                        }}
                    >
                        {project.description || 'No description.'}
                    </Typography>
                </CardContent>
                
                <CardActions sx={{ p: 2, flexDirection: 'column', gap: 1 }}>
                    <Button
                        onClick={() => router.visit(route('tasks.create', project.id))}
                        variant="contained"
                        fullWidth
                        startIcon={<Edit />}
                        sx={actionButtonStyle}
                    >
                        Add Task
                    </Button>
                    <Button
                        onClick={() => router.visit(route('projects.edit', project.id))}
                        variant="contained"
                        fullWidth
                        startIcon={<Edit />}
                        sx={actionButtonStyle}
                    >
                        Edit
                    </Button>
                    <Button
                        onClick={handleOpenDialog}
                        fullWidth
                        startIcon={<DoneAll />}
                        sx={actionButtonStyle}
                    >
                        Complete
                    </Button>
                </CardActions>
            </Card>

            {/* MUI ALERT DIALOG */}
            <Dialog
                open={openDeleteDialog}
                onClose={handleCloseDialog}
                PaperProps={{
                    sx: { 
                        bgcolor: theme.palette.primary.secondary,
                        color: theme.palette.text.primary,
                        borderRadius: 4, 
                        border: '2px solid #DA0037',
                        p: 1 
                    }
                }}
            >
                <DialogTitle sx={{ fontWeight: '900', textTransform: 'uppercase' }}>
                    Confirm Deletion
                </DialogTitle>
                <DialogContent>
                    <DialogContentText sx={{ color: theme.palette.text.primary,}}>
                        Are you sure you want to delete project <strong>{project.title}</strong>? 
                    </DialogContentText>
                </DialogContent>
                <MuiDialogActions sx={{ pb: 2, px: 3 }}>
                    <Button onClick={handleCloseDialog} sx={{ color: theme.palette.text.primary, fontWeight: 'bold' }}>
                        Cancel
                    </Button>
                    <Button 
                        onClick={confirmDelete} 
                        variant="contained" 
                        bgcolor="#DA0037" 
                        sx={{ 
                            bgcolor: '#DA0037', 
                            color: '#000', 
                            fontWeight: 'bold',
                            '&:hover': { bgcolor: '#ff1744' } 
                        }}
                    >
                        Confirm Delete
                    </Button>
                </MuiDialogActions>
            </Dialog>
        </>
    );
};

export default ProjectCard;