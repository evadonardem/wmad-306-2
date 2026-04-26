import {
    Card,
    CardContent,
    CardActions,
    Typography,
    Button,
    Box,
    Select,
    MenuItem,
    FormControl,
    InputLabel,
    IconButton,
    Chip,
    TextField,
} from '@mui/material';
import {
    Edit,
    Delete,
    Schedule,
    ToggleOn,
    ViewStream,
} from '@mui/icons-material';
import { router } from '@inertiajs/react';
import { useState } from 'react';
import { useThemeContext } from './ThemeProvider';
import StatusChip from './StatusChip';
import PriorityChip from './PriorityChip';

const TaskCard = ({ task, projects, onDelete, onUpdate, onToggleStatus }) => {
    const { theme } = useThemeContext();
    const [isEditing, setIsEditing] = useState(false);
    const [editData, setEditData] = useState({
        title: task.title,
        description: task.description || '',
        priority: task.priority,
        status: task.status,
        due_date: task.due_date || '',
    });

    const handleSave = () => {
        onUpdate(task.id, editData);
        setIsEditing(false);
    };

    const handleCancel = () => {
        setIsEditing(false);
    };

    const handleToggleStatus = () => {
        if (onToggleStatus) {
            onToggleStatus(task);
        }
    };

    return (
        <Card
            sx={{
                mb: 2,
                borderRadius: 3,
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
                transition: 'all 0.2s ease-in-out',
                '&:hover': {
                    boxShadow: '0 4px 16px rgba(0,0,0,0.15)',
                }
            }}
        >
            <CardContent sx={{ p: 3 }}>
                {isEditing ? (
                    <Box>
                        <Typography variant="body2" sx={{ mb: 2, fontWeight: 'medium', color: theme.palette.text.primary }}>
                            Edit Task
                        </Typography>
                        <Box sx={{ display: 'flex', gap: 2, mb: 2, alignItems: 'center', flexWrap: 'wrap' }}>
                            <Box sx={{ flexGrow: 1, minWidth: 200 }}>
                                <TextField
                                    label="Task Title"
                                    value={editData.title}
                                    onChange={(e) => setEditData({ ...editData, title: e.target.value })}
                                    size="small"
                                    fullWidth
                                />
                            </Box>
                            <FormControl size="small" sx={{ minWidth: 120 }}>
                                <InputLabel>Priority</InputLabel>
                                <Select
                                    value={editData.priority}
                                    label="Priority"
                                    onChange={(e) => setEditData({ ...editData, priority: e.target.value })}
                                >
                                    <MenuItem value="less important">Less Important</MenuItem>
                                    <MenuItem value="important">Important</MenuItem>
                                    <MenuItem value="very important">Very Important</MenuItem>
                                </Select>
                            </FormControl>
                            <FormControl size="small" sx={{ minWidth: 120 }}>
                                <InputLabel>Status</InputLabel>
                                <Select
                                    value={editData.status}
                                    label="Status"
                                    onChange={(e) => setEditData({ ...editData, status: e.target.value })}
                                >
                                    <MenuItem value="pending">Pending</MenuItem>
                                    <MenuItem value="on going">On Going</MenuItem>
                                    <MenuItem value="completed">Completed</MenuItem>
                                </Select>
                            </FormControl>
                            <TextField
                                label="Due Date"
                                type="date"
                                value={editData.due_date}
                                onChange={(e) => setEditData({ ...editData, due_date: e.target.value })}
                                InputLabelProps={{ shrink: true }}
                                size="small"
                                sx={{ minWidth: 150 }}
                            />
                        </Box>
                        <TextField
                            label="Description"
                            value={editData.description}
                            onChange={(e) => setEditData({ ...editData, description: e.target.value })}
                            multiline
                            rows={2}
                            fullWidth
                            sx={{ mb: 2 }}
                        />
                        <Box sx={{ display: 'flex', gap: 1 }}>
                            {/* Removed duplicate Save/Cancel buttons from CardContent */}
                            {/* Buttons are now only in CardActions section */}
                        </Box>
                    </Box>
                ) : (
                    <Box>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                            <Typography 
                                variant="h6" 
                                sx={{ 
                                    fontWeight: 'bold',
                                    color: theme.palette.text.primary,
                                    flexGrow: 1
                                }}
                            >
                                {task.title}
                            </Typography>
                            <Box sx={{ display: 'flex', gap: 1, ml: 2 }}>
                                <PriorityChip priority={task.priority} />
                            </Box>
                        </Box>
                        
                        {task.description && (
                            <Typography 
                                variant="body2" 
                                color={theme.palette.text.secondary} 
                                sx={{ mb: 4, lineHeight: 1.5 }}
                            >
                                {task.description}
                            </Typography>
                        )}
                        
                        <Box sx={{ display: 'flex', gap: 1, alignItems: 'center', flexWrap: 'wrap', mb: 2}}>
                            <Chip
                                icon={<ViewStream />}
                                label={`: ${task.project?.title} `}
                                size="small"
                                variant="outlined"
                                sx={{ fontSize: '12px' }}
                            />
                        </Box>
                        <Box sx={{ display: 'flex', gap: 1, alignItems: 'center', flexWrap: 'wrap' }}>
                            {task.due_date && (
                                <Chip
                                    icon={<Schedule />}
                                    label={`Due: ${new Date(task.due_date).toLocaleDateString()}`}
                                    size="small"
                                    color="secondary"
                                    variant="outlined"
                                    sx={{ fontSize: '12px' }}
                                />
                            )}
                        </Box>
                    </Box>
                )}
            </CardContent>
            
            <CardActions sx={{ px: 3, pb: 2 }}>
                {isEditing ? (
                    <Box sx={{ display: 'flex', gap: 1 }}>
                        <Button
                            size="small"
                            variant="contained"
                            onClick={handleSave}
                            sx={{ borderRadius: 2, textTransform: 'none' }}
                        >
                            Save
                        </Button>
                        <Button
                            size="small"
                            variant="outlined"
                            onClick={handleCancel}
                            sx={{ borderRadius: 2, textTransform: 'none' }}
                        >
                            Cancel
                        </Button>
                    </Box>
                ) : (
                    <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                        <IconButton
                            size="small"
                            onClick={() => setIsEditing(true)}
                            title="Edit"
                        >
                            <Edit />
                        </IconButton>
                        
                        
                        <IconButton
                            size="small"
                            onClick={() => onDelete(task.id)}
                            title="Delete"
                            color="error"
                        >
                            <Delete />
                        </IconButton>
                    </Box>
                )}
            </CardActions>
        </Card>
    );
};

export default TaskCard;
