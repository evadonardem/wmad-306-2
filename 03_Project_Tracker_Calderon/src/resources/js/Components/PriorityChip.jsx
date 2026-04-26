import { Chip } from '@mui/material';

const PriorityChip = ({ priority }) => {
    const getPriorityColor = (priority) => {
        switch (priority) {
            case 'very important':
                return 'error';
            case 'important':
                return 'warning';
            case 'less important':
                return 'success';
            default:
                return 'default';
        }
    };

    const getPriorityLabel = (priority) => {
        switch (priority) {
            case 'very important':
                return 'Very Important';
            case 'important':
                return 'Important';
            case 'less important':
                return 'Less Important';
            default:
                return priority;
        }
    };

    return (
        <Chip
            label={getPriorityLabel(priority)}
            color={getPriorityColor(priority)}
            size="small"
            variant="outlined"
            sx={{ fontWeight: 500 }}
        />
    );
};

export default PriorityChip;
